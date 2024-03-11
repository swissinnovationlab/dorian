#!/bin/bash

# No arguments from you!
if [ $# != 0 ]; then
    exit 1
fi

# Run as root
if [ "$EUID" -ne 0 ]; then
    sudo "$(readlink -f $0)" "$@"
    exit
fi

# Install Docker
pacman -S docker docker-compose docker-buildx

# Enable-start daemon
systemctl start docker.service
systemctl enable docker.service

# Add current user to group
gpasswd -a pyzeradmin docker
echo "Please logout and login to apply group assignment."
