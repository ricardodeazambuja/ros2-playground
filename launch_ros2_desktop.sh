#!/bin/bash

# Usage info (from http://mywiki.wooledge.org/BashFAQ/035)
show_help() {
cat << EOF
Usage: ${0##*/} [OPTIONS]
Launch a new docker ROS2 container.
    -h,  --help            display this help and exit
    -d,  --host_dir        directory to be mounted inside ~/host (default: $(pwd))
    -r,  --ros_domain_id   domain ID used with ROS2 (default: 0)
    -lo, --dds_local       set the env variable ROS_LOCALHOST_ONLY=1 to avoid cross talking between machines
    -e,  --env_var         allow to set env variables (e.g. "MY_ENV1=some value\nMY_ENV2=2")
    -i,  --image           docker image to use (default: ricardodeazambuja/ros2-galactic-desktop:latest)
    -n,  --name            container's name and hostname (default: ros2-<random 10 chars>)
    -l,  --local           sets it to use --network=host
    -v,  --video           device number you want to access from the host (default: 0)
    -na, --no_net-admin    disable the use of --cap-add=NET_ADMIN
    -nn, --no-nvidia       disable the use of NVIDIA Docker stuff
    -dr, --hard-dri        direct access to hardware (useful for Intel Graphics) --device=/dev/dri:/dev/dri
    -g,  --gdb             enable debugging using gdb
    -t,  --local_time      use host timezone
    -c,  --cmd             command to execute inside the container (default: bash)
EOF
}

# from https://unix.stackexchange.com/a/331530
ROS_DOMAIN_ID=0
IMAGE=ricardodeazambuja/ros2-galactic-desktop:latest
NAME=ros2-$(echo $RANDOM | md5sum | head -c 10)
CMD=bash
NET="--hostname=$NAME"
VIDEO=0
CAP="--cap-add=NET_ADMIN"
NGPU="--gpus all --env=NVIDIA_VISIBLE_DEVICES=all --env=NVIDIA_DRIVER_CAPABILITIES=all"
DRI=
GDB=
LTIME=
EXT_ENV=
LHO="--env=ROS_LOCALHOST_ONLY=0"
HOST_DIR=$(pwd)
while :; do
    case $1 in
        -h|--help) show_help
        exit 0
        ;;
        -r|--ros_domain_id) ROS_DOMAIN_ID=$2
        ;;
        -d|--host_dir) HOST_DIR=$(cd $2; pwd)
        ;;
        -lo|--dds_local) LHO="--env=ROS_LOCALHOST_ONLY=1"
        ;;
        -e|--env_var) tmpfile=$(mktemp); echo -e $2 > $tmpfile; EXT_ENV="--env-file=$tmpfile"
        ;;
        -i|--image) IMAGE=$2
        ;;
        -n|--name) NAME=$2
        NET="--hostname=$NAME"
        ;;
        -c|--cmd) CMD=$2
        ;;
        -l|--local) NET="--network=host"
        USING_HOST=1
        ;;
        -v|--video) VIDEO=$2
        ;;
        -na|--no_net-admin) CAP=""
        ;;
        -nn|--no-nvidia) NGPU=""
        ;;
        -dr|--hard-dri) DRI="--device=/dev/dri:/dev/dri"
        ;;
        -g|--gdb) GDB="--cap-add=SYS_PTRACE --security-opt=seccomp=unconfined"
        ;;
        -t|--local_time) LTIME="--volume /etc/localtime:/etc/localtime:ro"
        ;;
        *) break
    esac
    shift
done

if [ -z "$USING_HOST" ]; 
    then 
        echo "This is the container's name and hostname: $NAME"; 
    else
        echo "This is the container's name as $NAME and the host network"; 
fi

echo "Using a ROS_DOMAIN_ID=$ROS_DOMAIN_ID"
echo 
echo "This script mounted the directory ($HOST_DIR)" 
echo "inside the container at /home/ros2user/host."
echo "Therefore, remember that when you decide to use something like \"rm -rf *\" ;)"
echo 

docker run --rm -it $NET $CAP $NGPU $DRI $GDB $LTIME $LHO $EXT_ENV \
             --name $NAME \
             --user $(id -u):$(id -g) \
             --volume $HOST_DIR:/home/ros2user/host \
             --group-add video --group-add sudo \
             --device=/dev/video$VIDEO:/dev/video0 \
             --env=DISPLAY=$DISPLAY \
             --env=QT_X11_NO_MITSHM=1 \
             --volume /tmp/.X11-unix:/tmp/.X11-unix \
             --workdir="/home/ros2user/" \
             --mount type=bind,source=/home/$USER/.bash_history,target=/home/ros2user/.bash_history \
             --env=ROS_DOMAIN_ID=$ROS_DOMAIN_ID \
             $IMAGE $CMD