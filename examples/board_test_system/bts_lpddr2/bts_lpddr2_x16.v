//------------------------------------------------------------------------------
// Title:       bts_lpddr2_x16.v                                      		//
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


module bts_lpddr2_x16 (
	// clock
	input							clkintop_125_p,				
	input							clkintop_50,				
	input							cpu_resetn,					

	// user I/O
	input			   [2:0]		user_pb,				
    output   	   [3:0] 	user_led_g,          		
	
	// lpddr2 Interface
	output	wire 	[9:0]		lpddr2_a,
	output 	wire 				lpddr2_cke,
	output 	wire   			lpddr2_clk_p,
	output 	wire        	lpddr2_clk_n,
	output 	wire       		lpddr2_csn,
	output 	wire 	[1:0]		lpddr2_dm,
	inout  	wire 	[15:0]	lpddr2_dq,
	inout  	wire 	[1:0]		lpddr2_dqs_p,
	inout  	wire 	[1:0]		lpddr2_dqs_n,
	input							lpddr2_oct_rzq
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
        .clk_clk                                       (clkintop_125_p),
        .reset_reset_n                                 (cpu_resetn & reset_int & reset_timer_pls),
        .memory_mem_ca                                 (lpddr2_a),
        .memory_mem_ck                                 (lpddr2_clk_p),
        .memory_mem_ck_n                               (lpddr2_clk_n),
        .memory_mem_cke                                (lpddr2_cke),
        .memory_mem_cs_n                               (lpddr2_csn),
        .memory_mem_dm                                 (lpddr2_dm),
        .memory_mem_dq                                 (lpddr2_dq),
        .memory_mem_dqs                                (lpddr2_dqs_p),
        .memory_mem_dqs_n                            	 (lpddr2_dqs_n),
        .oct_rzqin                                     (lpddr2_oct_rzq),
		  
        .clk_50_clk                                    (clkintop_50),
        .reset_50_reset_n                              (cpu_resetn & reset_int & reset_timer_pls),
		  
        .master_driver_msgdma_0_conduit_end_error_mon	 (error_mon),
        .master_driver_msgdma_0_conduit_end_status_mon (status_mon),
		  
        .msgdma_0_status_mon_out_cal_fail_mon          (local_cal_fail),
        .msgdma_0_status_mon_out_cal_success_mon       (local_cal_success),
        .msgdma_0_status_mon_out_init_done_mon         (local_init_done)
    );

   assign user_led_g[0] = !status_mon | local_cal_fail | (!local_cal_success); 
   assign user_led_g[1] = error_mon;
   assign user_led_g[3:2] = 2'b11;
	 
endmodule