// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module dummy_master(
	input	reset_n,
	input	clk,
	
	input waitrequest_in,
	output	reg csn,
	output	reg wen,
	output reg oen,
	output	reg [3:0]be,
	output	reg [31:0]address,
	output	reg [31:0]data_write,
	input [31:0] data_read
);


	integer count;
	
  // This is only for simulation to wait till DDR memory to be ready
	always @(posedge clk or negedge reset_n)begin
		if(reset_n == 0)begin
			count <= 0;
		end
		else begin
			if(count == 18010)begin
				count <= 18010;
			end else begin
				count <= count + 1;
			end
		end
	end
	
	always @(posedge clk or negedge reset_n)begin
		if(reset_n == 0)begin
			csn <= 1'b1;
			wen <= 1'b1;
			oen <= 1'b1;
			address <= 0;
			data_write <= 0;
		end else begin
			if(count == 18005)begin
				csn <= 1'b0;
				wen <= 1'b0;
				oen <= 1'b1;
				address <= 12; // mem span
				data_write <= 32'h2000;
				be <= 4'b1111;
			end else if(18006)begin
				csn <= 1'b0;
				wen <= 1'b0;
				oen <= 1'b1;
				address <= 12; // mem span
				data_write <= 32'h2000;
				be <= 4'b1111;
			end else if(18007)begin
				csn <= 1'b1;
				wen <= 1'b1;
				oen <= 1'b1;
				address <= 0; // mem span
				data_write <= 0;
				be <= 0;
			end else begin
				csn <= 1'b1;
				wen <= 1'b1;
				oen <= 1'b1;
				address <= 0; // mem span
				data_write <= 0;
				be <= 0;
			end
		end // end of reset_n
	end // end of always
  
endmodule

