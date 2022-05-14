// #####################################################################################
// # Copyright (C) 1991-2008 Altera Corporation
// # Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
// # support information,  device programming or simulation file,  and any other
// # associated  documentation or information  provided by  Altera  or a partner
// # under  Altera's   Megafunction   Partnership   Program  may  be  used  only
// # to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
// # other  use  of such  megafunction  design,  netlist,  support  information,
// # device programming or simulation file,  or any other  related documentation
// # or information  is prohibited  for  any  other purpose,  including, but not
// # limited to  modification,  reverse engineering,  de-compiling, or use  with
// # any other  silicon devices,  unless such use is  explicitly  licensed under
// # a separate agreement with  Altera  or a megafunction partner.  Title to the
// # intellectual property,  including patents,  copyrights,  trademarks,  trade
// # secrets,  or maskworks,  embodied in any such megafunction design, netlist,
// # support  information,  device programming or simulation file,  or any other
// # related documentation or information provided by  Altera  or a megafunction
// # partner, remains with Altera, the megafunction partner, or their respective
// # licensors. No other licenses, including any licenses needed under any third
// # party's intellectual property, are provided herein.
// #####################################################################################

// #####################################################################################
// # Loopback module for SOPC system simulation with
// # Altera Triple Speed Ethernet (TSE) Megacore
// #
// # Generated at Wed Feb 13 15:11:47 2013 as a SOPC Builder component
// #
// #####################################################################################
// # This is a module used to provide external loopback on the TSE megacore by supplying
// # necessary clocks and default signal values on the network side interface 
// # (GMII/MII/TBI/Serial)
// #
// #   - by default this module generate clocks for operation in Gigabit mode that is
// #     of 8 ns clock period
// #   - no support for forcing collision detection and carrier sense in MII mode
// #     the mii_col and mii_crs signal always pulled to zero
// #   - you are recomment to set the the MAC operation mode using register access 
// #     rather than directly pulling the control signals
// #
// #####################################################################################
`timescale 1ns / 1ps

module c5efa7_fpga_bup_qsys_tse_mac_loopback (

  rx_clk,
  tx_clk,
  rgmii_out,
  tx_control,
  rgmii_in,
  rx_control,
  set_1000,
  set_10


);


  output rx_clk;
  output tx_clk;
  input [3:0] rgmii_out;
  input tx_control;
  output [3:0] rgmii_in;
  output rx_control;
  output set_1000;
  output set_10;


  reg clk_tmp;
  initial
     clk_tmp <= 1'b0;
  always
     #4 clk_tmp <= ~clk_tmp;
  reg reconfig_clk_tmp;
  initial
     reconfig_clk_tmp <= 1'b0;
  always
     #20 reconfig_clk_tmp <= ~reconfig_clk_tmp;
  reg clk_shift;
  reg start = 1'b0;
  always
     begin
     if(start == 1'b0)
        begin
        clk_shift <= 1'b0;
        #1 start <= 1'b1;
        end
     else
        begin
        #4 clk_shift <= ~clk_shift;
     end
  end

  assign rx_clk = clk_shift;
  assign tx_clk = clk_tmp;
  assign rgmii_in=rgmii_out;
  assign rx_control=tx_control;
  assign set_1000=0;
  assign set_10=0;


endmodule
