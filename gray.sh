#!/bin/bash

# credentials management

function set_device_id () {
    touch ~/devconn.env
    sed -i "/^DMP_DEVICE_ID/d" ~/devconn.env
    echo "DMP_DEVICE_ID=$1" >> ~/devconn.env
}

function set_api_key () {
    touch ~/devconn.env
    sed -i "/^DMP_API_KEY/d" ~/devconn.env
    echo "DMP_API_KEY=$1" >> ~/devconn.env
}

# hostname management

function set_hostname() {
    CURRENT_DMP_ID=$(grep DMP_DEVICE_ID devconn.env | cut -d'=' -f2)
    if [ ! -z $CURRENT_DMP_ID ]; then
        NEW_HOSTNAME="dorian-$CURRENT_DMP_ID"
        chmod +x gray_set_hostname.sh
        ./gray_set_hostname.sh $NEW_HOSTNAME
        chmod -x gray_set_hostname.sh
        echo "Hostname set, please logout and login to see effect."
    fi
}

# UI and profile management

function set_profile () {
    sed -i "/^export COMPOSE_PROFILES/d" ~/.bashrc
    echo "[PROFILE:] $1"
    echo "COMPOSE_PROFILES=$1" > ~/.env
}

function set_orientation () {
    case "$1" in
        "inverted") ;&
        "right")    ;&
        "left")     ;&
        "normal")     
            echo "[UI ORIENTATION:] $1"
            echo "ORIENTATION=$1" > ui.env
            if [ $(grep COORD_TF_MTX ~/.xinitrc | wc -l) -eq 0 ]; then
                # handle old version of .xinitrc without dynamic orientation
                cp ~/dorian/.xinitrc ~/
            fi 
            if ! test -f ~/gray_set_orientation.sh; then
                # handle missing orientation script
                cp ~/dorian/gray_set_orientation.sh ~/
                chmod +x ~/gray_set_orientation.sh
                cd ~
            fi
            ./gray_set_orientation.sh
            ;;
        *)
            usage_set_orientation
            ;;
    esac
}

function usage_set_orientation () {
    echo "Usage: ${0##*/} -o [normal|left|right|inverted]"
    exit 1
}

function install_ui() {
    chmod +x gray_install_ui.sh
    ./gray_install_ui.sh $USER
    chmod -x gray_install_ui.sh
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
        set_ui "residential"
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
    DOCKER_VOLUME=$(grep -E "^volume" -A 5 docker-compose.yml | grep "name" | cut -d : -f2 | awk -F\" '{print $2}')
    docker volume create $DOCKER_VOLUME
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
    cd ~/dorian
    git restore *
    git checkout main
    git pull
    chmod +x gray.sh
    chmod +x gray_set_orientation.sh
    cp *.yml ~/
    cd ~/
}

function update_experimental () {
    cd ~/dorian
    git restore *
    git checkout develop
    git pull
    chmod +x gray.sh
    chmod +x gray_set_orientation.sh
    cp *.yml ~/
    cd ~/
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

while getopts "a:Cd:eDIhmMo:p:uUV" opt; do
    case $opt in
    a) set_api_key "$OPTARG";;
    C) migrate;;
    d) set_device_id "$OPTARG";;
    e) update_experimental;;
    D) install_docker;;
    I) install_dorian;;
    h) set_hostname;;
    m) main_down;;
    M) main_up;;
    o) set_orientation "$OPTARG";;
    p) set_profile "$OPTARG";;
    u) update;;
    U) install_ui;;
    V) install_vpn;;
    esac
done
