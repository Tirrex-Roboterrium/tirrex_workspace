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
    ssh-keyscan forge.inrae.fr >>~/.ssh/known_hosts && \
    vcs import --recursive --shallow -w6 <repos

# copy manifests for caching
WORKDIR /opt
RUN mkdir -p /tmp/opt && \
    find . -name "package.xml"   | xargs cp --parents -t /tmp/opt && \
    find . -name "COLCON_IGNORE" | xargs cp --parents -t /tmp/opt 2>/dev/null || true


# compile fields2cover library with python interface
FROM ${FROM_IMAGE} AS f2c_builder
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl build-essential ca-certificates cmake \
        doxygen g++ git libeigen3-dev libgdal-dev libpython3-dev python3 python3-pip \
        python3-matplotlib python3-tk lcov libgtest-dev libtbb-dev swig libgeos-dev \
        gnuplot libtinyxml2-dev nlohmann-json3-dev libfftw3-dev

RUN git clone --depth 1 'https://github.com/Fields2Cover/Fields2Cover.git' /tmp/f2c && \
    mkdir /tmp/f2c/build && \
    cd /tmp/f2c/build && \
    cmake -DBUILD_PYTHON=ON -DBUILD_TEST=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/f2c .. && \
    make -j && \
    make install && \
    ( find /opt/f2c ! -iregex '.*\(fields2cover\|matplot\|steering_functions\|libortools\.so\).*' -delete || true )


# compile romea_path_editor
FROM ${FROM_IMAGE} AS path_editor_builder
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgdal-dev qtbase5-dev

RUN git clone --depth 1 'https://forge.inrae.fr/cyrille.pierre/romea_path_editor.git' /tmp/rpe && \
    mkdir /tmp/rpe/build && \
    cd /tmp/rpe/build && \
    cmake -DBUILD_PYTHON=ON -DBUILD_TEST=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/rpe .. && \
    make -j && \
    make install && \
    ldconfig


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
      ros-${ROS_DISTRO}-ros-gz \
      ros-${ROS_DISTRO}-ros2-control \
      ros-${ROS_DISTRO}-ros2-control-cmake \
      ros-${ROS_DISTRO}-gz-ros2-control \
      ros-${ROS_DISTRO}-gz-cmake-vendor \
      ros-${ROS_DISTRO}-moveit \
      gnome-terminal \
      libgdal34t64 \
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

# install compiled programs and libraries
COPY --from=f2c_builder /opt/f2c/ /opt/ros/$ROS_DISTRO/
COPY --from=path_editor_builder /opt/rpe/ /usr/local/

COPY --chmod=755 docker/ros_entrypoint.sh docker/ros_setup.sh /

RUN echo 'source <(register-python-argcomplete ros2)' >>/etc/bash.bashrc && \
    echo 'source <(register-python-argcomplete colcon)' >>/etc/bash.bashrc && \
    userdel -r ubuntu && \
    ldconfig

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
    colcon build --event-handlers log- event_log- log_command- --cmake-args -DBUILD_TESTING=OFF && \
    rm -rf build log

COPY demos $WORKSPACE/demos
RUN --mount=type=bind,source=scripts/update_models,dst=scripts/update_models \
    ./scripts/update_models

# these variables will be overrided by an overlay workspace (if there is one)
ENV TIRREX_WORKSPACE=${WORKSPACE} \
    WORKSPACE=${WORKSPACE} \
    USER=root
