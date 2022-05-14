// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module master_driver_msgdma(
	input	reset_n,
	input	clk,
	
	input		[3:0]	csr_address,
	input				csr_read,
	input				csr_write,
	output reg[31:0]csr_readdata,
	input		[31:0]csr_writedata,
	output			csr_waitrequest,

	input [1:0]irq,
//  input irq_read,
	input waitrequest_in,
	output	reg csn,
	output	reg wen,
	output reg oen,
	output	reg [3:0]be,
	output	reg [31:0]address /* synthesis keep */,
	output	reg [31:0]data_write /* synthesis keep */,
	input [31:0] data_read /* synthesis keep */,
	output	reset_out,
	output	error_mon,
	output	status_mon
);

	  
	parameter PRBS_PATTERN_GENERATOR_BASE = 32'h40000040;
	parameter PRBS_PATTERN_CHECKER_BASE = 32'h40000000;
//	parameter RAM_TEST_CONTROLLER_BASE = 32'h02021080;
	parameter MEMORY_BASE_ADDRESS = 32'h00000000;
	parameter MEMORY_SPAN = 32'h00008000;
	parameter BLOCK_SIZE = 32'h000100;
//	parameter BLOCK_TRAIL = 8'h02;
	
	parameter DISPATCHER_WRITE_CSR = 32'h40000060;
	parameter DISPATCHER_WRITE_DESCRIPTOR = 32'h400000A0;
	parameter DISPATCHER_READ_CSR = 32'h40000080;
	parameter DISPATCHER_READ_DESCRIPTOR = 32'h400000B0;
	parameter TIMER_BASE = 32'h40000100;
	parameter FREQUENCY_COUNTER_BASE = 32'h40000200;

	parameter ENABLE_PER_INFO = 1;
	parameter LOCAL_DATA_WORDS = 32'h00000010;			

	reg [31:0]timer;
	reg [31:0]timer_tx;
	reg failuer;
	  
//	integer count;
	reg [15:0] count;
//	integer command;
	reg [15:0] command /* synthesis keep */;
	
	
	wire [31:0] status;
	reg [31:0] contrl;
	reg [31:0] mem_base_addr;
	reg [31:0] mem_span;
	reg [31:0] blk_size;
	reg [7:0] blk_trail;
	reg [7:0] timer_res;
	reg [31:0] error_data_ins;
	reg [31:0] error_counter /* synthesis keep */;
	
	reg wait_for_write;
	reg error_ins;
	reg error_clear;
	reg error_status;
	reg clear_error_counter;
	reg process_start;
	reg [30:0] timeout_counter;
	reg system_status;
	reg [31:0] target_freq_counter;
	reg [31:0] target_freq;
	reg issue_reset, issue_reset_int1, issue_reset_int2;
	reg reset_out_int;
	reg reset_msgdma;
	reg reset_msgdma_int;
	reg [31:0] poly_counter;
	


	localparam TIMER_READ = 1;
	localparam FREQ_READ = 1000;
	localparam ERROR_READ = 2000; // the timer data was over wrapping at location of 100...
	localparam ISSUE_RESET = 3000;
	localparam SET_PRBS = 4000;
	localparam SET_WRITE_CSR = 5000;
	localparam SET_WRITE_DIS = 6000;
	localparam SET_READ_CSR = 8000;
	localparam SET_READ_DIS = 9000;

	reg resetn_int2, resetn_int;
	always @ (posedge clk or negedge reset_n)begin
		if (reset_n == 0)begin
			resetn_int2 <= 0;
			resetn_int <= 0;
		end else begin
			resetn_int2 <= 1;
			resetn_int <= resetn_int2;
		end
	end
	
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			reset_msgdma <= 0;
		end else begin
			reset_msgdma <= reset_msgdma_int;
		end
	end
  
	assign reset_out = reset_out_int | issue_reset | reset_msgdma;
	
	reg irq_int1, irq_int2, irq_int;
  always @ (posedge clk or negedge resetn_int)begin
    if (resetn_int == 0)begin
      irq_int1 <= 0;
      irq_int2 <= 1;
      irq_int <= 0;
    end else begin
//      irq_int1 <= irq_read;
      irq_int1 <= irq[1];
      irq_int2 <= !irq_int1;
      irq_int <= irq_int1 & irq_int2;
    end
  end

 
 
  reg irq_int3, irq_int4, irq_write_int;
  always @ (posedge clk or negedge resetn_int)begin
    if (resetn_int == 0)begin
      irq_int3 <= 0;
      irq_int4 <= 1;
      irq_write_int <= 0;
    end else begin
//      irq_int3 <= irq_write;
      irq_int3 <= irq[0];
      irq_int4 <= !irq_int3;
      irq_write_int <= irq_int4 & irq_int3;
    end
  end


// CSR control	
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			error_ins <= 0;
			process_start <= 1;
			clear_error_counter <= 0;
		end else  begin
			if(command == SET_WRITE_CSR+404)begin //SET_WRITE_CSR+404
				error_ins <= 0;
			end else if(command == ERROR_READ+105)begin
				clear_error_counter <= 0;			
			end else if (csr_write == 1 & csr_address == 3'b001) begin //4
				if(csr_writedata[0] == 1)begin
					error_ins <= 1;
				end
				if(csr_writedata[1] == 1)begin
					clear_error_counter <= 1;
				end
				process_start <= csr_writedata[31];
			end
		end
	end


	// generating issue_reset command
	reg [2:0]	issue_reset_counter;
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			issue_reset_counter <= 7;
		end else begin
			if (csr_write == 1 & csr_address == 3'b001 & csr_writedata[8] == 1)begin
				issue_reset_counter <= 0;
			end else if (issue_reset_counter == 7) begin
				issue_reset_counter <= issue_reset_counter;
			end else begin
				issue_reset_counter <= issue_reset_counter + 1;
			end
		end
	end
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			issue_reset <= 0;
		end else  begin
			if(issue_reset_counter == 5)begin
				issue_reset <= 1;
			end else begin
				issue_reset <= 0;
			end 
		end
	end
	
	
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			error_status <= 0;
		end else if (clear_error_counter == 1) begin
			error_status <= 0;
		end else if(issue_reset == 1)begin
			error_status <= 0;
		end else if (error_counter != 0) begin
			error_status <= 1;
		end else begin
		  error_status <= 0;
		end
	end
	
	
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			mem_base_addr <= MEMORY_BASE_ADDRESS;
		end else if (csr_write == 1 & csr_address == 3'b010) begin //8
			mem_base_addr <= csr_writedata;
		end
	end
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
//			mem_span <= 32'h8000;
			mem_span <= MEMORY_SPAN;			
		end else if (csr_write == 1 & csr_address == 3'b011) begin //12
			mem_span <= csr_writedata;
		end
	end
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			blk_size <= BLOCK_SIZE;
		end else if (csr_write == 1 & csr_address == 3'b100) begin //16
			blk_size <= csr_writedata;
		end
	end



	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			timeout_counter <= 0;
			system_status <= 1;
		end else begin
			if(command == 1)begin
				timeout_counter <= 0;
				system_status <= 1;
			end else if(timeout_counter == mem_span)begin 		// memory_span is long enough to say the timeout
				timeout_counter <= timeout_counter; 			// just because the datawidth is not 8 most of time.
				system_status <= 0;
			end else begin
				timeout_counter <= timeout_counter + 1;
				system_status <= 1;
			end
		end
	end

	
	assign status = {error_status, system_status, process_start};
	assign error_mon = error_status;
	assign status_mon = system_status;


  reg [31:0]total_time;
  reg [31:0]total_time_int1;
  reg [31:0]total_time_int2;
  reg [31:0]total_time_int3;
  reg [47:0]mem_span_int;
  reg [41:0]mem_span_int2;
  reg [37:0]freq_unit;
  reg [31:0]percent;
  reg [63:0]percent_int;
	reg [31:0] MBs;
	reg [31:0] MBs_int;
	reg [4:0] slow_clk_int;
	wire slow_clk;
	reg [3:0] slow_sequencer;
	reg [63:0] logical_max;


	generate
	if (ENABLE_PER_INFO==1) begin
		always @(posedge clk or negedge resetn_int)begin
			if(resetn_int == 0)begin
				slow_clk_int <= 0;
			end
			else begin
				if(slow_clk_int == 31)begin
					slow_clk_int <= 0;
				end else begin
					slow_clk_int <= slow_clk_int + 1;
				end
			end
		end	
	  
	  assign slow_clk = slow_clk_int[4];
	  
		always @(posedge slow_clk or negedge resetn_int)begin
			if(resetn_int == 0)begin
				slow_sequencer   <= 15;
			end
			else begin
				if(irq[1] == 1)begin
					slow_sequencer   <= 0;
				end else if(slow_sequencer   == 15)begin
					slow_sequencer   <= 15;
				end else begin
					slow_sequencer   <= slow_sequencer   + 1;
				end
			end
		end	

	  
		always @(posedge slow_clk or negedge resetn_int)begin
			if(resetn_int == 0)begin
				MBs <= 0;
				MBs_int <= 0;
				total_time <= 0;
				total_time_int1 <= 0;
				total_time_int2 <= 0;
				total_time_int3 <= 0;
				mem_span_int <= 0;
				mem_span_int2 <= 0;
				freq_unit <= 0;
				percent <= 0;
				percent_int <= 0;
				logical_max <= 0;
			end
			else begin
				if(slow_sequencer == 1)begin
				  total_time_int1 <= 32'hffffffff - timer;
				end else if(slow_sequencer == 2)begin
				  total_time_int2 <= total_time_int1 * 20; // making ns order at here
				end else if(slow_sequencer == 3)begin 
				  total_time_int3[30:0] <= total_time_int2[31:1]; // total_time is now in ns order
				  total_time_int3[31] <= 0;
//				  mem_span_int <= mem_span * 1000;
				  mem_span_int <= mem_span * 100000;
				end else if(slow_sequencer == 4)begin
				  MBs_int <= mem_span_int / total_time_int3;
				end else if(slow_sequencer == 5)begin
				  MBs <= MBs_int;
				end else if(slow_sequencer == 6)begin
//				  mem_span_int2 <= mem_span / 16; // 32bit half rate    4Byte*2*2
				  mem_span_int2 <= mem_span / LOCAL_DATA_WORDS; // 32bit half rate    4Byte*2*2
				end else if(slow_sequencer == 7)begin
				  freq_unit <= 1000000000 / target_freq; // freq_unit needs to be in ps order at here
				end else if(slow_sequencer == 8)begin
				  freq_unit <= freq_unit * 10;
				end else if(slow_sequencer == 9)begin
				  logical_max <= mem_span_int2 * freq_unit;
				end else if(slow_sequencer == 10)begin
				  percent_int <= logical_max / total_time_int3; // make it ns order at here
				end else if(slow_sequencer == 11)begin
				  percent[31:0] <= percent_int[31:0];
				end
			end
		end	
	end
	endgenerate
	


	
	always @ (posedge clk or negedge resetn_int)begin
		if (resetn_int == 0)begin
			csr_readdata <= 0;
		end else if(csr_read == 1)begin
			case(csr_address)
				0:csr_readdata <= status;
				1:csr_readdata <= contrl;
				2:csr_readdata <= mem_base_addr;			// mostly, it will be 0x00
				3:csr_readdata <= mem_span;				// total size of the target memory. Such as 0x40000000
				4:csr_readdata <= blk_size;				// not in use for now
				5:csr_readdata <= target_freq;			// this is the frequency that local bus is using, if it is half rate, then just x2 is the physical freq of the ddr
				6:csr_readdata <= timer_tx;				// time spent at the tx or the write operation
				7:csr_readdata <= timer;					// total time spent at both write and read operation
				8:csr_readdata <= error_counter;
				9:csr_readdata <= MBs;						// performance based on the datawith * target_freq
				10:csr_readdata <= percent;				// percentage of the performance
				
				
				default:csr_readdata <= 0;
			endcase
		end
	end
	
	
	
  // This is only for simulation to wait till DDR memory to be ready
	always @(posedge clk or negedge resetn_int)begin
		if(resetn_int == 0)begin
			count <= 0;
		end
		else begin
			if(count == 18000)begin
				count <= 18000;
			end else begin
				count <= count + 1;
			end
		end
	end


  


	
	always @(posedge clk or negedge resetn_int)begin
		if(resetn_int == 0)begin
			csn <= 1'b1;
			wen <= 1'b1;
			oen <= 1'b1;
			address <= 0;
			data_write <= 0;
			command <= 0;
			be <= 0;
			failuer <= 0;
			timer <= 0;
			timer_tx <= 0;
			wait_for_write <= 0;
			reset_out_int <= 0;
			error_counter <= 0;
			error_clear <= 0;
			target_freq <= 0;
			reset_msgdma_int <= 0;
			poly_counter <= 0;
		end else begin
			if(issue_reset == 1)begin
				csn <= 1'b1;
				wen <= 1'b1;
				oen <= 1'b1;
				address <= 0;
				data_write <= 0;
				be <= 4'b0000;
				reset_out_int <= 0;
				command <= 65436;
				wait_for_write <= 0;
				error_counter <= 0;
			end else if(count == 18000 & process_start == 1 )begin
				if(irq_int == 1)begin
					csn <= 1'b0;
					wen <= 1'b0;
					oen <= 1'b1;
					address <= TIMER_BASE + 20; // write dummy data
					data_write <= 32'h00; // dummy
					be <= 4'b1111;
					wait_for_write <= 0;          
				end else if(irq_write_int == 1)begin
					csn <= 1'b0;
					wen <= 1'b0;
					oen <= 1'b1;
					address <= TIMER_BASE + 20; // write dummy data
					data_write <= 32'h00; // dummy
					be <= 4'b1111;
					wait_for_write <= 0;
				end else begin
					case (command)
					  
					TIMER_READ,TIMER_READ+1:begin // read takes more time, so assigning 3 stages
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						address <= TIMER_BASE + 16; // get timer data
						be <= 4'b1111;
						if(waitrequest_in != 1)begin
							timer[15:0] <= data_read[15:0];
						end
					end



					TIMER_READ+100,TIMER_READ+101:begin // read takes more time, so assigning 3 stages
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						address <= TIMER_BASE + 20; // get timer data
						be <= 4'b1111;
						if(waitrequest_in != 1)begin
							timer[31:16] <= data_read[15:0];
						end
					end

					FREQ_READ:begin
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						reset_out_int <= 0;
						be <= 4'b1111;
						address <= FREQUENCY_COUNTER_BASE;
					end
					FREQ_READ+1:begin
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						reset_out_int <= 0;
						be <= 4'b1111;
						address <= FREQUENCY_COUNTER_BASE;
						if(waitrequest_in != 1)begin
							target_freq <= data_read;
						end
					end


					ERROR_READ,ERROR_READ+1:begin // read takes more time, so assigning 3 stages
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						reset_out_int <= 0;
						be <= 4'b1111;
						address <= PRBS_PATTERN_CHECKER_BASE + 32;
					end
					
					
					ERROR_READ+100:begin // read takes more time, so assigning 3 stages
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						reset_out_int <= 0;
						be <= 4'b1111;
						address <= PRBS_PATTERN_CHECKER_BASE + 32;
					end
					ERROR_READ+101:begin // read takes more time, so assigning 3 stages
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						reset_out_int <= 0;
						be <= 4'b1111;
						address <= PRBS_PATTERN_CHECKER_BASE + 32;
						if(waitrequest_in != 1)begin
							if(clear_error_counter == 1)begin
								error_counter <= 0;
							end else begin
								error_counter <= error_counter + data_read;
							end
						end

						if(waitrequest_in != 1)begin
							if(data_read != 0)begin
								failuer <= 1;
							end else begin
								failuer <= 0;
							end
						end  
					end
					ERROR_READ+105:begin
						if(clear_error_counter == 1)begin
							error_counter <= 0;
						end
					end
					ERROR_READ+200:begin // clear the error counter in the PRBS checker
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						be <= 4'b1111;
						address <= PRBS_PATTERN_CHECKER_BASE + 32;
						data_write <= 32'h00000000;
					end

					// reset the both write/read descriptor
					ISSUE_RESET:begin
            reset_msgdma_int					<= 1;
        end
					ISSUE_RESET+1:begin
            reset_msgdma_int					<= 0;
        end        
					ISSUE_RESET+100, ISSUE_RESET+101:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_CSR + 4;// issue reset dispatcher
						data_write <= 32'h00000002;
						be <= 4'b1111;
					end
					ISSUE_RESET, ISSUE_RESET+1:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_CSR + 4;// issue reset dispatcher
						data_write <= 32'h00000002;
						be <= 4'b1111;
					end


					//            IOWR_32DIRECT(MSGDMA_0_PRBS_PATTERN_GENERATOR_BASE, 0, memory_span);
					//            IOWR_8DIRECT(MSGDMA_0_PRBS_PATTERN_GENERATOR_BASE, 8, 0x00);
					//            IOWR_32DIRECT(MSGDMA_0_PRBS_PATTERN_CHECKER_BASE, 0, memory_span);
					//            IOWR_8DIRECT(MSGDMA_0_PRBS_PATTERN_CHECKER_BASE, 8, 0x00);
					//            IOWR_8DIRECT(MSGDMA_0_PRBS_PATTERN_CHECKER_BASE, 9, 0x00);
					//            IOWR_8DIRECT(MSGDMA_0_PRBS_PATTERN_CHECKER_BASE, 24, 0x00);
					//            IOWR_32DIRECT(MSGDMA_0_PRBS_PATTERN_CHECKER_BASE, 0, memory_span);
					//            IOWR_32DIRECT(MSGDMA_0_PRBS_PATTERN_GENERATOR_BASE, 0, memory_span);


					


					SET_PRBS, SET_PRBS+1:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_GENERATOR_BASE; // setting Payload Length
						data_write <= mem_span;
						be <= 4'b1111;
						reset_out_int <= 0;						
					end

					SET_PRBS+100, SET_PRBS+101:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_GENERATOR_BASE + 8; // disabling Infinite Payload Length
						data_write <= 32'h00000000;
						be <= 4'b1111;
					end

					SET_PRBS+200, SET_PRBS+201:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_CHECKER_BASE; // setting Payload Length
						data_write <= mem_span;
						be <= 4'b1111;
					end

					SET_PRBS+300, SET_PRBS+301:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_CHECKER_BASE + 8; // disabling Infinite Payload Length
						data_write <= 32'h00000000;
						be <= 4'b1111;
					end

					SET_PRBS+400, SET_PRBS+401:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_CHECKER_BASE + 24; // disabling Stop on Failure
						data_write <= 32'h00000000;
						be <= 4'b1111;
					end



					SET_PRBS+500, SET_PRBS+501:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_GENERATOR_BASE; // setting Payload Length
						data_write <= mem_span;
						be <= 4'b1111;
					end

					SET_PRBS+600, SET_PRBS+601:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_CHECKER_BASE; // setting Payload Length
						data_write <= mem_span;
						be <= 4'b1111;
					end

// writing new polynomial number at here
					SET_PRBS+700, SET_PRBS+701:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_CHECKER_BASE + 16;
						data_write <= poly_counter;
						be <= 4'b1111;
					end



					SET_PRBS+800, SET_PRBS+801:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_GENERATOR_BASE + 16;
						data_write <= poly_counter;
						be <= 4'b1111;
					end

					SET_PRBS+900:begin
						poly_counter <= poly_counter + 1;
					end

					/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_CSR_BASE, 4, 0x02);  // issue reset dispatcher
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_CSR_BASE, 0, 0x0000); //clear all the status
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_CSR_BASE, 4, 0x10); // set IRQ enable
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_CSR_BASE, 0, 0x0); //clear all the status
					//            IOWR_8DIRECT(MSGDMA_0_PRBS_PATTERN_GENERATOR_BASE, 11, 0x01);
					//              IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0x0, 0);
					//              IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0x4, block_size * k);
					//              IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0x8, block_size);
					//                IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0xC, 0x80004000);
					//        


					SET_WRITE_CSR, SET_WRITE_CSR+1:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_CSR + 4;// issue reset dispatcher
						data_write <= 32'h00000002;
						be <= 4'b1111;
					end

					SET_WRITE_CSR+100, SET_WRITE_CSR+101:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_CSR + 0;//clear all the status
						data_write <= 0;
						be <= 4'b1111;
					end

					SET_WRITE_CSR+200, SET_WRITE_CSR+201:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_CSR + 4; // set IRQ enaAC40ble
						data_write <= 32'h10;
						be <= 4'b1111;
					end


					SET_WRITE_CSR+300, SET_WRITE_CSR+301:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_CSR + 0;//clear all the status
						data_write <= 0;
						be <= 4'b1111;
					end

					  

					SET_WRITE_CSR+400, SET_WRITE_CSR+401:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_GENERATOR_BASE + 8; // sending GO command to generator
						if(error_ins == 1)begin
							data_write <= 32'h03000000;
						end else begin
							data_write <= 32'h01000000;
						end
						be <= 4'b1000;
					end

					// clear the error insrt signal
					SET_WRITE_CSR+403:begin
						error_clear <= 0;
					end
					
					SET_WRITE_CSR+404:begin
						error_clear <= 1;
					end
					
					SET_WRITE_CSR+405:begin
						error_clear <= 0;
					end

					
//					
//	for(i=0; i<(memory_span/block_size); i++){
//		IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0x0, 0);
//		IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0x4, block_size * i);
//		IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0x8, block_size);
//		if(i == (memory_span/block_size) - 1)
//			IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0xC, 0x80004000);
//		else
//			IOWR_32DIRECT(MSGDMA_0_DISPATCHER_WRITE_DESCRIPTOR_SLAVE_BASE, 0xC, 0x81000000);
//	}
//


					// writing descriptor from here
					SET_WRITE_DIS, SET_WRITE_DIS+1:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_DESCRIPTOR + 0;
						data_write <= 0; // get data from.
						be <= 4'b1111;
					end

					SET_WRITE_DIS+100, SET_WRITE_DIS+101:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_DESCRIPTOR + 4;
						data_write <= 0; // location to write to
						be <= 4'b1111;
					end

					SET_WRITE_DIS+200, SET_WRITE_DIS+201:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_DESCRIPTOR + 8;
						data_write <= mem_span; // size to write
						be <= 4'b1111;
					end



					SET_WRITE_DIS+300, SET_WRITE_DIS+301:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= TIMER_BASE + 0;
						data_write <= 32'h0;
						be <= 4'b1111;
					end

					SET_WRITE_DIS+400, SET_WRITE_DIS+401:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= TIMER_BASE + 4;
						data_write <= 32'hA;
						be <= 4'b1111;
					end

					SET_WRITE_DIS+500, SET_WRITE_DIS+501:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= TIMER_BASE + 8;
						data_write <= 32'hFFFFFFFF;
						be <= 4'b1111;
					end

					SET_WRITE_DIS+600, SET_WRITE_DIS+601:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= TIMER_BASE + 12;
						data_write <= 32'hFFFFFFFF;
						be <= 4'b1111;
					end


					SET_WRITE_DIS+700, SET_WRITE_DIS+701:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= TIMER_BASE + 4;
						data_write <= 32'h6;
						be <= 4'b1111;
					end




					SET_WRITE_DIS+800:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_WRITE_DESCRIPTOR + 12;
						data_write <= 32'h80004000;
						be <= 4'b1111;
					end
					// end of descriptor



					SET_WRITE_DIS+902:begin
						wait_for_write <= 1;
					end

					SET_WRITE_DIS+910, SET_WRITE_DIS+911:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= TIMER_BASE + 4;
						data_write <= 32'hA;
						be <= 4'b1111;
					end
					
					SET_WRITE_DIS+1000,SET_WRITE_DIS+1001:begin // read takes more time, so assigning 3 stages
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						address <= TIMER_BASE + 16; // get timer data
						be <= 4'b1111;
						if(waitrequest_in != 1)begin
							timer_tx[15:0] <= data_read[15:0];
						end
					end



					SET_WRITE_DIS+1100,SET_WRITE_DIS+1101:begin // read takes more time, so assigning 3 stages
						csn <= 1'b0;
						wen <= 1'b1;
						oen <= 1'b0;
						address <= TIMER_BASE + 20; // get timer data
						be <= 4'b1111;
						if(waitrequest_in != 1)begin
							timer_tx[31:16] <= data_read[15:0];
						end
					end
					


					//        
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_CSR_BASE, 4, 0x02);  // issue reset dispatcher
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_CSR_BASE, 0, 0x0000); //clear all the status
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_CSR_BASE, 4, 0x10); // set IRQ enable
					//            IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_CSR_BASE, 0, 0x0); //clear all the status
					//            IOWR_8DIRECT(MSGDMA_0_PRBS_PATTERN_CHECKER_BASE, 11, 0x01);
					//              IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_DESCRIPTOR_SLAVE_BASE, 0x0, block_size * k);
					//              IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_DESCRIPTOR_SLAVE_BASE, 0x4, 0);
					//              IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_DESCRIPTOR_SLAVE_BASE, 0x8, block_size);
					//                IOWR_32DIRECT(MSGDMA_0_DISPATCHER_READ_DESCRIPTOR_SLAVE_BASE, 0xC, 0x80004000);



					SET_READ_CSR, SET_READ_CSR+1:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_CSR + 4;// issue reset dispatcher
						data_write <= 32'h00000002;
						be <= 4'b1111;
					end

					SET_READ_CSR+100, SET_READ_CSR+101:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_CSR + 0;//clear all the status
						data_write <= 0;
						be <= 4'b1111;
					end

					SET_READ_CSR+200, SET_READ_CSR+201:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_CSR + 4; // set IRQ enable
						data_write <= 32'h10;
						be <= 4'b1111;
					end


					SET_READ_CSR+300, SET_READ_CSR+301:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_CSR + 0;//clear all the status
						data_write <= 0;
						be <= 4'b1111;
					end





					SET_READ_CSR+400, SET_READ_CSR+401:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= PRBS_PATTERN_CHECKER_BASE + 8; // sending GO command to generator
						data_write <= 32'h01000000;
						be <= 4'b1000;
					end


					// writing descriptor from here
					SET_READ_DIS, SET_READ_DIS+1:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_DESCRIPTOR + 0;
						data_write <= 0; // get data from.
						be <= 4'b1111;
					end

					SET_READ_DIS+100, SET_READ_DIS+101:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_DESCRIPTOR + 4;
						data_write <= 0; // location to write to
						be <= 4'b1111;
					end

					SET_READ_DIS+200, SET_READ_DIS+201:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_DESCRIPTOR + 8;
						data_write <= mem_span; // size to write
						be <= 4'b1111;
					end


					SET_READ_DIS+300, SET_READ_DIS+301:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= TIMER_BASE + 4;
						data_write <= 32'h6;
						be <= 4'b1111;
					end

					SET_READ_DIS+400:begin
						csn <= 1'b0;
						wen <= 1'b0;
						oen <= 1'b1;
						address <= DISPATCHER_READ_DESCRIPTOR + 12;
						data_write <= 32'h80004000;
						be <= 4'b1111;
					end
					
					SET_READ_DIS+405:begin
						wait_for_write <= 1;
					end


					default:begin
						csn <= 1'b1;
						wen <= 1'b1;
						oen <= 1'b1;
						address <= 0;
						data_write <= 0;
						be <= 4'b0000;
						reset_out_int <= 0;
					end

					endcase
				end // end of irq

				//				if(irq == 1)begin
				if(irq_int == 1)begin
					command <= 0;
				end else if(csn == 0 & waitrequest_in == 1)begin
					command <= command;
				end else if(wait_for_write == 1)begin
					command <= command;
					//				end else if(waitrequest_in != 1 & wait_for_write != 1)begin
				end else begin
					command <= command + 1;
				end


			end // end of irq_int   and    irq_write_int == 1
			else begin
				csn <= 1'b1;
				wen <= 1'b1;
				oen <= 1'b1;
				address <= 0;
				data_write <= 0;
				be <= 4'b0000;
				reset_out_int <= 0;
				command <= 0;
				wait_for_write <= 0;
			end // end of count == 18000 & process_start == 1
		end // end of reset_n
	end // end of always
  
endmodule
