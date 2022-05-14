module c5efa7_fpga_bup_top
(
   input                clkin_50,
   input                cpu_resetn,
   
   output               enet_mdc,
   inout                enet_mdio,
   output               enet_resetn, 
   input                enet_rx_clk,
   input                enet_rx_dv,
   input    [  3 : 0 ]  enet_rx_d,
   output               enet_gtx_clk,
   output               enet_tx_en,
   output   [  3 : 0 ]  enet_tx_d,
   
   output   			   flash_cen,
   output               flash_oen,
   output               flash_resetn,
   output               flash_wen,
   output   [ 25 : 0 ]  fsm_a,
   inout    [ 15 : 0 ]  fsm_d,
   output               flash_advn,
   output               flash_clk,
	
	output	[	1 : 0	]	ssram_bwn,
	output					ssram_cen,
	output					ssram_clk,
	output 					ssram_oen,
	output					ssram_wen,
	output					ssram_adsc_n,

   output               lcd_wen,
   inout    [  7 : 0]   lcd_data,
   output               lcd_en,
   output               lcd_d_cn,  
   
   input    [  3 : 0 ]  user_dipsw,
   input    [  3 : 0 ]  user_pb,
   output   [  3 : 0 ]  user_led
   
);

	wire              	locked_from_the_enet_pll;
	wire              	mdio_oen_from_the_tse_mac;
	wire              	mdio_out_from_the_tse_mac;
	wire              	eth_mode_from_the_tse_mac;
	wire              	ena_10_from_the_tse_mac;
	wire              	enet_tx_125;
	wire              	enet_tx_25;
	wire              	enet_tx_2p5;
	wire              	tx_clk_to_the_tse_mac;
	wire              	global_resetn;


	assign flash_resetn = cpu_resetn;
	assign flash_advn   = 1'b0;
	assign flash_clk    = 1'b0;
	

enet_gtx_clk_ddio_buffer   enet_gtx_clk_ddio_buffer_inst (
   .aclr       ( !cpu_resetn ),
   .datain_h   ( 1'b1 ),
   .datain_l   ( 1'b0 ),
   .outclock   ( tx_clk_to_the_tse_mac ),
   .dataout    ( enet_gtx_clk )
);
    
assign tx_clk_to_the_tse_mac =   ( eth_mode_from_the_tse_mac ) ? ( enet_tx_125 ) :  // GbE Mode = 125MHz clock
                                 ( ena_10_from_the_tse_mac ) ? ( enet_tx_2p5 ) :    // 10Mb Mode = 2.5MHz clock
                                 ( enet_tx_25 );                                    // 100Mb Mode = 25MHz clock
                        
assign enet_mdio = ( !mdio_oen_from_the_tse_mac ) ? ( mdio_out_from_the_tse_mac ) : ( 1'bz );

parameter MSB = 19; // PHY interface: need minimum 10ms delay for POR

    reg [MSB:0] epcount; 
    
    always @(posedge clkin_50)
    begin 
     if (cpu_resetn == 1'b0)
        epcount <= MSB + 1'b0;
      else
		if (epcount[MSB] == 1'b0)
			epcount <= epcount + 1;
		else
			epcount <= epcount;
    end
    
assign enet_resetn = !epcount[MSB-1];

c5efa7_fpga_bup_qsys c5efa7_fpga_bup_qsys_inst
(
   .clkin_50_clk                                       	  (clkin_50),
   .enet_pll_outclk0_clk                               	  (enet_tx_125),
   .enet_pll_outclk1_clk                               	  (enet_tx_25),
   .enet_pll_outclk2_clk                               	  (enet_tx_2p5),
   .merged_resets_in_reset_reset_n                     	  (cpu_resetn),
   
   .dipsw_pio_out_1_export                             	  (user_dipsw),
   .button_pio_out_export                              	  (user_pb),
   .led_pio_out_export                                 	  (user_led),
	
   .lcd_external_E                                     	  (lcd_en),
   .lcd_external_RS                                    	  (lcd_d_cn),
   .lcd_external_RW                                    	  (lcd_wen),
   .lcd_external_data                                  	  (lcd_data),    

   .tristate_conduit_bridge_fsm_add                        (fsm_a),    
	.tristate_conduit_bridge_fsm_data                       (fsm_d),
	
	.tristate_conduit_bridge_ext_flash_tcm_read_n_out       (flash_oen), 
   .tristate_conduit_bridge_ext_flash_tcm_write_n_out      (flash_wen),      
   .tristate_conduit_bridge_ext_flash_tcm_chipselect_n_out (flash_cen),  
	
   .tristate_conduit_bridge_ssram_tcm_outputenable_n_out   (ssram_oen),
   .tristate_conduit_bridge_ssram_tcm_byteenable_n_out     (ssram_bwn),    
   .tristate_conduit_bridge_ssram_tcm_chipselect_n_out     (ssram_cen),                        
   .tristate_conduit_bridge_ssram_tcm_write_n_out          (ssram_wen),  

   .ssram_clock_clk     											  (ssram_clk),

   .enet_pll_reset_reset                               	  (!cpu_resetn),
   .enet_pll_locked_export                             	  (locked_from_the_enet_pll),
   
   .ena_10_from_the_tse_mac                            	  (ena_10_from_the_tse_mac),
   .eth_mode_from_the_tse_mac                          	  (eth_mode_from_the_tse_mac),
   .mdc_from_the_tse_mac                               	  (enet_mdc),
   .mdio_in_to_the_tse_mac                             	  (enet_mdio),
   .mdio_oen_from_the_tse_mac                          	  (mdio_oen_from_the_tse_mac),
   .mdio_out_from_the_tse_mac                          	  (mdio_out_from_the_tse_mac),
   .rgmii_in_to_the_tse_mac                            	  (enet_rx_d),
   .rgmii_out_from_the_tse_mac                         	  (enet_tx_d),
   .rx_clk_to_the_tse_mac                              	  (enet_rx_clk),
   .rx_control_to_the_tse_mac                          	  (enet_rx_dv),
   .set_1000_to_the_tse_mac                            	  (),
   .set_10_to_the_tse_mac                              	  (),
   .tx_clk_to_the_tse_mac                              	  (tx_clk_to_the_tse_mac),
   .tx_control_from_the_tse_mac                       	  (enet_tx_en)
);

endmodule




   