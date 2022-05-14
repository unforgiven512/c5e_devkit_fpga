// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module frequency_counter(
	input	reset_n,
	input	clk,
	
	input		[3:0]	csr_address,
	input				csr_read,
	output reg[31:0]csr_readdata,
	output			csr_waitrequest,

	input sample_reset_n,
	input sample_clk
	
);

	reg [31:0]freq_int;
	reg [31:0]freq;
	reg [31:0]count_1ms;
	reg pls_1sec_int1, pls_1sec_int2, pls_1sec_int3, pls_1sec;
	  
	  
//	parameter SYSTEM_CLK_FREQ_PICO_SEC = 32'h4E20; // 20ns or 20000 pico-sec
	parameter SYSTEM_CLK_FREQ_PICO_SEC = 32'd20000; // 20ns or 20000 pico-sec
	localparam count_1ms_in_pico = 1000000000 / SYSTEM_CLK_FREQ_PICO_SEC;
	

	// counting 1 mili-sec at here
	// count_1ms is, most likely, 50MHz or 20ns
	always @ (posedge clk or negedge reset_n)begin
		if (reset_n == 0)begin
			count_1ms <= 0;
		end else  begin
			if(count_1ms == count_1ms_in_pico)begin
				count_1ms <= 0;
			end else begin
				count_1ms <= count_1ms + 1;
			end
		end
	end
	
	assign csr_waitrequest = 0;
	
	always @ (posedge clk or negedge reset_n)begin
		if (reset_n == 0)begin
			csr_readdata <= 0;
		end else if(csr_read == 1)begin
			case(csr_address)
				0:csr_readdata <= freq;
				default:csr_readdata <= 0;
			endcase
		end
	end


	
	
	// sample_clk is such as 266MHz(3.7ns) or 133MHz(7.5ns) with DDR
	// expecting the smaple_clk to be at least x2 of the system_clk speed.
	always @ (posedge sample_clk or negedge sample_reset_n)begin
		if (sample_reset_n == 0)begin
			pls_1sec_int1 <= 0;
		end else begin
			if (count_1ms >= count_1ms_in_pico-1) begin
				pls_1sec_int1 <= 1;
			end else begin
				pls_1sec_int1 <= 0;			  
			end
		end
	end

	// pls_1sec is 1 tick width of '1' of the sample_clk
	// This signal will be used to latch and clear the counter
	always @ (posedge sample_clk or negedge sample_reset_n)begin
		if (sample_reset_n == 0)begin
			pls_1sec_int2 <= 0;
			pls_1sec_int3 <= 1;
			pls_1sec <= 0;
		end else begin
			pls_1sec_int2 <= pls_1sec_int1;
			pls_1sec_int3 <= ~pls_1sec_int2;
			if(pls_1sec_int1 == 1 & pls_1sec_int2 == 1)begin
				pls_1sec <= pls_1sec_int2 & pls_1sec_int3;
			end
		end
	end
	
	
	//count up counter by using the sample_clk during 1ms
	// once detect the 1ms plus, latch the counter value and reset the counter
	always @ (posedge sample_clk or negedge sample_reset_n)begin
		if (sample_reset_n == 0)begin
			freq_int <= 0;
			freq <=0;
		end else begin
			if (pls_1sec == 1) begin
				freq <= freq_int;
				freq_int <= 0;
			end else begin
				freq_int <= freq_int + 1;
			end 
		end
	end

	
endmodule



