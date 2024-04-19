#!/bin/bash

# Give me one ping, Vasily. One ping only.
if [ $# != 1 ]; then
    echo -e "Usage: $0 <hostname>\n"
    exit 1
fi

# Run as root
if [ "$EUID" -ne 0 ]; then
    sudo "$(readlink -f $0)" "$@"
    exit
fi

hostnamectl hostname $1
