/****************************************************************************
 * Copyright © 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved. All use of this software and documentation is        *
 * subject to the License Agreement located at the end of this file below.   *
 ****************************************************************************/

/*
 * Here we give names to some registers to 
 * make the boot code a bit more readable
 */

// The zero register is always 0x0
#define zero                      r0

// These variables used for reading the flash
#define flash_ptr                 r2
#define boot_record_length        r3
#define boot_record_dest_addr     r4

// These are general purpose variables
#define byte_count                r5
#define counter                   r6
#define expected_value            r7
#define temp_data                 r8
#define debug_temp                r9
#define last_dest_address         r10
#define flash_base                r11

// These can be used to write to the LEDs for debugging
#define led_addr                  r12
#define led_value                 r13

// These are our subroutine-calling variables
#define return_value              r14
#define return_address_less_4     r15
#define return_address            r16

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
