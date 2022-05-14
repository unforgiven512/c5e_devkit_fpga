# TCL File Generated by Component Editor 9.0
# Wed May 06 13:35:48 PDT 2009
# DO NOT MODIFY


# +-----------------------------------
# | 
# | product_info "product_info" v1.0
# | null 2009.05.06.13:35:48
# | 
# | 
# | C:/kei/bup/stratixIVGX_4sgx230es_dev_bup/product_info.vhd
# | 
# |    ./product_info.vhd syn, sim
# | 
# +-----------------------------------


# +-----------------------------------
# | module product_info
# | 
set_module_property NAME product_info
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP BoardTestSystem
set_module_property DISPLAY_NAME product_info
set_module_property LIBRARIES {ieee.std_logic_1164.all ieee.std_logic_arith.all ieee.std_logic_unsigned.all std.standard.all}
set_module_property TOP_LEVEL_HDL_FILE product_info.vhd
set_module_property TOP_LEVEL_HDL_MODULE product_info
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file product_info.vhd {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_slave_0
# | 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressAlignment DYNAMIC
set_interface_property avalon_slave_0 bridgesToMaster ""
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 isMemoryDevice false
set_interface_property avalon_slave_0 isNonVolatileStorage false
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 printableDevice false
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0

set_interface_property avalon_slave_0 ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_slave_0 ENABLED true

add_interface_port avalon_slave_0 chipselect_n chipselect_n Input 1
add_interface_port avalon_slave_0 read_n read_n Input 1
add_interface_port avalon_slave_0 av_data_read readdata Output 32
add_interface_port avalon_slave_0 av_address address Input 2
# | 
# +-----------------------------------
