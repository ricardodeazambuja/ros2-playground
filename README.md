# ros2-playground
The name says it all ;)


This repo contains a Dockerfile (`ros2-playground.Dockerfile`) that inherits from `osrf/ros:<ROS_DISTRO>-desktop` and adds:
* Non-root `ros2user` (the files saved in your volume will then belong to the user UID 1000)
* Avahi support (avahi-daemon / libnss-mdns)
* Newest pip
* Python3 opencv package
* sudo
* ping 
* mesa-utils (for testing opengl with glxgears)
* x11-apps (for testing the display with xeyes)
* iproute2 (install things like ip, tc, etc.)
* plotjuggler (a much better tool than rqt_plot!)



The script `build_image.sh` will use your user as the based for UID and GID (in case your user is not using UID=GID=1000). 
You can also modify the command to create an image with another UID/GID:
```
docker build --build-arg ROS_DISTRO=<ROS_DISTRO> --build-arg UID=<put your UID here> --build-arg GID=<put your GID here> \
  -f ros2-playground.Dockerfile -t <name of your image> .
```

In addition to the Dockerfile, I created a bash script that automates the launch of new containers (`launch_ros2_desktop.sh`) 
and mounts the current directory under `/home/ros2user/host`.
This script automatically creates random container names (i.e. `ros2-<random 10 chars>`) that are easier to filter from `docker ps -a`, and you can
access through `ros2-<random 10 chars>.local` as well depending on the arguments you passed to the script.
Use `launch_ros2_desktop.sh --help` to check the options:
```
Usage: launch_ros2_desktop.sh [OPTIONS]
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
    -ds, --dont_source     do not source install/setup.bash and add python stuff to path from the host dir
    -c,  --cmd             command to execute inside the container (default: bash)

```


If you want to open a new terminal using the running container called `ros2-8589d9bd2d`
```
$ docker exec -it ros2-8589d9bd2d bash
```

Or if you decide to just execute something (without the need for sourcing ros2):
```
$ docker exec -t ros2-8589d9bd2d bash -i -c "ros2 topic list"
```

And it works with commands that open a graphical window:
```
$ docker exec -t ros2-8589d9bd2d bash -i -c "ros2 run plotjuggler plotjuggler"
```

Finally, you don't need to remember the IP address for that container as it will be accessible using `ros2-8589d9bd2d.local`.

## VSCode
If you are using VSCode, you can take advantage of its `Remote - Containers` extension and attach VSCode to a running container (https://code.visualstudio.com/docs/remote/attach-container). However, by default, it will not have the extensions, but you can simply open the Extensions tab and click/install the ones you need or you can change the global settings to install some by default (https://code.visualstudio.com/docs/remote/containers#_always-installed-extensions).


By default the container will look for `install/setup.bash` inside the host directory and source if available. 
It will also search for python packages and add them to PYTHONPATH. These steps are to allow IntelliSense to see all packages inside the workspace. 
You can disable this behaviour using `--dont_source`.


[VSCode will save the configurations for each image inside this directory](https://code.visualstudio.com/docs/remote/attach-container#_attached-container-configuration-files):

`~/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/imageConfigs`

The filename is exactly what you type for the image with `/` and `:` replaced with URL encoding. E.g: 

`ricardodeazambuja%2fros2-galactic-desktop%3alatest.json`

The funny thing is that if I manually change the file it always undo it. Probably there's another place with this information...

You still need to have the directory `.vscode` inside the place you will use VSCode, and make adjustments to `c_cpp_properties.json`, if you are using C++.

It may be easier to use a VSCode workspace template, [like this one](https://github.com/athackst/vscode_ros2_workspace), and start the container from VSCode instead of attaching to a running container.