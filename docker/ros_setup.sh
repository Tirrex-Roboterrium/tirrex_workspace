#!/bin/bash
set -e
source /usr/share/gazebo/setup.sh
source /opt/ros/$ROS_DISTRO/setup.bash

# The TIRREX_WORKSPACE variable is only defined in workspaces that extend this one
if [[ -n "$TIRREX_WORKSPACE" && "$TIRREX_WORKSPACE" != "$WORKSPACE" ]] ; then
  if [[ -r "$TIRREX_WORKSPACE/install/local_setup.bash" ]] ; then
    source "$TIRREX_WORKSPACE/install/local_setup.bash"
  else
    if [[ -e "$TIRREX_WORKSPACE" ]] ; then
      echo >&2 "Error: env TIRREX_WORKSPACE is defined but is not compiled."
      echo >&2 "You have to go in this directory and build it:"
      echo >&2 "  cd $TIRREX_WORKSPACE"
      echo >&2 "  docker compose run --rm compile"
    else
      echo >&2 "Error: Workspace '$TIRREX_WORKSPACE' does not exist."
    fi
    exit 1
  fi

  export GAZEBO_RESOURCE_PATH="$TIRREX_WORKSPACE/gazebo:$GAZEBO_RESOURCE_PATH"
  export GAZEBO_MODEL_PATH="$TIRREX_WORKSPACE/gazebo/models:$GAZEBO_MODEL_PATH"
fi

# The variable WORSPACE corresponds to the sub-workspace.
# It may also correspond to this workspace if it is directly called from a local docker service
if [[ -r "$WORKSPACE/install/local_setup.bash" ]] ; then
  source "$WORKSPACE/install/local_setup.bash"
fi

export RCUTILS_COLORIZED_OUTPUT=1
export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}] {name}: {message}"
export GAZEBO_RESOURCE_PATH="$WORKSPACE/gazebo:$GAZEBO_RESOURCE_PATH"
export GAZEBO_MODEL_PATH="$WORKSPACE/gazebo/models:$GAZEBO_MODEL_PATH"

exec $@
