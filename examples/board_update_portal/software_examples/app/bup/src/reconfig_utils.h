/*****************************************************************************
 *  File: reconfig_utils.h
 *
 *  This file contains the constants, structure definitions, and funtion
 *  prototypes for the application selector.
 *
 ****************************************************************************/

#ifndef APP_SELECTOR_H_
#define APP_SELECTOR_H_

#include "sys/alt_flash_dev.h"

//#define DEBUG_MODE 1 // debugging help
//#define MAN_DEBUG 1 // debugging help
//#define UPDATE_PFL 1 // option to keep or update PFL OPTION BITS

#define NUM_VIDEO_FRAMES 2

#define FLASH_SECTOR_SIZE            0x20000  //128KB
#define FLASH_BOOT_BLOCK_SECTOR_SIZE 0x08000  //32KB
#define HW_IMAGE_SIZE                0x6b9943	// 0x0107A78F (pfl erases) so 0x20000-0x0109FFFF before 0x10A0000
#define SECTORS_FOR_HW_IMAGE         ((HW_IMAGE_SIZE / FLASH_SECTOR_SIZE) + 1) // 5C
#define BYTES_FOR_HW_IMAGE           (SECTORS_FOR_HW_IMAGE * FLASH_SECTOR_SIZE)
#define BOARD_ID 					 0x24     // used for board ID in flash (for Cyclone V E 00:07:ED:"24")

/****************************************************************
// CV FPGA Kit
 Section                 Size  Address
 -----------------------------------------------------
 Top boot blocks        128KB  0x03FE0000 - 0x03FFFFFF
 User Software           64MB  0x023C0000 - 0x03FDFFFF
 Factory Software         8MB  0x01BC0000 - 0x023BFFFF
 zipfs (html content)     8MB  0x017C0000 - 0x01BBFFFF
 User Hardware 2         33MB  0x00FE0000 - 0x017BFFFF
 User Hardware 1         33MB  0x00800000 - 0x00FDFFFF
 Factory Hardware        33MB  0x00020000 - 0x007FFFFF
 ----------------------------------------------------
 PFL Option Bits         32KB  0x00018000 - 0x0001FFFF
 Board Info              16KB  0x00010000 - 0x00017FFF
 Ethernet Option Bits 2  32KB  0x0000C000 - 0x000 FFFF
 Ethernet Option Bits 1  32KB  0x00004000 - 0x0000BFFF
 User Reset Vector       16KB  0x00000000 - 0x00007FFF

****************************************************************/

#define FACTORY_HW_IMAGE_PAGE        0
#define FACTORY_HW_IMAGE_OFFSET      0x00020000
#define FACTORY_SW_IMAGE_OFFSET      0x01BC0000

// correct user #defines
#define USER_HW_IMAGE_PAGE           1
#define USER_HW_IMAGE_OFFSET         0x00800000
#define USER_SW_IMAGE_OFFSET         0x023C0000


#define RO_ZIPFS_OFFSET              0x017C0000
#define ETHERNET_OPTION_BITS_2       0x0000C000
#define ETHERNET_OPTION_BITS         0x00004000
#define PFL_OPTION_BIT_OFFSET        0x00018000

#define SREC_BUFFER_SIZE             0x00020000

// These are the SIVGX SI 16bit masks for the MAXII reconfiguation 16bit registers:
#define MAXII_CLEAR_PSR_MASK         0xFFFE // 1111 1111 1111 1110 | 0
#define MAXII_CLEAR_PSO_MASK         0xFFFD // 1111 1111 1111 1101 | 1
#define MAXII_FORCE_RECONFIG_MASK    0x000B // 0000 0000 0000 1011 | B
#define MAXII_CLEAR_PSS_MASK         0xFFF7 // 1111 1111 1111 0111 | 3

//#define MAXII_RSU_REG				0x6 // was 0x8
#define MAXII_RSU_REG  0x8 			// MAXII_REG2 is 0x8

#define PAGE_USER				1	// NIOS_PIO_PAGE_SELECT_BASE
#define SRST					0	// NIOS_PIO_RECONFIGURE_N_BASE

#define USE_HAL_FLASH_DRIVER            0
#define USE_INTEL_P30_FLASH_DRIVER      1

// Error Codes
#define SUCCESS                      0
#define FAILURE                     -1
#define ERROR_FAT_FAILED_TO_MOUNT   -2
#define ERROR_FAT_COULD_NOT_FIND    -3
#define ERROR_FAT_READ_ZERO_BYTES   -4
#define ERROR_SREC_HAS_NO_TIMESTAMP -5
#define ERROR_COULD_NOT_ALLOCATE    -6

// Filetypes
#define FLASH                        1
#define RBF                          2

#define FILE_BUFFER_SIZE FLASH_SECTOR_SIZE

int ReconfigFPGA( unsigned int hw_flash_page );
void InitializePFLOptionBits( unsigned int option_bit_offset );

#endif /*APP_SELECTOR_H_*/
