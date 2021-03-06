# TCL File Generated by Component Editor 12.0
# Tue Jun 05 13:05:30 PDT 2012
# DO NOT MODIFY


# 
# master_driver_msgdma "master_driver_msgdma" v1.0
# null 2012.06.05.13:05:30
# H/W driver to control the DMA
# 

# 
# request TCL package from ACDS 12.0
# 
package require -exact qsys 12.0


# 
# module master_driver_msgdma
# 
set_module_property DESCRIPTION "H/W driver to control the DMA"
set_module_property NAME master_driver_msgdma
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP BoardTestSystem
set_module_property DISPLAY_NAME master_driver_msgdma
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset quartus_synth QUARTUS_SYNTH "" "Quartus Synthesis"
set_fileset_property quartus_synth TOP_LEVEL master_driver_msgdma
set_fileset_property quartus_synth ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file master_driver_msgdma.v VERILOG PATH master_driver_msgdma.v

add_fileset sim_verilog SIM_VERILOG "" "Verilog Simulation"
set_fileset_property sim_verilog TOP_LEVEL master_driver_msgdma
set_fileset_property sim_verilog ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file master_driver_msgdma.v VERILOG PATH master_driver_msgdma.v


# 
# parameters
# 
add_parameter PRBS_PATTERN_GENERATOR_BASE STD_LOGIC_VECTOR 1073741888 "Specify the Qsys address of PRBS Generator"
set_parameter_property PRBS_PATTERN_GENERATOR_BASE DEFAULT_VALUE 1073741888
set_parameter_property PRBS_PATTERN_GENERATOR_BASE DISPLAY_NAME PRBS_PATTERN_GENERATOR_BASE
set_parameter_property PRBS_PATTERN_GENERATOR_BASE WIDTH 32
set_parameter_property PRBS_PATTERN_GENERATOR_BASE TYPE STD_LOGIC_VECTOR
set_parameter_property PRBS_PATTERN_GENERATOR_BASE UNITS None
set_parameter_property PRBS_PATTERN_GENERATOR_BASE ALLOWED_RANGES 0:4294967295
set_parameter_property PRBS_PATTERN_GENERATOR_BASE DESCRIPTION "Specify the Qsys address of PRBS Generator"
set_parameter_property PRBS_PATTERN_GENERATOR_BASE HDL_PARAMETER true


add_parameter PRBS_PATTERN_CHECKER_BASE STD_LOGIC_VECTOR 1073741824 "Specify the Qsys address of PRBS checker"
set_parameter_property PRBS_PATTERN_CHECKER_BASE DEFAULT_VALUE 1073741824
set_parameter_property PRBS_PATTERN_CHECKER_BASE DISPLAY_NAME PRBS_PATTERN_CHECKER_BASE
set_parameter_property PRBS_PATTERN_CHECKER_BASE WIDTH 32
set_parameter_property PRBS_PATTERN_CHECKER_BASE TYPE STD_LOGIC_VECTOR
set_parameter_property PRBS_PATTERN_CHECKER_BASE UNITS None
set_parameter_property PRBS_PATTERN_CHECKER_BASE ALLOWED_RANGES 0:4294967295
set_parameter_property PRBS_PATTERN_CHECKER_BASE DESCRIPTION "Specify the Qsys address of PRBS checker"
set_parameter_property PRBS_PATTERN_CHECKER_BASE HDL_PARAMETER true


add_parameter MEMORY_BASE_ADDRESS STD_LOGIC_VECTOR 0 "Specify the Qsys address of the target memory"
set_parameter_property MEMORY_BASE_ADDRESS DEFAULT_VALUE 0
set_parameter_property MEMORY_BASE_ADDRESS DISPLAY_NAME MEMORY_BASE_ADDRESS
set_parameter_property MEMORY_BASE_ADDRESS WIDTH 32
set_parameter_property MEMORY_BASE_ADDRESS TYPE STD_LOGIC_VECTOR
set_parameter_property MEMORY_BASE_ADDRESS UNITS None
set_parameter_property MEMORY_BASE_ADDRESS ALLOWED_RANGES 0:4294967295
set_parameter_property MEMORY_BASE_ADDRESS DESCRIPTION "Specify the Qsys address of the target memory"
set_parameter_property MEMORY_BASE_ADDRESS HDL_PARAMETER true


add_parameter MEMORY_SPAN STD_LOGIC_VECTOR 536870912 "Specify the size of the target memory in Byte"
set_parameter_property MEMORY_SPAN DEFAULT_VALUE 536870912
set_parameter_property MEMORY_SPAN DISPLAY_NAME MEMORY_SPAN
set_parameter_property MEMORY_SPAN WIDTH 32
set_parameter_property MEMORY_SPAN TYPE STD_LOGIC_VECTOR
set_parameter_property MEMORY_SPAN UNITS None
set_parameter_property MEMORY_SPAN ALLOWED_RANGES 0:4294967295
set_parameter_property MEMORY_SPAN DESCRIPTION "Specify the size of the target memory in Byte"
set_parameter_property MEMORY_SPAN HDL_PARAMETER true


add_parameter BLOCK_SIZE STD_LOGIC_VECTOR 256 "Specify the size of the block to prcess at a time in Byte"
set_parameter_property BLOCK_SIZE DEFAULT_VALUE 256
set_parameter_property BLOCK_SIZE DISPLAY_NAME BLOCK_SIZE
set_parameter_property BLOCK_SIZE WIDTH 32
set_parameter_property BLOCK_SIZE TYPE STD_LOGIC_VECTOR
set_parameter_property BLOCK_SIZE UNITS None
set_parameter_property BLOCK_SIZE ALLOWED_RANGES 0:4294967295
set_parameter_property BLOCK_SIZE DESCRIPTION "Specify the size of the block to prcess at a time in Byte"
set_parameter_property BLOCK_SIZE HDL_PARAMETER true


add_parameter DISPATCHER_WRITE_CSR STD_LOGIC_VECTOR 1073741920 "Specify the Qsys address of dispatcher CSR write"
set_parameter_property DISPATCHER_WRITE_CSR DEFAULT_VALUE 1073741920
set_parameter_property DISPATCHER_WRITE_CSR DISPLAY_NAME DISPATCHER_WRITE_CSR
set_parameter_property DISPATCHER_WRITE_CSR WIDTH 32
set_parameter_property DISPATCHER_WRITE_CSR TYPE STD_LOGIC_VECTOR
set_parameter_property DISPATCHER_WRITE_CSR UNITS None
set_parameter_property DISPATCHER_WRITE_CSR ALLOWED_RANGES 0:4294967295
set_parameter_property DISPATCHER_WRITE_CSR DESCRIPTION "Specify the Qsys address of dispatcher CSR write"
set_parameter_property DISPATCHER_WRITE_CSR HDL_PARAMETER true


add_parameter DISPATCHER_WRITE_DESCRIPTOR STD_LOGIC_VECTOR 1073741984 "Specify the Qsys address of dispatcher descriptor write"
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR DEFAULT_VALUE 1073741984
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR DISPLAY_NAME DISPATCHER_WRITE_DESCRIPTOR
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR WIDTH 32
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR TYPE STD_LOGIC_VECTOR
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR UNITS None
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR ALLOWED_RANGES 0:4294967295
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR DESCRIPTION "Specify the Qsys address of dispatcher descriptor write"
set_parameter_property DISPATCHER_WRITE_DESCRIPTOR HDL_PARAMETER true


add_parameter DISPATCHER_READ_CSR STD_LOGIC_VECTOR 1073741952 "Specify the Qsys address of dispatcher CSR read"
set_parameter_property DISPATCHER_READ_CSR DEFAULT_VALUE 1073741952
set_parameter_property DISPATCHER_READ_CSR DISPLAY_NAME DISPATCHER_READ_CSR
set_parameter_property DISPATCHER_READ_CSR WIDTH 32
set_parameter_property DISPATCHER_READ_CSR TYPE STD_LOGIC_VECTOR
set_parameter_property DISPATCHER_READ_CSR UNITS None
set_parameter_property DISPATCHER_READ_CSR ALLOWED_RANGES 0:4294967295
set_parameter_property DISPATCHER_READ_CSR DESCRIPTION "Specify the Qsys address of dispatcher CSR read"
set_parameter_property DISPATCHER_READ_CSR HDL_PARAMETER true


add_parameter DISPATCHER_READ_DESCRIPTOR STD_LOGIC_VECTOR 1073742000 "Specify the Qsys address of dispatcher descriptor read"
set_parameter_property DISPATCHER_READ_DESCRIPTOR DEFAULT_VALUE 1073742000
set_parameter_property DISPATCHER_READ_DESCRIPTOR DISPLAY_NAME DISPATCHER_READ_DESCRIPTOR
set_parameter_property DISPATCHER_READ_DESCRIPTOR WIDTH 32
set_parameter_property DISPATCHER_READ_DESCRIPTOR TYPE STD_LOGIC_VECTOR
set_parameter_property DISPATCHER_READ_DESCRIPTOR UNITS None
set_parameter_property DISPATCHER_READ_DESCRIPTOR ALLOWED_RANGES 0:4294967295
set_parameter_property DISPATCHER_READ_DESCRIPTOR DESCRIPTION "Specify the Qsys address of dispatcher descriptor read"
set_parameter_property DISPATCHER_READ_DESCRIPTOR HDL_PARAMETER true


add_parameter TIMER_BASE STD_LOGIC_VECTOR 1074270208 "Specify the Qsys address of timer"
set_parameter_property TIMER_BASE DEFAULT_VALUE 1074270208
set_parameter_property TIMER_BASE DISPLAY_NAME TIMER_BASE
set_parameter_property TIMER_BASE WIDTH 32
set_parameter_property TIMER_BASE TYPE STD_LOGIC_VECTOR
set_parameter_property TIMER_BASE UNITS None
set_parameter_property TIMER_BASE ALLOWED_RANGES 0:4294967295
set_parameter_property TIMER_BASE DESCRIPTION "Specify the Qsys address of timer"
set_parameter_property TIMER_BASE HDL_PARAMETER true


add_parameter FREQUENCY_COUNTER_BASE STD_LOGIC_VECTOR 1073742336 "Specify the Qsys address of frequency counter"
set_parameter_property FREQUENCY_COUNTER_BASE DEFAULT_VALUE 1073742336
set_parameter_property FREQUENCY_COUNTER_BASE DISPLAY_NAME FREQUENCY_COUNTER_BASE
set_parameter_property FREQUENCY_COUNTER_BASE WIDTH 32
set_parameter_property FREQUENCY_COUNTER_BASE TYPE STD_LOGIC_VECTOR
set_parameter_property FREQUENCY_COUNTER_BASE UNITS None
set_parameter_property FREQUENCY_COUNTER_BASE ALLOWED_RANGES 0:4294967295
set_parameter_property FREQUENCY_COUNTER_BASE DESCRIPTION "Specify the Qsys address of frequency counter"
set_parameter_property FREQUENCY_COUNTER_BASE HDL_PARAMETER true




add_parameter ENABLE_PER_INFO INTEGER 1 "Enable Performance Information Calclation in HDL" 
set_parameter_property ENABLE_PER_INFO DISPLAY_NAME "Enable Performance Calculation in HDL"
set_parameter_property ENABLE_PER_INFO DISPLAY_HINT boolean
set_parameter_property ENABLE_PER_INFO AFFECTS_GENERATION false
set_parameter_property ENABLE_PER_INFO HDL_PARAMETER true
set_parameter_property ENABLE_PER_INFO DERIVED false
set_parameter_property ENABLE_PER_INFO AFFECTS_ELABORATION true
add_display_item "Performance Calculate Options" ENABLE_PER_INFO parameter


add_parameter LOCAL_DATA_WORDS STD_LOGIC_VECTOR 16 "Specify the Qsys local data width in word"
set_parameter_property LOCAL_DATA_WORDS DEFAULT_VALUE 16
set_parameter_property LOCAL_DATA_WORDS DISPLAY_NAME LOCAL_DATA_WORDS
set_parameter_property LOCAL_DATA_WORDS WIDTH 32
set_parameter_property LOCAL_DATA_WORDS TYPE STD_LOGIC_VECTOR
set_parameter_property LOCAL_DATA_WORDS UNITS None
set_parameter_property LOCAL_DATA_WORDS ALLOWED_RANGES 0:256
set_parameter_property LOCAL_DATA_WORDS DESCRIPTION "local side datawidth in word"
set_parameter_property LOCAL_DATA_WORDS HDL_PARAMETER true
add_display_item "Performance Calculate Options" LOCAL_DATA_WORDS parameter

# 
# display items
# 


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true

add_interface_port reset reset_n reset_n Input 1


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1


# 
# connection point csr
# 
add_interface csr avalon end
set_interface_property csr addressAlignment DYNAMIC
set_interface_property csr addressUnits WORDS
set_interface_property csr associatedClock clock
set_interface_property csr associatedReset reset
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr explicitAddressSpan 0
set_interface_property csr holdTime 0
set_interface_property csr isMemoryDevice false
set_interface_property csr isNonVolatileStorage false
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr printableDevice false
set_interface_property csr readLatency 0
set_interface_property csr readWaitTime 1
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0
set_interface_property csr ENABLED true

add_interface_port csr csr_address address Input 4
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_waitrequest waitrequest Output 1


# 
# connection point interrupt_receiver
# 
add_interface interrupt_receiver interrupt start
set_interface_property interrupt_receiver associatedAddressablePoint avalon_master
set_interface_property interrupt_receiver associatedClock clock
set_interface_property interrupt_receiver associatedReset reset
set_interface_property interrupt_receiver irqScheme INDIVIDUAL_REQUESTS
set_interface_property interrupt_receiver ENABLED true

add_interface_port interrupt_receiver irq irq Input 2


# 
# connection point avalon_master
# 
add_interface avalon_master avalon start
set_interface_property avalon_master addressUnits SYMBOLS
set_interface_property avalon_master associatedClock clock
set_interface_property avalon_master associatedReset reset
set_interface_property avalon_master burstOnBurstBoundariesOnly false
set_interface_property avalon_master doStreamReads false
set_interface_property avalon_master doStreamWrites false
set_interface_property avalon_master linewrapBursts false
set_interface_property avalon_master readLatency 0
set_interface_property avalon_master ENABLED true

add_interface_port avalon_master waitrequest_in waitrequest Input 1
add_interface_port avalon_master csn chipselect_n Output 1
add_interface_port avalon_master wen write_n Output 1
add_interface_port avalon_master oen read_n Output 1
add_interface_port avalon_master be byteenable Output 4
add_interface_port avalon_master address address Output 32
add_interface_port avalon_master data_write writedata Output 32
add_interface_port avalon_master data_read readdata Input 32


# 
# connection point reset_source
# 
add_interface reset_source reset start
set_interface_property reset_source associatedClock clock
set_interface_property reset_source associatedDirectReset ""
set_interface_property reset_source associatedResetSinks ""
set_interface_property reset_source synchronousEdges DEASSERT
set_interface_property reset_source ENABLED true

add_interface_port reset_source reset_out reset Output 1


# 
# connection point conduit_end
# 
add_interface conduit_end conduit end
set_interface_property conduit_end associatedClock clock
set_interface_property conduit_end associatedReset ""
set_interface_property conduit_end ENABLED true

add_interface_port conduit_end error_mon export Output 1
add_interface_port conduit_end status_mon export Output 1

