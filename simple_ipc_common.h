//
//  simple_ipc_common.h
//
//  Copyright © 2016年 pebble8888. All rights reserved.
//

#ifndef simple_ipc_common_h
#define simple_ipc_common_h

#include <mach/mach.h>
#include <servers/bootstrap.h>

#define SERVICE_NAME "com.osxbook.FactorialServer"
#define DEFAULT_MSG_ID 400

#define EXIT_ON_MACH_ERROR(msg, retval, success_retval) \
    if (kr != success_retval) { mach_error(msg ":", kr); exit((retval)); }

typedef struct {
    mach_msg_header_t header;
    int32_t sendval;
    int32_t sendbuf[512];
} msg_format_send_t;

typedef struct {
    mach_msg_header_t  header;
    int32_t recvval;
    int32_t recvbuf[512];
    mach_msg_trailer_t trailer; 
} msg_format_recv_t;

#endif /* simple_ipc_common_h */
