#!/bin/bash
set -e

# override TIRREX_WORKSPACE if it is the full docker image
if [[ -n "$TIRREX_IMAGE_FULL" ]] ; then
  export TIRREX_WORKSPACE='/opt/tirrex_ws'
fi

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
exec sudo -snEHu "$USER" -- /ros_setup.sh $@
