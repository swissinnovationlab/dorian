#!/bin/bash

install_arch () {
    # Update repositories
    pacman -Sy archlinux-keyring --needed
    pacman -Su

    # Install Docker
    pacman -S docker docker-compose docker-buildx --needed

    # Add current user to group
    gpasswd -a $1 docker

    # Enable-start daemon
    systemctl start docker.service
    systemctl enable docker.service
}

install_debian () {
    # Add Docker's official GPG key:
    apt-get update
    apt-get install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update repositories
    apt-get update

    # Install Docker
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add current user to group
    gpasswd -a $1 docker
}

# Give me one ping, Vasily. One ping only.
if [ $# != 1 ]; then
    echo -e "Usage: $0 <user>\n"
    exit 1
fi

# Run as root
if [ "$EUID" -ne 0 ]; then
    sudo "$(readlink -f $0)" "$@"
    exit
fi

loginctl enable-linger $1

# Add current user to group
gpasswd -a $1 docker

if [ $(grep ^NAME /etc/os-release | grep "Arch" | wc -l) -eq 1 ]; then
    echo "-- Docker: Arch detected --"
    install_arch $1
    echo "Please reboot before continuing installation."
    exit 2
elif [ $(grep ^NAME /etc/os-release | grep "Debian" | wc -l) -eq 1 ]; then
    echo "-- Docker: Debian detected --"
    install_debian
    echo "Please logout and login before continuing installation."   
    exit 0
else
    echo "-- Docker: distribution currently not supported --"
    exit 3
fi
