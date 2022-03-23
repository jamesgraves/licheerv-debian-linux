#!/usr/bin/env bash

set -eou pipefail

git submodule update --init --recursive

cwd=`pwd`

echo "Build RISC-V toolchain"
pushd riscv-gnu-toolchain
./configure --prefix=$cwd/riscv64-unknown-linux-gnu --with-arch=rv64gc --with-abi=lp64d
make linux -j `nproc`
export PATH=$cwd/riscv64-unknown-linux-gnu/bin:$PATH
popd

echo "Boot0 binary"
pushd sun20i_d1_spl
make CROSS_COMPILE=$cwd/riscv64-unknown-linux-gnu/bin/riscv64-unknown-linux-gnu- p=sun20iw1p1 mmc
popd

echo "OpenSBI binary"
pushd opensbi
make CROSS_COMPILE=$cwd/riscv64-unknown-linux-gnu/bin/riscv64-unknown-linux-gnu- PLATFORM=generic FW_PIC=y FW_OPTIONS=0x2
popd

echo "u-boot binary"
make CROSS_COMPILE=$cwd/riscv64-unknown-linux-gnu/bin/riscv64-unknown-linux-gnu- nezha_defconfig
make -j `nproc` ARCH=riscv CROSS_COMPILE=$cwd/riscv64-unknown-linux-gnu/bin/riscv64-unknown-linux-gnu- all V=1

echo "Generate u-boot table of contents"
./u-boot/tools/mkimage -T sunxi_toc1 -d licheerv_toc1.cfg u-boot.toc1`

echo "Linux kernel"
mkdir -p linux-build/arch/riscv/configs
cp licheerv_linux_defconfig linux-build/arch/riscv/configs/licheerv_defconfig
make ARCH=riscv -C linux O=$cwd/linux-build licheerv_defconfig
make -j `nproc` -C linux-build ARCH=riscv CROSS_COMPILE=$cwd/riscv64-unknown-linux-gnu/bin/riscv64-unknown-linux-gnu- V=1

echo "Realtek 8723DS WiFi Driver"
pushd rtl8723ds
make -j `nproc` ARCH=riscv CROSS_COMPILE=$cwd/riscv64-unknown-linux-gnu/bin/riscv64-unknown-linux-gnu- KSRC=$cwd/linux-build modules`
popd

echo "Successfully finished build process"
