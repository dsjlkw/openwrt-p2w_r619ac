#!/bin/sh
set -e -x

_vermagic="$(curl --retry 5 -L https://downloads.openwrt.org/snapshots/targets/ipq40xx/generic/openwrt-ipq40xx-generic.manifest | sed -e '/^kernel/!d' -e 's/^.*-\([^-]*\)$/\1/g' | head -n 1)"

OLD_CWD="$(pwd)"

[ "$(find build_dir/ -name .vermagic -exec cat {} \;)" = "$_vermagic" ] && \
mkdir ~/imb && \
tar -xJf bin/targets/ipq40xx/generic/openwrt-imagebuilder-ipq40xx-generic.Linux-x86_64.tar.xz -C ~/imb && \
cd ~/imb/* && \
mkdir -p packages && \
find $OLD_CWD/bin -depth -iname "ipq-wifi-p2w_r619ac*.ipk" -exec cp {} packages/ \; && \
echo "src custom file://""$(pwd)""/packages" >> repositories.conf && \
make image PROFILE='p2w_r619ac-128m' PACKAGES="kmod-usb-storage block-mount kmod-fs-ext4 luci luci-proto-qmi kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan kmod-usb-uhci kmod-usb-storage-uas kmod-usb-storage-extras luci-i18n-base-zh-cn wget ca-certificates" && \
mv bin/targets/ipq40xx/generic/openwrt-ipq40xx-generic-p2w_r619ac-128m-squashfs-nand-factory.ubi ../openwrt-minimal-ipq40xx-generic-p2w_r619ac-128m-squashfs-nand-factory.ubi && \
mv bin/targets/ipq40xx/generic/openwrt-ipq40xx-generic-p2w_r619ac-128m-squashfs-nand-sysupgrade.bin ../openwrt-minimal-ipq40xx-generic-p2w_r619ac-128m-squashfs-nand-sysupgrade.bin && \
make clean && \
mv ../*.bin ../*.ubi "$OLD_CWD/bin/targets/ipq40xx/generic/" && \
rm -rf bin/* && \
cd ~/imb/ && \
tar -cJf openwrt-imagebuilder-ipq40xx-generic.Linux-x86_64.tar.xz openwrt-imagebuilder-* && \
mv openwrt-imagebuilder-ipq40xx-generic.Linux-x86_64.tar.xz "$OLD_CWD/bin/targets"/*/*/

cd "$OLD_CWD/bin/targets"/*/*
mv openwrt-imagebuilder-* openwrt-sdk-* ..
rm -rf packages
tar -c * | xz -z -e -9 -T 0 > "../$(grep -i "openwrt-.*-sysupgrade.bin" *sums | head -n 1 | cut -d "*" -f 2 | cut -d - -f 1-5)-firmware.tar.xz"
rm -rf *
xz -d -c ../openwrt-imagebuilder-* | xz -z -e -9 -T 0 > "$(basename ../openwrt-imagebuilder-*)"
xz -d -c ../openwrt-sdk-* | xz -z -e -9 -T 0 > "$(basename ../openwrt-sdk-*)"
mv ../*-firmware.tar.xz .
rm -f ../openwrt-imagebuilder-* ../openwrt-sdk-* *sums
sha256sum * > ../sha256sums
mv ../sha256sums .
