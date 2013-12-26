#!/bin/sh

DEVICE="GCW Zero"
MOUNTLIST=/proc/mounts

export DIALOGOPTS="--colors --backtitle \"Unmount external storage\""
echo "screen_color = (RED,RED,ON)" > /tmp/dialog_err.rc

# Assemble the mount points that can be unmounted.

devices=$(ls -1 /dev/mmcblk[1-9]* /dev/sd[a-z]*)

# Here at least one can be unmounted. Prepare the argument list for the unmount dialog.
state=on
args=
for device in $devices
do
  if grep -E "^$device " "$MOUNTLIST" >/dev/null
  then
    if [ "${device:5:6}" = mmcblk ]
    then
      args="$args $device microSD $state"
    elif [ "${device:5:2}" = sd ]
    then
      args="$args $device USB $state"
    else
      args="$args $device $device $state"
    fi
    state=off
  fi
done

if [ -z "$args" ]
then
  dialog --msgbox "Your $DEVICE does not have external storage devices to unmount right now." 0 0
  exit 0
fi

device_to_umount=$(exec 3>&1; dialog --output-fd 3 --radiolist "Select the external storage device to unmount." 0 0 0 $args 3>&1 >&2; 3>&-)

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
    if ! grep -E "^$device_to_umount " "$MOUNTLIST" >/dev/null
    then
      dialog --msgbox "You can now safely remove the following external storage device from your $DEVICE:

$device_to_umount" 0 0
      exit 0
    else
      DIALOGRC=/tmp/dialog_err.rc dialog --msgbox "The external storage device was not unmounted and cannot be ejected safely from your $DEVICE.

umount exited with status code $umount_result

$umount_output" 0 0
      exit 1
    fi
  else
    dialog --msgbox "You can now safely remove the following external storage device from your $DEVICE:

$device_to_umount" 0 0
    exit 0
  fi
fi

