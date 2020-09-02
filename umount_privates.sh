#!/bin/bash

dbus-monitor --session "type='signal',interface='com.ubuntu.Upstart0_6'" |
(
  while true; do
    read X
    if echo $X | grep "desktop-lock" &> /dev/null; then
        # SCREEN_LOCKED;
        ecryptfs-umount-private
    elif echo $X | grep "desktop-unlock" &> /dev/null; then
        # SCREEN_UNLOCKED;
        /bin/echo -ne ""
    fi
  done
)
