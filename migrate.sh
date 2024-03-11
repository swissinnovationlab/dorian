#!/bin/bash

echo "= Migration START ="

RESIDENTIAL=

while getopts "r:" opt; do
    case $opt in
    r) RESIDENTIAL=true ;;
    esac
done

echo "-- Stopping loytra processes --"
# Disable old processes, leave VPN alive
loytra disable devconn_vpn_client/handler
loytra disable devconn_client/router
loytra disable pyzer/api_server
loytra disable pyzer/entity_manager
loytra disable pyflexen/engine

# disable loytra
mv ~/.local/bin/loytra ~/.local/bin/loytra-rip
echo -e "#!/bin/sh\nloytra no longer used on this device, check docker documentation" > ~/.local/bin/loytra && chmod +x ~/.local/bin/loytra

echo "-- Migrating DMP parameters --"
# Extract device params
DEVICE_ID=$(grep device_ ~/.local/share/devconn_proxy_client/config.json | cut -d : -f2 | awk -F\" '{print $2}')
API_KEY=$(grep api ~/.local/share/devconn_proxy_client/config.json | cut -d : -f2 | awk -F\" '{print $2}')
# Generate and inject params
echo -e "DMP_DEVICE_ID=YOUR_DEVICE_ID\nDMP_API_KEY=YOUR_DEVICE_API_KEY" > ~/devconn.env
sed -i "s/YOUR_DEVICE_ID/$DEVICE_ID/g ; s/YOUR_DEVICE_API_KEY/$API_KEY/g" ~/devconn.env

if [ ! -z $RESIDENTIAL ]; then
    echo "-- Preparing for Residential UI --"
    sed -i "/^COMPOSE_PROFILES/d" ~/.bashrc
    echo -e "COMPOSE_PROFILES=residential" >> ~/.bashrc
fi

echo "-- Migrating resources and flows --"
# Prepare docker volume
DOCKER_VOLUME=$(grep -E "^volume" -A 5 docker-compose.yml | grep "name" | cut -d : -f2 | awk -F\" '{print $2}')
docker volume create $DOCKER_VOLUME
DOCKER_MOUNT_POINT=$(docker inspect $DOCKER_VOLUME | grep Mountpoint | cut -d : -f2 | awk -F\" '{print $2}')

# Migrate entities and flows
./migrate_as_sudo.sh $USER $DOCKER_MOUNT_POINT

echo "-- Starting containers --"
# Start the containers
source ~/.bashrc
docker compose -f docker-compose-vpn.yml up --build -d
docker compose -f docker-compose.yml up --build -d

echo "== Migration DONE =="
chmod -x $0
