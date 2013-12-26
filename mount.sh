#!/bin/sh

MOUNTLIST=/proc/mounts
DEVICE=/dev/mmcblk1p1
MOUNTPOINT=/media/sdcard

export DIALOGOPTS="--colors --backtitle \"Mount external microSD\""
echo "screen_color = (RED,RED,ON)" > /tmp/dialog_err.rc

existing_mount_line=$(grep "$DEVICE" "$MOUNTLIST")

if [ "x$existing_mount_line" != x ]
then
  existing_mountpoints=$(echo "$existing_mount_line" | cut -d" " -f2)
  dialog --msgbox "Your external microSD card is already mounted at the following locations:

$existing_mountpoints" 0 0
  exit 0
fi

mount_output=$(mount "$DEVICE" "$MOUNTPOINT" 2>&1)
mount_result=$?

if [ $mount_result -ne 0 ]
then
  DIALOGRC=/tmp/dialog_err.rc dialog --msgbox "Your external microSD card was not mounted.

mount exited with status code $mount_result

$mount_output" 0 0
  exit 1
else
  dialog --msgbox "You can now use your external microSD card at $MOUNTPOINT." 0 0
  exit 0
fi
