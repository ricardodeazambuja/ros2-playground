#!/bin/bash

if [[ $# -lt 2 ]] ; then
    echo "Oups, you forgot to choose the arguments!"
    echo "First, is the docker container name (e.g. ros2-ros2-7afe96bba7)"
    echo "Second is the image name (e.g. ricardodeazambuja/ros2-galactic-desktop:carlasim)."
    exit 1
fi

# stops avahi-daemon to allow it to do the cleanup
docker exec $1 bash -c "sudo avahi-daemon -k"
# commits the container (1st argument, $1) to the image (2nd argument $2)
docker commit $1 $2
# re-starts avahi-daemon
docker exec $1 bash -c "sudo avahi-daemon -D"

# It would be possible to add to launch_ros2_desktop.sh something like explained here:
# https://stackoverflow.com/questions/32163955/how-to-run-shell-script-on-host-from-docker-container/63719458#63719458
# to allow us to call this script from the docker container itself. This would be useful to automate things... 
# but it seems overkill right now.