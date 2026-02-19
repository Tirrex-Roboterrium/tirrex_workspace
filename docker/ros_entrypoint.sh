#!/bin/bash
if [[ -z "$WORKSPACE" ]] ; then 
  echo >&2 "Missing environment variable 'WORKSPACE'"
  exit 1
fi

cd -- "$WORKSPACE"

ws_uid=$(stat -c '%u' "$WORKSPACE")
ws_user=$(stat -c '%U' "$WORKSPACE")

# execute command as USER if it is the owner of $WORKSPACE
if [[ $(id -u) = 0 && "$ws_uid" != 0 && "$ws_user" != 'nobody' ]] ; then
  if [[ -z "$USER" && -z "$HOME" ]] ; then 
    echo >&2 "Missing environment variable 'USER' or 'HOME'"
    exit 2
  fi

  # create user if it does not exist
  if ! id -u "$USER" &>/dev/null ; then
    ws_gid=$(stat -c '%g' "$WORKSPACE")
    groupadd -g "$ws_gid" "$USER"
    useradd -u "$ws_uid" -g "$ws_gid" -s /bin/bash -d "$HOME" -G dialout "$USER"

    # if HOME is not mounted, chown it and install default skeleton
    if [[ $(stat -c '%u' "$HOME") = 0 ]] ; then
      chown -f -- "$USER:" "$HOME" "$HOME/.config"

      if [[ ! -e "$HOME/.bashrc" ]] ; then
        sudo -u "$USER" cp -a /etc/skel/. "$HOME"
      fi
    fi
  fi

  # provide full access to graphic cards and input devices
  chmod -Rf o+rw /dev/dri /dev/input

  # provide full acess to serial devices
  if [[ -d /dev/serial ]] ; then
    find -L -type c -exec chmod o+rw '{}' \;
  fi

  exec sudo -snEHu "$USER" -- /ros_setup.sh "$@"

# for podman or docker rootless, ros_setup.sh is executed as root
else
  # if the HOME dir is not /root (env specified in the compose.yaml), it may not contain .bashrc
  if [[ ! -e "$HOME/.bashrc" ]] ; then
    cp -a /etc/skel/. "$HOME"
  fi

  exec /ros_setup.sh "$@"
fi
