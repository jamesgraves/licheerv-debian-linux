#!/usr/bin/env bash

set -eou pipefail

sudo apt install \
	autoconf automake autotools-dev curl python3 libmpc-dev \
	libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo \
	gperf libtool patchutils bc zlib1g-dev libexpat-dev swig \
	libssl-dev python3-setuptools python3-dev \
	debootstrap debian-ports-archive-keyring \
	qemu-user-static qemu-system qemu-utils qemu-system-misc binfmt-support
