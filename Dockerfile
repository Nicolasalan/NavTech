# Ubuntu 20.04 image with NVIDIA CUDA + OpenGL and ROS Noetic
FROM nvidia/cuda:11.8.0-base-ubuntu20.04 

# Install basic apt packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y locales lsb-release
RUN dpkg-reconfigure locales

# Install ROS Noetic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update \
 && apt-get install -y --no-install-recommends ros-noetic-ros-base
RUN apt-get install -y --no-install-recommends python3-rosdep
RUN rosdep init \
 && rosdep fix-permissions \
 && rosdep update
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]

# Setup minimal
RUN apt-get update

# Install dependencies
RUN apt-get install -q -y --no-install-recommends \
  build-essential \
  apt-utils \
  cmake \
  g++ \
  git \
  libcanberra-gtk* \
  python3-catkin-tools \
  python3-pip \
  python3-tk \
  python3-yaml \
  python3-dev \
  python3-numpy \
  python3-rosinstall \
  python3-catkin-pkg \
  python3-rosdistro \
  python3-rospkg \
  wget \
  curl \
  vim 

# Install dependencies ros
RUN apt-get update && apt-get install -y ros-noetic-ros-controllers \
 && apt-get install -y ros-noetic-joint-state-controller \
 && apt-get install -y ros-noetic-joint-state-publisher \
 && apt-get install -y ros-noetic-robot-state-publisher \
 && apt-get install -y ros-noetic-robot-state-controller \
 && apt-get install -y ros-noetic-xacro \ 
 && apt-get install -y ros-noetic-smach-ros \
 && apt-get install -y ros-noetic-gazebo-ros \
 && apt-get install -y ros-noetic-gazebo-ros-control \
 && apt-get install -y ros-noetic-rplidar-ros \
 && apt-get install -y ros-noetic-driver-base \
 && apt-get install -y ros-noetic-rosserial-arduino \
 && apt-get install -y ros-noetic-map-server \
 && apt-get install -y ros-noetic-gazebo-ros-pkgs

# install pytorch
RUN pip install torch

RUN pip3 install tensorboard

# create a catkin workspace
RUN mkdir -p /ws/src \
 && cd /ws/src \
 && source /opt/ros/noetic/setup.bash \
 && catkin_init_workspace \
 && git clone -b master https://github.com/Nicolasalan/motion.git 

# Copy the source files
COPY ./src/ /ws/src/

# Set the working directory
WORKDIR /ws

# Build the Catkin workspace
RUN cd /ws \
 && source /opt/ros/noetic/setup.bash \
 && rosdep install -y --from-paths src --ignore-src \
 && catkin build

# Setup bashrc
RUN echo "source /ws/devel/setup.bash" >> ~/.bashrc 

# Install python dependencies
RUN cd /ws && pip3 install -r requirements.txt

# Remove display warnings
RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
ENV NO_AT_BRIDGE 1

# command to run on container start
ENTRYPOINT [ "/ws/entrypoint.sh" ]