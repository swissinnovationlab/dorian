#!/bin/bash

cd dorian_builder
git pull
cd ~

docker compose down
docker compose up --build -d
