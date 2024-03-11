#!/bin/bash

echo "= Install START ="

RESIDENTIAL=

while getopts "r:" opt; do
    case $opt in
    r) RESIDENTIAL=true ;;
    esac
done

# Enter device params
read -p "DMP device id: " DEVICE_ID
read -p "DMP API key: " DMP API_KEY
# Generate and inject parameters 
echo -e "DMP_DEVICE_ID=YOUR_DEVICE_ID\nDMP_API_KEY=YOUR_DEVICE_API_KEY" > ~/devconn.env
sed -i "s/YOUR_DEVICE_ID/$DEVICE_ID/g ; s/YOUR_DEVICE_API_KEY/$API_KEY/g" ~/devconn.env

if [ ! -z $RESIDENTIAL ]; then
    echo "-- Preparing for Residential UI --"
    sed -i "/^COMPOSE_PROFILES/d" ~/.bashrc
    echo -e "COMPOSE_PROFILES=residential" >> ~/.bashrc
fi

source ~/.bashrc
docker compose -f docker-compose-vpn.yml up --build -d
docker compose -f docker-compose.yml up --build -d

echo "= install DONE ="
chmod -x $0
