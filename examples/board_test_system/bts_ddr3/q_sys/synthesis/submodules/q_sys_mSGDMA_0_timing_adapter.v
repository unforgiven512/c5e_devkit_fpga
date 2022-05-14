// --------------------------------------------------------------------------------
//| Avalon Streaming Timing Adapter
// --------------------------------------------------------------------------------
// altera message_level level1

`timescale 1ns / 100ps
module q_sys_mSGDMA_0_timing_adapter (
    
      // Interface: clk
      input              clk,
      // Interface: reset
      input              reset_n,
      // Interface: in
      output reg         in_ready,
      input              in_valid,
      input      [127: 0] in_data,
      // Interface: out
      input              out_ready,
      output reg         out_valid,
      output reg [127: 0] out_data
);




   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------

   reg  [127: 0] in_payload;
   wire [127: 0] out_payload;
   wire         in_ready_wire;
   wire         out_valid_wire;
   wire [ 3: 0] fifo_fill;
   reg  [ 0: 0] ready;


   // ---------------------------------------------------------------------
   //| Payload Mapping
   // ---------------------------------------------------------------------
   always @* begin
     in_payload = {in_data};
     {out_data} = out_payload;
   end

   // ---------------------------------------------------------------------
   //| FIFO
   // ---------------------------------------------------------------------
   q_sys_mSGDMA_0_timing_adapter_fifo q_sys_mSGDMA_0_timing_adapter_fifo 
     ( 
       .clk        (clk),
       .reset_n    (reset_n),
       .in_ready   (),
       .in_valid   (in_valid),      
       .in_data    (in_payload),
       .out_ready  (ready[0]),
       .out_valid  (out_valid_wire),      
       .out_data   (out_payload),
       .fill_level (fifo_fill)
       );

   // ---------------------------------------------------------------------
   //| Ready & valid signals.
   // ---------------------------------------------------------------------
   always @* begin
      in_ready = (fifo_fill < 4 );
      out_valid = out_valid_wire;
      ready[0] = out_ready;
   end



endmodule

