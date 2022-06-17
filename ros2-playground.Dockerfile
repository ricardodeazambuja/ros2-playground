ARG ROS_DISTRO='galactic'
FROM osrf/ros:$ROS_DISTRO-desktop

# ROS2 Galactic
# FROM osrf/ros@sha256:97c07f6b3c8bd0cd2b9dd68baac3a9f790a90dd51b4d21f7a6d0766083f3d583
# To find the hash: $ docker images --digests


# SHELL ["/bin/bash", "-c"] # the default shell for docker seems to be /bin/sh

# Default values (see build_image.sh)
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID -o ros2user
RUN useradd -m -u $UID -g $GID -o -s /bin/bash ros2user

RUN usermod -aG sudo ros2user
RUN echo "ros2user    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 
# Use sudo without a password

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  bash-completion \
  vim \
  sudo \
  x11-apps \
  iputils-ping \
  mesa-utils \
  avahi-daemon \
  libnss-mdns \
  python3-pip \
  libopencv-dev \
  python3-opencv \
  python3-tk \
  iproute2 \
  ros-galactic-gazebo-ros-pkgs \
  ros-galactic-joint-state-publisher \
  ros-galactic-xacro \
  ros-galactic-plotjuggler-ros \
  ros-galactic-navigation2 \
  ros-galactic-nav2-bringup \
  ros-galactic-robot-localization \
  && apt-get -qq -y autoclean \
  && apt-get -qq -y autoremove \
  && apt-get -qq -y clean \
  && rm -rf /var/lib/apt/lists/*
# x11-apps is for testing the display with xeyes
# mesa-utils is for testing opengl with glxgears
# opencv is used by a lot of ros packages...
# libnss-mdns is for resolving .local names inside the container
# while avahi-daemon publishes
# iproute2 install things like ip, tc, etc.
# plotjuggler a much better tool than rqt_plot!

RUN python3 -m pip install --upgrade pip
# Solve the problem where pip complains about package versions...

# Remove old stuff
RUN pip uninstall --yes numpy && \
    pip uninstall --yes scipy && \
    pip install numpy && \
    pip install scipy

RUN echo "shopt -s histappend" >> /home/ros2user/.bashrc
RUN echo "PROMPT_COMMAND='history -a;history -n'" >> /home/ros2user/.bashrc
# The two lines above are used with the launch_ros_desktop.sh so
# we have access to the .bash_history from the host.

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /etc/.bashrc
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/ros2user/.bashrc
# It's necessary to add to .bashrc if you want to start the container with bash
# and have the auto completion working for ros2 stuff out of the box...


ENV TERM xterm-256color
# For a colourful terminal...

COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY ros_entrypoint.sh /ros_entrypoint.sh

ENV ROS_DISTRO $ROS_DISTRO
ENTRYPOINT ["/ros_entrypoint.sh"] # this is already defined in the base image...

CMD ["bash"]