# licheerv-debian-linux
Build scripts for creating a Debian GNU/Linux image for the Lichee RV RISC-V board

Based on build instructions created by Andreas Jung:

https://andreas.welcomes-you.com/boot-sw-debian-risc-v-lichee-rv/

Disclaimer
==========

The `burn.sh` script will write data to the specified storage device. Make sure
the device specified is the micro-SD card you intend to erase and write the
operating system image on.

Instructions
============

Debian-based host operating system (Debian, Ubuntu, Mint) can use the
`prepare_debian_host.sh` script to install OS packages needed for the
build process.  TODO: add support for RPM based Linux systems.

Run `build.sh` to download (if needed) and build the various software packages
needed for the Lichee RV image.

Run `create_rootfs.sh` to download the Debian root filesystem into the `rootfs`
directory, and prepare that for boot.

Run `burn.sh /dev/sdX` (where 'X' corresponds to the micro-SD card
device on the host system) to write a bootable image onto a micro-SD
card for use with the Lichee RV board.

Running
=======

This image currently does not have the HDMI working.

Install the micro-SD card in the Lichee RV, connect the serial console,
and power it on.

Login with username `root` and password `licheerv`.
