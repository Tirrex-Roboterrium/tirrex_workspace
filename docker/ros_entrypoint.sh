#!/bin/bash
set -e

if [[ -z "$WORKSPACE" ]] ; then 
  echo >&2 "Missing environment variable 'WORKSPACE'"
  exit 1
fi

cd -- "$WORKSPACE"

ws_uid=$(stat -c "%u" "$WORKSPACE")

# execute command as USER if it is the owner of $WORKSPACE
if [[ $(id -u) = 0 && "$ws_uid" != 0 ]] ; then
  if [[ -z "$USER" && -z "$HOME" ]] ; then 
    echo >&2 "Missing environment variable 'USER' or 'HOME'"
    exit 2
  fi
  
  # create user if it does not exist
  if ! id -u "$USER" &>/dev/null ; then
    ws_gid=$(stat -c "%g" "$WORKSPACE")
    groupadd -g "$ws_gid" "$USER"
    useradd -u "$ws_uid" -g "$ws_gid" -s /bin/bash -d "$HOME" -G dialout "$USER"
  fi

  exec sudo -snEHu "$USER" -- /ros_setup.sh "$@"

else
  exec /ros_setup.sh "$@"
fi
