#!/bin/bash

RESIDENTIAL=

while getopts "r:" opt; do
    case $opt in
    r) RESIDENTIAL=true ;;
    esac
done

sed -i "/^COMPOSE_PROFILES/d" ~/.bashrc
if [ ! -z $RESIDENTIAL ]; then
    echo "-- Preparing for Residential UI --"
    echo -e "COMPOSE_PROFILES=residential" >> ~/.bashrc
fi

source ~/.bashrc
docker compose down
docker compose up --build -d
