#!/bin/bash

# credentials
DEVICE_ID=
API_KEY=

# UI selector
UI=
RESIDENTIAL="RESIDENTIAL"
PORSCHE="PORSCHE"

# Runtime parameters

set_ui () {
    sed -i "/^COMPOSE_PROFILES/d" ~/.bashrc
    if [ $UI == $RESIDENTIAL ]; then
        echo "[UI:] Residential"
        echo "COMPOSE_PROFILES=residential" >> ~/.bashrc
    elif [ $UI == $PORSCHE ]; then
        echo "[UI:] Porsche"
        echo "COMPOSE_PROFILES=porsche" >> ~/.bashrc
    else
        echo "[UI:] n/a"
    fi
    source ~/.bashrc
    unset UI
}

set_device_id () {
    touch ~/devconn.env
    if [ ! -z $DEVICE_ID ]; then
        sed -i "/^DMP_DEVICE_ID/d" ~/devconn.env
        echo "DMP_DEVICE_ID=$DEVICE_ID" >> ~/devconn.env
    fi
}

set_api_key () {
    touch ~/devconn.env
    if [ ! -z $API_KEY ]; then
        sed -i "/^DMP_API_KEY/d" ~/devconn.env
        echo "DMP_API_KEY=$API_KEY" >> ~/devconn.env
    fi
}

usage () {
    echo "Usage: $0" 1>&2
    exit 1
}

stop_loytra () {
    IS_LOYTRA_AVAILABLE=$(ls ~/.local/bin/loytra | wc -l)
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
    IS_LOYTRA_PYTHON=$(grep "#!/" ~/.local/bin/loytra | grep python | wc -l)
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
    chmod +x ./gray_migrate_data.sh
    ./gray_migrate_data.sh $USER $DOCKER_MOUNT_POINT
    chmod -x ./gray_migrate_data.sh
}

install_dorian () {
    echo "= dorian installer ="
    echo "--------------------"
    vpn_up
    main_up
}

migrate () {
    echo "= loytra to dorian migrator ="
    echo "-----------------------------"
    stop_loytra
    disable_loytra
    migrate_dmp
    migrate_data
}

update () {
    RETURN_PATH=$(pwd)
    cd ~/dorian
    git restore *
    git pull
    chmod +x *.sh
    cp gray*.sh ~/
    cp *.yml ~/
    cd $RETURN_PATH
    unset -v RETURN_PATH
}

# Docker operations

install_docker () {
    chmod +x ./gray_install_docker.sh
    ./gray_install_docker.sh
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
    source ~/.bashrc
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

while getopts "a:cd:DigmMnpruvV?": opt; do
    case $opt in
    a) API_KEY="$OPTARG"
       set_api_key;;
    c) migrate
       install_dorian;;
    d) DEVICE_ID="$OPTARG"
       set_device_id;;
    D) install_docker;;
    i) install_dorian;;
    m) main_down;;
    M) main_up;;
    n) unset UI
       set_ui;;
    p) UI=$PORSCHE;;
       set_ui;;
    r) UI=$RESIDENTIAL
       set_ui;;
    u) update;;
    v) vpn_down;;
    V) vpn_up;;
    ?) usage;;
    esac
done
