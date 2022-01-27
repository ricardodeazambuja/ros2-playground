#!/usr/bin/env bash

set -e

echo
echo "ros_entrypoint starts here..."
echo

# Avahi is necessary if you want to use .local domains
echo "sudo avahi-daemon -D";
sudo avahi-daemon -D; 

# setup ros2 environment
echo "source '/opt/ros/$ROS_DISTRO/setup.bash'"
source /opt/ros/$ROS_DISTRO/setup.bash

echo
echo "ros_entrypoint finished..."
echo
echo $@

$@

# 'exec "$@"' is typically used to make the entrypoint a pass through that then 
# runs the docker command. It will replace the current running shell with the 
# command that "$@" is pointing to. By default, that variable points to the command line arguments.
# https://stackoverflow.com/a/48096779/7658422