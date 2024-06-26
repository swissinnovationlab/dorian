#!/bin/bash

install_arch () {
    # Update repositories
    pacman -Sy archlinux-keyring --needed
    pacman -Su

    # Install UI prerequisites
    pacman -S xorg xorg-xinit i3 slim unclutter x11vnc xdotool --needed
}

install_debian () {
    # Update repositories
    apt update

    # Install UI prerequisites
    apt install xorg xinit i3 slim unclutter x11vnc xdotool
    dpkg-reconfigure slim
}

# Give me one ping, Vasily. One ping only.
if [ $# != 1 ]; then
    echo -e "Usage: $0 <\$USER>\n"
    exit 1
fi

# Run as root
if [ "$EUID" -ne 0 ]; then
    sudo "$(readlink -f $0)" "$@"
    exit
fi

if [ $(grep ^NAME /etc/os-release | grep "Arch" | wc -l) -eq 1 ]; then
    echo "-- Docker: Arch detected --"
    install_arch
elif [ $(grep ^NAME /etc/os-release | grep "Debian" | wc -l) -eq 1 ]; then
    echo "-- Docker: Debian detected --"
    install_debian
else
    echo "-- Docker: distribution currently not supported --"
    exit 3
fi

# Set up SLIM to autologin current user and to enable session start
echo -e "default_user\t\t$1" >> /etc/slim.conf
echo -e "auto_login\t\tyes" >> /etc/slim.conf
echo -e "sessionstart_cmd\t/usr/bin/xhost +local:" >> /etc/slim.conf
echo -e "login_cmd\t\texec /bin/bash -login ~/.xinitrc %session" >> /etc/slim.conf

cp /home/$1/dorian/.xinitrc /home/$1/.xinitrc
chown $1:$1 /home/$1/.xinitrc
cp -r /home/$1/dorian/.config /home/$1/.config
chown -R $1:$1 /home/$1/.config

systemctl enable slim
systemctl start slim

loginctl enable-linger $1
