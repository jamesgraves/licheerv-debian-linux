#!/usr/bin/env bash

set -eou pipefail

#
# Check micro-SD card
#

if [ $# -ne 2 ]; then
	echo "Specify SD card device (such as /dev/sdc) on command line"
	exit 1
fi

SD_CARD=$1

#
# Check that all partitions on SD card are unmounted.
#
if [ -b ${SD_CARD} ]; then
	for partitions in ${SD_CARD}[1-9]
	do
		if mount | grep --quiet ${partition} ; then
			echo "${partition} is currently mounted."
			echo "You may need to manually umount it:"
			echo "   umount ${partition}"
			exit 1
		fi
	done
else
	echo "SD card device not found: ${SD_CARD}"
	exit 1
fi

set -x

echo "Erase existing partition table"
sudo dd if=/dev/zero of=${SD_CARD} bs=1M count=200
echo "Create new GPT parititon table and partitions"
sudo parted -s -a optimal -- ${SD_CARD} mklabel gpt
sudo parted -s -a optimal -- ${SD_CARD} mkpart primary ext2 40MiB 100MiB
sudo parted -s -a optimal -- ${SD_CARD} mkpart primary ext4 100MiB -1GiB
sudo parted -s -a optimal -- ${SD_CARD} mkpart primary linux-swap -1GiB 100%
echo "Create filesystems and swap space"
sudo mkfs.ext2 ${SD_CARD}1
sudo mkfs.ext4 ${SD_CARD}2
sudo mkswap ${SD_CARD}3
echo "Write SPL"
sudo dd if=sun20i_d1_spl/nboot/boot0_sdcard_sun20iw1p1.bin of=${SD_CARD} bs=8192 seek=16
echo "Write u-boot table of contents"
sudo dd if=u-boot.toc1 of=${SD_CARD} bs=512 seek=32800
sudo mkdir -p /mnt/sdcard_boot
sudo mkdir -p /mnt/sdcard_rootfs
echo "Copy files to /boot partition"
sudo mount ${SD_CARD}1 /mnt/sdcard_boot
sudo cp linux-build/arch/riscv/boot/Image.gz /mnt/sdcard_boot
sudo cp boot.scr /mnt/sdcard_boot
sudo umount /mnt/sdcard_boot
echo "Copy files to root filesystem"
sudo mount ${SD_CARD}2 /mnt/sdcard_rootfs
sudo cp -a rootfs/* /mnt/sdcard_rootfs/
sudo umount /mnt/sdcard_rootfs
sudo rmdir /mnt/sdcard_boot
sudo rmdir /mnt/sdcard_rootfs
echo "Successfully finished writing Lichee RV image to ${SD_CARD}"
