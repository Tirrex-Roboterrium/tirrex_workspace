ARG FROM_IMAGE=osrf/ros:humble-desktop
ARG WORKSPACE=/opt/tirrex_ws
ARG REPOS_FILE=./repositories

# multi-stage for caching
FROM $FROM_IMAGE AS cacher

ARG WORKSPACE
ARG REPOS_FILE
WORKDIR $WORKSPACE
COPY $REPOS_FILE repos
RUN --mount=type=ssh \
    mkdir -pm 700 ~/.ssh && \
    ssh-keyscan github.com >>~/.ssh/known_hosts && \
    ssh-keyscan gitlab-ssh.irstea.fr >>~/.ssh/known_hosts && \
    ssh-keyscan forgemia.inra.fr >>~/.ssh/known_hosts && \
    vcs import --recursive -w6 <repos

# copy manifests for caching
WORKDIR /opt
RUN mkdir -p /tmp/opt && \
    find . -name "package.xml"   | xargs cp --parents -t /tmp/opt && \
    find . -name "COLCON_IGNORE" | xargs cp --parents -t /tmp/opt 2>/dev/null || true


# multi-stage for installing dependencies
FROM $FROM_IMAGE AS installer

# install some dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/lib/apt/lists \
    echo "deb [trusted=yes] https://download.eclipse.org/zenoh/debian-repo/ /" \
        >/etc/apt/sources.list.d/zenoh.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
      ros-${ROS_DISTRO}-rmw-zenoh-cpp \
      ros-${ROS_DISTRO}-rosbag2-storage-mcap \
      ros-${ROS_DISTRO}-plotjuggler-ros \
      zenoh-bridge-ros2dds \
      python3-pip && \
    rm -rf /var/lib/apt/lists/*

ARG WORKSPACE
WORKDIR $WORKSPACE

# install package dependencies
COPY --from=cacher /tmp/$WORKSPACE/src ./src
RUN --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && \
    rosdep install -iyr --from-paths src && \
    rm -rf /var/lib/apt/lists/*

# fix a bug when rendering shadows in gazebo
RUN sed -i '7i \ \ depth += 0.001;  // added to fix a bug' \
   /usr/share/gazebo-11/media/materials/programs/shadow_caster_fp.glsl

# multi-stage for developing
FROM installer AS dever

RUN --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      gdb gdbserver valgrind strace && \
    rm -rf /var/lib/apt/lists/*

ARG WORKSPACE
WORKDIR $WORKSPACE
ENV SHELL=/bin/bash
# Remove the cloned projects to use a volume instead
RUN rm -rf "$WORKSPACE"

COPY --chmod=755 ros_entrypoint.sh ros_setup.sh /

RUN echo 'source <(register-python-argcomplete3 ros2)' >>/etc/bash.bashrc

FROM dever AS debug
