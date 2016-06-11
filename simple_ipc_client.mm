//
//  simple_ipc_client.cpp
//
//  Copyright © 2016年 pebble8888. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "simple_ipc_common.h"
#include <Foundation/Foundation.h>

int factorial(int n)
{
    if (n < 1)
        return 1;
    else
        return n * factorial(n-1);
}

int main(int argc, char **argv) {
    kern_return_t kr;
    msg_format_recv_t recv_msg;
    msg_format_send_t send_msg;
    mach_msg_header_t *recv_hdr, *send_hdr;
    mach_port_t client_port, server_port;
    
    kr = bootstrap_look_up(bootstrap_port, SERVICE_NAME, &server_port);
    EXIT_ON_MACH_ERROR("bootstrap_look_up", kr, BOOTSTRAP_SUCCESS);
    
    kr = mach_port_allocate(mach_task_self(),
                            MACH_PORT_RIGHT_RECEIVE,
                            &client_port);
    EXIT_ON_MACH_ERROR("mach_port_allocate", kr, KERN_SUCCESS);
    
    NSLog(@"client_port = %d, servier_port = %d\n", client_port, server_port);
    
    /*
    // prepare request
    send_hdr = &(send_msg.header);
    send_hdr->msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_MAKE_SEND);
    send_hdr->msgh_size = sizeof(send_msg);
    send_hdr->msgh_remote_port = server_port; // 送信先ポート
    send_hdr->msgh_local_port = client_port;  // 送信元ポート
    send_hdr->msgh_reserved = 0;
    send_hdr->msgh_id = DEFAULT_MSG_ID;
    send_msg.data = 0;
    
    if (argc == 2)
        send_msg.data = atoi(argv[1]);
    if ((send_msg.data < 1) || (send_msg.data > 20))
        send_msg.data = 4;
     */
    
    for(;;) {
        // receive
        recv_hdr = &(recv_msg.header);
        recv_hdr->msgh_remote_port = server_port;
        recv_hdr->msgh_local_port = client_port;
        recv_hdr->msgh_size = sizeof(recv_msg);
        
        kr = mach_msg(recv_hdr,
                      MACH_RCV_MSG,
                      0,
                      recv_hdr->msgh_size,
                      client_port,
                      MACH_MSG_TIMEOUT_NONE,
                      MACH_PORT_NULL);
        EXIT_ON_MACH_ERROR("mach_msg(recv)", kr, MACH_MSG_SUCCESS);
        NSLog(@"%d\n", recv_msg.data);
        
        send_hdr = &send_msg.header);
        send_hdr->msgh_bits = MACH_MSGH_BITS_LOCAL(recv_hdr->msgh_bits); 
        //MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND,MACH_MSG_TYPE_MAKE_SEND)
        send_hdr->msgh_size = sizeof(send_msg);
        send_hdr->msgh_remote_port = recv_hdr->msgh_remote_port; //server_port; // 送信先ポート
        send_hdr->msgh_local_port = client_port;  // 送信元ポート
        send_hdr->msgh_reserved = 0;
        send_hdr->msgh_id = recv_hdr->msgh_id; // DEFAULT_MSG_ID;
        send_msg.data = factorial(recv_msg.data); //4;
        
        // send request
        kr = mach_msg(send_hdr,
                      MACH_SEND_MSG,
                      send_hdr->msgh_size,
                      0,
                      MACH_PORT_NULL,
                      MACH_MSG_TIMEOUT_NONE,
                      MACH_PORT_NULL);
        EXIT_ON_MACH_ERROR("mach_msg(send)", kr, MACH_MSG_SUCCESS);
    }
   
    exit(0);
}
