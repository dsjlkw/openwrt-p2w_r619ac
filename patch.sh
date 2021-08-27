#!/bin/sh
set -e -x

echo '
define Build/qsdk-ipq-factory-nand
	$(TOPDIR)/scripts/mkits-qsdk-ipq-image.sh \
		$@.its ubi $@
	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -f $@.its $@.new
	@mv $@.new $@
endef

define Build/qsdk-ipq-factory-nor
	$(TOPDIR)/scripts/mkits-qsdk-ipq-image.sh \
		$@.its hlos $(IMAGE_KERNEL) rootfs $(IMAGE_ROOTFS)
	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -f $@.its $@.new
	@mv $@.new $@
endef' >> include/image-commands.mk

sed -i 's/ALLWIFIBOARDS[ \t]*:=/ALLWIFIBOARDS:= p2w_r619ac /' package/firmware/ipq-wifi/Makefile
sed -i '/$(eval $(call [^,]*,linksys_ea8300,[^)]*))/a$(eval $(call generate-ipq-wifi-package,p2w_r619ac,board-p2w_r619ac.qca4019,P&W R619AC))' package/firmware/ipq-wifi/Makefile

curl --retry 5 -L https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/firmware/ipq-wifi/board-p2w_r619ac.qca4019 > package/firmware/ipq-wifi/board-p2w_r619ac.qca4019  ## From lean
#curl --retry 5 -L https://raw.githubusercontent.com/x-wrt/x-wrt/master/package/firmware/ipq-wifi/board-p2w_r619ac.qca4019 > package/firmware/ipq-wifi/board-p2w_r619ac.qca4019  ## From X-WRT

curl --retry 5 -L https://raw.githubusercontent.com/coolsnowwolf/lede/master/scripts/mkits-qsdk-ipq-image.sh > scripts/mkits-qsdk-ipq-image.sh

sed -i '/\*)/i\p2w,r619ac |\\' target/linux/ipq40xx/base-files/etc/board.d/01_leds  ## x-wrt have not
sed -i '/\*)/i\p2w,r619ac-128m)' target/linux/ipq40xx/base-files/etc/board.d/01_leds  ## x-wrt have not
sed -i '/\*)/i\\tucidef_set_led_wlan "wlan2g" "WLAN2G" "r619ac:blue:wlan2g" "phy0tpt"' target/linux/ipq40xx/base-files/etc/board.d/01_leds  ## x-wrt have not
sed -i '/\*)/i\\tucidef_set_led_wlan "wlan5g" "WLAN5G" "r619ac:blue:wlan5g" "phy1tpt"' target/linux/ipq40xx/base-files/etc/board.d/01_leds  ## x-wrt have not
sed -i '/\*)/i\\t;;' target/linux/ipq40xx/base-files/etc/board.d/01_leds  ## x-wrt have not

sed -i '/asus,rt-ac58u|/a\\tp2w,r619ac|\\' target/linux/ipq40xx/base-files/etc/board.d/02_network
sed -i '/asus,rt-ac58u|/a\\tp2w,r619ac-128m|\\' target/linux/ipq40xx/base-files/etc/board.d/02_network
sed -i '/asus,rt-ac58u)/i\\tp2w,r619ac-128m|\\' target/linux/ipq40xx/base-files/etc/board.d/02_network
sed -i '/asus,rt-ac58u)/i\\tp2w,r619ac)' target/linux/ipq40xx/base-files/etc/board.d/02_network
sed -i '/asus,rt-ac58u)/i\\t\tlan_mac=$(cat /sys/class/net/eth0/address)' target/linux/ipq40xx/base-files/etc/board.d/02_network
sed -i '/asus,rt-ac58u)/i\\t\twan_mac=$(macaddr_add "$lan_mac" 1)' target/linux/ipq40xx/base-files/etc/board.d/02_network
sed -i '/asus,rt-ac58u)/i\\t\tlabel_mac=$lan_mac' target/linux/ipq40xx/base-files/etc/board.d/02_network
sed -i '/asus,rt-ac58u)/i\\t\t;;' target/linux/ipq40xx/base-files/etc/board.d/02_network

sed -i '/"ath10k\/pre-cal-pci-0000:01:00.0.bin")/a\\tfi' target/linux/ipq40xx/base-files/etc/hotplug.d/firmware/11-ath10k-caldata  ## x-wrt have not
sed -i '/"ath10k\/pre-cal-pci-0000:01:00.0.bin")/a\\t\tath10kcal_extract "ART" 36864 12064' target/linux/ipq40xx/base-files/etc/hotplug.d/firmware/11-ath10k-caldata  ## x-wrt have not
sed -i '/"ath10k\/pre-cal-pci-0000:01:00.0.bin")/a\\tif [ "$board" = "p2w,r619ac" ] || [ "$board" = "p2w,r619ac-128m" ] ; then' target/linux/ipq40xx/base-files/etc/hotplug.d/firmware/11-ath10k-caldata  ## x-wrt have not
sed -i '/8dev,jalapeno[ \t]*|/i\\tp2w,r619ac |\\' target/linux/ipq40xx/base-files/etc/hotplug.d/firmware/11-ath10k-caldata
sed -i '/8dev,jalapeno[ \t]*|/i\\tp2w,r619ac-128m |\\' target/linux/ipq40xx/base-files/etc/hotplug.d/firmware/11-ath10k-caldata

sed -i '/8dev,jalapeno[ \t]*|/i\\tp2w,r619ac-128m |\\' target/linux/ipq40xx/base-files/lib/upgrade/platform.sh
sed -i '/8dev,jalapeno[ \t]*|/i\\tp2w,r619ac |\\' target/linux/ipq40xx/base-files/lib/upgrade/platform.sh

curl --retry 5 -L https://raw.githubusercontent.com/coolsnowwolf/openwrt/lede-17.01/target/linux/ipq40xx/files-4.19/arch/arm/boot/dts/qcom-ipq4019-r619ac-128m.dts > target/linux/ipq40xx/files/arch/arm/boot/dts/qcom-ipq4019-r619ac-128m.dts
curl --retry 5 -L https://raw.githubusercontent.com/coolsnowwolf/openwrt/lede-17.01/target/linux/ipq40xx/files-4.19/arch/arm/boot/dts/qcom-ipq4019-r619ac.dts > target/linux/ipq40xx/files/arch/arm/boot/dts/qcom-ipq4019-r619ac.dts
curl --retry 5 -L https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/ipq40xx/files/arch/arm/boot/dts/qcom-ipq4019-r619ac.dtsi > target/linux/ipq40xx/files/arch/arm/boot/dts/qcom-ipq4019-r619ac.dtsi
#curl --retry 5 -L https://raw.githubusercontent.com/x-wrt/x-wrt/master/target/linux/ipq40xx/files/arch/arm/boot/dts/qcom-ipq4019-r619ac.dtsi > target/linux/ipq40xx/files/arch/arm/boot/dts/qcom-ipq4019-r619ac.dtsi  ## Use X-WRT's dts

sed -i '${/$(eval $(call BuildImage))/d;}' target/linux/ipq40xx/image/Makefile
echo '
define Device/p2w_r619ac
	$(call Device/FitzImage)
	$(call Device/UbiFit)
	DEVICE_TITLE := P&W R619AC
	DEVICE_DTS := qcom-ipq4019-r619ac
	DEVICE_DTS_CONFIG := config@10
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	IMAGES += nand-factory.bin
	IMAGE/nand-factory.bin := append-ubi | qsdk-ipq-factory-nand
	DEVICE_PACKAGES := ipq-wifi-p2w_r619ac
endef
TARGET_DEVICES += p2w_r619ac

define Device/p2w_r619ac-128m
	$(call Device/FitzImage)
	$(call Device/UbiFit)
	DEVICE_TITLE := P&W R619AC
	DEVICE_DTS := qcom-ipq4019-r619ac-128m
	DEVICE_DTS_CONFIG := config@10
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	DEVICE_PACKAGES := ipq-wifi-p2w_r619ac
endef
TARGET_DEVICES += p2w_r619ac-128m

$(eval $(call BuildImage))' >> target/linux/ipq40xx/image/Makefile

sed -i 's/qcom-ipq4019-a62.dtb/qcom-ipq4019-a62.dtb qcom-ipq4019-r619ac.dtb qcom-ipq4019-r619ac-128m.dtb/' target/linux/ipq40xx/patches-5.4/901-arm-boot-add-dts-files.patch
