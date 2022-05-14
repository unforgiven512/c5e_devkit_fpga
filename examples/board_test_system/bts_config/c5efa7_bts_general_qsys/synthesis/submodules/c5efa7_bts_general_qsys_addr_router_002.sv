// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/12.1sp1/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2012/10/10 $
// $Author: swbranch $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module c5efa7_bts_general_qsys_addr_router_002_default_decode
  #(
     parameter DEFAULT_CHANNEL = 2,
               DEFAULT_DESTID = 3 
   )
  (output [98 - 94 : 0] default_destination_id,
   output [17-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[98 - 94 : 0];
  generate begin : default_decode
    if (DEFAULT_CHANNEL == -1)
      assign default_src_channel = '0;
    else
      assign default_src_channel = 17'b1 << DEFAULT_CHANNEL;
  end
  endgenerate

endmodule


module c5efa7_bts_general_qsys_addr_router_002
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [109-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [109-1    : 0] src_data,
    output reg [17-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 98;
    localparam PKT_DEST_ID_L = 94;
    localparam ST_DATA_W = 109;
    localparam ST_CHANNEL_W = 17;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;




    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h10 - 64'h0);
    localparam PAD1 = log2ceil(64'h20 - 64'h10);
    localparam PAD2 = log2ceil(64'h30 - 64'h20);
    localparam PAD3 = log2ceil(64'h40 - 64'h38);
    localparam PAD4 = log2ceil(64'h50 - 64'h40);
    localparam PAD5 = log2ceil(64'h60 - 64'h50);
    localparam PAD6 = log2ceil(64'h800 - 64'h400);
    localparam PAD7 = log2ceil(64'h100000 - 64'h80000);
    localparam PAD8 = log2ceil(64'h180000 - 64'h100000);
    localparam PAD9 = log2ceil(64'h600200 - 64'h600000);
    localparam PAD10 = log2ceil(64'ha00000 - 64'h800000);
    localparam PAD11 = log2ceil(64'hc000000 - 64'h8000000);
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'hc000000;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;
    localparam RG = RANGE_ADDR_WIDTH-1;

      wire [PKT_ADDR_W-1 : 0] address = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;

    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [17-1 : 0] default_src_channel;




    c5efa7_bts_general_qsys_addr_router_002_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_src_channel (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;

        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;
        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

        // ( 0x0 .. 0x10 )
        if ( {address[RG:PAD0],{PAD0{1'b0}}} == 28'h0 ) begin
            src_channel = 17'b000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 12;
        end

        // ( 0x10 .. 0x20 )
        if ( {address[RG:PAD1],{PAD1{1'b0}}} == 28'h10 ) begin
            src_channel = 17'b000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
        end

        // ( 0x20 .. 0x30 )
        if ( {address[RG:PAD2],{PAD2{1'b0}}} == 28'h20 ) begin
            src_channel = 17'b010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 15;
        end

        // ( 0x38 .. 0x40 )
        if ( {address[RG:PAD3],{PAD3{1'b0}}} == 28'h38 ) begin
            src_channel = 17'b001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 13;
        end

        // ( 0x40 .. 0x50 )
        if ( {address[RG:PAD4],{PAD4{1'b0}}} == 28'h40 ) begin
            src_channel = 17'b000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
        end

        // ( 0x50 .. 0x60 )
        if ( {address[RG:PAD5],{PAD5{1'b0}}} == 28'h50 ) begin
            src_channel = 17'b100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 16;
        end

        // ( 0x400 .. 0x800 )
        if ( {address[RG:PAD6],{PAD6{1'b0}}} == 28'h400 ) begin
            src_channel = 17'b000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
        end

        // ( 0x80000 .. 0x100000 )
        if ( {address[RG:PAD7],{PAD7{1'b0}}} == 28'h80000 ) begin
            src_channel = 17'b000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
        end

        // ( 0x100000 .. 0x180000 )
        if ( {address[RG:PAD8],{PAD8{1'b0}}} == 28'h100000 ) begin
            src_channel = 17'b000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
        end

        // ( 0x600000 .. 0x600200 )
        if ( {address[RG:PAD9],{PAD9{1'b0}}} == 28'h600000 ) begin
            src_channel = 17'b000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
        end

        // ( 0x800000 .. 0xa00000 )
        if ( {address[RG:PAD10],{PAD10{1'b0}}} == 28'h800000 ) begin
            src_channel = 17'b000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
        end

        // ( 0x8000000 .. 0xc000000 )
        if ( {address[RG:PAD11],{PAD11{1'b0}}} == 28'h8000000 ) begin
            src_channel = 17'b000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
        end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


