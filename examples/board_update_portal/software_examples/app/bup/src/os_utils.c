
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "includes.h"
#include "os_utils.h"

int global_show_stack_usage = SHOW_TASK_STACK_USAGE;

OS_EVENT *OSPrintfSem;

int printf( const char * format, ... )
{
  OS_SEM_DATA semdata;
  INT8U err;
  char* string;
  int length;
  int ret_code;
  
  // If the OSPrintfSem semaphore has not yet been initialized, 
  // wait until it has before we proceed.
  while( OSSemQuery( OSPrintfSem, &semdata ) != OS_NO_ERR )
  {
    OSTimeDlyHMSM( 0, 0, 0, 10 );
  }
    
  // Grab the printf semaphore before we try any printing.
  OSSemPend( OSPrintfSem, 0, &err );
    if( err == OS_NO_ERR )
    {
    string = malloc( 256 );
    va_list ap;
  
  va_start( ap ,format );
    ret_code = vsprintf( string, format, ap );
  va_end( ap );
  
    length = strlen( string );
    fwrite ( string, 1, length, stdout );
    free( string );

    err = OSSemPost( OSPrintfSem );
  }
  
  if( err == OS_NO_ERR )
  {
    return( ret_code );
  }
  else
  {
    return( -1 );
  }
}


int fprintf( FILE* stream, const char * format, ... )
{
  va_list ap;
  va_start( ap ,format );
  char* string;
  int ret_code;
  
  string = malloc( 256 );
    
  ret_code = vsprintf( string, format, ap );
  ret_code = printf( "%s", string );
  
  free( string );

  return( ret_code );
}


void alt_uCOSIIErrorHandler(INT8U error_code, void *expanded_diagnosis_ptr)
{
   FAULT_LEVEL fault_level;
   
   if(error_code == OS_NO_ERR)
   {
      return;
   }
   
   fault_level = SYSTEM;  
   OSSchedLock();  /* Disable Task Switching but still service other IRQs */
      
   switch (error_code)
   {  
      case OS_PRIO_EXIST:
         fprintf(stderr, "Attempted to assign task priority aready in use.\n");
         break;
      case OS_PRIO_INVALID:
         fprintf(stderr, "Specified task priority higher than allowed max.\n");
         fprintf(stderr, "Task can't be assigned a priority higher than %d\n",
            OS_LOWEST_PRIO);
         break;
      case OS_NO_MORE_TCB:
         fprintf(stderr, "Task Control Blocks have been exhausted\n");
         fprintf(stderr, "Current max number of tasks is %d\n",OS_MAX_TASKS);
         break;
      case OS_MBOX_FULL:
         fault_level = NONE;
         fprintf(stderr, "Attempted Post to Mailbox already holding message\n");
         break;
      case OS_ERR_EVENT_TYPE:
         fault_level = TASK;
         fprintf(stderr, 
"Attempted to access a resource with no match for the required data type.\n");
         break;
      case OS_ERR_PEVENT_NULL:
         fprintf(stderr, "Attempting to access a resource pointing to NULL\n");
         break;
      case OS_ERR_POST_NULL_PTR:
         fault_level = TASK;
         fprintf(stderr, "Attempted to Post a NULL to a resource. \n");
         break;
      case OS_TIMEOUT:
         fault_level = NONE;
         fprintf(stderr, "Resource not received in specified time\n");
         break;
      case OS_ERR_PEND_ISR:
         fprintf(stderr, "Attempting to pend for a resource in an ISR\n");
         break;
      case OS_TASK_DEL_IDLE:
         fprintf(stderr, "Attempted to delete the IDLE task\n");
         break;
      case OS_TASK_DEL_ERR:
         fault_level = NONE;
         fprintf(stderr, "Attempted to delete a task that does not exist\n");
         break;
      case OS_TASK_DEL_ISR:
         fprintf(stderr, "Attempted to delete a task from an ISR\n");
         break;
      case OS_Q_FULL:
         fault_level = NONE;
         fprintf(stderr, "Attempted to post to a full message queue\n");
         break;
      case OS_ERR_NOT_MUTEX_OWNER:
         fault_level = TASK;
         fprintf(stderr, "Attempted to post a mutex not owned by the task\n");
         break;
      case EXPANDED_DIAGNOSIS_CODE:      
         fault_level = SYSTEM;
         printf(
"\n[MicroC/OS-II]: See STDERR for expanded diagnosis translation.");    
         fprintf(stderr, "\n[MicroC/OS-II]: Expanded Diagnosis: %s.", 
                 (char *)expanded_diagnosis_ptr);
         break;           
      default:
         printf("\n[MicroC/OS-II]: (Not a MicroC/OS-II error) See STDERR.\n");    
         fprintf(stderr, "\n[MicroC/OS-II]:");
         fprintf(stderr, "\nError_code %d.\n", error_code);
         perror("\n[MicroC/OS-II]: (Not a MicroC/OS-II error), ERRNO: ");
         break;

   }

   /* Process the error based on the fault level, 
    * reenable scheduler if appropriate. */  
   switch (fault_level) {
      case TASK:
         /* Error can be isolated by killing the task */
         printf("\n[MicroC/OS-II]: See STDERR (FAULT_LEVEL is TASK).");
         fprintf(stderr, "\n[MicroC/OS-II]: FAULT_LEVEL is TASK");
         fprintf(stderr, "\n[MicroC/OS-II]: Task is being deleted.\n");
         OSSchedUnlock(); /* Reenable Task Switching */
         OSTaskDel(OS_PRIO_SELF);
         /* Reinvoke uCOSII error handler in case task deletion fails, in 
          * which case fault_level for this secondary error will be SYSTEM. */
         alt_uCOSIIErrorHandler(error_code, 0);         
         break;
      case SYSTEM:
         /* Total System Failure, Restart Required */
         printf("\n[MicroC/OS-II]: See STDERR (FAULT_LEVEL is SYSTEM).");    
         fprintf(stderr, "\n[MicroC/OS-II]: FAULT_LEVEL is SYSTEM");
         fprintf(stderr, "\n[MicroC/OS-II]: FATAL Error, Restart required.");
         fprintf(stderr, "\n[MicroC/OS-II]: Locking scheduler - endless loop.\n");
         while(1); /* Since scheduler is locked,loop halts all task activity.*/
         break;
      case NONE:
         fprintf(stderr, "\n[MicroC/OS-II]: FAULT_LEVEL is NONE");
         fprintf(stderr, "\n[MicroC/OS-II]: Informational error only, control"); 
         fprintf(stderr, 
            "returned to task to complete processing at application level.\n");
         OSSchedUnlock(); /* Reenable Task Switching */
         return;   
         break;      
      default:
         printf("\n[MicroC/OS-II]: See STDERR (FAULT_LEVEL is Unknown).\n");
         fprintf(stderr, "\n[MicroC/OS-II]: FAULT_LEVEL is unknown!?!\n");
   }
   while(1); /* Correct Program Flow never gets here. */
}

