#!/bin/bash
set -e

if [[ -z "$WORKSPACE" ]] ; then 
  echo >&2 "Missing environment variable 'WORKSPACE'"
  exit 1
fi

cd -- "$WORKSPACE"

# execute command as USER if it is the owner of $WORKSPACE
if [[ $(id -u) = 0 && $(stat -c "%u" "$WORKSPACE") != 0 ]] ; then
  if [[ -z "$USER" ]] ; then 
    echo >&2 "Missing environment variable 'USER'"
    exit 2
  fi
  
  exec sudo -snEHu "$USER" -- /ros_setup.sh $@

else
  exec /ros_setup.sh $@
fi
