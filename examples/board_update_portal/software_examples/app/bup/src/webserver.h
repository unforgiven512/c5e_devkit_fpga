/******************************************************************************
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************
*                                                                             *
* File: webserver.h                                                                *
*                                                                             *
* Headers for our "basic" implementation of HTTP. Please note this is not a   *
* complete implementation only enough for our demo web server.                *
*                                                                             *
* Please refer to file ReadMe.txt for notes on this software example.         *
******************************************************************************/
#ifndef __WEBSERVER_H__
#define __WEBSERVER_H__

#include "alt_types.h"
#include "includes.h"

#define   HTTP_RX_BUF_SIZE      8192  /* Receive buffer size */
#define   HTTP_TX_BUF_SIZE      8192  /* Transmission buffer size */
#define   HTTP_URI_SIZE         8192  /* Max size of a URI *URL) string */
#define   HTTP_KEEP_ALIVE_COUNT 20    /* Max number of files per connection */
#define   HTTP_KEEP_ALIVE_TIME  5000  /* TCP connection keep-alive time (ms) */
#define   HTTP_PORT             80    /* TCP port number to listen on */
#define   HTTP_NUM_CONNECTIONS  6     /* Maximum concurrent HTTP connections */
#define   HTTP_MAX_LINE_SIZE    256   /* The maximum size of any line. */
#define   MAX_CABLE_DOWN        1     /* The maximum time that an ethernet cable can be "down" before sending a disconnect msg. */

#define   HTTP_DEFAULT_DIR        "webserver_html"
#define   HTTP_DEFAULT_FILE       "/index.html"
#define   HTTP_VERSION_STRING     "HTTP/1.1 "
#define   HTTP_OK                 200
#define   HTTP_OK_STRING          "200 OK\r\n"
#define   HTTP_NO_CONTENT_STRING  "204 No Content\r\n"
#define   HTTP_NOT_FOUND          404
#define   HTTP_NOT_FOUND_STRING   "404 Not Found\r\n"
#define   HTTP_NOT_FOUND_FILE     "/not_found.html"
#define   HTTP_CONTENT_TYPE       "Content-Type: "
#define   HTTP_CONTENT_TYPE_HTML  "text/html\r\n"
#define   HTTP_CONTENT_TYPE_TXT   "text/plain\r\n"
#define   HTTP_CONTENT_TYPE_JPG   "image/jpg\r\n"
#define   HTTP_CONTENT_TYPE_GIF   "image/gif\r\n"
#define   HTTP_CONTENT_TYPE_PNG   "image/png\r\n"
#define   HTTP_CONTENT_TYPE_JS    "application/x-javascript\r\n"
#define   HTTP_CONTENT_TYPE_CSS   "text/css\r\n"
#define   HTTP_CONTENT_TYPE_SWF   "application/x-shockwave-flash\r\n"
#define   HTTP_CONTENT_TYPE_ICO   "image/vnd.microsoft.icon\r\n"
#define   HTTP_CONTENT_LENGTH     "Content-Length: "
#define   HTTP_KEEP_ALIVE         "Connection: Keep-Alive\r\n"
#define   HTTP_CLOSE              "Connection: close\r\n"
#define   HTTP_CR_LF              "\r\n"
#define   HTTP_END_OF_HEADER     "\r\n\r\n"
#define   HTTP_CT_SIZE            40
#define   BOUNDARY_SIZE           80
#define   MAXLINE                 256

#define   SREC_UPLOAD_BUF_SIZE    10240

#define   BINARY_UPLOAD_BUF_SIZE  FLASH_SECTOR_SIZE+512
#define   FLASH_WRITE_THRESHOLD   FLASH_SECTOR_SIZE

#define   FILE_TYPE_SREC          0
#define   FILE_TYPE_BINARY        1

typedef struct upload_buf_struct
{
  alt_u8* srec_wr_pos;
  alt_u8* srec_rd_pos;
  alt_u8* srec_buffer;
  alt_u8* bin_wr_pos;
  alt_u8* bin_rd_pos;
  alt_u8* bin_buffer;
} upld_buf;

typedef struct http_socket
{
  enum      { READY, PROCESS, DATA, COMPLETE, RESET, CLOSE } state;
  enum      { UNKNOWN=0, GET, POST } action;
  enum      { COUNTED=0,CHUNKED,UNKNOWN_ENC } rx_encoding;
  int       fd;                          /* Socket descriptor */
  int       close;                       /* Close the connection after we're done? */
  int       content_length;              /* Extracted content length */
  int       content_received;            /* Content we've received on this connection. */
  int       keep_alive_count;            /* No. of files tx'd in single connection */
  int       file_length;                 /* Length of the current file being sent */
  int       data_sent;                   /* Number of bytes already sent */
  int       file_upload;                 /* File upload flag. */
  int       filetype;                    /* file type of the uploaded file */
  FILE*     file_handle;                 /* File handle for file we're sending */
  alt_u32   activity_time;               /* Time of last HTTP activity */
  alt_u8*   rx_rd_pos;                   /* position we've read up to */
  alt_u8*   rx_wr_pos;                   /* position we've written up to */
  alt_u8*   srec_start;                  /* place holder for the start of an SREC buffer. */
  alt_u8*   srec_end;                    /* place holder for the end of an SREC buffer. */
  alt_u8*   rx_buffer;                   /* pointer to global RX buffer */
  alt_u8*   tx_buffer;                   /* pointer to global TX buffer */
  alt_u8    requested_filename[256];     /* name of file being requested by web client */
  alt_u8    upload_filename[256];        /* filename for an uploaded file */
  alt_u8    post_name[256];              /* field name of post currently being processed */
  alt_u8    content_type[HTTP_CT_SIZE];  /* content type for detecting multipart forms. */
  upld_buf* upload_buffer;               /* an upload buffer structure, one for each connection */
  alt_u8    boundary[BOUNDARY_SIZE];     /* Boundary between elements of a multi-part form. */
  alt_u8    uri[HTTP_URI_SIZE];          /* URI buffer */
  alt_u8    version[20];                 /* HTTP version */
  alt_u8    connection[20];              /* HTTP connection */
}http_conn;

void WSTask();

/*
 * Prototypes:
 *    die_with_error() - Kills current task and delivers error message to
 *                       STDERR.
 *
 * dhcp_timeout_task() - Keeps track of whether an IP address has been
 *                       aquired from a DHCP server, or times out and resorts
 *                       to a static IP address.
 *
 *         http_task() - Manages HTTP connections and calls relevant
 *                       subroutines to service HTTP requests.
 */
void die_with_error(char err_msg[]);

struct http_form_data
{
  alt_u8 LED_ON;
  alt_u8 SSD_ON;
  alt_u8 LCD_TEXT[20];
  alt_u8 File_Upload[20];
};

extern FILE* lcdDevice;

struct   tcpstat
{
   u_long   tcps_connattempt;    /* connections initiated */
   u_long   tcps_accepts;        /* connections accepted */
   u_long   tcps_connects;       /* connections established */
   u_long   tcps_drops;          /* connections dropped */
   u_long   tcps_conndrops;      /* embryonic connections dropped */
   u_long   tcps_closed;         /* conn. closed (includes drops) */
   u_long   tcps_segstimed;      /* segs where we tried to get rtt */
   u_long   tcps_rttupdated;     /* times we succeeded */
   u_long   tcps_delack;         /* delayed acks sent */
   u_long   tcps_timeoutdrop;    /* conn. dropped in rxmt timeout */
   u_long   tcps_rexmttimeo;     /* retransmit timeouts */
   u_long   tcps_persisttimeo;   /* persist timeouts */
   u_long   tcps_keeptimeo;      /* keepalive timeouts */
   u_long   tcps_keepprobe;      /* keepalive probes sent */
   u_long   tcps_keepdrops;      /* connections dropped in keepalive */

   u_long   tcps_sndtotal;       /* total packets sent */
   u_long   tcps_sndpack;        /* data packets sent */
   u_long   tcps_sndbyte;        /* data bytes sent */
   u_long   tcps_sndrexmitpack;  /* data packets retransmitted */
   u_long   tcps_sndrexmitbyte;  /* data bytes retransmitted */
   u_long   tcps_sndacks;        /* ack-only packets sent */
   u_long   tcps_sndprobe;       /* window probes sent */
   u_long   tcps_sndurg;         /* packets sent with URG only */
   u_long   tcps_sndwinup;       /* window update-only packets sent */
   u_long   tcps_sndctrl;        /* control (SYN|FIN|RST) packets sent */

   u_long   tcps_rcvtotal;       /* total packets received */
   u_long   tcps_rcvpack;        /* packets received in sequence */
   u_long   tcps_rcvbyte;        /* bytes received in sequence */
   u_long   tcps_rcvbadsum;      /* packets received with ccksum errs */
   u_long   tcps_rcvbadoff;      /* packets received with bad offset */
   u_long   tcps_rcvshort;       /* packets received too short */
   u_long   tcps_rcvduppack;     /* duplicate-only packets received */
   u_long   tcps_rcvdupbyte;     /* duplicate-only bytes received */
   u_long   tcps_rcvpartduppack; /* packets with some duplicate data */
   u_long   tcps_rcvpartdupbyte; /* dup. bytes in part-dup. packets */
   u_long   tcps_rcvoopack;      /* out-of-order packets received */
   u_long   tcps_rcvoobyte;      /* out-of-order bytes received */
   u_long   tcps_rcvpackafterwin;   /* packets with data after window */
   u_long   tcps_rcvbyteafterwin;   /* bytes rcvd after window */
   u_long   tcps_rcvafterclose;  /* packets rcvd after "close" */
   u_long   tcps_rcvwinprobe;    /* rcvd window probe packets */
   u_long   tcps_rcvdupack;      /* rcvd duplicate acks */
   u_long   tcps_rcvacktoomuch;  /* rcvd acks for unsent data */
   u_long   tcps_rcvackpack;     /* rcvd ack packets */
   u_long   tcps_rcvackbyte;     /* bytes acked by rcvd acks */
   u_long   tcps_rcvwinupd;      /* rcvd window update packets */

   u_long   tcps_mcopies;        /* m_copy() actual copies */
   u_long   tcps_mclones;        /* m_copy() clones */
   u_long   tcps_mcopiedbytes;   /* m_copy() # bytes copied */
   u_long   tcps_mclonedbytes;   /* m_copy() # bytes cloned */

   u_long   tcps_oprepends;      /* ip_output() prepends of header to data */
   u_long   tcps_oappends;       /* ip_output() appends of data to header */
   u_long   tcps_ocopies;        /* ip_output() copies */
   u_long   tcps_predack;        /* VJ predicted-header acks */
   u_long   tcps_preddat;        /* VJ predicted-header data packets */
   u_long   tcps_zioacks;        /* acks recvd during zio sends */
#ifdef TCP_SACK
   u_long   tcps_sackconn;       /* connections which negotiated SACK */
   u_long   tcps_sacksent;       /* SACK option headers sent */
   u_long   tcps_sackresend;     /* segs resent because of recv SACKs */
   u_long   tcps_sackrcvd;       /* SACK option headers received */
   u_long   tcps_sackmaxblk;     /* most SACK blocks in a received option field */
#endif /* TCP_SACK */
};

extern struct tcpstat tcpstat;

/*
 * The IP, gateway, and subnet mask address below are used as a last resort if
 * if no network settings can be found, and DHCP (if enabled) fails. You can
 * edit these as a quick-and-dirty way of changing network settings if desired.
 *
 * Default fall-back address:
 *           IP: 192.168.1.234
 *      Gateway: 192.168.1.1
 *  Subnet Mask: 255.255.255.0
 */

#define IPADDR0   0
#define IPADDR1   0
#define IPADDR2   0
#define IPADDR3   0

// static IP ADDR for debugging
//#define IPADDR0   192
//#define IPADDR1   168
//#define IPADDR2   69
//#define IPADDR3   234

#define GWADDR0   0
#define GWADDR1   0
#define GWADDR2   0
#define GWADDR3   0

#define MSKADDR0  0
#define MSKADDR1  0
#define MSKADDR2  0
#define MSKADDR3  0


/*
 * Buffer size for a routine to call if things fail
 */
#define DIE_WITH_ERROR_BUFFER 256

/* Default reconfiguration address for CIII NEEK board.
 *   - Assume "user" application.
 *     NOTE:  This maps to the "UNUSED" section of flash
 *            as defined by the NEEK application selector.
 */

#define RECONFIG_ADDRESS 0xe00000
#define FLASH_DEVICE "ext_flash"


void send_progress( http_conn* conn );


#endif /* __WEBSERVER_H__ */

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
