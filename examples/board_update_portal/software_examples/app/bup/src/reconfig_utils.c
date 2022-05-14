/*****************************************************************************
 *  File: app_selector.c
 *
 *  This file contains functions for performing general tasks associated
 *  with the application selector.
 *
 ****************************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <sys/alt_alarm.h>
#include <string.h>
#include "includes.h"
#include "os_utils.h"
#include "webserver.h"
#include "sys/alt_cache.h"
#include "sys/alt_flash.h"
#include "sys/alt_flash_dev.h"
#include "system.h"
#include "alt_types.h"
#include "io.h"
#include "reconfig_utils.h"
#include "altera_avalon_pio_regs.h"
#include "srec/srec.h"

// Flash semaphore
extern OS_EVENT *FlashSem;


void InitializePFLOptionBits( unsigned int option_bit_offset ) // touch the PFL Option Register
{
  unsigned int* option_bits_buffer;
  unsigned int page_start, page_end;

#if USE_HAL_FLASH_DRIVER
  alt_flash_fd* flash_fd;

  flash_fd = alt_flash_open_dev( EXT_FLASH_NAME );
#endif

    option_bits_buffer = malloc( 256 ); // create PFI buffer
    if( option_bits_buffer != NULL )
    {
      memset( option_bits_buffer, 0xFF, 256 ); // initialize PFL buffer

      // Factory image
      page_start =  FACTORY_HW_IMAGE_OFFSET; // page_start=0x20000

      page_end = page_start + BYTES_FOR_HW_IMAGE; // 0x20000+0x60A78F=0x62A78F

      option_bits_buffer[FACTORY_HW_IMAGE_PAGE] = ( page_end << 4 ) | ( page_start >> 12 );

      // User image
      page_start =  USER_HW_IMAGE_OFFSET; // 0x00630000

      page_end = page_start + BYTES_FOR_HW_IMAGE; // 0x00630000+0x60A78F = 0xC3A78F

      option_bits_buffer[USER_HW_IMAGE_PAGE] = ( page_end << 4 ) | ( page_start >> 12 );


#ifdef DEBUG_MODE
    printf("DEBUG: touched PFL Option Bits\n");
#endif

      // The byte following the 128-byte option bit section must be 0x3
      // These values indicate the "version" of file image being used
//      option_bits_buffer[32] = 0xFFFFFF02;  // version 2 : old for SIII and SIVGX
    option_bits_buffer[32] = 0xFFFFFF03;  // version 3 : NEW for AIIGX, SIVE, and CIIILS Pofs


    if( memcmp( option_bits_buffer, (void*)(EXT_FLASH_BASE + option_bit_offset), 256 ))
      {
#if USE_HAL_FLASH_DRIVER
        alt_erase_flash_block( flash_fd, option_bit_offset, FLASH_SECTOR_SIZE );
        alt_write_flash_block( flash_fd, option_bit_offset, option_bit_offset, (void*)option_bits_buffer, 256 );
#elif USE_INTEL_P30_FLASH_DRIVER
      flash_intel_p30_erase( EXT_FLASH_BASE, option_bit_offset, FLASH_BOOT_BLOCK_SECTOR_SIZE );
      flash_intel_p30_write( EXT_FLASH_BASE, option_bit_offset, (void*)option_bits_buffer, 256/2 );
#endif

#ifdef DEBUG_MODE
  printf( "DEBUG: Init PFL: Prog Flash b=0x%X, o=0x%X\n", EXT_FLASH_BASE, option_bit_offset );
#endif
      }

      free( option_bits_buffer );
    }
#if USE_HAL_FLASH_DRIVER
    alt_flash_close_dev( flash_fd );
#endif
}

/*****************************************************************************
 *  Function: ReconfigFPGA16DIRECT
 *
 *  Purpose: Uses the alt_remote_update megafunction to recongigure the FPGA
 *           from the byte-offset in flash, "hw_flash_offset"
 *
 *  Returns: 0 ( but never exits since it reconfigures the FPGA )
 *
 * note:ReconfigFPGA(hw_flash_page = 1); gets called by webserver to reconfigure
 *
 ****************************************************************************/
int ReconfigFPGA( unsigned int hw_flash_page )
{

  unsigned int reconfig_reg;
  volatile int i, led = 0xff; // 16 bit data MaxII still uses 32 bit macro

#ifdef DEBUG_MODE
	    printf( "DEBUG: Initializiing PFL Option Bits: InitializePFLOptionBits() \n" );
	    // which i don't believe to be the problem,
	    //i think we are somehow screwing up the flash file when programming it
#endif
 		InitializePFLOptionBits( PFL_OPTION_BIT_OFFSET ); // suspicious!! man_debug

  while( 1 )
  {
/*
	      printf("\nMAXII_REG0-3 offset: IORD_32DIRECT(MAXII_INTERFACE_BASE, MAXII_REG0-3)\n");
	      printf("\nMAXII_REG0 index: %d:\t0x%x ", MAXII_REG0, IORD_32DIRECT(MAXII_INTERFACE_BASE, MAXII_REG0) );
	      printf("\nMAXII_REG1 index: %d:\t0x%x ", MAXII_REG1, IORD_32DIRECT(MAXII_INTERFACE_BASE, MAXII_REG1) );
	      printf("\nMAXII_REG2 index: %d:\t0x%x ", MAXII_REG2, IORD_32DIRECT(MAXII_INTERFACE_BASE, MAXII_REG2) );
	      printf("\nMAXII_REG3 index: %d:\t0x%x ", MAXII_REG3, IORD_32DIRECT(MAXII_INTERFACE_BASE, MAXII_REG3) );
*/

/* turn off for demo; no RSU
    reconfig_reg = IORD_32DIRECT( MAXII_INTERFACE_BASE, MAXII_RSU_REG );

    // Clear the page select register bits
    reconfig_reg &= MAXII_CLEAR_PSR_MASK;

    // Clear the reset select bit so that we reconfigure from the
    // PSR (page select register), not the PSS (page select switch)
    reconfig_reg &= MAXII_CLEAR_PSO_MASK;
*/
    // Now set the page selection register
//    reconfig_reg |= ( hw_flash_page << 6 ); // set PSR bit of 16

/* turn off for sunday demo; no RSU

//ReconfigFPGA(hw_flash_page = 1); gets called by webserver to reconfigure
//hw_flash_page << 6 =  = 0x800000, so reconfig_reg = reconfig_reg | 0x800000

//    IOWR_32DIRECT( MAXII_INTERFACE_BASE, 0x8, reconfig_reg  );
    IOWR_32DIRECT( MAXII_INTERFACE_BASE, MAXII_RSU_REG, reconfig_reg  );

    // Now reconfigure the fpga
    reconfig_reg |= MAXII_FORCE_RECONFIG_MASK;

//    IOWR_32DIRECT( MAXII_INTERFACE_BASE, 0x8, reconfig_reg  );
    IOWR_16DIRECT( MAXII_INTERFACE_BASE, MAXII_RSU_REG, reconfig_reg  );
*/

// flash leds instead of reconfiguring:
    IOWR_ALTERA_AVALON_PIO_DATA(LED_PIO_BASE, ~led);

    i = 0;
    while (i<1000000)  i++;

  }

  // should never get here.
  while( 1 );

  return( 0 );
}
