#!/usr/bin/env bash

set -e

echo
echo "ros_entrypoint starts here..."
echo "(This script, ENTRYPOINT, runs only when the container is created)"
echo

# Avahi is necessary if you want to use .local domains
echo "sudo avahi-daemon -D"
sudo avahi-daemon -D

# setup ros2 environment
echo "source '/opt/ros/$ROS_DISTRO/setup.bash'"
source /opt/ros/$ROS_DISTRO/setup.bash

if [ "$SOURCE_HOST" = "1" ]; then 
    if grep -Fq "#SEARCH4LIBRARIES" /home/ros2user/.bashrc
    then
        echo "Code already found in ~/.bashrc"
    else
        echo
        echo "Adding stuff to .bashrc to source /home/ros2user/host/install/setup.bash..."
        echo "test -f /home/ros2user/host/install/setup.bash && source /home/ros2user/host/install/setup.bash #SEARCH4LIBRARIES" >> /home/ros2user/.bashrc
        # Considering the ros2 workspace will be mounted at ~/host, it will check for a local setup.bash

        echo "...and to search for Python packages and add them to PYTHONPATH!"

        # It will add to PYTHONPATH all packages found under /home/ros2user/host/src
        echo "for i in \$(find /home/ros2user/host/src -name \"__init__.py\"); do PYTHONPATH=\$PYTHONPATH:\$(cd \$(dirname \"\$i\"); cd ..; pwd); done" >> /home/ros2user/.bashrc
        echo "export PYTHONPATH" >> /home/ros2user/.bashrc
        # Above we will go through the dir /home/ros2user/host/ and search for python packages to add them to PYTHONPATH    
    fi
fi


echo
echo "ros_entrypoint finished..."
echo
echo "Command(s) to be executed:" $@

$@

# 'exec "$@"' is typically used to make the entrypoint a pass through that then 
# runs the docker command. It will replace the current running shell with the 
# command that "$@" is pointing to. By default, that variable points to the command line arguments.
# https://stackoverflow.com/a/48096779/7658422