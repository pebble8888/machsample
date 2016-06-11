//
//  simple_ipc_server.cpp
//
//  Copyright © 2016年 pebble8888. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "simple_ipc_common.h"
#include <Foundation/Foundation.h>

int main(int argc, char **argv)
{
    kern_return_t kr;
    msg_format_recv_t recv_msg;
    msg_format_send_t send_msg;
    mach_msg_header_t *recv_hdr, *send_hdr;
    mach_port_t       server_port; // メッセージのローカルポート
    
    kr = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &server_port);
    EXIT_ON_MACH_ERROR("mach_port_allocate", kr, KERN_SUCCESS);
    
    kr = bootstrap_register(bootstrap_port, (char*)SERVICE_NAME, server_port);
    EXIT_ON_MACH_ERROR("bootstrap_register", kr, BOOTSTRAP_SUCCESS);
    
    NSLog(@"servier_port = %d\n", server_port);
    
    for (;;){
        // process message and prepare reply
        send_hdr = &(send_msg.header);
        send_hdr->msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_MAKE_SEND);
        // MACH_MSGH_BITS_LOCAL(recv_hdr->msgh_bits);
        send_hdr->msgh_size = sizeof(send_msg);
        send_hdr->msgh_local_port = server_port; //MACH_PORT_NULL;
        send_hdr->msgh_remote_port = MACH_PORT_NULL; //recv_hdr->msgh_remote_port;
        send_hdr->msgh_id = DEFAULT_MSG_ID; // recv_hdr->msgh_id;
        send_msg.data = 4; // 4!の計算を依頼  factorial(recv_msg.data);
        
        // send message
        kr = mach_msg(send_hdr,
                      MACH_SEND_MSG,
                      send_hdr->msgh_size,
                      0,
                      MACH_PORT_NULL,
                      MACH_MSG_TIMEOUT_NONE,
                      MACH_PORT_NULL);
        EXIT_ON_MACH_ERROR("mach_msg(send)", kr, MACH_MSG_SUCCESS);
        
        NSLog(@"reply sent\n");
        // receive message
        recv_hdr = &(recv_msg.header);
        recv_hdr->msgh_local_port = server_port;
        recv_hdr->msgh_size = sizeof(recv_msg);
        kr = mach_msg(recv_hdr,
                      MACH_RCV_MSG|MACH_RCV_TIMEOUT,
                      0,
                      recv_hdr->msgh_size,
                      server_port,
                      //MACH_MSG_TIMEOUT_NONE,
                      3000, // msec
                      MACH_PORT_NULL);
        if (kr == MACH_RCV_TIMED_OUT){
            NSLog(@".\n");
            continue;
        }
        EXIT_ON_MACH_ERROR("mach_msg(recv)", kr, MACH_MSG_SUCCESS);
        
        NSLog(@"recv data = %d, id = %d, local_port = %d, remote_port = %d\n",
               recv_msg.data, recv_hdr->msgh_id,
               recv_hdr->msgh_local_port, recv_hdr->msgh_remote_port);
        
    }
    
    exit(0);
}