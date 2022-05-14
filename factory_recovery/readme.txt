Restoring the Flash Device to the Factory Settings

This section describes how to restore the original factory contents to the flash memory
device on the CycloneV E Development Board. Make sure you have the Nios II EDS installed, and 
perform the following instructions:

1. Set the board switches to the factory default settings described in "Factory Default
Switch Settings" on page 4-2.

2. Launch the Quartus II Programmer to configure the FPGA with a .sof capable of
flash programming. Refer to "Configuring the FPGA Using the Quartus II
Programmer" on page 6-13 for more information.

3. Click Add File and select <install dir>\kits\cycloneVE_5cefa7f31es_fpga\factory_recovery\c5efa7_fpga_bup.sof.

4. Turn on the Program/Configure option for the added file.

5. Click Start to download the selected configuration file to the FPGA. Configuration
is complete when the progress bar reaches 100%. The FACTORY_IMAGE LED (D19)
illuminates, indicating that the flash device is ready for programming.

6. On the Windows Start menu, click All Programs > Altera > Nios II EDS > Nios II
Command Shell.

7. In the Nios II command shell, navigate to the <install
dir>\kits\cycloneVE_5cefa7f31es_fpga\factory_recovery directory and type the
following command to run the restore script:

	./restore.sh <Enter>

Restoring the flash memory might take several minutes. Follow any instructions
that appear in the Nios II command shell.

8. After all flash programming completes, cycle the POWER switch (SW5) off then on to 
load and run the restored factory design.

9. The restore script cannot restore the board’s MAC address automatically. In the
Nios II command shell, type the following Nios II EDS command:

	nios2-terminal <Enter>

and follow the instructions in the terminal window to generate two unique MAC addresses for two Ethernet ports.