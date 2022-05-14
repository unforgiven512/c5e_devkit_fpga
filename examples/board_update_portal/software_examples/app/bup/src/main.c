/*****************************************************************************
 *  File: main.c
 *
 *  This file is the top level of the application selector.
 *
 ****************************************************************************/
#include <stdio.h>
#include <unistd.h>
#include "io.h"
#include "reconfig_utils.h"

// to help debug
#ifdef DEBUG_MODE
  #include "errno.h"
#endif

// UCOS-II definitions
#include "includes.h"
#include "os_utils.h"

// Nichestack definitions
#include "ipport.h"
#include "libport.h"
#include "osport.h"
#include "tcpport.h"
#include "net.h"
#include "webserver.h"

// Si Xing Says... rgmii mode config for marvell phy
#include "system.h"
#include "altera_avalon_tse.h"
#include "altera_avalon_tse_system_info.h"

alt_tse_system_info tse_mac_device[MAXNETS] = {
            TSE_SYSTEM_EXT_MEM_NO_SHARED_FIFO(TSE_MAC, 0, SGDMA_TX, SGDMA_RX, TSE_PHY_AUTO_ADDRESS, &marvell_cfg_rgmii, DESCRIPTOR_MEMORY)

};
// cuz Si Xing Says so

// Task Stacks
OS_STK led_task_stk[LED_TASK_STACKSIZE];
OS_STK lcd_task_stk[LCD_TASK_STACKSIZE];

// Message Boxes
OS_EVENT* WebserverStatusMbox;
extern char ws_msg_string[256];

// printf semaphore.
extern  OS_EVENT *OSPrintfSem;

// Network init.
extern void NETInit();

void LedTask( void* pdata )
{
  char led_value = 0;

#ifdef DEBUG_MODE
printf( "DEBUG: LEDTask \n" );
#endif

  while (1)
  {
    // Flip the led
    led_value ^= 0x1;

    // Now display it.
    IOWR( LED_PIO_BASE, 0, led_value );

    // Wait 1/4 second
    OSTimeDlyHMSM( 0, 0, 0, 250 );
  }
}

void LCDTask( void* pdata )
{
  FILE* lcd_dev;
  char* web_server_status;
  INT8U err;
  OS_MBOX_DATA mbox_data;
  int length;

  // Wait until we're sure the message box has been created.
  while( OSMboxQuery( WebserverStatusMbox, &mbox_data ) != OS_NO_ERR );

  while( 1 )
  {
    web_server_status = OSMboxPend( WebserverStatusMbox, 0, &err );
    lcd_dev = fopen( "/dev/lcd", "w" );

#ifdef DEBUG_MODE
        printf( "DEBUG: LCDTask \n" );
    if (lcd_dev == NULL)                            // added test to see if lcd_dev failed to open
        printf( "DEBUG: ERRNO: %s \n", strerror(errno) ); //just to see if no error is returned
#endif

    length = strlen( web_server_status );
    fwrite( web_server_status, 1, length, lcd_dev );
    fclose( lcd_dev );
  }

}



/*****************************************************************************
 *  Function: InitialTask
 *
 *  Purpose: InitialTask will initialize the NichStack TCP/IP stack and
 *           then initialize the rest of the tasks.
 *
 *  Returns: void
 ****************************************************************************/
void InitialTask( void* pdata )
{

#ifdef DEBUG_MODE
        printf( "DEBUG: InitialTask0 \n" );
#endif

  INT8U return_code = OS_NO_ERR;

#ifdef UPDATE_PFL
  // Before we do anything, make sure the PFL option bits are initialized correctly.
  // Only update if required, else rely on factory file pfl_bits.flash for correct
  // PFL register values
 InitializePFLOptionBits( PFL_OPTION_BIT_OFFSET );

#endif

   #ifdef DEBUG_MODE
         printf( "DEBUG: no update to InitializePFLOptionBits\n" );
#endif


  // Initialize the Web Server Status message box.
  WebserverStatusMbox = OSMboxCreate((void *)0);

  // Initialize the printf semaphore
  OSPrintfSem = OSSemCreate( 1 );

/*****************************************************************************
 *  Create the system tasks.
 ****************************************************************************/

  return_code = OSTaskCreateExt( LCDTask,
                                 NULL,
                                 (void *)&lcd_task_stk[LCD_TASK_STACKSIZE],
                                 LCD_PRIO,
                                 LCD_PRIO,
                                 lcd_task_stk,
                                 LCD_TASK_STACKSIZE,
                                 NULL,
                                 OS_TASK_OPT_STK_CHK + OS_TASK_OPT_STK_CLR );
  alt_uCOSIIErrorHandler( return_code, 0 );

  return_code = OSTaskCreateExt( LedTask,
                                 NULL,
                                 (void *)&led_task_stk[LED_TASK_STACKSIZE],
                                 LED_PRIO,
                                 LED_PRIO,
                                 led_task_stk,
                                 LED_TASK_STACKSIZE,
                                 NULL,
                                 OS_TASK_OPT_STK_CHK + OS_TASK_OPT_STK_CLR );
  alt_uCOSIIErrorHandler( return_code, 0 );

#ifdef DEBUG_MODE
        printf( "DEBUG: InitialTask alt_uCOSIIErrorHandler \n" );
#endif

  sprintf( ws_msg_string, "Not Connected\n\n" );
  while( OSMboxPost( WebserverStatusMbox, &ws_msg_string ) != OS_NO_ERR );

  // Initialize the Network.
  NETInit();
  // This task deletes itself, since there's no reason to keep it around, once
  // it's complete.
  return_code = OSTaskDel( OS_PRIO_SELF );
  alt_uCOSIIErrorHandler( return_code, 0 );


  while(1); // Correct Program Flow should not reach here.
}


int main()
{

  INT8U return_code;

  #ifdef DEBUG_MODE

        printf( "DEBUG: RUNNING IN PRINTF DEBUG MODE! \n" );
        printf( "DEBUG: main \n" );

#endif


  OS_STK InitialTaskStk[INITIAL_TASK_STACKSIZE];

  /* Clear the RTOS timer */
  OSTimeSet(0);


  /* InitialTask will initialize the NicheStack TCP/IP Stack and then
   * initialize the rest of the web server's tasks.
   */

  return_code = OSTaskCreateExt( InitialTask,
                                 NULL,
                                 (void *)&InitialTaskStk[INITIAL_TASK_STACKSIZE],
                                 INITIAL_TASK_PRIO,
                                 INITIAL_TASK_PRIO,
                                 InitialTaskStk,
                                 INITIAL_TASK_STACKSIZE,
                                 NULL,
                                 0 );
  alt_uCOSIIErrorHandler( return_code, 0 );

  /*
   * As with all MicroC/OS-II designs, once the initial thread(s) and
   * associated RTOS resources are declared, we start the RTOS. That's it!
   */
  OSStart();

  while(1); /* Correct Program Flow never gets here. */

  return ( 0 );
}

