#!/bin/bash
#
# usage: ./restore.sh
#

echo " 
 ***********************************************************
 ******* Board Update Portal - Factory Flash Restore *******
 ***********************************************************

 This script will restore flash using nios2-flash-programmer 
 as specified in the User's Guide, chapter entitled: 
 "Restoring the Flash Device with the Factory Settings"

 Warning: Running the restore.sh script will restore
 all of the flash memory files on your board except for
 the ethernet mac address which must be created and entered 
 at the nios2-terminal upon first-run of the restored software.

 For proper restore to work, the FPGA should be configured  
 as described in the User's Guide chapter entitled: 
 \"Restoring the Flash Device with the Factory Settings\"
 
 Please consult the User Guide for instructions before proceeding!
 
 Once flash is restored to factory and the board has been 
 reconfigured as instructed, run the Nios II shell command 
 "nios2-terminal". The user is instructed (one-time only) 
 to generate a new mac address and factory behavior is resumed.
 
 To continue restoring, Press the \"c\" key then Press \"Enter\"
 
 Press any other key to safely quit and exit > "

read input

if   [ "$input" = "c" ]; then

	echo " 
nios2-flash-programmer -b 0x0 restore_c5efa7_fpga_bup.flash
	"
nios2-flash-programmer -b 0x0 restore_c5efa7_fpga_bup.flash

	echo " 
	Note: the board FPGA should be configured as described 
	 in the User's Guide, chapter entitled: 
	 \"Restoring the Flash Device with the Factory Settings\"
	"
	echo "Done.
	"
	exit 1;

elif [ "$input" = "C" ]; then

	echo " 
nios2-flash-programmer -b 0x0 restore_c5efa7_fpga_bup.flash
	"
nios2-flash-programmer -b 0x0 restore_c5efa7_fpga_bup.flash

	echo " 
	Note: the board FPGA should be configured as described 
	 in the User's Guide, chapter entitled: 
	 \"Restoring the Flash Device with the Factory Settings\"
	"
	echo "Done.
	"
	exit 1;

else 
	echo "Quiting and Exiting...
	"
	exit 1;
fi
