#!/bin/bash

# mode switches
INTERACTIVE=
INSTALL_DOCKER=

# credentials
DEVICE_ID=
API_KEY=

# UI selector
RESIDENTIAL=
PORSCHE=

# storage
PROFILE_STORAGE_FILE=~/.bashrc

set_ui () {
    sed -i "/^COMPOSE_PROFILES/d" $PROFILE_STORAGE_FILE
    if [ ! -z $RESIDENTIAL ]; then
        echo "[UI:] Residential"
        echo -e "COMPOSE_PROFILES=residential" >> $PROFILE_STORAGE_FILE
    elif [ ! -z $PORSCHE ]; then
        echo "[UI:] Porsche"
        echo -e "COMPOSE_PROFILES=porsche" >> $PROFILE_STORAGE_FILE
    else
        echo "[UI:] n/a"
    fi
    source $PROFILE_STORAGE_FILE
}

set_device_id () {
    if [ ! -z $DEVICE_ID ]; then
        sed -i "/^DMP_DEVICE_ID/d" ~/devconn.env
        echo -e "DMP_DEVICE_ID=$DEVICE_ID\n" >> ~/devconn.env
    fi
}

set_api_key () {
    if [ ! -z $API_KEY ]; then
        sed -i "/^DMP_API_KEY/d" ~/devconn.env
        echo -e "DMP_API_KEY=$API_KEY\n" >> ~/devconn.env
    fi
}

usage () {
    echo "Usage: $0" 1>&2
    exit 1
}

#interact () {
    #echo "Menu goes here"
    #echo "--------------"
#}

stop_loytra () {
    IS_LOYTRA_AVAILABLE = $(ls ~/.local/bin/loytra | wc -l)
    if [ $IS_LOYTRA_AVAILABLE -eq 1 ]; then
        echo "-- Stopping loytra processes --"
        loytra disable devconn_vpn_client/handler
        loytra disable devconn_client/router
        loytra disable pyzer/api_server
        loytra disable pyzer/entity_manager
        loytra disable pyflexen/engine
        loytra disable goxmler_app_residential/x86_64
    fi
}

disable_loytra () {
    IS_LOYTRA_PYTHON = $(grep "#!/" ~/.local/bin/loytra | grep python | wc -l)
    if [ $IS_LOYTRA_PYTHON -eq 1 ]; then
        mv ~/.local/bin/loytra ~/.local/bin/loytra-rip
        echo -e '#!/bin/sh\necho "loytra no longer used on this device, check dorian documentation"' > ~/.local/bin/loytra && chmod +x ~/.local/bin/loytra
    fi
}

migrate_dmp () {
    echo "-- Migrating DMP parameters --"
    DEVICE_ID=$(grep device_ ~/.local/share/devconn_proxy_client/config.json | cut -d : -f2 | awk -F\" '{print $2}')
    API_KEY=$(grep api ~/.local/share/devconn_proxy_client/config.json | cut -d : -f2 | awk -F\" '{print $2}')
    set_device_id
    set_api_key
}

migrate_ui () {
    echo "-- Migrating UI installation --"
    IS_RESIDENTIAL_INSTALLED = $(ls .local/share | grep goxmler | wc -l)
    if [ $IS_RESIDENTIAL_INSTALLED -eq 1 ]; then
        RESIDENTIAL=true
        set_ui
    fi
}

migrate_data () {
    echo "-- Migrating data to docker volume --"
    DOCKER_VOLUME=$(grep -E "^volume" -A 5 docker-compose.yml | grep "name" | cut -d : -f2 | awk -F\" '{print $2}')
    docker volume create $DOCKER_VOLUME

    ./gray_migrate_data.sh $USER $DOCKER_MOUNT_POINT
}

migrate () {
    echo "= loytra to dorian migrator ="
    echo "-----------------------------"
    stop_loytra
    disable_loytra
    migrate_dmp
    vpn_up
    main_up
}

automate () {
    echo "automatic setup here"
    echo "--------------------"
    set_device_id
    set_api_key
    set_ui
}

update () {
    RETURN_PATH=$(pwd)
    cd ~/dorian
    git pull
    chmod +x *.sh
    cp *.sh ~/
    cp *.yml ~/
    cd $RETURN_PATH
    unset -v RETURN_PATH
}

# Docker operations

install_docker () {
    ./gray_install_docker.sh
    if [ $? -ne 0 ]; then
        exit 1
    fi
}

main_down () {
    echo "-- Main container going down --"
    docker compose down
}

main_up () {
    echo "-- Main container going up --"
    source PROFILE_STORAGE_FILE
    docker compose up --build -d
}

vpn_down () {
    TUN_ADDR=$(ip addr | grep tun | grep scope | cut -f 6 -d " " | cut -f1-3 -d ".")
    USER_ADDR=$(who am i | cut -f 2 -d "(" | cut -f1-3 -d ".")
    if [ $TUN_ADDR == $USER_ADDR ]; then
        echo "= VPN DOWN disabled, you're connected through VPN! ="
        return
    fi

    echo "-- VPN going down --"
    docker compose -f docker-compose-vpn.yml down
}

vpn_up () {
    echo "-- VPN going up --"
    docker compose -f docker-compose-vpn.yml up --build -d
}

# switchology

while getopts "acdDmMprvV?": opt; do
    case $opt in
    a) API_KEY="$OPTARG";;
    c) migrate;;
    d) DEVICE_ID="$OPTARG";;
    D) install_docker;;
#    i) interactive;;
#    probably turn this into install instead
    g) set_ui;;
    m) main_down;;
    M) main_up;;
    p) PORSCHE=true;;
    r) RESIDENTIAL=true;;
    u) update;;
    v) vpn_down;;
    V) vpn_up;;
    ?) usage;;
    esac
done
