#!/bin/bash
set -e
source /usr/share/gazebo/setup.sh
source /opt/ros/$ROS_DISTRO/setup.bash
source $WORKSPACE/install/local_setup.bash || true
export RCUTILS_COLORIZED_OUTPUT=1
export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}] {name}: {message}"
exec $@
