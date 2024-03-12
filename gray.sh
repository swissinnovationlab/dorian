#!/bin/bash

PROFILE_STORAGE_FILE=~/.bashrc

set_ui () {
    sed -i "/^COMPOSE_PROFILES/d" $PROFILE_STORAGE_FILE
    if [ ! -z $RESIDENTIAL ]; then
        echo "[UI:] Residential"
        echo -e "COMPOSE_PROFILES=residential\n" >> $PROFILE_STORAGE_FILE
    elif [ ! -z $PORSCHE ]; then
        echo "[UI:] Porsche"
        echo -e "COMPOSE_PROFILES=porsche\n" >> $PROFILE_STORAGE_FILE
    else
        echo "[UI:] n/a"
    fi
    source $PROFILE_STORAGE_FILE
}

set_device_id () {
    if [ ! -z $DEVICE_ID ]; then
        sed -i "/^DMP_DEVICE_ID/d" ~/devconn.env
        echo -e "DMP_DEVICE_ID=$DEVICE_ID\n" >> devconn.env
    fi
}

set_api_key () {
    if [ ! -z $API_KEY ]; then
        sed -i "/^DMP_API_KEY/d" ~/devconn.env
        echo -e "nDMP_API_KEY=$API_KEY\n" >> devconn.env
    fi
}

usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

interact() {
    echo "Menu goes here"
    echo "--------------"
}

migrate() {
    echo "Migration goes here"
    echo "-------------------"
}

automate() {
    echo "automatic setup here"
    echo "-------------------"
    set_device_id
    set_api_key
    set_ui
}

# Docker section

main_down {
    docker compose down
}

main_up {
    source PROFILE_STORAGE_FILE
    docker compose up --build -d
}

vpn_down {
    docker compose -f docker-compose-vpn.yml down
}

vpn_up {
    docker compose -f docker-compose-vpn.yml up --build -d
}

# main
# mode switches
INTERACTIVE=
INSTALL_DOCKER=

# credentials
DEVICE_ID=
API_KEY=

# UI selector
RESIDENTIAL=
PORSCHE=

while getopts "adDpr?": opt; do
    case $opt in
    a) API_KEY="$OPTARG";;
    d) DEVICE_ID="$OPTARG";;
    D) INSTALL_DOCKER=true;;
    m) main_down;;
    M) main_up;;
    p) PORSCHE=true;;
    r) RESIDENTIAL=true;;
    v) vpn_down
    V) vpn_up
    ?) usage;;
    esac
done
