#ifndef __FLASH_INTEL_P30_H_DEFINED__
#define __FLASH_INTEL_P30_H_DEFINED__

////////////////////////////////////////////////////////////////
// Flash: Intel P30
//
//  Flash write- and erase-routines optimized specifically for Intel P30
//  StrataFlash.   And implemented and tested for only one member of
//  the family, at that.
//
//  If you just want generic, safe flash-management routines:  Boy,
//  are you looking in the wrong place.  You probably want to use the CFI
//  flash routines built-right-in to HAL.  The HAL routines are safe,
//  tested, and flexible.  They'll work with virtually-any CFI flash,
//  no hassle.
//
//  These routines are designed to work ONLY with the Intel-brand
//  P30-family StrataFlash devices.  These have been implemented and
//  tested specifically for only one member of this family:
//
//     Intel XXXXXXX
//
//       * 128Mbit (16MByte) capacity
//       * 16-bit-wide data
//       * "Bottom Boot" configuration
//
// It's relatively-straightforward for *you* to change some constants
// to make this work with other members of the P30 family...but that
// (and any other use of this code) is at your own risk and on your
// own recognizance.
//
// So...why would you want to use this code?
//
// Because it's FAST, that's why.  The write-routines here use the
// P30's "fast buffered write" mode, which is 20x faster (!) than the
// safe "one-word-at-a-time" mode which the HAL routines wisely use
// (because the HAL routines will work with *any* CFI flash, not just
// the P30).
//
// So: If you've got an Intel XXXXX P30 flash, and you want to write
// data to it in a hurry:  You've come to the right place.
//
// Significantly:  Erasing isn't any faster than normal.  Only
// writing.
//
//
// ----THE API
//
// There are only two functions in the public API:
//
//     flash_intel_p30_erase()         // Erase a region of flash.
//                                     //   May span any number of erase-blocks
//
//     flash_intel_p30_write()         // Write a buffer-full of data
//                                     //   to flash.  May span any
//                                     //   number of erase-blocks.
//
// That's all.  You don't have to "open" your flash-device, or
// initialize it, or anything else.  the only things you can do are
// (a) erase, and (b) write.
//
// You are responsible for erasing a region of flash before you try
// writing to it.  If you try to write to unerased flash, the
// write-routine will fail with an error code.
//
// Both routines return 0 to mean "success," and nonzero for failure.
//
// -----TWEAKS
//
// DEBUGGING
//
// If you compile this module with the preprocessor-symbol:
//
//     FLASH_INTEL_P30_DEBUG
//
// defined, then it will print-out interesting statistics when things
// go right, and semi-informative failure messages when things go
// wrong.
//
//
// OTHER P30 FAMILY MEMBERS
//
// A handful of contstants (right here!) define the
// device-characteristics.
//
// If you want to make this code work with another member of the P30
// family, you need to:
//
//      1) Change the NUM_128K_BLOCKS parameter to agree with the
//         number of full, 128KByte blocks present in your intel P30
//         device.
//
//      2) Choose the BOTTOM_BOOT_BLOCK parameter to agree with your
//         device.  "1" means that the smaller, 32-KByte blocks appear
//         at numerically-low offsets in flash address-space ("the
//         bottom"),  and "0" means the smaller, 32-KByte blocks
//         appear at numerically-high offsets ("the top").
//
//      3) (Maybe) change NUM_32K_BLOCKS to agree with the number of
//         small, 32KByte blocks in your device.  But I think every
//         member of the P30 family has four of these blocks, so
//         you'll probably never change this parameter.
//
//      4) Test it out, and good luck with that.  No guarantees from me.
//
//
//
// TIMING and TIMEOUTS
//
// This code uses a very loosey-goosey timeout scheme.  The program
// just polls the ready-status of the P30 after every erase- or write-
// operation, and gives-up after a certain number of tries (returning
// with an error, of course).
//
// The P30 will complete its operation within some range of wall-clock
// time, according (more-or-less) to the datasheet.  But the number of
// samples we can take in that time depends on lots of stuff:  How
// fast is your Nios running?  How is it connected to the flash?  Is
// anyone else using the flash?  Did you compile your code with
// "-O3?", etc., etc.
//
// Happily: The timeouts don't really matter that much.  But they have
// to be here to keep your program from just going-out-to-lunch and
// never coming back if, for example, the flash isn't even connected.
//
// To balance these requirements (Value doesn't matter; Just prevent
// lock-up), very, very long timeout values are used by default.
// These werre "long" compared to the reasonable amount of time
// required by a 100MHz Nios to program flash.  You can change them if
// you want...but you'll probably never have to.  I just don't want
// you to think that their values were carefully-chosen, or that
// anything-much depends on them.
//
////////////////////////////////////////////////////////////////
#include <alt_types.h>

#define MAX_FLASH_BLOCKS ( 1023 + 4 )

// Arbitrary "timeout" values.
#define FLASH_INTEL_P30_BUFFER_READY_POLLING_LIMIT 1000000
#define FLASH_INTEL_P30_PROGRAM_DONE_POLLING_LIMIT 1000000
#define FLASH_INTEL_P30_ERASE_DONE_POLLING_LIMIT   100000000


////////////////////////////////////////////////////////////////
// flash_intel_p30_write
//
//  Write data, contained in a buffer, to a contiguous region of intel
//  P30 flash.
//
//  The parameters are:
//
//  * base          The (byte-)base-address of the flash memory, just
//                  like you'd find defined as a symbol in your
//                  "system.h" file.
//
//  * offset        The BYTE offset (BYTE! offset) of the first
//                  location in the P30 flash you want programmed.
//                  The offset is relative to the base-address of the flash.
//                  Zero-offset means: the first location in the
//                  flash-device will be programmed, regardless of
//                  where the flash is located in the system memory
//                  space.
//
//                  The offset must be an even number (you cannot
//                  write flash starting at an odd byte address).
//
//
//  * buffer        A pointer to the first word in a buffer of 16-bit
//                  "words" (a "word" for this flash-device is 16
//                  bits).   There must be at least word_count valid
//                  16-bit values in this buffer--because: whatever's
//                  there in memory...it's all gonna get written to
//                  flash.
//
//  * word_count    The number of 16-BIT WORDS that you want written
//                  to flash.  Notice that the starting-offset is
//                  given as a BYTE-address offset, but the size of
//                  the payload-buffer is given in 16-BIT WORDS.  This
//                  may be inconsistent and confusing, but you can't
//                  say I haven't been clear about it.
//
//  The destination-region of flash may span any number of
//  erase-blocks.
//
//  The destination-region of flash must already be erased when you
//  call this function...otherwise you will almost certainly get an
//  error.  This function does not attempt to erase the flash before
//  programming.
//
//  This routine DOES unlock every block it tries to write.
//
////////////////////////////////////////////////////////////////

int flash_intel_p30_write (alt_u32 base,
			   alt_u32 offset,
			   alt_u16* buffer,
			   int word_count  );

////////////////////////////////////////////////////////////////
// flash_intel_p30_erase
//
//  Erase all the blocks in an Intel P30 flash which include the
//  specified region.
//
//  Note that if the specified region doesn't start or end on a
//  block-boundary, then a larger, enclosing region of flash will
//  actually be erased (rounded to the next-encompasing block-boundary
//  in either direction).
//
//  The parameters are:
//
//  * base          The (byte-)base-address of the flash memory, just
//                  like you'd find defined as a symbol in your
//                  "system.h" file.
//
//  * offset        The BYTE offset (BYTE! offset) of the lowest
//                  address in the specified region. The entire block
//                  containing this location will be erased.
//                  The offset is relative to the base-address of the flash.
//                  Zero-offset means: the first location in the
//                  flash-device will be erased, regardless of
//                  where the flash is located in the system memory
//                  space.
//
//  * span          The BYTE offset (BYTE! offset) which describes the
//                  total BYTE-address span of the region to be
//                  erased.  The block containing the location
//                  "offset+span" will be erased--along with all preceding
//                  blocks all the way down to "offset."
//
//  This routine DOES unlock every block it tries to erase.
//
////////////////////////////////////////////////////////////////
int flash_intel_p30_erase (alt_u32 base,
			   alt_u32 offset,
			   alt_u32 span);


#endif //__FLASH_INTEL_P30_H_DEFINED__
