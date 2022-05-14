post_message -type info "Entering c5efa7_bts_general.sdc"

source src/checkQuartusVersion.sdc
source src/commentOutSDCFile.sdc

checkQuartusVersion "Version 12.1 Build 243 01/31/2013 SJ Full Version"
commentOutSDCFile "c5efa7_bts_general_qsys/synthesis/submodules/c5efa7_bts_general_qsys_tse_mac_constraints.sdc"

#
# Start by getting all of the PLL related clocks declared
#
derive_pll_clocks -create_base_clocks

#
# these are the input clocks to the FPGA
#
set altera_reserved_tck { altera_reserved_tck }
create_clock -period 20.00 -name clkin_50  [ get_ports clkin_50  ]
create_clock -period 20.00 -name ssram_clk [ get_ports ssram_clk  ]

#
# some clock uncertainty is required
#
derive_clock_uncertainty

# Create false paths between clock domains that are not fully constrained by the IP that makes these paths.
# Ideally we should not have to do this, however, these paths must be cut to meet timing and in most cases
# the IP should be accounting for synchronization between these paths.
# The risk of a global cut like these is that if the IP is not synchronizing properly between the two domains
# then you have significant problems with the design.  Ideally the IP should synchronize it's clock crossing
# paths and create constraints to cut those paths so we don't have to perform a global cut like this.
#

#
# Create false paths between clock domains that are not fully constrained by the IP that makes these paths.
# Ideally we should not have to do this, however, these paths must be cut to meet timing and in most cases
# the IP should be accounting for synchronization between these paths.
# The risk of a global cut like these is that if the IP is not synchronizing properly between the two domains
# then you have significant problems with the design.  Ideally the IP should synchronize it's clock crossing
# paths and create constraints to cut those paths so we don't have to perform a global cut like this.
#

#
# these are clock crossing paths from our global reset generator which should be cut
#
set_false_path  -from [get_keepers *reset_counter*resetn_out] -to *
set_false_path  -from * -to [get_keepers *bit_synchronizer*p1]
set_false_path  -from [get_ports cpu_resetn] -to *
set_false_path  -from * -to [get_ports flash_resetn]
set_false_path -from {c5efa7_bts_general_qsys_inst|pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to [get_ports {ssram_clk}]

#
# The following constraints are for miscelaneous input and output pins in the
# design that are not constrained elsewhere.
#

# cpu_resetn
set_input_delay   -clock [ get_clocks clkin_50 ] 10  [ get_ports {cpu_resetn} ]

# flash interface
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {fsm_add[*]} ]
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {fsm_data[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {fsm_data[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_csn} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_oen} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_resetn}]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_advn} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {flash_wen} ]

# ssram interface
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {ssram_cen} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {ssram_oen} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {ssram_wen} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {ssram_bwn[*]}]

# max5 interface
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {max5_csn} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {max5_wen} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {max5_rdn} ]

# jtag interface
set_input_delay   -clock [ get_clocks $altera_reserved_tck ] 10 [ get_ports altera_reserved_tms ]
set_input_delay   -clock [ get_clocks $altera_reserved_tck ] 10 [ get_ports altera_reserved_tdi ]
set_output_delay  -clock [ get_clocks $altera_reserved_tck ] 10 [ get_ports altera_reserved_tdo ]

# user pb, dipsw and led
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {user_dispsw[*]} ]
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {user_pbin[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {user_led[*]} ]
set_output_delay  -clock [ get_clocks clkin_50 ] 2   [ get_ports {lcd_*} ]
set_input_delay   -clock [ get_clocks clkin_50 ] 2   [ get_ports {lcd_data[*]} ]

set_false_path -from * -to [get_ports {lcd_*}]
set_false_path -from [get_ports {lcd_data[*]}] -to * 




  
