# licheerv-debian-linux
Build scripts for creating a Debian GNU/Linux image for the Lichee RV RISC-V board

Based on build instructions created by Andreas Jung:

https://andreas.welcomes-you.com/boot-sw-debian-risc-v-lichee-rv/

Instructions
============

Debian-based host operating system (Debian, Ubuntu, Mint) can use the
`prepare_debian_host.sh` script to install OS packages needed for the
build process.  TODO: add support for RPM based Linux systems.

Run `build.sh` to download (if needed) and build the various software packages
needed for the Lichee RV image.

Run `burn.sh` to write a bootable image onto a micro-SD card for use with the
Lichee RV board.
