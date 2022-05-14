////////////////////////////////////////////////////////////////
// Flash: Intel P30
//
//  Flash write- and erase-routines optimized specifically for Intel P30
//  StrataFlash.   And implemented and tested for only one member of
//  the family, at that.
//
//  If you want to know all about this API, see the large, complete
//  comment atop the accomanying header-file.
//
////////////////////////////////////////////////////////////////

#include <io.h>
#include "flash_intel_p30.h"

//#define FLASH_INTEL_P30_DEBUG 1

#if FLASH_INTEL_P30_DEBUG
#include <stdio.h>
#endif


#define FLASH_CMD_QUERY                    0x98
#define FLASH_CMD_BUFFERED_PROGRAM_SETUP   0xE8
#define FLASH_CMD_BUFFERED_PROGRAM_CONFIRM 0xD0
#define FLASH_CMD_BLOCK_ERASE_SETUP        0x20
#define FLASH_CMD_BLOCK_ERASE_CONFIRM      0xD0
#define FLASH_CMD_BLOCK_LOCK_SETUP         0x60
#define FLASH_CMD_BLOCK_LOCK               0x01
#define FLASH_CMD_BLOCK_UNLOCK             0xD0
#define FLASH_CMD_CLEAR_STATUS             0x50
#define FLASH_CMD_READ_DEVICE_ID           0x90
#define FLASH_CMD_RESTORE_READ_MODE        0xFF

#define FLASH_STATUS_READY_MASK 0x80
#define FLASH_STATUS_ERROR_MASK 0x3B

#define MAX(X,Y) ( ((X)>(Y))  ? (X) : (Y))
#define MIN(X,Y) ( ((X)<(Y))  ? (X) : (Y))


////////////////////////////////////////////////////////////////
// It's handy, and not that hard, to keep some statistics on "how long
// did it take me to program that buffer?" and such.
//
// A structure helps organize the statistics we like to keep about the
// programming-process.
////////////////////////////////////////////////////////////////
typedef struct flash_program_stats_struct
{
  unsigned int max_buffer_retry_count;
  unsigned int min_buffer_retry_count;
  unsigned int cum_buffer_retry_count;

  unsigned int max_program_retry_count;
  unsigned int min_program_retry_count;
  unsigned int cum_program_retry_count;

  unsigned int num_samples;
} flash_program_stats;


////////////////////////////////////////////////////////////////
// flash_program_stats_init
//
// Initialize the programming-statistics structure.
////////////////////////////////////////////////////////////////
static
void flash_program_stats_init (flash_program_stats* fps)
{
  fps->max_buffer_retry_count  = 0;
  fps->min_buffer_retry_count  = 0xFFFFFFFF;
  fps->cum_buffer_retry_count  = 0;

  fps->max_program_retry_count = 0;
  fps->min_program_retry_count = 0xFFFFFFFF;
  fps->cum_program_retry_count = 0;

  fps->num_samples             = 0;
}

////////////////////////////////////////////////////////////////
// flash_program_stats_add_sample
//
// Add the buffer-acquisition- and program-done-polling-counts for the
// last operation.
//
// If you call this after every operation, the structure "keeps score"
// and you can ask for your stats later.
//
////////////////////////////////////////////////////////////////
static
void flash_program_stats_add_sample (flash_program_stats* fps,
				     unsigned int buffer_retry_count,
				     unsigned int program_retry_count)
{
  fps->num_samples++;
  fps->cum_buffer_retry_count  += buffer_retry_count;
  fps->cum_program_retry_count += program_retry_count;

  fps->max_buffer_retry_count  = MAX(buffer_retry_count,
				     fps->max_buffer_retry_count);
  fps->min_buffer_retry_count  = MIN(buffer_retry_count,
				     fps->min_buffer_retry_count);
  fps->max_program_retry_count = MAX(program_retry_count,
				     fps->max_program_retry_count);
  fps->min_program_retry_count = MIN(program_retry_count,
				     fps->min_program_retry_count);
}

////////////////////////////////////////////////////////////////
// flash_program_stats_print
//
// Print-out the score (statistics results), presumably after some
// relatively-large amount of programming activity.
//
////////////////////////////////////////////////////////////////
static
void flash_program_stats_print (flash_program_stats* fps)
{
#if FLASH_INTEL_P30_DEBUG
  printf ("%d commands.  %d average retries, range [%d..%d].\n",
	  fps->num_samples,
	  fps->cum_program_retry_count / fps->num_samples,
	  fps->min_program_retry_count,
	  fps->max_program_retry_count);
#endif
}


////////////////////////////////////////////////////////////////
// flash_init_block_map
//
// This function initializes an array (provided by the caller) with
// the BYTE-offsets of the boundaries of the various blocks.  It
// determines this based on a couple of constants defined in the
// header-file.  See the constants and comments there.
//
////////////////////////////////////////////////////////////////

static
void flash_init_block_map (int base, alt_u32 block_map [MAX_FLASH_BLOCKS])
{
  int boundary_num  = 0;
  alt_u32 offset    = 0;
  unsigned int low_block_size, high_block_size, num_low_blocks, num_high_blocks;

  // Issue a query command
  IOWR_16DIRECT( base, 0, FLASH_CMD_QUERY );
//  num_regions = IORD_8DIRECT( base, 0x58 );

  // Calculate the high and low block sizes from the CFI table data
  low_block_size = (( IORD_8DIRECT( base, 0x60 ) << 8 ) |  IORD_8DIRECT( base, 0x5E )) << 8;
  high_block_size = (( IORD_8DIRECT( base, 0x68 ) << 8 ) |  IORD_8DIRECT( base, 0x66 )) << 8;

  // Calculate the number of high and low blocks from the CFI table data
  num_low_blocks = (( IORD_8DIRECT( base, 0x5C ) << 8 ) |  IORD_8DIRECT( base, 0x5A )) +1;
  num_high_blocks = (( IORD_8DIRECT( base, 0x64 ) << 8 ) |  IORD_8DIRECT( base, 0x62 )) +1;


#ifdef MAN_DEBUG
  printf( "MAN_DEBUG: low_block_size  = %d\n", low_block_size); // man_debug
  printf( "MAN_DEBUG: high_block_size = %d\n", high_block_size); // man_debug
  printf( "MAN_DEBUG: num_low_blocks  = %d\n", num_low_blocks); // man_debug
  printf( "MAN_DEBUG: num_high_blocks = %d\n", num_high_blocks); // man_debug
#endif


  // Pace-off the low blocks:
  for (; boundary_num < num_low_blocks; boundary_num++) {
    block_map [boundary_num] = offset;
    offset += low_block_size;

#ifdef MAN_DEBUG
  printf( "MAN_DEBUG: block_map[%d] = %d\n", block_map[boundary_num], offset); // man_debug
#endif

  }

  // Followed by the high-blocks:
  for (; boundary_num < num_high_blocks; boundary_num++) {
    block_map [boundary_num] = offset;
    offset += high_block_size;

#ifdef MAN_DEBUG
  printf( "MAN_DEBUG: block_map[%d]= %d\n", block_map[boundary_num], offset); // man_debug
#endif

  }

}


////////////////////////////////////////////////////////////////
// flash_find_previous_block_boundary
//
// Given an offset X in the flash, finds the bottom (lowest offset) of
// the block containing X.
//
// This has a (slightly) inefficient implementation, because it
// recreates an entire, private block-map every time you ask the
// question.
//
// In practice, this is no big deal because you're usually only asking
// this question (at most) a few dozen times during a huge erase- or
// program-operation (and usually: more like once).   These operations
// take SECONDS, so the amount of time required to compute a block-map
// a dozen times is negligible.
//
// But you should avoid calling this function in your inner-loop.
//
////////////////////////////////////////////////////////////////
static
alt_u32 flash_find_previous_block_boundary (alt_u32 base, alt_u32 offset)
{
  alt_u32 block_map [MAX_FLASH_BLOCKS];
  int i;

  flash_init_block_map (base, block_map);

  for (i = 1; i < MAX_FLASH_BLOCKS; i++)
    if (block_map [i] > offset)
      break;

  return block_map [i-1];
}

////////////////////////////////////////////////////////////////
// flash_find_next_block_boundary
//
// Given an offset X in the flash, finds the bottom (lowest offset) of
// the NEXT address-sequential block.
//
// Like its brother ..._previous_..., this function computes a private
// block-map every time it's called, so all the same caveats apply.
//
////////////////////////////////////////////////////////////////
static
alt_u32 flash_find_next_block_boundary (alt_u32 base, alt_u32 offset)
{
  alt_u32 block_map [MAX_FLASH_BLOCKS];
  int i;

  flash_init_block_map (base, block_map);

  for (i = 1; i <  MAX_FLASH_BLOCKS; i++)
    if (block_map [i] > offset){

#ifdef MAN_DEBUG
    	printf("block_map [%d] > offset [0x%x]\n", i, offset); // man_debug
#endif
    	break;
    }

#ifdef MAN_DEBUG
    else
    	printf("MAN_DEBUG:block_map [%d] !> offset [0x%x]\n", i, offset); // man_debug
#endif

  return block_map [i];
}

////////////////////////////////////////////////////////////////
// flash_clear_status_register
//
// According to the datasheet, the P30's WSM (write state-machine) can
// only *set* bits in the status register.  So it's probably a good
// idea to *clear* the status-register before you start an operation.
//
////////////////////////////////////////////////////////////////
static
void flash_clear_status_register (alt_u32 base)
{
  IOWR_16DIRECT(base, 0, FLASH_CMD_CLEAR_STATUS);
}

////////////////////////////////////////////////////////////////
// flash_restore_read_mode
//
// Restores the indicated block to "array read" mode.
//
////////////////////////////////////////////////////////////////
static
void flash_restore_read_mode (alt_u32 base, alt_u32 block_offset)
{
  flash_clear_status_register(base);
  IOWR_16DIRECT(base, block_offset, FLASH_CMD_RESTORE_READ_MODE);
}

////////////////////////////////////////////////////////////////
// flash_read_device_id_reg
//
// You can access the "device ID" register by sending a
// command-sequence (or by calling this routine which does it for
// you).  This register contains two bits which tell you about the
// lock-status of the P30.
//
////////////////////////////////////////////////////////////////
static
int flash_read_device_id_reg (alt_u32 base, alt_u32 block_offset)
{
  int result = 0;
  IOWR_16DIRECT(base, block_offset + 4, FLASH_CMD_READ_DEVICE_ID);

  result = IORD_16DIRECT (base, block_offset + 4);

  flash_restore_read_mode (base, block_offset);

  return result;
}

////////////////////////////////////////////////////////////////
// flash_unlock_erase_block
//
// "Unlocks" the erase-block which contains the BYTE-offset "offset."
//
// As-written, this function always assumes the operation was
// successful.  There is some checking we could do if the need ever
// arises.
//
////////////////////////////////////////////////////////////////
static
int flash_unlock_erase_block (alt_u32 base, alt_u32 offset)
{
  alt_u32 block_start_offset = flash_find_previous_block_boundary (base, offset);
  int device_id_reg = 0;

  //printf ("  Unlocking at address %X...", block_start_offset);

  flash_clear_status_register (base);

  IOWR_16DIRECT (base, block_start_offset, FLASH_CMD_BLOCK_LOCK_SETUP);
  IOWR_16DIRECT (base, block_start_offset, FLASH_CMD_BLOCK_UNLOCK);

  device_id_reg = flash_read_device_id_reg (base, block_start_offset);

  //printf ("device-id = %X\n", device_id_reg);

  // We probably want to do more checking here...if we start to have
  // trouble
  return 0;
}

////////////////////////////////////////////////////////////////
// flash_acquire_write_buffer
//
// Before you can use "fast buffered write" mode, you have to request
// (and be granted) access to the P30's internal write buffer.  This
// function requests access, waits until it is granted, and tells you
// whether or not it was successful.
//
// "retry_max" is the maximum number of times you want this to poll
// for the buffer to be ready.  "retry_count" will contain the actual
// number of polling-events performed after the function completes.
//
////////////////////////////////////////////////////////////////
static
int flash_acquire_write_buffer (alt_u32 base,
				alt_u32 offset,
				int* retry_count,
				int  retry_max)
{
  *retry_count = 0;
  do {
    IOWR_16DIRECT (base, offset, FLASH_CMD_BUFFERED_PROGRAM_SETUP);
    alt_u16 status = IORD_16DIRECT (base, offset);

    if (status & FLASH_STATUS_READY_MASK) {
      // Done.  Check for errors.
      if (status & FLASH_STATUS_ERROR_MASK) {
#if FLASH_INTEL_P30_DEBUG
	printf ("Error waiting for buffer ready:  Error %X after %d retrys\n",
		status, *retry_count);
#endif
	return status;
      } else {
	// Done, no error.
	return 0;
      }
    }
  }
  while ((*retry_count)++ < retry_max);

  return -1;
}

////////////////////////////////////////////////////////////////
// flash_fill_write_buffer
//
// Takes "buffer_word_count" number of 16-bit words from "buffer" and
// writes them into the P30's write-buffer, in preparation for
// programming those words at "offset."
//
// This function is just a small chunk of "flash_program_buffer."
//
// You must acquire the buffer before you call this function.
//
////////////////////////////////////////////////////////////////
static
void flash_fill_write_buffer (alt_u32 base,
			      alt_u32 offset,
			      alt_u16* buffer,
			      int  buffer_word_count)
{
  while (buffer_word_count-- > 0) {
    IOWR_16DIRECT (base, offset, *buffer++);
    offset += 2;
  }
}

////////////////////////////////////////////////////////////////
// flash_wait_for_operation_done
//
// When you issue a command to the flash, you read-back the "status"
// register to see if the operation has finished.  Bit 7 of the
// "status" register indicates "done;" other bits indicate various
// kinds of errors.
//
// This function returns zero if successful (operation finished, error-
// free, within the given timeout-interval), and nonzero if there is
// an error.
//
// A timeout results in a negative return value.
//
// If a device-error occurs, the value of the status-register is
// returned.
//
////////////////////////////////////////////////////////////////
static
int flash_wait_for_operation_done (alt_u32 base,
				   alt_u32 offset,
				   int* retry_count,
				   int  retry_max)

{
  *retry_count = 0;
  do {
    alt_u16 status = IORD_16DIRECT (base, offset);

    if (status & FLASH_STATUS_READY_MASK) {
      // Done.  Check for errors.
      if (status & FLASH_STATUS_ERROR_MASK) {
#if FLASH_INTEL_P30_DEBUG
	printf ("Error waiting for operation:  Error %X after %d retrys\n",
		status, *retry_count);
#endif
	return status;
      } else {
	// Done, no error.
	return 0;
      }
    }
  }
  while ((*retry_count)++ < retry_max);

  return -1;
}

////////////////////////////////////////////////////////////////
// flash_program_buffer
//
// Executes ONE complete "fast buffered write" sequence to the flash.
// The result is either:
//
//     * 1..32 words written to the flash successfully, or
//     * an error-code.
//
// It is the caller's responsibility to make sure the region of flash
// at "offset" is erased prior to calling this function.  You may not
// use this function to write more than 32 bytes at a time.
//
// According to the P30 datasheet, this function will run fastest if
// the offset is an even multiple of 32 WORDS (= 64 BYTES).  It is the
// caller's responsibility to keep track of the offset.
//
// You may NOT call this function to program a region which spans a
// block-boundary.  Well: You CAN, but it will result in an error.
//
// Returns zero if successful; negative for timeout; status-register
// value if device error.
//
////////////////////////////////////////////////////////////////
static
int flash_program_buffer (alt_u32 base,
			  alt_u32 offset,
			  alt_u16* buffer,
			  int  buffer_word_count,
			  int* buffer_retry_count,
			  int  buffer_retry_max,
			  int* program_retry_count,
			  int  program_retry_max)
{
  // Get the write-buffer.

  flash_clear_status_register (base);

  int error_code = flash_acquire_write_buffer(base,
					      offset,
					      buffer_retry_count,
					      buffer_retry_max);
  if (error_code  != 0) {
#if FLASH_INTEL_P30_DEBUG
    printf ("Unable to acquire write-buffer (code %X) after %d retries\n",
	    error_code, *buffer_retry_count);
#endif
    return error_code;
  }

  // Write the word-count (minus one, because that's what the intel
  // app-note says clearly; and the spec says very-obtusely:
  IOWR_16DIRECT (base, offset, buffer_word_count-1);
  error_code = IORD_16DIRECT (base, offset);
  if (error_code & FLASH_STATUS_ERROR_MASK) {
#if FLASH_INTEL_P30_DEBUG
    printf ("Error (%X) writing word-count (%d) to flash.\n",
	    error_code, buffer_word_count-1);
#endif
    return error_code;
  }

  //Fill the flash write-buffer with the words:
  flash_fill_write_buffer (base, offset, buffer, buffer_word_count);

  // Write the confirm-command,
  IOWR_16DIRECT (base, offset, FLASH_CMD_BUFFERED_PROGRAM_CONFIRM);

  error_code = flash_wait_for_operation_done (base,
					      offset,
					      program_retry_count,
					      program_retry_max);
  if (error_code != 0) {
#if FLASH_INTEL_P30_DEBUG
    printf ("Error (%X) waiting for programming to finish after %d retries.\n",
	    error_code, *program_retry_count);
#endif
    return error_code;
  }
  return 0;
}

////////////////////////////////////////////////////////////////
// flash_program_within_erase_block
//
// Programs a region of flash.  The region of flash:
//
//     * Must have been previously-erased.
//     * Must all lie within the same erase-block.
//
// This breaks the region into multiple  32-word "buffer-sized" chunks
// and calls flash_program_buffer as many times as it takes.  Care is
// taken to align the buffers on 64-BYTE boundaries for faster
// operation.
//
// Keeps running statistics on the number of polling-loops required to
// run each command.
//
// Returns zero if successful, negative if timeout, status-register
// value if device-error.
//
////////////////////////////////////////////////////////////////
static
int flash_program_within_erase_block (alt_u32 base,
				      alt_u32 offset,
				      alt_u16* buffer,
				      int  word_count,
				      flash_program_stats* fps,
				      int  buffer_retry_max,
				      int  program_retry_max)

{
  int buffer_retry_count = 0;
  int program_retry_count = 0;
  int chunk_size = 0;
  int error_code = 0;

  while (word_count > 0) {
    // Start-off assuming we're going to write a maximum-sized chunk
    chunk_size = 32;

    // Deal with the "odd offset" case.
    if (offset % 64 != 0) {
      // Make this chunk only big-enough to get us to the next multiple of 64.
      int next_even_offset = ((offset / 64) + 1 ) * 64;
      int bytes_to_write   = next_even_offset - offset;

       // We write 16-bit words to the flash...not bytes.
      chunk_size = bytes_to_write / 2;
    }

    // Deal with the "we're at the end" case.
    if (chunk_size > word_count)
      chunk_size = word_count;

    error_code = flash_program_buffer (base,
				       offset,
				       buffer,
				       chunk_size,
				       &buffer_retry_count,
				       buffer_retry_max,
				       &program_retry_count,
				       program_retry_max);

    if (error_code != 0) {
#if FLASH_INTEL_P30_DEBUG
      printf ("Flash programming failed with error-code %X.\n", error_code);
#endif
      return error_code;
    }

    flash_program_stats_add_sample (fps,
				    buffer_retry_count, program_retry_count);


    buffer     += chunk_size;     // Buffer contains 16-bit WORDS.
    offset     += chunk_size* 2;  // Offset given in 8-bit BYTES.
    word_count -= chunk_size;
  }

  flash_restore_read_mode (base, offset);
  return 0;
}

////////////////////////////////////////////////////////////////
// flash_program_across_blocks
//
// Programs "word_count" 16-bit words from "buffer" into the
// contiguous region of flash starting at BYTE-offset "offset."
//
// The region of flash must have been previously erased.
//
// The region of flash can span any number of erase-block boundaries.
//
// This function just calls "flash_program_within_erase_block" for
// every erase-block in the region.
//
////////////////////////////////////////////////////////////////
static
int flash_program_across_blocks (alt_u32 base,
				 alt_u32 offset,
				 alt_u16* buffer,
				 int  word_count,
				 flash_program_stats* fps,
				 int  buffer_retry_max,
				 int  program_retry_max)
{
  int error_code = 0;
  while (word_count > 0) {
    // Figure-out if we're going to run past the next erase-block-boundary
    int chunk_size = word_count;
    int next_block_boundary = flash_find_next_block_boundary (base, offset);

    int words_left_in_block = (next_block_boundary - offset) / 2;
    //printf ("@%X: %d words left in block.\n", offset, words_left_in_block);

    if (words_left_in_block < word_count)
      chunk_size = words_left_in_block;

    // Unlock this erase-block:
    error_code = flash_unlock_erase_block (base, offset);
    if (error_code != 0) {
#if FLASH_INTEL_P30_DEBUG
      printf ("Error %X unlocking flash-block at offset %uX.\n",
	      error_code, offset);
#endif
      return error_code;
    }

    error_code = flash_program_within_erase_block (base,
						   offset,
						   buffer,
						   word_count,
						   fps,
						   buffer_retry_max,
						   program_retry_max);
    if (error_code != 0) {
#if FLASH_INTEL_P30_DEBUG
      printf ("Error %X writing flash-block at offset %X.\n",
	      error_code, offset);
#endif
      return error_code;
    }

    buffer     += chunk_size;     // Buffer contains 16-bit WORDS.
    offset     += chunk_size* 2;  // Offset given in 8-bit BYTES.
    word_count -= chunk_size;
  }
  return 0;
}

////////////////////////////////////////////////////////////////
// flash_intel_p30_write
//
// Public API routine.
//
//   See large comment in the .h-file.
//
// This function just calls "flash_program_across_blocks," but hides
// the whole business about statistics-keeping, and
// automatically-selects default "timeouts" based on constants defined
// in the header-file.
////////////////////////////////////////////////////////////////
int flash_intel_p30_write (alt_u32 base,
			   alt_u32 offset,
			   alt_u16* buffer,
			   int word_count  )
{
  flash_program_stats fps;
  flash_program_stats_init (&fps);

  int error_code = 0;

  error_code = flash_program_across_blocks
    (base,
     offset,
     buffer,
     word_count,
     &fps,
     FLASH_INTEL_P30_BUFFER_READY_POLLING_LIMIT,
     FLASH_INTEL_P30_PROGRAM_DONE_POLLING_LIMIT
     );


  if (error_code == 0) {
#if FLASH_INTEL_P30_DEBUG
    printf ("Programming completed: ");
#endif
    flash_program_stats_print (&fps);
  } else {
#if FLASH_INTEL_P30_DEBUG
    printf ("Programming failed with error-code %X.\n", error_code);
#endif
  }
  return 0;
}


////////////////////////////////////////////////////////////////
// flash_erase_block
//
// Erase the single block of flash which contains the BYTE-offset
// "offset."
//
// Returns zero if successful, negative for timeout, or
// status-register value for device-error.
//
////////////////////////////////////////////////////////////////
static
int flash_erase_block (alt_u32 base,
		       alt_u32 offset,
		       int* retry_count,
		       int  retry_max)
{
  int error_code;

  flash_clear_status_register (base);

  IOWR_16DIRECT (base, offset, FLASH_CMD_BLOCK_ERASE_SETUP);
  IOWR_16DIRECT (base, offset, FLASH_CMD_BLOCK_ERASE_CONFIRM);

  error_code = flash_wait_for_operation_done (base,
					      offset,
					      retry_count,
					      retry_max);
  if (error_code != 0) {
#if FLASH_INTEL_P30_DEBUG
    printf ("Error code %X waiting for erase after %d retries.\n",
	    error_code, *retry_count);
#endif
    return error_code;
  }

  flash_restore_read_mode (base, offset);
  return 0;

}

////////////////////////////////////////////////////////////////
// flash_erase_across_blocks
//
// Erase all of the blocks which intersect with the given range
// (offset + span).  This just calls "flash_erase_block" enough times
// to do the job.
//
////////////////////////////////////////////////////////////////
static
int flash_erase_across_blocks (alt_u32 base,
			       alt_u32 offset,
			       alt_u32 span,
			       flash_program_stats* fps,
			       int erase_retry_max)
{
  int retry_count;
  int error_code;
  alt_u32 end = offset + span;
  int remaining = span;

  while (remaining > 0) {
    error_code = flash_unlock_erase_block (base, offset);
    if (error_code != 0) {
#if FLASH_INTEL_P30_DEBUG
      printf ("Error %X unlocking flash-block at offset %uX.\n",
	      error_code, offset);
#endif
      return error_code;
    }

    error_code = flash_erase_block (base, offset, &retry_count, erase_retry_max);
    if (error_code != 0) {
#if FLASH_INTEL_P30_DEBUG
      printf ("Error %X erasing block at %X.\n", error_code, offset);
#endif
      return error_code;
    }

    flash_program_stats_add_sample (fps, 0, retry_count);

    offset = flash_find_next_block_boundary (base, offset + 1);
    remaining = end - offset;
  }
  return 0;
}

////////////////////////////////////////////////////////////////
// flash_intel_p30_erase
//
// Public API routine.
//
// See large comment in the .h-file.
//
// This function just calls "flash_erase_across_blocks," but hides
// the whole business about statistics-keeping, and
// automatically-selects default "timeouts" based on constants defined
// in the header-file.
//
////////////////////////////////////////////////////////////////
int flash_intel_p30_erase (alt_u32 base,
			   alt_u32 offset,
			   alt_u32 span)
{
  flash_program_stats fps;
  flash_program_stats_init (&fps);

  int error_code = 0;

  error_code = flash_erase_across_blocks
    (base,
     offset,
     span,
     &fps,
     FLASH_INTEL_P30_ERASE_DONE_POLLING_LIMIT
     );

  if (error_code == 0) {
#if FLASH_INTEL_P30_DEBUG
    printf ("Erase completed: ");
#endif
    flash_program_stats_print (&fps);
  } else {
#if FLASH_INTEL_P30_DEBUG
    printf ("Erase failed with error-code %X.\n", error_code);
#endif
  }

  return 0;

}

