#!/bin/bash

install_arch() {
    # Update repositories
    pacman -Sy archlinux-keyring --needed
    pacman -Su

    # Install VPN
    pacman -S openvpn --needed
}

install_debian() {
    apt-get update
    apt install openvpn
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

# use DEVCONN data for VPN
DMP_DEVICE_ID=$(grep DMP_DEVICE_ID /home/$1/devconn.env | cut -d = -f2 | awk -F\" '{print $1}')
DMP_API_KEY=$(grep DMP_API_KEY /home/$1/devconn.env | cut -d = -f2 | awk -F\" '{print $1}')
echo -e "$DMP_DEVICE_ID\n$DMP_API_KEY" > /etc/openvpn/client/dmp_up.txt

# pull OpenVPN keys from DMP
curl -s -H "Content-Type: application/json" -d '{"device_id": "'"$DMP_DEVICE_ID"'", "device_key": "'"$DMP_API_KEY"'"}' \
            -X POST https://dmp.swissinnolab.com:4040/service/internal/device/vpn_config \
            -o /etc/openvpn/client/dmp.conf
systemctl start openvpn-client@dmp.service
systemctl enable openvpn-client@dmp.service
