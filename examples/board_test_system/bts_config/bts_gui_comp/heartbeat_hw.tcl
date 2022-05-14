# TCL File Generated by Component Editor 9.1
# Fri Sep 25 14:01:32 PDT 2009
# DO NOT MODIFY


# +-----------------------------------
# | 
# | heartbeat "heartbeat" v1.0
# | null 2009.09.25.14:01:32
# | 
# | 
# | /net/sj-home/sga/keiito/work/s4e/ddr3_dimm_restored/bts_gui_comp/heartbeat.vhd
# | 
# |    ./heartbeat.vhd syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module heartbeat
# | 
set_module_property NAME heartbeat
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP ""
set_module_property DISPLAY_NAME heartbeat
set_module_property TOP_LEVEL_HDL_FILE heartbeat.vhd
set_module_property TOP_LEVEL_HDL_MODULE heartbeat
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file heartbeat.vhd {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_slave_0
# | 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressAlignment DYNAMIC
set_interface_property avalon_slave_0 associatedClock clock_sink
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 explicitAddressSpan 0
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

set_interface_property avalon_slave_0 ASSOCIATED_CLOCK clock_sink
set_interface_property avalon_slave_0 ENABLED true

add_interface_port avalon_slave_0 nios_address address Input 1
add_interface_port avalon_slave_0 nios_chipselect_n chipselect_n Input 1
add_interface_port avalon_slave_0 nios_read_n read_n Input 1
add_interface_port avalon_slave_0 nios_write_n write_n Input 1
add_interface_port avalon_slave_0 nios_writedata writedata Input 32
add_interface_port avalon_slave_0 nios_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_end
# | 
add_interface conduit_end conduit end

set_interface_property conduit_end ENABLED true

add_interface_port conduit_end led export Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_sink
# | 
add_interface clock_sink clock end

set_interface_property clock_sink ENABLED true

add_interface_port clock_sink nios_clk clk Input 1
add_interface_port clock_sink nios_reset_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point interrupt_sender
# | 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint avalon_slave_0

set_interface_property interrupt_sender ASSOCIATED_CLOCK clock_sink
set_interface_property interrupt_sender ENABLED true

add_interface_port interrupt_sender nios_irq irq Output 1
# | 
# +-----------------------------------
