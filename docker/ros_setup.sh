#!/bin/bash
set -e
source /usr/share/gazebo/setup.sh
source /opt/ros/$ROS_DISTRO/setup.bash
source $WORKSPACE/install/local_setup.bash || true

export RCUTILS_COLORIZED_OUTPUT=1
export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}] {name}: {message}"
export GAZEBO_RESOURCE_PATH="$WORKSPACE/gazebo:$GAZEBO_RESOURCE_PATH"
export GAZEBO_MODEL_PATH="$WORKSPACE/gazebo/models:$GAZEBO_MODEL_PATH"

exec $@
