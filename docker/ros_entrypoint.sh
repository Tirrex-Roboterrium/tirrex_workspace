#!/bin/bash
set -e

if [[ -z "$WORKSPACE" ]] ; then 
  echo >&2 "Missing environment variable 'WORKSPACE'"
  exit 1
fi

if [[ -z "$USER" ]] ; then 
  echo >&2 "Missing environment variable 'USER'"
  exit 2
fi

cd -- "$WORKSPACE"

# execute command as USER
exec sudo -snEHu "$USER" -- /ros_setup.sh $@
