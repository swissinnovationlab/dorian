#!/bin/bash

# credentials
DEVICE_ID=
API_KEY=

# profile selector
PROFILE=

# profile and UI

function set_profile () {
    sed -i "/^export COMPOSE_PROFILES/d" ~/.bashrc
    if [ ! -z $PROFILE ]; then
        echo "[UI:] $PROFILE"
        echo "COMPOSE_PROFILES=$PROFILE" > ~/.env
    else
        echo "[UI:] none"
        rm ~/.env
    fi
}

function install_ui() {
    chmod +x gray_install_ui.sh
    ./gray_install_ui.sh $USER
    chmod -x gray_install_ui.sh
}

# credentials

function set_device_id () {
    touch ~/devconn.env
    if [ ! -z $DEVICE_ID ]; then
        sed -i "/^DMP_DEVICE_ID/d" ~/devconn.env
        echo "DMP_DEVICE_ID=$DEVICE_ID" >> ~/devconn.env
    fi
}

function set_api_key () {
    touch ~/devconn.env
    if [ ! -z $API_KEY ]; then
        sed -i "/^DMP_API_KEY/d" ~/devconn.env
        echo "DMP_API_KEY=$API_KEY" >> ~/devconn.env
    fi
}

# Help

function usage () {
    echo "Usage: $0" 1>&2
    exit 1
}

# Migration

function stop_loytra () {
    IS_LOYTRA_AVAILABLE=$(ls ~/.local/bin/loytra | wc -l)
    if [ $IS_LOYTRA_AVAILABLE -eq 1 ]; then
        echo "-- Stopping loytra processes --"
        loytra disable devconn_vpn_client/handler
        loytra disable devconn_vpn_client/client
        loytra disable devconn_client/router
        loytra disable pyzer/api_server
        loytra disable pyzer/entity_manager
        loytra disable pyflexen/engine
        loytra disable goxmler_app_residential/x86_64
    fi
}

function disable_loytra () {
    IS_LOYTRA_PYTHON=$(grep "#!/" ~/.local/bin/loytra | grep python | wc -l)
    if [ $IS_LOYTRA_PYTHON -eq 1 ]; then
        mv ~/.local/bin/loytra ~/.local/bin/loytra-rip
        echo -e '#!/bin/sh\necho "loytra no longer used on this device, check dorian documentation"' > ~/.local/bin/loytra && chmod +x ~/.local/bin/loytra
    fi
}

function migrate_dmp () {
    echo "-- Migrating DMP parameters --"
    DEVICE_ID=$(grep device_ ~/.local/share/devconn_proxy_client/config.json | cut -d : -f2 | awk -F\" '{print $2}')
    API_KEY=$(grep api ~/.local/share/devconn_proxy_client/config.json | cut -d : -f2 | awk -F\" '{print $2}')
    set_device_id
    set_api_key
}

function migrate_ui () {
    echo "-- Migrating UI installation --"
    IS_RESIDENTIAL_INSTALLED = $(ls .local/share | grep goxmler | wc -l)
    if [ $IS_RESIDENTIAL_INSTALLED -eq 1 ]; then
        PROFILE=residential
        set_ui
    fi
}

function migrate_data () {
    echo "-- Migrating data to docker volume --"
    DOCKER_VOLUME=$(grep -E "^volume" -A 5 docker-compose.yml | grep "name" | cut -d : -f2 | awk -F\" '{print $2}')
    docker volume create $DOCKER_VOLUME
    DOCKER_MOUNT_POINT="/var/lib/docker/volumes/$DOCKER_VOLUME/_data/"
    chmod +x ./gray_migrate_data.sh
    ./gray_migrate_data.sh $USER $DOCKER_MOUNT_POINT
    chmod -x ./gray_migrate_data.sh
}

# Dorian core operations

function install_dorian () {
    echo "= dorian installer ="
    echo "--------------------"
    vpn_up
    main_up
}

function migrate () {
    echo "= loytra to dorian migrator ="
    echo "-----------------------------"
    stop_loytra
    disable_loytra
    migrate_dmp
    migrate_data
}

function update () {
    RETURN_PATH=$(pwd)
    cd ~/dorian
    git restore *
    git pull
    chmod +x gray.sh
    cp gray*.sh ~/
    cp *.yml ~/
    cd $RETURN_PATH
    unset -v RETURN_PATH
}

# VPN operations

function install_vpn() {
    IS_DEVCONN_FILE_OK=$(wc -l ~/devconn.env | cut -f1 -d' ')
    if [ $IS_DEVCONN_FILE_OK -eq 2 ]; then
        chmod +x gray_install_vpn.sh
        ./gray_install_vpn.sh $USER
        chmod -x gray_install_vpn.sh
    else
        echo "Unable to install VPN, no valid devconn.env"
    fi
}

# Docker operations

install_docker () {
    chmod +x ./gray_install_docker.sh
    ./gray_install_docker.sh $USER
    if [ $? -ne 0 ]; then
        chmod -x ./gray_install_docker.sh
        exit 1
    fi
    chmod -x ./gray_install_docker.sh
}

main_down () {
    echo "-- Main container going down --"
    docker compose down
}

main_up () {
    echo "-- Main container going up --"
    docker compose up --build -d
}

# switchology
while getopts "a:cd:DihmMp::uUV" opt; do
    case $opt in
    a) API_KEY="$OPTARG"
       set_api_key;;
    c) migrate;;
    d) DEVICE_ID="$OPTARG"
       set_device_id;;
    D) install_docker;;
    I) install_dorian;;
    h) usage;;
    m) main_down;;
    M) main_up;;
    p) if [ ! -z $UI ]; then
           PROFILE="$OPTARG"
       else
           unset PROFILE
       fi
       set_profile;;
    u) update;;
    U) install_ui;;
    V) install_vpn;;
    esac
done
