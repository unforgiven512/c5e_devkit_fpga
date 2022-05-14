// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module reset_gen(
	input	reset_n,
	input	clk,
	
	input		[3:0]	csr_address,
	input				csr_read,
	input				csr_write,
	output reg[31:0]csr_readdata,
	input		[31:0]csr_writedata,
	output			csr_waitrequest,

	output reset_out
);

	reg issue_reset, issue_reset_int1, issue_reset_int2;
	reg reset_out_int;
	reg [3:0] counter;


	assign reset_out = issue_reset;
	
	reg irq_int1, irq_int2, irq_int;

	// counter for self clear bit
	always @ (posedge clk or negedge reset_n)begin
		if (reset_n == 0)begin
			counter <= 15;
		end else begin
			if(csr_write == 1 & csr_address == 3'b000 & csr_writedata[0] == 1)begin
				counter <= 0;
			end else if(counter == 15)begin
				counter <= counter;
			end else begin
				counter <= counter + 1;
			end
		end
	end

	
	// generating issue_reset command
	always @ (posedge clk or negedge reset_n)begin
		if (reset_n == 0)begin
			issue_reset_int1 <= 0;
		end else if(counter == 15)begin // self clear
			issue_reset_int1 <= 0;
		end else if (counter == 1)begin
			issue_reset_int1 <= 1;
		end
	end
	always @ (posedge clk or negedge reset_n)begin
		if (reset_n == 0)begin
			issue_reset <= 0;
			issue_reset_int2 <= 1;
		end else  begin
			issue_reset <= issue_reset_int1 & issue_reset_int2;
			issue_reset_int2 <= !issue_reset_int1;
		end
	end
	
endmodule


