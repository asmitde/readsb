#!/bin/bash

RTLSDR=RTL2832U
ENVFILE=.env
RUNDIR=/run/readsb
BUS=$(lsusb | grep $RTLSDR | awk -F' |:' 'NR==1 {print $2}')
DEVICE=$(lsusb | grep $RTLSDR | awk -F' |:' 'NR==1 {print $4}')

IMAGE=readsb:latest
CONTAINER=readsb
NETWORK=adsb-net

# Stop and remove running readsb containers
docker stop $(docker ps -f name=$CONTAINER -q)
docker rm $(docker ps -f name=$CONTAINER -f status=exited -q)

# Create a network to serve adsb data to feeder clients
[[ -z $(docker network ls -f name=$NETWORK -q) ]] && docker network create $NETWORK

# Create a volume for run directory
docker volume create run_readsb

docker run \
 -d \
 --restart on-failure:5 \
 --name $CONTAINER \
 --hostname $CONTAINER-server \
 --network $NETWORK \
 --env-file $ENVFILE \
 --device /dev/bus/usb/$BUS/$DEVICE:/dev/bus/usb/$BUS/$DEVICE \
 -p 30005:30005 \
 -v $RUNDIR:/run/readsb \
 $IMAGE
