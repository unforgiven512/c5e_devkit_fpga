//+---------------------------------------------------------------------------	
//|	
//| Cyclone V E Development Kit	
//| Dev Kit Readme v12.1.1.0	
//|	
//+---------------------------------------------------------------------------	
	
This readme.txt file accompanies the Cyclone V E Development Kit for	
Production Silicon (I7).	
	
//=============================	
//    System Requirements	
//=============================	
	
Software Requirements	
========================	
Demo applications require the installation of Quartus II v12.1.0 or later and are	
supported on the following operating systems:	
   Windows 7 64-bit Professional Edition	
   Windows XP SP2 64-bit Professional 64 Edition	
	
   	
Hardware Requirements	
========================	
   Pentium III or later for Windows	
   Color display capable of 1024 X 768 pixel resolution	
   One or more of the following I/O ports:	
   -  USB port (if using Windows XP or Windows 7) for 	
	  USB-Blaster(TM), USB-Blaster(TM) II or MasterBlaster(TM)
      communications cables, or APU programming unit	
   -  Ethernet port with DHCP (for Board Update Portal)	
	
//=============================	
//       Release Notes	
//=============================	
	
(1) Documentation, example designs, and other programs or collateral may have known"	
	issues documented in the directories that contain them and have been targeted
    to the Rev B PCB pinouts with a target device 5CEFA7F31C7NES	
	
    For Cyclone V E device errata please visit www.altera.com	
	
(2) Setting MSEL bits to a state not defined in the Chapter 7 Cyclone V Device Handbook 	
	can cause contention and excessive power supply current draw possibly damaging
    the FPGA.  The default setting is Fast-Passive-Parallel (FPP) x16, fast 	
	POR delay, decompression and design security features are disabled. User can
	change the configuration scheme by changing the DIP switch setting on SW1.
	
(3)	Configuration through Board Test System GUI is not supported at this moment. User 
	is advised to use Quartus II programmer to configure the FPGA device.
	
 (4) Configure FPGA using "Use PSS" within the System Info tab of Board Test System GUI is 	
    not working. 	
	
(5) The ClockControl.exe application has the following requirements for 	
    correct operation:	
	a) Use Quartus II 12.1.0 (currently set as $QUARTUS_ROOTDIR)
	b) Only 1 USB Blaster can be connected to your computer.  Run
       jtagconfig at the command line in Windows to see how many JTAG 	
       connections are detected.	
	c) Program the MAX V with the pof file included in this installer
          under examples/max5.	
	d) Set SW4 CLK SEL switch "ON" which should be the default setting.
	
(6)	The PowerMonitor.exe application has the same requirements as (5) above except for
	(5d).

(7) Board Update Portal design example is using Ethernet PHY A.	
	User needs to attach the Ethernet cable from the board RJ45 (J8) to network hub.
 	
