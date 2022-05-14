//------------------------------------------------------------------------------
// Title:       bts_ddr3_x32.v                                      		//
// Rev:         Rev 1.0                                                     //
//--------------------------------------------------------------------------//
// Description: All Cyclone V E Development Kit I/O signals and settings      	//
//              such as termination, drive strength, etc...                 //
//              Some toggle_rate=0 where needed for fitter rules. (TR=0)    // 
//--------------------------------------------------------------------------//
// Revision History:                                                        //
// Rev 1.0: Initial								   							//
//------ 1 ------- 2 ------- 3 ------- 4 ------- 5 ------- 6 ------- 7 ------7
//------ 0 ------- 0 ------- 0 ------- 0 ------- 0 ------- 0 ------- 0 ------8
//Copyright � 2012 Altera Corporation. All rights reserved.  Altera products
//are protected under numerous U.S. and foreign patents, maskwork rights,
//copyrights and other intellectual property laws.   
//                 
//This reference design file, and your use thereof, is subject to and
//governed by the terms and conditions of the applicable Altera Reference
//Design License Agreement.  By using this reference design file, you
//indicate your acceptance of such terms and conditions between you and
//Altera Corporation.  In the event that you do not agree with such terms and
//conditions, you may not use the reference design file. Please promptly                         
//destroy any copies you have made.
//
//This reference design file being provided on an "as-is" basis and as an
//accommodation and therefore all warranties, representations or guarantees
//of any kind (whether express, implied or statutory) including, without
//limitation, warranties of merchantability, non-infringement, or fitness for
//a particular purpose, are specifically disclaimed.  By making this
//reference design file available, Altera expressly does not recommend,
//suggest or require that this reference design file be used in combination 
//with any other product not provided by Altera


module bts_ddr3_x32 (
	// clock
	input							clkintop_125_p,			
	input							clkintop_50,				
	input							cpu_resetn,					

	// user I/O
	output   		[3:0] 	user_led_g,          		
	
	// DDR3 Interface
	output	wire 	[13:0]	ddr3_a,
	output 	wire 	[2:0]		ddr3_ba,
	output 	wire           ddr3_casn,
	output 	wire 				ddr3_cke,
	output 	wire   			ddr3_clk_p,
	output 	wire        	ddr3_clk_n,
	output 	wire       		ddr3_csn,
	output 	wire 	[3:0]		ddr3_dm,
	inout  	wire 	[31:0]	ddr3_dq,
	inout  	wire 	[3:0]		ddr3_dqs_p,
	inout  	wire 	[3:0]		ddr3_dqs_n,
	output 	wire           ddr3_odt,
	output 	wire           ddr3_rasn,
	output 	wire           ddr3_resetn,
	output 	wire           ddr3_wen,	
	input							ddr3_oct_rzq
);

   wire local_init_done;
	wire local_cal_success;
	wire local_cal_fail;

	wire reset_int;
	wire error_mon;
	wire status_mon;
	
	reg [31:0]reset_timer;
	reg  reset_timer_pls;

	always @(posedge clkintop_50 or negedge cpu_resetn)begin
		if(cpu_resetn == 0)begin
			reset_timer <= 0;
		end else if(reset_timer == 32'h2000000)begin
			reset_timer <= 32'h2000000;
		end else begin
			reset_timer <= reset_timer + 1;
		end
	end

	always @(posedge clkintop_50 or negedge cpu_resetn)begin
		if(cpu_resetn == 0)begin
			reset_timer_pls <= 1;
		end else if(reset_timer == 32'h1fffffe)begin
			reset_timer_pls <= 0;
		end else begin
			reset_timer_pls <= 1;
		end
	end
	
	issp issp (
		.probe({local_cal_fail, local_cal_success, local_init_done }),
		.source(reset_int)
	);
	 
   q_sys u0 (
	   .clk_clk                                     	 (clkintop_125_p),
	   .reset_reset_n                               	 (cpu_resetn & reset_int & reset_timer_pls),
	   .memory_mem_a                                	 (ddr3_a),
	   .memory_mem_ba                               	 (ddr3_ba),
	   .memory_mem_ck                               	 (ddr3_clk_p),
	   .memory_mem_ck_n                             	 (ddr3_clk_n),
	   .memory_mem_cke                              	 (ddr3_cke),
	   .memory_mem_cs_n                             	 (ddr3_csn),
	   .memory_mem_dm                               	 (ddr3_dm),
	   .memory_mem_ras_n                            	 (ddr3_rasn),
	   .memory_mem_cas_n                            	 (ddr3_casn),
	   .memory_mem_we_n                             	 (ddr3_wen),
	   .memory_mem_reset_n                          	 (ddr3_resetn),
	   .memory_mem_dq                               	 (ddr3_dq),
	   .memory_mem_dqs                              	 (ddr3_dqs_p),
	   .memory_mem_dqs_n                            	 (ddr3_dqs_n),
	   .memory_mem_odt                              	 (ddr3_odt),
	   .oct_rzqin                                   	 (ddr3_oct_rzq),
	   .clk_50_clk                                    	 (clkintop_50),
	   .reset_50_reset_n                              	 (cpu_resetn & reset_int & reset_timer_pls),
	   .master_driver_msgdma_0_conduit_end_error_mon  	 (error_mon),
	   .master_driver_msgdma_0_conduit_end_status_mon 	 (status_mon),
	   .msgdma_0_status_mon_out_cal_fail_mon          	 (local_cal_fail),
	   .msgdma_0_status_mon_out_cal_success_mon       	 (local_cal_success),
	   .msgdma_0_status_mon_out_init_done_mon         	 (local_init_done)
    );

   assign user_led_g[0] = !status_mon | local_cal_fail | (!local_cal_success); 
   assign user_led_g[1] = error_mon;
   assign user_led_g[3:2] = 2'b11;
	 
endmodule