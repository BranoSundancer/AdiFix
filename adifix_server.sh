#!/bin/bash
. $1
while true ; do socat udp4-recvfrom:$ADIFIX_LISTEN,fork EXEC:"./adifix_send.sh $1" ; done
