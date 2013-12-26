#!/bin/sh

MOUNTLIST=/proc/mounts
DEVICE=/dev/mmcblk1p1

export DIALOGOPTS="--colors --backtitle \"Unmount external microSD\""
echo "screen_color = (RED,RED,ON)" > /tmp/dialog_err.rc

existing_mount_line=$(grep "$DEVICE" "$MOUNTLIST")

if [ "x$existing_mount_line" == x ]
then
  dialog --msgbox "Your external microSD card was already unmounted and can now be ejected safely." 0 0
  exit 0
fi

umount_output=$(umount "$DEVICE" 2>&1)
umount_result=$?

if [ $umount_result -ne 0 ]
then
  # It's possible that umount says it failed, but it really didn't.
  # Double-check before reporting this as a failure.
  if ! grep "$DEVICE" "$MOUNTLIST"
  then
    dialog --msgbox "You can now safely eject your external microSD card." 0 0
    exit 0
  else
    DIALOGRC=/tmp/dialog_err.rc dialog --msgbox "Your external microSD card was not unmounted and cannot be ejected safely.

umount exited with status code $umount_result

$umount_output" 0 0
    exit 1
  fi
else
  dialog --msgbox "You can now safely eject your external microSD card." 0 0
  exit 0
fi
