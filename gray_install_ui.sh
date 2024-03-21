#!/bin/bash

install_arch () {
    # Update repositories
    pacman -Sy archlinux-keyring
    pacman -Su

    # Install UI prerequisites
    pacman -S xorg xorg-xinit i3 slim unclutter
}

install_debian () {
    # Update repositories
    apt update

    # Install UI prerequisites
    apt install xorg xinit i3 slim unclutter
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

    # Set up SLIM to autologin current user and to enable 
sed -i "s/^#default_user.*/default_user\t\t$1/1" /etc/slim.conf
sed -i "s/^#auto_login.*/auto_login\t\tyes/1" /etc/slim.conf
sed -i "s/^# sessionstart_cmd.*/sessionstart_cmd\t\t/usr/bin/xhost +local:" /etc/slim.conf
sed -i "s/^#login_cmd.*/login_cmd\t\texec /bin/bash -login ~/.xinitrc %session" /etc/slim.conf

cp /home/$1/dorian/.xinitrc /home/$1/.xinitrc
chown $1:$1 /home/$1/.xinitrc
cp -r /home/$1/dorian/.config /home/$1/.config
chown -R $1:$1 /home/$1/.config

systemctl enable slim
systemctl start slim

loginctl enable-linger $1
