.PHONY: all

all:
	mksquashfs umount.png umount.gcw0.desktop umount.sh COPYING AUTHORS esdmount.opk -noappend -no-exports -all-root -no-xattrs