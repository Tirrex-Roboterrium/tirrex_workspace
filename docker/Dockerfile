ARG FROM_IMAGE=docker.io/osrf/ros:jazzy-desktop
ARG WORKSPACE=/opt/tirrex_ws
ARG REPOS_FILE=./repositories

# multi-stage for caching
FROM $FROM_IMAGE AS cacher

ARG WORKSPACE
ARG REPOS_FILE
WORKDIR $WORKSPACE
COPY docker/$REPOS_FILE repos
RUN --mount=type=ssh \
    mkdir -pm 700 ~/.ssh && \
    ssh-keyscan github.com >>~/.ssh/known_hosts && \
    ssh-keyscan gitlab-ssh.irstea.fr >>~/.ssh/known_hosts && \
    ssh-keyscan forge.inrae.fr >>~/.ssh/known_hosts && \
    vcs import --recursive --shallow -w6 <repos

# copy manifests for caching
WORKDIR /opt
RUN mkdir -p /tmp/opt && \
    find . -name "package.xml"   | xargs cp --parents -t /tmp/opt && \
    find . -name "COLCON_IGNORE" | xargs cp --parents -t /tmp/opt 2>/dev/null || true


# multi-stage to install dependencies
FROM $FROM_IMAGE AS installer

# install some dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/lib/apt/lists \
    curl -L https://download.eclipse.org/zenoh/debian-repo/zenoh-public-key \
      | gpg --dearmor --yes --output /etc/apt/keyrings/zenoh-public-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/zenoh-public-key.gpg] https://download.eclipse.org/zenoh/debian-repo/ /" \
      >/etc/apt/sources.list.d/zenoh.list && \
    curl https://packages.osrfoundation.org/gazebo.gpg -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" && \
      > /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    curl -L https://packages.clearpathrobotics.com/public.key | gpg --dearmor --yes -o /etc/apt/keyrings/clearpathrobotics.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/clearpathrobotics.gpg] https://packages.clearpathrobotics.com/stable/ubuntu $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/clearpath-latest.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
      ros-${ROS_DISTRO}-rmw-zenoh-cpp \
      ros-${ROS_DISTRO}-rosbag2-storage-mcap \
      ros-${ROS_DISTRO}-plotjuggler-ros \
      zenoh-bridge-ros2dds \
      # libgz-cmake4-dev \
      ros-${ROS_DISTRO}-ros-gz \
      ros-${ROS_DISTRO}-ros2-control \
      ros-${ROS_DISTRO}-ros2-control-cmake \
      ros-${ROS_DISTRO}-gz-ros2-control \
      ros-${ROS_DISTRO}-gz-cmake-vendor \
      # ros-${ROS_DISTRO}-clearpath-description \
      # ros-${ROS_DISTRO}-clearpath-common \
      # ros-${ROS_DISTRO}-clearpath-config \
      # ros-${ROS_DISTRO}-clearpath-msgs \
      ros-${ROS_DISTRO}-moveit \
      # ros-${ROS_DISTRO}-gz-sim \
      # ros-${ROS_DISTRO}-gz-plugin \
      # ros-${ROS_DISTRO}-gz-sensors \
      # ros-${ROS_DISTRO}-gz-tools-vendor \
      python3-pip && \
    rm -rf /var/lib/apt/lists/*

ARG WORKSPACE
WORKDIR $WORKSPACE

# install package dependencies
ENV PIP_BREAK_SYSTEM_PACKAGES=1
COPY --from=cacher /tmp/$WORKSPACE/src ./src
RUN --mount=type=cache,target=/var/lib/apt/lists \
    curl -L 'https://raw.githubusercontent.com/clearpathrobotics/public-rosdistro/master/rosdep/50-clearpath.list' \
      -o /etc/ros/rosdep/sources.list.d/50-clearpath.list && \
    apt-get update && \
    rosdep update && \
    rosdep install -iyr --from-paths src && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=755 docker/ros_entrypoint.sh docker/ros_setup.sh /

RUN echo 'source <(register-python-argcomplete ros2)' >>/etc/bash.bashrc && \
    echo 'source <(register-python-argcomplete colcon)' >>/etc/bash.bashrc


# multi-stage for developing
FROM installer AS dever

# RUN --mount=type=cache,target=/var/lib/apt/lists \
#     apt-get update && \
#     apt-get install -y --no-install-recommends \
#       gdb gdbserver valgrind strace && \
#     rm -rf /var/lib/apt/lists/*

ARG WORKSPACE
WORKDIR $WORKSPACE
ENV SHELL=/bin/bash
# Remove the cloned projects to use a volume instead
RUN rm -rf "$WORKSPACE"


# multi-stage to compile the workspace inside the image
FROM installer AS builder
ARG WORKSPACE
COPY --from=cacher ${WORKSPACE} ${WORKSPACE}

WORKDIR $WORKSPACE
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    colcon build --event-handlers log- event_log- log_command- && \
    rm -rf build log

COPY demos $WORKSPACE/demos
RUN --mount=type=bind,source=scripts/update_models,dst=scripts/update_models \
    ./scripts/update_models

# these variables will be overrided by an overlay workspace (if there is one)
ENV TIRREX_WORKSPACE=${WORKSPACE} \
    WORKSPACE=${WORKSPACE} \
    USER=root
