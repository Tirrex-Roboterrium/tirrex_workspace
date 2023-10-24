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

# execute command as USER
sudo -snEHu $USER -- /ros_setup.sh $@
