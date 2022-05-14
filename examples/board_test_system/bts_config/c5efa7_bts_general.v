module c5efa7_bts_general
(
   input                clkin_50,
   input                cpu_resetn,
	
	inout		[ 15 : 0 ]  fsm_data,
	output	[ 25 : 0 ]	fsm_add,
	output					flash_wen,
	output					flash_oen,
	output					flash_csn,
	output					flash_advn,
	output					flash_clk,
	output					flash_resetn,
	
   output   [  3 : 0 ]  user_led,
   input    [  3 : 0 ]  user_dispsw,
	input    [  3 : 0 ]  user_pbin,
	
	output					lcd_wen,
	inout		[  7 : 0 ] 	lcd_data,
	output					lcd_csn,
	output					lcd_d_cn,
	
	output					max5_csn,
	output					max5_wen,
	output					max5_rdn,
	
	output	[	1 : 0	]	ssram_bwn,
	output					ssram_cen,
	output					ssram_oen,
	output					ssram_wen,
	output					ssram_clk
);

	assign flash_advn = 0;
	assign flash_clk = 0;
	assign flash_resetn = 1;
	
c5efa7_bts_general_qsys c5efa7_bts_general_qsys_inst  
(
  .clkin_50_clk                                           (clkin_50),                                           
  .clkin_50_clk_in_reset_reset_n                          (cpu_resetn),   
  
  .led_pio_export                                         (user_led),  
  .dipsw_in_export                                        (user_dispsw),                                       
  .pb_in_export                                           (user_pbin),  

  .lcd_external_1_data                                    (lcd_data),                                   
  .lcd_external_1_E                                       (lcd_csn),                                      
  .lcd_external_1_RS                                      (lcd_d_cn),                                     
  .lcd_external_1_RW                                      (lcd_wen),        
  
  .tristate_conduit_bridge_fsm_add                        (fsm_add),  
  .tristate_conduit_bridge_fsm_data                       (fsm_data),
  
  .tristate_conduit_bridge_ssram_tcm_outputenable_n_out   (ssram_oen),    
  .tristate_conduit_bridge_ssram_tcm_byteenable_n_out     (ssram_bwn), 
  .tristate_conduit_bridge_ssram_tcm_chipselect_n_out     (ssram_cen),   
  .tristate_conduit_bridge_ssram_tcm_write_n_out          (ssram_wen),    
  
  .tristate_conduit_bridge_ext_flash_tcm_read_n_out       (flash_oen),       
  .tristate_conduit_bridge_ext_flash_tcm_write_n_out      (flash_wen),     
  .tristate_conduit_bridge_ext_flash_tcm_chipselect_n_out (flash_csn), 
            
  .tristate_conduit_bridge_max5_inf_tcm_chipselect_n_out  (max5_csn), 
  .tristate_conduit_bridge_max5_inf_tcm_write_n_out       (max5_wen),     
  .tristate_conduit_bridge_max5_inf_tcm_read_n_out        (max5_rdn),       
        
  .ssram_clk_clk                                          (ssram_clk)
  
);

endmodule
