#!/bin/bash
set -e

if [[ -z "$WORKSPACE" ]] ; then 
  echo >&2 "Missing environment variable 'WORKSPACE'"
  exit 1
fi
cd -- "$WORKSPACE"

if [[ -z "$USER" ]] ; then 
  echo >&2 "Missing environment variable 'USER'"
  exit 2
fi

# joy_node needs to access joysticks via event interface
if [[ -d "/dev/input" ]] ; then
  chmod -R o+rw /dev/input
fi

# execute command as USER
exec sudo -snEHu "$USER" -- /ros_setup.sh $@
