#!/bin/bash
. $1
./adifix.sh $1 | socat -t 0 - UDP:${ADIFIX_FORWARD}
