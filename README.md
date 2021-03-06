# licheerv-debian-linux

Build scripts for creating a Debian GNU/Linux image for the Lichee RV
RISC-V board on a Linux host system.

Based on build instructions created by Andreas Jung:

https://andreas.welcomes-you.com/boot-sw-debian-risc-v-lichee-rv/

Disclaimer
==========

The `write_sd_card.sh` script will write data to the specified storage device. Make sure
the device specified is the micro-SD card you intend to erase and write the
operating system image on. Run the `dmesg` command after inserting
the micro-SD card to see what the storage device name is.

Instructions
============

Debian-based host operating system (Debian, Ubuntu, Mint) can use the
`prepare_debian_host.sh` script to install OS packages needed for the
build process.  TODO: add support for RPM based Linux systems.

Second, run `build.sh` to download (if needed) and build the various
software packages needed for the Lichee RV image. This includes the GNU
cross-compile toolchain.  This can take a long time.

Third, run `setup_rootfs.sh` to download the minimal Debian root
filesystem into the `rootfs` directory, and prepare it for running.

Fourth, run `write_sd_card.sh /dev/sdX` (where 'X' corresponds to the micro-SD card
device on the host system) to write a bootable image onto a micro-SD
card for use with the Lichee RV board.

Running
=======

This image currently does not have the HDMI working.

Install the micro-SD card in the Lichee RV, connect the serial console,
and power it on.

Login with username `root` and password `licheerv`.
