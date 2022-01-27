#!/bin/bash

if [[ $# -lt 1 ]] ; then
    echo "Oups, you forgot to choose the arguments!"
    echo "First, and only, argument is the docker image name (e.g. ricardodeazambuja/ros2-galactic-desktop:latest)."
    exit 1
fi

# --no-cache is useful when you are debugging as it will force to build from scratch
docker build --no-cache --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
  -f my-ros2-playground.Dockerfile -t $1 .

# https://stackoverflow.com/a/44683248/7658422