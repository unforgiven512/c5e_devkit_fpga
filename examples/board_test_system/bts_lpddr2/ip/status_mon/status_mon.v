module status_mon(
		input local_init_done,
		input local_cal_success,
		input local_cal_fail,
		
		output reg reset_out_n,
		output init_done_mon,
		output cal_success_mon,
		output cal_fail_mon,
		
		
		input slv_clk,
		input slv_reset_n,
		
		input slv_cs_n,
		input slv_read_n,
		input slv_write_n,
		input [1:0] slv_address,
		input [31:0] slv_data_write,
		output reg [31:0] slv_data_read
);

	always @ (posedge slv_clk or negedge slv_reset_n)begin
		if(slv_reset_n == 0)begin
			slv_data_read <= 0;
			reset_out_n <= 1;
		end else begin
			if(slv_cs_n == 0 & slv_read_n == 0)begin
				slv_data_read[2:0] <= {local_cal_success, local_init_done, local_cal_fail};
			end else if(slv_cs_n == 0 & slv_write_n == 0)begin
				reset_out_n <= slv_data_write[0];
			end
		end
	end
	

	assign init_done_mon = local_init_done;
	assign cal_success_mon = local_cal_success;
	assign cal_fail_mon = local_cal_fail;

endmodule
