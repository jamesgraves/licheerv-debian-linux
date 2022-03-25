#!/usr/bin/env bash

set -eou pipefail

read -p "Type in WLAN SSID: " WLAN_SSID
read -s -p "Type in WLAN secret key: " WLAN_SECRET
echo ""

keyring_option="--keyring /usr/share/keyrings/debian-ports-archive-keyring.gpg"
if [ $# -eq 1 ]; then
	if [ $1 = "--no-check-gpg" ]; then
		keyring_option="--no-check-gpg"
	fi
fi

if sudo debootstrap --arch=riscv64 ${keyring_option} --components main,contrib,non-free --include=debian-ports-archive-keyring,pciutils,autoconf,automake,autotools-dev,curl,python3,libmpc-dev,libmpfr-dev,libgmp-dev,gawk,build-essential,bison,flex,texinfo,gperf,libtool,patchutils,bc,zlib1g-dev,wpasupplicant,htop,net-tools,wireless-tools,firmware-realtek,ntpdate,openssh-client,openssh-server,sudo,e2fsprogs,git,man-db,lshw,dbus,wireless-regdb,libsensors5,lm-sensors,swig,libssl-dev,python3-distutils,python3-dev,alien,fakeroot,dkms,libblkid-dev,uuid-dev,libudev-dev,libaio-dev,libattr1-dev,libelf-dev,python3-setuptools,python3-cffi,python3-packaging,libffi-dev,libcurl4-openssl-dev,python3-ply,iotop,tmux,psmisc unstable rootfs http://deb.debian.org/debian-ports
then
	echo "Created rootfs"
else
	echo "Failed to create rootfs using debootstrap."
	echo "If the error is that the keyring is missing or out-of-date,"
	echo "this command can be re-run with the --no-check-gpg option."
fi

pushd linux-build
sudo make modules_install ARCH=riscv INSTALL_MOD_PATH=../rootfs KERNELRELEASE=5.17.0-rc2-379425-g06b026a8b714
popd

sudo install -D -p -m 644 rtl8723ds/8723ds.ko rootfs/lib/modules/5.17.0-rc2-379425-g06b026a8b714/kernel/drivers/net/wireless/8723ds.ko
sudo rm rootfs/lib/modules/5.17.0-rc2-379425-g06b026a8b714/build
sudo rm rootfs/lib/modules/5.17.0-rc2-379425-g06b026a8b714/source
sudo depmod -a -b rootfs 5.17.0-rc2-379425-g06b026a8b714
sudo sh -c 'echo "8723ds" >> rootfs/etc/modules'

echo "Set root user password to: licheerv"
sudo sed -i 's/^root.*$/root:$1$root$sOsYxD2g.F8d7oZbbEt.m1:19072:0:99999:7:::/' rootfs/etc/shadow
sudo cp fstab rootfs/etc/

sudo rm -f /tmp/wlan0_contents
cat > /tmp/wlan0_contents << EOF
allow-hotplug wlan0
iface wlan0 inet dhcp
	wpa-ssid ${WLAN_SSID}
	wpa-psk ${WLAN_SECRET}
EOF
sudo cp /tmp/wlan0_contents rootfs/etc/network/interfaces.d/
sudo rm /tmp/wlan0_contents

echo "Set host name to 'licheerv'"
sudo sh -c 'echo licheerv > rootfs/etc/hostname'
sudo sh -c 'echo "@reboot for i in 1 2 3 4 5; do /usr/sbin/ntpdate 0.europe.pool.ntp.org && break || sleep 15; done" >> rootfs/var/spool/cron/crontabs/root'
sudo chmod 600 rootfs/var/spool/cron/crontabs/root

