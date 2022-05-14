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


// $Id: //acds/rel/12.1sp1/ip/merlin/altera_tristate_conduit_bridge/altera_tristate_conduit_bridge.sv.terp#1 $
// $Revision: #1 $
// $Date: 2012/10/10 $
// $Author: swbranch $

//Defined Terp Parameters


			    

`timescale 1 ns / 1 ns
  				      
module c5efa7_bts_general_qsys_tristate_conduit_bridge (
     input  logic clk
    ,input  logic reset
    ,input  logic request
    ,output logic grant
    ,input  logic[ 25 :0 ] tcs_fsm_add
    ,output  wire [ 25 :0 ] fsm_add
    ,input  logic[ 0 :0 ] tcs_ssram_tcm_outputenable_n_out
    ,output  wire [ 0 :0 ] ssram_tcm_outputenable_n_out
    ,input  logic[ 0 :0 ] tcs_ext_flash_tcm_read_n_out
    ,output  wire [ 0 :0 ] ext_flash_tcm_read_n_out
    ,input  logic[ 1 :0 ] tcs_ssram_tcm_byteenable_n_out
    ,output  wire [ 1 :0 ] ssram_tcm_byteenable_n_out
    ,input  logic[ 0 :0 ] tcs_ext_flash_tcm_write_n_out
    ,output  wire [ 0 :0 ] ext_flash_tcm_write_n_out
    ,input  logic[ 0 :0 ] tcs_ext_flash_tcm_chipselect_n_out
    ,output  wire [ 0 :0 ] ext_flash_tcm_chipselect_n_out
    ,input  logic[ 0 :0 ] tcs_ssram_tcm_chipselect_n_out
    ,output  wire [ 0 :0 ] ssram_tcm_chipselect_n_out
    ,output logic[ 15 :0 ] tcs_fsm_data_in
    ,input  logic[ 15 :0 ] tcs_fsm_data
    ,input  logic tcs_fsm_data_outen
    ,inout  wire [ 15 :0 ]  fsm_data
    ,input  logic[ 0 :0 ] tcs_max5_inf_tcm_chipselect_n_out
    ,output  wire [ 0 :0 ] max5_inf_tcm_chipselect_n_out
    ,input  logic[ 0 :0 ] tcs_max5_inf_tcm_reset_out
    ,output  wire [ 0 :0 ] max5_inf_tcm_reset_out
    ,input  logic[ 0 :0 ] tcs_max5_inf_tcm_write_n_out
    ,output  wire [ 0 :0 ] max5_inf_tcm_write_n_out
    ,input  logic[ 0 :0 ] tcs_max5_inf_tcm_read_n_out
    ,output  wire [ 0 :0 ] max5_inf_tcm_read_n_out
    ,input  logic[ 0 :0 ] tcs_ssram_tcm_write_n_out
    ,output  wire [ 0 :0 ] ssram_tcm_write_n_out
		     
   );
   reg grant_reg;
   assign grant = grant_reg;
   
   always@(posedge clk) begin
      if(reset)
	grant_reg <= 0;
      else
	grant_reg <= request;      
   end
   


 // ** Output Pin fsm_add 
 
    reg                       fsm_adden_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   fsm_adden_reg <= 'b0;
	 end
	 else begin
	   fsm_adden_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 25 : 0 ] fsm_add_reg;   

     always@(posedge clk) begin
	 fsm_add_reg   <= tcs_fsm_add[ 25 : 0 ];
      end
          
 
    assign 	fsm_add[ 25 : 0 ] = fsm_adden_reg ? fsm_add_reg : 'z ;
        


 // ** Output Pin ssram_tcm_outputenable_n_out 
 
    reg                       ssram_tcm_outputenable_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   ssram_tcm_outputenable_n_outen_reg <= 'b0;
	 end
	 else begin
	   ssram_tcm_outputenable_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] ssram_tcm_outputenable_n_out_reg;   

     always@(posedge clk) begin
	 ssram_tcm_outputenable_n_out_reg   <= tcs_ssram_tcm_outputenable_n_out[ 0 : 0 ];
      end
          
 
    assign 	ssram_tcm_outputenable_n_out[ 0 : 0 ] = ssram_tcm_outputenable_n_outen_reg ? ssram_tcm_outputenable_n_out_reg : 'z ;
        


 // ** Output Pin ext_flash_tcm_read_n_out 
 
    reg                       ext_flash_tcm_read_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   ext_flash_tcm_read_n_outen_reg <= 'b0;
	 end
	 else begin
	   ext_flash_tcm_read_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] ext_flash_tcm_read_n_out_reg;   

     always@(posedge clk) begin
	 ext_flash_tcm_read_n_out_reg   <= tcs_ext_flash_tcm_read_n_out[ 0 : 0 ];
      end
          
 
    assign 	ext_flash_tcm_read_n_out[ 0 : 0 ] = ext_flash_tcm_read_n_outen_reg ? ext_flash_tcm_read_n_out_reg : 'z ;
        


 // ** Output Pin ssram_tcm_byteenable_n_out 
 
    reg                       ssram_tcm_byteenable_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   ssram_tcm_byteenable_n_outen_reg <= 'b0;
	 end
	 else begin
	   ssram_tcm_byteenable_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 1 : 0 ] ssram_tcm_byteenable_n_out_reg;   

     always@(posedge clk) begin
	 ssram_tcm_byteenable_n_out_reg   <= tcs_ssram_tcm_byteenable_n_out[ 1 : 0 ];
      end
          
 
    assign 	ssram_tcm_byteenable_n_out[ 1 : 0 ] = ssram_tcm_byteenable_n_outen_reg ? ssram_tcm_byteenable_n_out_reg : 'z ;
        


 // ** Output Pin ext_flash_tcm_write_n_out 
 
    reg                       ext_flash_tcm_write_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   ext_flash_tcm_write_n_outen_reg <= 'b0;
	 end
	 else begin
	   ext_flash_tcm_write_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] ext_flash_tcm_write_n_out_reg;   

     always@(posedge clk) begin
	 ext_flash_tcm_write_n_out_reg   <= tcs_ext_flash_tcm_write_n_out[ 0 : 0 ];
      end
          
 
    assign 	ext_flash_tcm_write_n_out[ 0 : 0 ] = ext_flash_tcm_write_n_outen_reg ? ext_flash_tcm_write_n_out_reg : 'z ;
        


 // ** Output Pin ext_flash_tcm_chipselect_n_out 
 
    reg                       ext_flash_tcm_chipselect_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   ext_flash_tcm_chipselect_n_outen_reg <= 'b0;
	 end
	 else begin
	   ext_flash_tcm_chipselect_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] ext_flash_tcm_chipselect_n_out_reg;   

     always@(posedge clk) begin
	 ext_flash_tcm_chipselect_n_out_reg   <= tcs_ext_flash_tcm_chipselect_n_out[ 0 : 0 ];
      end
          
 
    assign 	ext_flash_tcm_chipselect_n_out[ 0 : 0 ] = ext_flash_tcm_chipselect_n_outen_reg ? ext_flash_tcm_chipselect_n_out_reg : 'z ;
        


 // ** Output Pin ssram_tcm_chipselect_n_out 
 
    reg                       ssram_tcm_chipselect_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   ssram_tcm_chipselect_n_outen_reg <= 'b0;
	 end
	 else begin
	   ssram_tcm_chipselect_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] ssram_tcm_chipselect_n_out_reg;   

     always@(posedge clk) begin
	 ssram_tcm_chipselect_n_out_reg   <= tcs_ssram_tcm_chipselect_n_out[ 0 : 0 ];
      end
          
 
    assign 	ssram_tcm_chipselect_n_out[ 0 : 0 ] = ssram_tcm_chipselect_n_outen_reg ? ssram_tcm_chipselect_n_out_reg : 'z ;
        


 // ** Bidirectional Pin fsm_data 
   
    reg                       fsm_data_outen_reg;
  
    always@(posedge clk) begin
	 fsm_data_outen_reg <= tcs_fsm_data_outen;
     end
  
  
    reg [ 15 : 0 ] fsm_data_reg;   

     always@(posedge clk) begin
	 fsm_data_reg   <= tcs_fsm_data[ 15 : 0 ];
      end
         
  
    assign 	fsm_data[ 15 : 0 ] = fsm_data_outen_reg ? fsm_data_reg : 'z ;
       
  
    reg [ 15 : 0 ] 	fsm_data_in_reg;
								    
    always@(posedge clk) begin
	 fsm_data_in_reg <= fsm_data[ 15 : 0 ];
    end
    
  
    assign      tcs_fsm_data_in[ 15 : 0 ] = fsm_data_in_reg[ 15 : 0 ];
        


 // ** Output Pin max5_inf_tcm_chipselect_n_out 
 
    reg                       max5_inf_tcm_chipselect_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   max5_inf_tcm_chipselect_n_outen_reg <= 'b0;
	 end
	 else begin
	   max5_inf_tcm_chipselect_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] max5_inf_tcm_chipselect_n_out_reg;   

     always@(posedge clk) begin
	 max5_inf_tcm_chipselect_n_out_reg   <= tcs_max5_inf_tcm_chipselect_n_out[ 0 : 0 ];
      end
          
 
    assign 	max5_inf_tcm_chipselect_n_out[ 0 : 0 ] = max5_inf_tcm_chipselect_n_outen_reg ? max5_inf_tcm_chipselect_n_out_reg : 'z ;
        


 // ** Output Pin max5_inf_tcm_reset_out 
 
    reg                       max5_inf_tcm_reset_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   max5_inf_tcm_reset_outen_reg <= 'b0;
	 end
	 else begin
	   max5_inf_tcm_reset_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] max5_inf_tcm_reset_out_reg;   

     always@(posedge clk) begin
	 max5_inf_tcm_reset_out_reg   <= tcs_max5_inf_tcm_reset_out[ 0 : 0 ];
      end
          
 
    assign 	max5_inf_tcm_reset_out[ 0 : 0 ] = max5_inf_tcm_reset_outen_reg ? max5_inf_tcm_reset_out_reg : 'z ;
        


 // ** Output Pin max5_inf_tcm_write_n_out 
 
    reg                       max5_inf_tcm_write_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   max5_inf_tcm_write_n_outen_reg <= 'b0;
	 end
	 else begin
	   max5_inf_tcm_write_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] max5_inf_tcm_write_n_out_reg;   

     always@(posedge clk) begin
	 max5_inf_tcm_write_n_out_reg   <= tcs_max5_inf_tcm_write_n_out[ 0 : 0 ];
      end
          
 
    assign 	max5_inf_tcm_write_n_out[ 0 : 0 ] = max5_inf_tcm_write_n_outen_reg ? max5_inf_tcm_write_n_out_reg : 'z ;
        


 // ** Output Pin max5_inf_tcm_read_n_out 
 
    reg                       max5_inf_tcm_read_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   max5_inf_tcm_read_n_outen_reg <= 'b0;
	 end
	 else begin
	   max5_inf_tcm_read_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] max5_inf_tcm_read_n_out_reg;   

     always@(posedge clk) begin
	 max5_inf_tcm_read_n_out_reg   <= tcs_max5_inf_tcm_read_n_out[ 0 : 0 ];
      end
          
 
    assign 	max5_inf_tcm_read_n_out[ 0 : 0 ] = max5_inf_tcm_read_n_outen_reg ? max5_inf_tcm_read_n_out_reg : 'z ;
        


 // ** Output Pin ssram_tcm_write_n_out 
 
    reg                       ssram_tcm_write_n_outen_reg;     
  
    always@(posedge clk) begin
	 if( reset ) begin
	   ssram_tcm_write_n_outen_reg <= 'b0;
	 end
	 else begin
	   ssram_tcm_write_n_outen_reg <= 'b1;
	 end
     end		     
   
 
    reg [ 0 : 0 ] ssram_tcm_write_n_out_reg;   

     always@(posedge clk) begin
	 ssram_tcm_write_n_out_reg   <= tcs_ssram_tcm_write_n_out[ 0 : 0 ];
      end
          
 
    assign 	ssram_tcm_write_n_out[ 0 : 0 ] = ssram_tcm_write_n_outen_reg ? ssram_tcm_write_n_out_reg : 'z ;
        

endmodule


