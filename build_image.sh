#!/bin/bash

if [[ $# -lt 1 ]] ; then
    echo "Oups, you forgot to choose the arguments!"
    echo "First, is the docker image name (e.g. ricardodeazambuja/ros2-galactic-desktop:latest)."
    echo "Second argument is the ROS2 distro name (default: galactic)."
    echo "Third argument is used to pass extra args like --no-cache, but you must pass the 2nd argument to get here :)"
    exit 1
fi

ROS_DISTRO=${2:-galactic}
NOCACHE=${3:-}
# --no-cache is useful when you are debugging as it will force to build from scratch
docker build $NOCACHE --build-arg ROS_DISTRO=$ROS_DISTRO --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
  -f ros2-playground.Dockerfile -t $1 .

# https://stackoverflow.com/a/44683248/7658422