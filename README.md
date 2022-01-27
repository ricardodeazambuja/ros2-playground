# ros2-playground
The name says it all ;)


This repo contains a Dockerfile (`my-ros2-playground.Dockerfile`) that inherits from `osrf/ros:galactic-desktop` and adds:
* Non-root `ros2user` (the files saved in your volume will then belong to the user UID 1000)
* Avahi support (avahi-daemon / libnss-mdns)
* Newest pip
* Python3 opencv package
* sudo
* ping 
* mesa-utils (for testing opengl with glxgears)
* x11-apps (for testing the display with xeyes)


The script `build_image.sh` will use your user as the based for UID and GID (in case your user is not using UID=GID=1000). 
You can also modify the command to create an image with another UID/GID:
```
docker build --build-arg UID=<put your UID here> --build-arg GID=<put your GID here> \
  -f my-ros2-playground.Dockerfile -t <name of your image> .

```

In addition to the Dockerfile, I created a bash script that automates the launch of new containers (`launch_ros2_galactic_desktop.sh`) 
and mounts the current directory under `/home/ros2user/host`.
This script automatically creates random container names (i.e. `ros2galactic-<random 10 chars>`) that are easier to filter from `docker ps -a`, and you can
access through `ros2galactic-<random 10 chars>.local` as well depending on the arguments you passed to the script.
Use `launch_ros2_galactic_desktop.sh --help` to check the options.


If you want to open a new terminal using the running container called `ros2galactic-8589d9bd2d`
```
$ docker exec -it ros2galactic-8589d9bd2d bash
```

Or if you decide to just execute something (without the need for sourcing ros2):
```
$ docker exec -t ros2galactic-8589d9bd2d bash -i -c "ros2 topic list"
```

Finally, you don't need to remember the IP address of that container as it will be `ros2galactic-8589d9bd2d.local` from different ROS2 containers.


