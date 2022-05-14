## LPDDR2_TOP timing constraints
#source lpddr2_top_phy_ddr_timing.sdc

derive_pll_clocks

#create_clock -name {altera_reserved_tck} -period 20.800 -waveform { 0.000 10.400 } [get_ports { altera_reserved_tck }]
# For USB2
create_clock -period "40.000 ns" -name {altera_reserved_tck} {altera_reserved_tck}

set_input_delay -clock altera_reserved_tck 5 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck 5 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall -max 5 [get_ports altera_reserved_tdo]

## External clocks
create_clock -name {clkintop_125_p} -period 8.00 [ get_ports clkintop_125_p]
create_clock -name {clkintop_50} -period 20.000 -waveform {0 10} {clkintop_50}
set_false_path -from * -to [get_clocks {clkintop_50}]
set_false_path -from [get_clocks {clkintop_50}] -to *
set_false_path -from * -to [get_ports {user_led_g[*]}]


######################
# new 
######################

create_clock -name {data1_38} -period 6.6 -waveform {0 3.3} {q_sys:u0|q_sys_mSGDMA_0:msgdma_0|altera_avalon_st_pipeline_stage:agent_pipeline_006|altera_avalon_st_pipeline_base:core|data1[38]}

set_clock_groups -exclusive -group { data1_38 } -group { u0|pll_0|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk }
set_false_path -to {*|frequency_counter*|pls_1sec_int1}
set_false_path -to {*|frequency_counter*|csr_readdata*}

#create_generated_clock -name slow_clk -source {*|pll_afi_clk} -divide_by 32 {*|master_driver_msgdma_0|slow_clk_int[4]}
create_generated_clock -name slow_clk -source {clkintop_50}  -divide_by 32 {*|master_driver_msgdma_0|slow_clk_int[4]}

#set_false_path -from [get_clocks {clkintop_50}] -to [get_clocks {u0|pll_0|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}]
#set_false_path -from [get_clocks {u0|pll_0|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] -to  [get_clocks {clkintop_50}]

set_false_path -from [get_clocks {data1_38}] -to  *
set_false_path -from * -to  [get_clocks {data1_38}]
set_false_path -from * -to [get_clocks {slow_clk}]
set_false_path -from [get_clocks {slow_clk}] -to  *

set_false_path -from {cpu_resetn} -to *

set_false_path -from [get_clocks {u0|pll_0|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {u0|mem_if_lpddr2_emif_0|pll0|pll_write_clk}]
set_false_path -from [get_clocks {u0|mem_if_lpddr2_emif_0|pll0|pll_write_clk}] -to [get_clocks {u0|pll_0|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path -from [get_clocks {u0|mem_if_lpddr2_emif_0|pll0|pll_afi_clk}] -to [get_clocks {u0|pll_0|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]