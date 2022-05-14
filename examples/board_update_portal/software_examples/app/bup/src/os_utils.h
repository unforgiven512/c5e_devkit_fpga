#ifndef __OS_UTILS_H__
#define __OS_UTILS_H__


#include <stdio.h>
#include "alt_types.h"
#include "includes.h"


#define   SHOW_TASK_STACK_USAGE 0

/* Definition of Task Stack size. */
//#define   INITIAL_TASK_STACKSIZE       1024
//#define   NETMAN_TASK_STACKSIZE        1024
//#define   LCD_TASK_STACKSIZE           512
//#define   HTTP_TASK_STACKSIZE          4096
//#define   LED_TASK_STACKSIZE           512

#define   INITIAL_TASK_STACKSIZE       2048
#define   NETMAN_TASK_STACKSIZE        2048
#define   LCD_TASK_STACKSIZE           1024
#define   HTTP_TASK_STACKSIZE          8192
#define   LED_TASK_STACKSIZE           1024

//#define   INITIAL_TASK_STACKSIZE       4096
//#define   NETMAN_TASK_STACKSIZE        4096
//#define   LCD_TASK_STACKSIZE           2048
//#define   HTTP_TASK_STACKSIZE          16384
//#define   LED_TASK_STACKSIZE           2048


/*
 * Task priorities
 *
 * MicroC/OS-II only allows one task (thread) per priority number. Our web
 * SERVER task is given a high priority (lower only than timers which must run
 * when they need to) so that we can focus on pushing data *out* of the system.
 * An ethernet CLIENT application would have lower prioritization than the
 * stack & ethernet tasks.
 */
#define INITIAL_TASK_PRIO 0
#define LED_PRIO         16
#define LCD_PRIO         15
#define NETMAN_PRIO      10
#define HTTP_PRIO        11


/* EXPANDED_DIAGNOSIS_CODE value of 255 is equivalent to -1
 * (after casting to INT8S) for functions that return -1 as an error_code
 * to indicate errno has been set.
 */

#define EXPANDED_DIAGNOSIS_CODE 255

typedef enum FAULT_LEVEL_ENUM FAULT_LEVEL;
enum FAULT_LEVEL_ENUM {NONE, TASK, SYSTEM};


void PrintfTask( void* pdata );
int OSPrintf( const char * format, ... );
int printf( const char * format, ... );
int fprintf( FILE* stream, const char * format, ... );
void alt_uCOSIIErrorHandler( INT8U error_code,
                             void *expanded_diagnosis_ptr);

#endif /* __OS_UTILS_H__ */

