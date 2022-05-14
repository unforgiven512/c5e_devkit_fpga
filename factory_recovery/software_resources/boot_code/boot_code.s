/****************************************************************************
 * Copyright © 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved. All use of this software and documentation is        *
 * subject to the License Agreement located at the end of this file below.   *
 ****************************************************************************/
/*****************************************************************************
*  File: small_boot_copier.s
*
*  This is an example of a small-code-size Nios II boot copier implemented 
*  in assembly language.  This program uses only Nios II CPU registers for 
*  data storage, no variables are stored in RAM, making this code completely 
*  relocatable.  
*
*  This boot copier can be build using the accompianing Makefile provided
*  with the example.  To build the boot copier, open a Nios II Command Shell 
*  in this directory and type "make all".  Type "make help" for more 
*  information
*
*  Feel free to customize this boot copier, but do so at your own risk.  This 
*  boot copier can only be supported by Altera in its current, unmodified form
*  
*****************************************************************************/

#include "boot_code.h"

#define LED_ADDR 0x09000060
#define SW_APP_CODE 0x023C0000

// FLASH_BASE and BOOT_IMAGE_OFFSET are passed in through 'make'
#define BOOT_IMAGE_ADDR  ( FLASH_BASE + BOOT_IMAGE_OFFSET )

//  These all might be aliases for our boot copier's 
//  entry point. 

  .global reset
  .global _start
  .global main
  .global end_of_boot_copier


/*****************************************************************************
*  Function: main
*
*  Purpose: This is our boot copier's entry point. This function checks for
*  the presence of a applicatoin boot image in flash memory, copies it to its 
*  execution memory (set in Nios II IDE), then branches to the application's
*  entry point.  It's important to ensure all function calls are only one
*  level deep, since we are using one register to store the return pointer, 
*  not the stack.
*
*****************************************************************************/
reset:
_start:
main:

  // Clear the CPU's status-register, thereby disabling interrupts.
  wrctl   status, zero


  // Flush the instruction cache.
  movhi   counter,%hi(0x10000)
cache_flush_loop:
  initi   counter
  addi    counter, counter,-32
  bne     counter, zero, cache_flush_loop

  // Flush the pipeline
  flushp
  
  // Get our flash base address 
  // movia uses the linker address, not neccessarily the REAL address, 
  // so we'll use a combination of nextpc and movia
  nextpc  temp_data
current_code_offset:  
  movia   counter, current_code_offset
  sub     flash_base, temp_data, counter 

  // Load up the address of the sw application
  movhi   flash_ptr, %hi(SW_APP_CODE)
  ori     flash_ptr, flash_ptr, %lo(SW_APP_CODE)
  add     flash_ptr, flash_ptr, flash_base

  callr   flash_ptr

 // This is where we end up if the application ever returns.
loop_forever:
  br      loop_forever
  
  .end


/*
 * This LED routine can be used for lighting LEDs for debug purposes
 * Since we only support one-level function calls, it's best to just 
 * copy and past this wherever you need it.  You'll also need to 
 * define LED_ADDR as the base address of your LED PIO.
 */
/* 
  // Debugging LED routine
  movhi   led_addr, %hi(LED_ADDR)
  ori     led_addr, led_addr, %lo(LED_ADDR)
  mov    led_value, return_address
  srli    led_value, led_value, 16
  stbio   led_value, 0(led_addr)
stall_loop:
	br stall_loop
*/

// end of file

/******************************************************************************
 *                                                                             *
 * License Agreement                                                           *
 *                                                                             *
 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved.                                                        *
 *                                                                             *
 * Permission is hereby granted, free of charge, to any person obtaining a     *
 * copy of this software and associated documentation files (the "Software"),  *
 * to deal in the Software without restriction, including without limitation   *
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
 * and/or sell copies of the Software, and to permit persons to whom the       *
 * Software is furnished to do so, subject to the following conditions:        *
 *                                                                             *
 * The above copyright notice and this permission notice shall be included in  *
 * all copies or substantial portions of the Software.                         *
 *                                                                             *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
 * DEALINGS IN THE SOFTWARE.                                                   *
 *                                                                             *
 * This agreement shall be governed in all respects by the laws of the State   *
 * of California and by the laws of the United States of America.              *
 * Altera does not recommend, suggest or require that this reference design    *
 * file be used in conjunction or combination with any other product.          *
 ******************************************************************************/
