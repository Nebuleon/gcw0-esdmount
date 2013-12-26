#!/bin/sh

MOUNTLIST=/proc/mounts

export DIALOGOPTS="--colors --backtitle \"Unmount external microSD\""
echo "screen_color = (RED,RED,ON)" > /tmp/dialog_err.rc

# Assemble the mount points that can be unmounted.

mmcblk_devices="/dev/mmcblk[1-9]*"
if [ "$mmcblk_devices" = '/dev/mmcblk[1-9]*' ]
then
  mmcblk_devices=
fi

usb_devices="/dev/sd[a-z]*"
if [ "$usb_devices" = '/dev/sd[a-z]*' ]
then
  usb_devices=
fi

devices="$mmcblk_devices $usb_devices"
echo "$devices"
if [ -z "$devices" ]
then
  dialog --msgbox "You have no storage devices to unmount." 0 0
  exit 0
fi

# Here at least one can be unmounted. Prepare the argument list for the unmount dialog.
args=
for device in $devices
do
  args="$args "$device" "$device" ''"
done

device_to_umount=$(exec 3>&1; dialog --output-fd 3 --radiolist "Select the device to unmount." 0 0 0 $args 3>&1 >&2; 3>&-)

if [ -z "$device_to_umount" ]
then
  exit 0  # Cancelled
else
  umount_output=$(umount "$device_to_umount" 2>&1)
  umount_result=$?

  if [ $umount_result -ne 0 ]
  then
    # It's possible that umount says it failed, but it really didn't.
    # Double-check before reporting this as a failure.
    if ! grep "$device_to_umount" "$MOUNTLIST"
    then
      dialog --msgbox "You can now safely remove the following device:

$device_to_umount" 0 0
      exit 0
    else
      DIALOGRC=/tmp/dialog_err.rc dialog --msgbox "The device was not unmounted and cannot be ejected safely.

umount exited with status code $umount_result

$umount_output" 0 0
      exit 1
    fi
  else
    dialog --msgbox "You can now safely remove the following device:

$device_to_umount" 0 0
    exit 0
  fi
fi

