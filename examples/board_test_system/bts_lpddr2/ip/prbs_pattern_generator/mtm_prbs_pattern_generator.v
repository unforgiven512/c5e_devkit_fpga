/*
  Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
  use of Altera Corporation's design tools, logic functions and other
  software and tools, and its AMPP partner logic functions, and any
  output files any of the foregoing (including device programming or
  simulation files), and any associated documentation or information are
  expressly subject to the terms and conditions of the Altera Program
  License Subscription Agreement or other applicable license agreement,
  including, without limitation, that your use is for the sole purpose
  of programming logic devices manufactured by Altera and sold by Altera
  or its authorized distributors.  Please refer to the applicable
  agreement for further details.
*/


/*

PRBS generator core


Description:  This component is generates various PRBS patterns based on the data width chosen or a custom polynomial of your choosing.  When the host
              writes to the start bit of the CSR slave port the component will begin to send the contents from the PRBS pipeline to the data streaming
              port.  You should use the prbs checker component with this component.
              
              The following polynomials are used by default, you may overwrite them by writing the PRBS Polynomial at run time.  The following polynomials
              are used:
              
              Data width = 16 bits  --> PRBS-16 (taps [16, 14, 13, 11])
              Data width = 32 bits  --> PRBS-32 (taps [32, 30, 26, 25])
              Data width = 64 bits  --> PRBS-64 (taps [64, 63, 61, 60])
              Data width = 128 bits --> PRBS-128 (taps [128, 127, 126, 121])
              
              The PRBS polynomials do not include the implied '1' so if you provide your own custom polynomial do not program the implied '1'.  For example
              the PRBS-128 polynomial of x^128 + x^127 + x^126 + x^121 + 1 programs bits 127, 126, 125, and 120 high and the rest are low.  The generator
              is seeded a hardcoded value based on the data width.

Register map:

|-------------------------------------------------------------------------------------------------------------------------------------------------------|
|  Address   |   Access Type   |                                                            Bits                                                        |
|            |                 |------------------------------------------------------------------------------------------------------------------------|
|            |                 |            31..24            |            23..16            |            15..8            |            7..0            |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|
|     0      |       r/w       |                                                       Payload Length                                                   |
|     4      |       N/A       |                                                            N/A                                                         |
|     8      |       r/w       |                           Run                 Seed Generator                                   Infinite Payload Length |
|     12     |       N/A       |                                                            N/A                                                         |
|     16     |       r/w       |                                                   PRBS Polynomial [31..0]                                              |
|     20     |       r/w       |                                                   PRBS Polynomial [63..32]                                             |
|     24     |       r/w       |                                                   PRBS Polynomial [95..64]                                             |
|     28     |       r/w       |                                                   PRBS Polynomial [127..96]                                            |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|


Address 0  --> Bits 31:0 are used store the payload length as well as read it back while the checker core is operating.  This field should only be written to while
               the checker is stopped.
Address 4  --> <reserved>
Address 8  --> Bit 0 is used tell the checker to ignore the payload length field and generate the pattern until stopped.  The seed generator should be set any time you
               want to start the generator from its original position.  The run field must be accessed at the same time as the other bits or later.
Address 12 --> <reserved>
Address 16 --> PRBS polynomial bits 31-0 (does not include the implied '1' in the polynomial)
Address 20 --> PRBS polynomial bits 63-32
Address 24 --> PRBS polynomial bits 95-64
Address 28 --> PRBS polynomial bits 127-96


Author: JCJB

Initial release 1.0: 04/21/2010

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10230


module mtm_prbs_pattern_generator (
  clk,
  reset,

  csr_address,
  csr_writedata,
  csr_write,
  csr_readdata,
  csr_read,
  csr_byteenable,

  src_data,
  src_valid,
  src_ready
);


  parameter DATA_WIDTH = 32;          // must be 8, 16, 32, 64, 128, 256, 512, 1024
  parameter PRBS_WIDTH = 16;          // must be 8, 16, 32, 64, or 128


  localparam NUM_OF_SYMBOLS = DATA_WIDTH / 8;
//  localparam POLYNOMIAL_RESET_VALUE = (PRBS_WIDTH == 16)? 16'hB400 :                                                    // taps [16, 14, 13, 11]
//                                      (PRBS_WIDTH == 32)? 32'hA300_0000 :                                                // taps [32, 30, 26, 25]
//                                      (PRBS_WIDTH == 64)? 64'hD800_0000_0000_0000 : 128'hE100_0000_0000_0000_0000_0000_0000_0000; // taps [64, 63, 61, 60] : taps [128, 127, 126, 121]
//  localparam SEED_VALUE = (PRBS_WIDTH == 16)? 16'hFACE:
//                          (PRBS_WIDTH == 32)? 32'hDEAD_BEEF:
//                          (PRBS_WIDTH == 64)? 64'hFEED_ABBA_BABE_BEEF : 128'hCA11_DEAF_ABBA_BABE_B01D_5CA1_AB1E_FACE;
  localparam POLYNOMIAL_RESET_VALUE = (PRBS_WIDTH == 8)? 8'hB8 :                                                    // taps [8, 6, 5, 4]
												  (PRBS_WIDTH == 16)? 16'hB400 :                                                    // taps [16, 14, 13, 11]
                                      (PRBS_WIDTH == 32)? 32'hA300_0000 :                                                // taps [32, 30, 26, 25]
                                      (PRBS_WIDTH == 64)? 64'hD800_0000_0000_0000 : 128'hE100_0000_0000_0000_0000_0000_0000_0000; // taps [64, 63, 61, 60] : taps [128, 127, 126, 121]
  localparam SEED_VALUE = (PRBS_WIDTH == 8)? 8'h5A:
								  (PRBS_WIDTH == 16)? 16'hFACE:
                          (PRBS_WIDTH == 32)? 32'hDEAD_BEEF:
                          (PRBS_WIDTH == 64)? 64'hFEED_ABBA_BABE_BEEF : 128'hCA11_DEAF_ABBA_BABE_B01D_5CA1_AB1E_FACE;

  input clk;
  input reset;

  input [2:0] csr_address;
  input [31:0] csr_writedata;
  input csr_write;
  output wire [31:0] csr_readdata;
  input csr_read;
  input [3:0] csr_byteenable;

  output wire [DATA_WIDTH-1:0] src_data;
  output wire src_valid;
  input src_ready;

  // interal registers and wires
  reg [31:0] payload_length_counter;
  wire load_payload_length_counter;
  wire [3:0] load_payload_length_counter_lanes;
  reg infinite_payload_length;
  wire load_infinite_payload_length;
  reg seed_generator;
  wire load_seed_generator;
  wire clear_seed_generator;
  reg start;
  wire load_start;
  wire clear_start;
  reg [127:0] polynomial;
  wire load_polynomial;
  wire [15:0] load_polynomial_lanes;
  reg [PRBS_WIDTH-1:0] pipeline;
  reg [PRBS_WIDTH-1:0] pipeline_d1;
  wire [PRBS_WIDTH-1:0] pipeline_d2;
  wire [PRBS_WIDTH-1:0] pipeline_input;
  wire pipeline_enable;
  reg pipeline_enable_d1;
  reg [31:0] readback_mux;
  reg [31:0] readback_mux_d1;
  wire decrement_payload_length_counter;

  reg pipeline_enable_d1_1, pipeline_enable_d1_2;
  reg ins_error;


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      start <= 0;
    end
    else
    begin
      if (clear_start == 1)
      begin
        start <= 0;
      end
      else if (load_start == 1)
      begin
        start <= csr_writedata[24];
      end
    end
  end

always @ (posedge clk or posedge reset)
begin
  if (reset == 1)
  begin
    ins_error <= 0;
  end
  else
  begin
    if (clear_start == 1)
    begin
      ins_error <= 0;
    end
    else if (load_start == 1)
    begin
      ins_error <= csr_writedata[25];
    end
  end
end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      seed_generator <= 0;
    end
    else
    begin
      if (clear_seed_generator == 1)
      begin
        seed_generator <= 0;
      end
      else if (load_seed_generator == 1)
      begin
        seed_generator <= csr_writedata[16];
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      payload_length_counter <= 0;
    end
    else 
    begin
      if (load_payload_length_counter == 1)
      begin
        if (load_payload_length_counter_lanes[0] == 1)
        begin
          payload_length_counter[7:0] <= csr_writedata[7:0];
        end
        if (load_payload_length_counter_lanes[1] == 1)
        begin
          payload_length_counter[15:8] <= csr_writedata[15:8];
        end
        if (load_payload_length_counter_lanes[2] == 1)
        begin
          payload_length_counter[23:16] <= csr_writedata[23:16];
        end
        if (load_payload_length_counter_lanes[3] == 1)
        begin
          payload_length_counter[31:24] <= csr_writedata[31:24];
        end
      end
      else if (decrement_payload_length_counter == 1)
      begin
        payload_length_counter <= payload_length_counter - NUM_OF_SYMBOLS;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      infinite_payload_length <= 0;
    end
    else if (load_infinite_payload_length == 1)
    begin
      infinite_payload_length <= csr_writedata[0];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      polynomial <= POLYNOMIAL_RESET_VALUE;
    end
    else if (load_polynomial == 1)
    begin
      if (load_polynomial_lanes[0] == 1)
      begin
        polynomial[7:0] <= csr_writedata[7:0];
      end
      if (load_polynomial_lanes[1] == 1)
      begin
        polynomial[15:8] <= csr_writedata[15:8];
      end
      if (load_polynomial_lanes[2] == 1)
      begin
        polynomial[23:16] <= csr_writedata[23:16];
      end
      if (load_polynomial_lanes[3] == 1)
      begin
        polynomial[31:24] <= csr_writedata[31:24];
      end

      if (load_polynomial_lanes[4] == 1)
      begin
        polynomial[39:32] <= csr_writedata[7:0];
      end
      if (load_polynomial_lanes[5] == 1)
      begin
        polynomial[47:40] <= csr_writedata[15:8];
      end
      if (load_polynomial_lanes[6] == 1)
      begin
        polynomial[55:48] <= csr_writedata[23:16];
      end
      if (load_polynomial_lanes[7] == 1)
      begin
        polynomial[63:56] <= csr_writedata[31:24];
      end

      if (load_polynomial_lanes[8] == 1)
      begin
        polynomial[71:64] <= csr_writedata[7:0];
      end
      if (load_polynomial_lanes[9] == 1)
      begin
        polynomial[79:72] <= csr_writedata[15:8];
      end
      if (load_polynomial_lanes[10] == 1)
      begin
        polynomial[87:80] <= csr_writedata[23:16];
      end
      if (load_polynomial_lanes[11] == 1)
      begin
        polynomial[95:88] <= csr_writedata[31:24];
      end

      if (load_polynomial_lanes[12] == 1)
      begin
        polynomial[103:96] <= csr_writedata[7:0];
      end
      if (load_polynomial_lanes[13] == 1)
      begin
        polynomial[111:104] <= csr_writedata[15:8];
      end
      if (load_polynomial_lanes[14] == 1)
      begin
        polynomial[119:112] <= csr_writedata[23:16];
      end
      if (load_polynomial_lanes[15] == 1)
      begin
        polynomial[127:120] <= csr_writedata[31:24];
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      pipeline <= SEED_VALUE;
    end
    else
    begin
      if (seed_generator == 1)
      begin
        pipeline <= SEED_VALUE;
      end
      else if (pipeline_enable == 1)
      begin
        pipeline <= pipeline_input;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      pipeline_d1 <= 0;
    end
    else if (pipeline_enable == 1)
    begin
      
      if(pipeline_enable_d1_1 == 1 & pipeline_enable_d1_2 == 1 & ins_error == 1)begin
        pipeline_d1 <= !pipeline; // insert error at here
      end else begin
        pipeline_d1 <= pipeline;
      end
      
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      pipeline_enable_d1 <= 0;
    end
    else
    begin
      pipeline_enable_d1 <= pipeline_enable;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      readback_mux_d1 <= 0;
    end
    else if (csr_read == 1)
    begin
      readback_mux_d1 <= readback_mux;
    end
  end



  always @ (csr_address or payload_length_counter or polynomial or infinite_payload_length or start or seed_generator)
  begin
    case (csr_address)
      3'b000: readback_mux = payload_length_counter;
      3'b001: readback_mux = {32{1'b0}};
      3'b010: readback_mux = {{7{1'b0}}, start, {7{1'b0}}, seed_generator, {15{1'b0}}, infinite_payload_length};
      3'b011: readback_mux = {32{1'b0}};
      3'b100: readback_mux = polynomial[31:0];
      3'b101: readback_mux = polynomial[63:32];
      3'b110: readback_mux = polynomial[95:64];
      3'b111: readback_mux = polynomial[127:96];
    endcase
  end


// LSFR input data for all the pipeline stages
genvar d;
generate
  for (d = 0; d < (PRBS_WIDTH-1); d = d + 1)  // highest order pipeline input will be generated independent of this loop 
  begin: pipeline_taps
    assign pipeline_input[d] = pipeline[d+1] ^ (pipeline[0] & polynomial[d]);
  end
endgenerate
  assign pipeline_input[PRBS_WIDTH-1] = pipeline[0];


//genvar i;
//generate
//  for (i = 0; i < NUM_OF_SYMBOLS; i = i + 1)
//  begin : byte_reversal
//    assign src_data[((8*(i+1))-1):(8*i)] = pipeline_d1[((8*((NUM_OF_SYMBOLS-1-i)+1))-1):(8*(NUM_OF_SYMBOLS-1-i))];
//    assign pipeline_d2[((8*(i+1))-1):(8*i)] = pipeline_d1[((8*((NUM_OF_SYMBOLS-1-i)+1))-1):(8*(NUM_OF_SYMBOLS-1-i))];
    assign pipeline_d2 = pipeline_d1;
//  end
//endgenerate

  assign src_data = {(DATA_WIDTH/PRBS_WIDTH){pipeline_d2}};

  assign load_payload_length_counter = (csr_address == 0) & (csr_write == 1);
  assign load_payload_length_counter_lanes = csr_byteenable;

  assign load_infinite_payload_length = (csr_address == 2) & (csr_write == 1) & (csr_byteenable[0] == 1);
  assign load_start = (csr_address == 2) & (csr_write == 1) & (csr_byteenable[3] == 1);

  assign load_seed_generator = (csr_address == 2) & (csr_write == 1) & (csr_byteenable[2] == 1);
  assign clear_seed_generator = (load_start == 1) & (seed_generator == 1);

  assign load_polynomial = (csr_address[2] == 1) & (csr_write == 1);
  assign load_polynomial_lanes[3:0] = (csr_address[1:0] == 0)? csr_byteenable : 0;
  assign load_polynomial_lanes[7:4] = (csr_address[1:0] == 1)? csr_byteenable : 0;
  assign load_polynomial_lanes[11:8] = (csr_address[1:0] == 2)? csr_byteenable : 0;
  assign load_polynomial_lanes[15:12] = (csr_address[1:0] == 3)? csr_byteenable : 0;

  assign pipeline_enable = (start == 1) & (src_ready == 1);
  assign decrement_payload_length_counter = (start == 1) & (src_ready == 1) & (infinite_payload_length == 0);
  assign clear_start = (start == 1) & (infinite_payload_length == 0) & (payload_length_counter == NUM_OF_SYMBOLS) & (pipeline_enable == 1);
  assign src_valid = (pipeline_enable_d1 == 1);

  assign csr_readdata = readback_mux_d1;




  // those signals are used to generate word error
  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      pipeline_enable_d1_1 <= 0;
      pipeline_enable_d1_2 <= 1;
    end
    else  begin
      pipeline_enable_d1_1 <= start;
      pipeline_enable_d1_2 <= !pipeline_enable_d1_1;
    end
  end

endmodule

