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



  
`timescale 1 ns / 1 ns

			 
module c5efa7_bts_general_qsys_tristate_conduit_pin_sharer_pin_sharer (
 // ** Clock and Reset Connections
    input  logic clk
   ,input  logic reset

 // ** Arbiter Connections

 // *** Arbiter Grant Interface
   ,output logic ack
   ,input  logic [ 3 - 1 : 0 ] next_grant

// *** Arbiter Request Interface

    ,output logic arb_ext_flash_tcm 
    ,output logic arb_max5_inf_tcm 
    ,output logic arb_ssram_tcm 
		
		     // ** Avalon TC Slave Interfaces




  // Slave Interface tcs2

    ,input  logic tcs2_request 
    ,output logic tcs2_grant   

  //ext_flash.tcm signals
    ,input  logic[ 25 :0 ] tcs2_tcm_address_out
    ,input  logic[ 0 :0 ] tcs2_tcm_read_n_out
    ,input  logic[ 0 :0 ] tcs2_tcm_write_n_out
    ,output logic[ 15 :0 ]  tcs2_tcm_data_in
    ,input  logic[ 15 :0 ]  tcs2_tcm_data_out
    ,input  logic tcs2_tcm_data_outen
    ,input  logic[ 0 :0 ] tcs2_tcm_chipselect_n_out



  // Slave Interface tcs1

    ,input  logic tcs1_request 
    ,output logic tcs1_grant   

  //max5_inf.tcm signals
    ,input  logic[ 8 :0 ] tcs1_tcm_address_out
    ,input  logic[ 0 :0 ] tcs1_tcm_read_n_out
    ,input  logic[ 0 :0 ] tcs1_tcm_write_n_out
    ,input  logic[ 0 :0 ] tcs1_tcm_reset_out
    ,output logic[ 15 :0 ]  tcs1_tcm_data_in
    ,input  logic[ 15 :0 ]  tcs1_tcm_data_out
    ,input  logic tcs1_tcm_data_outen
    ,input  logic[ 0 :0 ] tcs1_tcm_chipselect_n_out



  // Slave Interface tcs0

    ,input  logic tcs0_request 
    ,output logic tcs0_grant   

  //ssram.tcm signals
    ,input  logic[ 20 :0 ] tcs0_tcm_address_out
    ,input  logic[ 0 :0 ] tcs0_tcm_outputenable_n_out
    ,input  logic[ 1 :0 ] tcs0_tcm_byteenable_n_out
    ,input  logic[ 0 :0 ] tcs0_tcm_write_n_out
    ,output logic[ 15 :0 ]  tcs0_tcm_data_in
    ,input  logic[ 15 :0 ]  tcs0_tcm_data_out
    ,input  logic tcs0_tcm_data_outen
    ,input  logic[ 0 :0 ] tcs0_tcm_chipselect_n_out
		     
		     // ** Avalon TC Master Interface
    ,output logic request
    ,input  logic grant

		     // *** Passthrough Signals
		     
    ,output  logic[ 0 :0 ] ext_flash_tcm_read_n_out
    ,output  logic[ 0 :0 ] ext_flash_tcm_write_n_out
    ,output  logic[ 0 :0 ] ext_flash_tcm_chipselect_n_out
    ,output  logic[ 0 :0 ] max5_inf_tcm_read_n_out
    ,output  logic[ 0 :0 ] max5_inf_tcm_write_n_out
    ,output  logic[ 0 :0 ] max5_inf_tcm_reset_out
    ,output  logic[ 0 :0 ] max5_inf_tcm_chipselect_n_out
    ,output  logic[ 0 :0 ] ssram_tcm_outputenable_n_out
    ,output  logic[ 1 :0 ] ssram_tcm_byteenable_n_out
    ,output  logic[ 0 :0 ] ssram_tcm_write_n_out
    ,output  logic[ 0 :0 ] ssram_tcm_chipselect_n_out
		     
                     // *** Shared Signals
		      	     
    ,output  logic[ 25 :0 ] fsm_add
    ,input   logic[ 15  :0 ]  fsm_data_in
    ,output  logic[ 15  :0 ]  fsm_data
    ,output  logic fsm_data_outen

		     );

   function [3-1:0] getIndex;
      
      input [3-1:0] select;
      
      getIndex = 'h0;
      
      for(int i=0; i < 3; i = i + 1) begin
	 if( select[i] == 1'b1 )
           getIndex = i;
      end
      
   endfunction // getIndex

   logic[ 3 - 1 : 0 ] selected_grant;


   // Request Assignments

    assign arb_ext_flash_tcm = tcs2_request;
    assign arb_max5_inf_tcm = tcs1_request;
    assign arb_ssram_tcm = tcs0_request;
   
   logic [ 3 - 1 : 0 ] concated_incoming_requests;
   
   
   assign 			      concated_incoming_requests = {						    
         tcs2_request 
        ,tcs1_request 
        ,tcs0_request 
				};
   
				       
   assign 			      request = | concated_incoming_requests;
  assign        tcs0_grant = selected_grant[0];
  assign        tcs1_grant = selected_grant[1];
  assign        tcs2_grant = selected_grant[2];

   
    // Perform Grant Selection						  
   always@(posedge clk, posedge reset) begin
     if(reset) begin
	selected_grant<=0;
	ack <= 0;
     end 
     else begin
       if(grant && (concated_incoming_requests[getIndex(selected_grant)] == 0 || selected_grant == 0 )) begin
	  if(~request)
	    selected_grant <= '0;
	  else
	    selected_grant <= next_grant;
	  
          ack<=1;
       end
       else begin
         ack<=0;
         selected_grant <= selected_grant;
       end
     end
   end // always@ (posedge clk, posedge reset)

// Passthrough Signals

    assign ext_flash_tcm_read_n_out = tcs2_tcm_read_n_out;
    assign ext_flash_tcm_write_n_out = tcs2_tcm_write_n_out;
    assign ext_flash_tcm_chipselect_n_out = tcs2_tcm_chipselect_n_out;
    assign max5_inf_tcm_read_n_out = tcs1_tcm_read_n_out;
    assign max5_inf_tcm_write_n_out = tcs1_tcm_write_n_out;
    assign max5_inf_tcm_reset_out = tcs1_tcm_reset_out;
    assign max5_inf_tcm_chipselect_n_out = tcs1_tcm_chipselect_n_out;
    assign ssram_tcm_outputenable_n_out = tcs0_tcm_outputenable_n_out;
    assign ssram_tcm_byteenable_n_out = tcs0_tcm_byteenable_n_out;
    assign ssram_tcm_write_n_out = tcs0_tcm_write_n_out;
    assign ssram_tcm_chipselect_n_out = tcs0_tcm_chipselect_n_out;
  
// Renamed Signals
  
// Shared Signals
  c5efa7_bts_general_qsys_tristate_conduit_pin_sharer_pin_sharer_multiplexor_3 #(.WIDTH(26) )
    fsm_add_mux (
                              {
                                tcs2_grant
                               ,tcs1_grant
                               ,tcs0_grant
                              }
                              ,tcs2_tcm_address_out
                              ,{17'h0,tcs1_tcm_address_out}
                              ,{5'h0,tcs0_tcm_address_out}
                              , fsm_add
                             );
  assign tcs0_tcm_data_in = fsm_data_in[15:0]; 
  assign tcs2_tcm_data_in = fsm_data_in[15:0]; 
  assign tcs1_tcm_data_in = fsm_data_in[15:0]; 
  c5efa7_bts_general_qsys_tristate_conduit_pin_sharer_pin_sharer_multiplexor_3 #(.WIDTH(1) )
    fsm_data_outen_mux (
                              {
                                tcs2_grant
                               ,tcs1_grant
                               ,tcs0_grant
                              }
                              ,tcs2_tcm_data_outen
                              ,tcs1_tcm_data_outen
                              ,tcs0_tcm_data_outen
                              , fsm_data_outen
                             );
  c5efa7_bts_general_qsys_tristate_conduit_pin_sharer_pin_sharer_multiplexor_3 #(.WIDTH(16) )
    fsm_data_mux (
                              {
                                tcs2_grant
                               ,tcs1_grant
                               ,tcs0_grant
                              }
                              ,tcs2_tcm_data_out
                              ,tcs1_tcm_data_out
                              ,tcs0_tcm_data_out
                              , fsm_data
                             );
  
endmodule   
					    

  
module c5efa7_bts_general_qsys_tristate_conduit_pin_sharer_pin_sharer_multiplexor_3
  #( parameter WIDTH      = 8
    ) (
    input logic  [ 3 -1 : 0]                       SelectVector,
    input logic  [ WIDTH - 1 : 0 ]                Input_2,
    input logic  [ WIDTH - 1 : 0 ]                Input_1,
    input logic  [ WIDTH - 1 : 0 ]                Input_0,
    output logic [ WIDTH - 1 : 0 ]                OutputSignal
       );


function [3-1:0] getIndex;
      
    input [3-1:0] select;
   
    getIndex = 'h0;
    
    for(int i=0; i < 3; i = i + 1) begin
      if( select[i] == 1'b1 )
        getIndex = i;
    end
			      				
endfunction
								 
   always @* begin
     case(getIndex(SelectVector))
       default: OutputSignal = Input_0;
       0 : OutputSignal = Input_0;									   
       1 : OutputSignal = Input_1;									   
       2 : OutputSignal = Input_2;									   
     endcase
   end
   
endmodule



