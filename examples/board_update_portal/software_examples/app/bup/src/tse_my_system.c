/*
Solution ID: rd11122009_293
Last Modified: Dec 06, 2009
Product Category: Embedded
Product Area: Software Development
Product Sub-area: Ethernet

Problem

How do I change the Nios II Triple Speed Ethernet MAC drivers to use RGMII settings?
Solution

You will need to update your application and associated BSP to configure the TSE MAC for RGMII.

In your BSP, you will need to add -DTSE_MY_SYSTEM to your defined symbols.
This can be done in Nios® II Software Build Tools for Eclipse by updating the defined symbols in the Nios II BSP Properties page.

For command line, add "--set hal.make.bsp_cflags_defined_symbols -DTSE_MY_SYSTEM" to the list of BSP Arguments when creating your BSP.

In your Application, you will need to create a global structure of type "alt_tse_system_info",
named "tse_mac_device", which descibes your TSE configuration.  This can be a separate source file or included in your application source.
This structure will be read during initialization while configuring the TSE MAC.

Add a C file to your application (i.e. tse_my_system.c) with the following:

*/

/*
  #include "ipport.h"                   // MAXNETS
  #include "system.h"                // component names
  #include "altera_avalon_tse.h"  // phy_cfg_fp, alt_tse_system_info, TSE_PHY_AUTO_ADDRESS
  #include "altera_avalon_tse_system_info.h"  // TSE_SYSTEM_EXT_MEM_NO_SHARED_FIFO

  alt_tse_system_info tse_mac_device[MAXNETS] = {
    //Macro defined in altera_avalon_tse_system_info, should match TSE configuration
    TSE_SYSTEM_EXT_MEM_NO_SHARED_FIFO(
                                              TSE_MAC,                    //tse_name
                                              0,                                 //offset
                                              SGDMA_TX,                  //sgdma_tx_name
                                              SGDMA_RX,                  //sgdma_rx_name
                                              TSE_PHY_AUTO_ADDRESS,      //phy_address
                                              &marvell_cfg_rgmii,        //phy_cfg_fp
                                              DESCRIPTOR_MEMORY)         //desc_mem_name

  };



For PHYs not supported by the TSE software drivers, refer to the Software Programming Interface section of the
Triple Speed Ethernet MegaCore Function User Guide.

*/