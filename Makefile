.PHONY: all

all:
	mksquashfs mount.png umount.png mount.gcw0.desktop umount.gcw0.desktop mount.sh umount.sh COPYING AUTHORS esdmount.opk -noappend -no-exports -all-root -no-xattrs