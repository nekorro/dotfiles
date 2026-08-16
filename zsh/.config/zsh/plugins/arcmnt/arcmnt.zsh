#!/bin/zsh
# Mount Arcadia and run post-mount commands

ARCMNT_POST_COMMANDS="${0:A:h}/post-mount.zsh"

function arcmnt() {
  local mount_point="$HOME/arcadia"

  if mountpoint -q "$mount_point" 2>/dev/null || mount | grep -q " on $mount_point "; then
    echo "Arcadia is already mounted at $mount_point"
    export ARCADIA_ROOT="$mount_point"
  else
    echo "Mounting Arcadia..."
    if ! arc mount "$mount_point"; then
      echo "Failed to mount Arcadia" >&2
      return 1
    fi
    export ARCADIA_ROOT="$mount_point"
    echo "Arcadia mounted at $mount_point"
  fi

  if [[ -f "$ARCMNT_POST_COMMANDS" ]]; then
    echo "Running post-mount commands..."
    source "$ARCMNT_POST_COMMANDS"
  fi
}
