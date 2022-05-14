post_message -type info "Entering c5efa7_fpga_bup.sdc"

source src/checkQuartusVersion.sdc
source src/commentOutSDCFile.sdc

checkQuartusVersion "Version 12.1 Build 243 01/31/2013 SJ Full Version"
commentOutSDCFile "c5efa7_fpga_bup_qsys/synthesis/submodules/c5efa7_fpga_bup_qsys_tse_mac_constraints.sdc"

#Info: Reading SDC File: 'c5efa7_fpga_bup_qsys/synthesis/submodules/c5efa7_fpga_bup_qsys_tse_mac_constraints.sdc'

#
# Start by getting all of the PLL related clocks declared
#
derive_pll_clocks -create_base_clocks

#
# these are the input clocks to the FPGA
#
set altera_reserved_tck { altera_reserved_tck }
#set clkin_50_fpga       { clkin_50_fpga }
create_clock -period 20.00 -name clkin_50  [ get_ports clkin_50 ]
create_clock -period 20.00 -name ssram_clk [ get_ports ssram_clk]

#
# these are the generated clocks from jtag and plls that we care about
#
#set ddrlo_sysclk_125    { c5efa7_fpga_bup_qsys_inst|ddr2_lo_latency_128m|s5gx100g_fpga_bup_qsys_inst_ddr2_lo_latency_128m_controller_phy_inst|s5gx100g_fpga_bup_qsys_inst_ddr2_lo_latency_128m_phy_inst|s5gx100g_fpga_bup_qsys_inst_ddr2_lo_latency_128m_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1] }
#set ddrlo_auxhalf_62p5  { c5efa7_fpga_bup_qsys_inst|ddr2_lo_latency_128m|s5gx100g_fpga_bup_qsys_inst_ddr2_lo_latency_128m_controller_phy_inst|s5gx100g_fpga_bup_qsys_inst_ddr2_lo_latency_128m_phy_inst|s5gx100g_fpga_bup_qsys_inst_ddr2_lo_latency_128m_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[0] }

set enet_pll_125  { c5efa7_fpga_bup_qsys_inst|enet_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } 
set enet_pll_25   { c5efa7_fpga_bup_qsys_inst|enet_pll|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk }
set enet_pll_2p5  { c5efa7_fpga_bup_qsys_inst|enet_pll|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk }

set enet_reset    { c5efa7_fpga_bup_qsys_inst|enet_pll|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk }
set enet_locked   { c5efa7_fpga_bup_qsys_inst|enet_pll|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk }

set ssram_clk     { c5efa7_fpga_bup_qsys_inst|pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk }
#
# constrain the Ethernet RGMII interface, the order of these source statements is specific
#
source src/rgmii_clocks.sdc
source src/rgmii_input.sdc
source src/rgmii_output.sdc

#
# some clock uncertainty is required
#
derive_clock_uncertainty

#
# Create false paths between clock domains that are not fully constrained by the IP that makes these paths.
# Ideally we should not have to do this, however, these paths must be cut to meet timing and in most cases
# the IP should be accounting for synchronization between these paths.
# The risk of a global cut like these is that if the IP is not synchronizing properly between the two domains
# then you have significant problems with the design.  Ideally the IP should synchronize it's clock crossing
# paths and create constraints to cut those paths so we don't have to perform a global cut like this.
#
set_clock_groups \
    -exclusive \
    -group [get_clocks {tx_clk_125 tx_clk_25 tx_clk_2p5}] \
    -group [get_clocks enet_rx_clk] \
    -group [get_clocks clkin_50] 
#	 -group [get_clocks ssram_clk]
    
#
# these are clock crossing paths from our global reset generator which should be cut
#
set_false_path  -from [get_keepers *reset_counter*resetn_out] -to *
set_false_path  -from * -to [get_keepers *bit_synchronizer*p1]
#set_false_path -from {pll_inst|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to [get_ports {ssram_clk}]
set_false_path -from {c5efa7_fpga_bup_qsys_inst|pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to [get_ports {ssram_clk}]

#
# this is the locked output from the Ethernet PLL in the design, it can be cut
#
#set_false_path -from {c5efa7_fpga_bup_qsys_inst:c5efa7_fpga_bup_qsys_inst|enet_pll:the_enet_pll|count_done} -to *

#
# this is for the IRQ signals that come from the slow peripheral clock domain to the linux cpu
#
#set_false_path  -from * -to [get_keepers *irq_from_sa_clock_crossing_linux_cpu_data_master\|data_in_d1]

#
# These are the constraints out of the TSE MAC SDC file that are relevant to us.
# The TSE MAC SDC file should be commented out by this script.
#
set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*] -to [ get_registers *]
set_multicycle_path -setup 5 -from [ get_registers *] -to [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*]
set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*] -to [ get_registers *]
set_multicycle_path -hold 5 -from [ get_registers *] -to [ get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|altera_tse_retransmit_cntl:U_RETR|*]
set_max_delay 7 -from [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|dout_reg_sft*] -to [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*]
set_max_delay 7 -from [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|eop_sft*] -to [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*]
set_max_delay 7 -from [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_tx_min_ff:U_TXFF|sop_reg*] -to [get_registers *|altera_tse_top_w_fifo:U_MAC|altera_tse_top_1geth:U_GETH|altera_tse_mac_tx:U_TX|*]

#
# The following constraints are for miscelaneous input and output pins in the
# design that are not constrained elsewhere.
#

# cpu_resetn
set_input_delay   -clock [ get_clocks clkin_50 ] 10  [ get_ports {cpu_resetn} ]
#set_input_delay   -clock [ get_clocks clkin_50 ] 10  [ get_ports {max_cpu_resetn} ]
set_false_path -from [get_ports cpu_resetn] -to *
set_false_path -from * -to [get_ports flash_resetn]

# Ethernet MDIO interface
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {enet_mdc} ]
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {enet_mdio} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {enet_mdio} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {enet_resetn} ]

# flash interface
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {fsm_a[*]} ]
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {fsm_d[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {fsm_d[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_cen} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_oen} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_resetn} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_wen} ]

# ssram interface
set_output_delay  -clock [ get_clocks clkin_50]  2   [get_ports {ssram_bwn[*]}]
set_output_delay  -clock [ get_clocks clkin_50]  2   [get_ports {ssram_cen}]
set_output_delay  -clock [ get_clocks clkin_50]  2   [get_ports {ssram_oen}]
set_output_delay  -clock [ get_clocks clkin_50]  2   [get_ports {ssram_wen}]

# jtag interface
set_input_delay   -clock [ get_clocks $altera_reserved_tck ] 10 [ get_ports altera_reserved_tms ]
set_input_delay   -clock [ get_clocks $altera_reserved_tck ] 10 [ get_ports altera_reserved_tdi ]
set_output_delay  -clock [ get_clocks $altera_reserved_tck ] 10 [ get_ports altera_reserved_tdo ]

# user pb, dipsw and led
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {user_pb[*]} ]
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {user_dipsw[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {user_led[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {lcd_*} ]
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {lcd_data[*]} ]

set_false_path -from * -to [get_ports {lcd_*}]
set_false_path -from [get_ports {lcd_data[*]}] -to * 


  
