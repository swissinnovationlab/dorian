#!/bin/bash

# Two! Two argument! AH-AH-AH-AH!
if [ $# != 2 ]; then
    exit 1
fi

# Run as root
if [ "$EUID" -ne 0 ]; then
    sudo "$(readlink -f $0)" "$@"
    exit
fi

cp -r /home/$1/.local/share/pyzer $2
cp -r /home/$1/.local/share/pyflexen $2
cp -r /home/$1/.local/share/goxmler_app_residential $2

chmod -x $0
