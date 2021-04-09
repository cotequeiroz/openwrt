# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2012-2016 OpenWrt.org
# Copyright (C) 2016 LEDE-project.org

DTS_DIR := $(DTS_DIR)/marvell

define Build/fortigate-header
  ( \
    dd if=/dev/zero bs=384 count=1 2>/dev/null; \
    datalen=$$(wc -c $@ | cut -d' ' -f1); \
    datalen=$$(printf "%08x" $$datalen); \
    datalen="$${datalen:6:2}$${datalen:4:2}$${datalen:2:2}$${datalen:0:2}"; \
    printf $$(echo "00020000$${datalen}ffff0000ffff0000" | sed 's/../\\x&/g'); \
    dd if=/dev/zero bs=112 count=1 2>/dev/null; \
    cat $@; \
  ) > $@.new
  mv $@.new $@
endef

define Build/seil-header
  ( \
    data_size_crc="$$(gzip -c $@ | tail -c8 | \
        od -An -tx8 --endian little | tr -d ' \n')"; \
    printf "SEIL2015"; \
    printf "$(call toupper,$(LINUX_KARCH)) $(VERSION_DIST) Linux-$(LINUX_VERSION)" | \
        dd bs=80 count=1 conv=sync 2>/dev/null; \
    printf "$$(echo $${data_size_crc:8:8} | sed 's/../\\x&/g')"; \
    printf "\x00\x00\x00\x01\x00\x00\x00\x09\x00\x00\x00\x63"; \
    printf "$(REVISION)" | dd bs=32 count=1 conv=sync 2>/dev/null; \
    printf "\x00\x00\x00\x00"; \
    printf "$$(echo $${data_size_crc:0:8} | sed 's/../\\x&/g')"; \
    cat $@; \
  ) > $@.new
  mv $@.new $@
endef

define Device/dsa-migration
  DEVICE_COMPAT_VERSION := 1.1
  DEVICE_COMPAT_MESSAGE := Config cannot be migrated from swconfig to DSA
endef

define Device/kernel-size-migration
  DEVICE_COMPAT_VERSION := 2.0
  DEVICE_COMPAT_MESSAGE := Partition design has changed compared to older versions (up to 19.07) due to kernel size restrictions. \
	Upgrade via sysupgrade mechanism is not possible, so new installation via factory style image is required.
endef

define Device/cznic_turris-omnia
  DEVICE_VENDOR := CZ.NIC
  DEVICE_MODEL := Turris Omnia
  KERNEL_INSTALL := 1
  SOC := armada-385
  KERNEL := kernel-bin
  KERNEL_INITRAMFS := kernel-bin | libdeflate-gzip | fit gzip $$(KDIR)/image-$$(DEVICE_DTS).dtb
  DEVICE_PACKAGES :=  \
    mkf2fs e2fsprogs kmod-fs-vfat kmod-nls-cp437 kmod-nls-iso8859-1 \
    wpad-basic-mbedtls kmod-ath9k kmod-ath10k-ct ath10k-firmware-qca988x-ct \
    kmod-mt7915-firmware partx-utils kmod-i2c-mux-pca954x kmod-leds-turris-omnia \
    kmod-turris-omnia-mcu kmod-gpio-button-hotplug omnia-eeprom omnia-mcu-firmware \
    omnia-mcutool kmod-dsa-mv88e6xxx
  IMAGES := sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz := boot-scr | boot-img | sdcard-img | libdeflate-gzip | append-metadata
  SUPPORTED_DEVICES += armada-385-turris-omnia
  BOOT_SCRIPT := turris-omnia
endef
TARGET_DEVICES += cznic_turris-omnia

define Device/fortinet
  DEVICE_VENDOR := Fortinet
  SOC := armada-385
  KERNEL := kernel-bin | append-dtb
  KERNEL_SIZE := 6144k
  IMAGE/sysupgrade.bin := append-rootfs | pad-rootfs | \
    sysupgrade-tar rootfs=$$$$@ | append-metadata
  DEVICE_PACKAGES := kmod-hwmon-nct7802 kmod-dsa-mv88e6xxx
endef

define Device/fortinet_fg-30e
  $(Device/fortinet)
  DEVICE_MODEL := FortiGate 30E
  DEVICE_DTS := armada-385-fortinet-fg-30e
  KERNEL_INITRAMFS := kernel-bin | append-dtb | fortigate-header | \
    gzip-filename FGT30E
endef
TARGET_DEVICES += fortinet_fg-30e

define Device/fortinet_fwf-30e
  $(Device/fortinet)
  DEVICE_MODEL := FortiWiFi 30E
  DEVICE_DTS := armada-385-fortinet-fwf-30e
  KERNEL_INITRAMFS := kernel-bin | append-dtb | fortigate-header | \
    gzip-filename FWF30E
  DEVICE_PACKAGES += kmod-ath9k wpad-basic-mbedtls
endef
TARGET_DEVICES += fortinet_fwf-30e

define Device/fortinet_fg-50e
  $(Device/fortinet)
  DEVICE_MODEL := FortiGate 50E
  DEVICE_DTS := armada-385-fortinet-fg-50e
  KERNEL_INITRAMFS := kernel-bin | append-dtb | fortigate-header | \
    gzip-filename FGT50E
endef
TARGET_DEVICES += fortinet_fg-50e

define Device/fortinet_fg-51e
  $(Device/fortinet)
  DEVICE_MODEL := FortiGate 51E
  DEVICE_DTS := armada-385-fortinet-fg-51e
  KERNEL_INITRAMFS := kernel-bin | append-dtb | fortigate-header | \
    gzip-filename FGT51E
endef
TARGET_DEVICES += fortinet_fg-51e

define Device/fortinet_fg-52e
  $(Device/fortinet)
  DEVICE_MODEL := FortiGate 52E
  DEVICE_DTS := armada-385-fortinet-fg-52e
  KERNEL_INITRAMFS := kernel-bin | append-dtb | fortigate-header | \
    gzip-filename FGT52E
endef
TARGET_DEVICES += fortinet_fg-52e

define Device/fortinet_fwf-50e-2r
  $(Device/fortinet)
  DEVICE_MODEL := FortiWiFi 50E-2R
  DEVICE_DTS := armada-385-fortinet-fwf-50e-2r
  KERNEL_INITRAMFS := kernel-bin | append-dtb | fortigate-header | \
    gzip-filename FW502R
  DEVICE_PACKAGES += kmod-ath10k-ct ath10k-firmware-qca988x-ct \
    wpad-basic-mbedtls
endef
TARGET_DEVICES += fortinet_fwf-50e-2r

define Device/fortinet_fwf-51e
  $(Device/fortinet)
  DEVICE_MODEL := FortiWiFi 51E
  DEVICE_DTS := armada-385-fortinet-fwf-51e
  KERNEL_INITRAMFS := kernel-bin | append-dtb | fortigate-header | \
    gzip-filename FWF51E
  DEVICE_PACKAGES += kmod-ath9k wpad-basic-mbedtls
endef
TARGET_DEVICES += fortinet_fwf-51e

define Device/iptime_nas1dual
  DEVICE_VENDOR := ipTIME
  DEVICE_MODEL := NAS1dual
  DEVICE_PACKAGES := kmod-hwmon-drivetemp kmod-hwmon-gpiofan \
    kmod-usb-xhci-pci-renesas
  SOC := armada-385
  KERNEL := kernel-bin | append-dtb | iptime-naspkg nas1dual
  KERNEL_SIZE := 6144k
  IMAGES := sysupgrade.bin
  IMAGE_SIZE := 64256k
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$(KERNEL_SIZE) | \
	append-rootfs | pad-rootfs | check-size | append-metadata
endef
TARGET_DEVICES += iptime_nas1dual

define Device/kobol_helios4
  DEVICE_VENDOR := Kobol
  DEVICE_MODEL := Helios4
  KERNEL_INSTALL := 1
  KERNEL := kernel-bin
  DEVICE_PACKAGES := mkf2fs e2fsprogs partx-utils
  IMAGES := sdcard.img.gz
  IMAGE/sdcard.img.gz := boot-scr | boot-img-ext4 | sdcard-img-ext4 | libdeflate-gzip | append-metadata
  SOC := armada-388
  UBOOT := helios4-u-boot-with-spl.kwb
  BOOT_SCRIPT := clearfog
endef
TARGET_DEVICES += kobol_helios4

define Device/linksys
  $(Device/NAND-128K)
  DEVICE_VENDOR := Linksys
  DEVICE_PACKAGES := kmod-mwlwifi wpad-basic-mbedtls
  IMAGES += factory.img
  IMAGE/factory.img := append-kernel | pad-to $$$$(KERNEL_SIZE) | \
	append-ubi | pad-to $$$$(PAGESIZE)
  KERNEL_SIZE := 6144k
endef

define Device/linksys_wrt1200ac
  $(call Device/linksys)
  $(Device/dsa-migration)
  DEVICE_MODEL := WRT1200AC
  DEVICE_ALT0_VENDOR := Linksys
  DEVICE_ALT0_MODEL := Caiman
  DEVICE_DTS := armada-385-linksys-caiman
  DEVICE_PACKAGES += mwlwifi-firmware-88w8864 kmod-dsa-mv88e6xxx
  SUPPORTED_DEVICES += armada-385-linksys-caiman linksys,caiman
endef
TARGET_DEVICES += linksys_wrt1200ac

define Device/linksys_wrt1900acs
  $(call Device/linksys)
  $(Device/dsa-migration)
  DEVICE_MODEL := WRT1900ACS
  DEVICE_VARIANT := v1
  DEVICE_ALT0_VENDOR := Linksys
  DEVICE_ALT0_MODEL := WRT1900ACS
  DEVICE_ALT0_VARIANT := v2
  DEVICE_ALT1_VENDOR := Linksys
  DEVICE_ALT1_MODEL := Shelby
  DEVICE_DTS := armada-385-linksys-shelby
  DEVICE_PACKAGES += mwlwifi-firmware-88w8864 kmod-dsa-mv88e6xxx
  SUPPORTED_DEVICES += armada-385-linksys-shelby linksys,shelby
endef
TARGET_DEVICES += linksys_wrt1900acs

define Device/linksys_wrt1900ac-v2
  $(call Device/linksys)
  $(Device/dsa-migration)
  DEVICE_MODEL := WRT1900AC
  DEVICE_VARIANT := v2
  DEVICE_ALT0_VENDOR := Linksys
  DEVICE_ALT0_MODEL := Cobra
  DEVICE_DTS := armada-385-linksys-cobra
  DEVICE_PACKAGES += mwlwifi-firmware-88w8864 kmod-dsa-mv88e6xxx
  SUPPORTED_DEVICES += armada-385-linksys-cobra linksys,cobra
endef
TARGET_DEVICES += linksys_wrt1900ac-v2

define Device/linksys_wrt3200acm
  $(call Device/linksys)
  $(Device/dsa-migration)
  DEVICE_MODEL := WRT3200ACM
  DEVICE_ALT0_VENDOR := Linksys
  DEVICE_ALT0_MODEL := Rango
  DEVICE_DTS := armada-385-linksys-rango
  DEVICE_PACKAGES += kmod-btmrvl kmod-mwifiex-sdio mwlwifi-firmware-88w8964 \
	kmod-dsa-mv88e6xxx
  SUPPORTED_DEVICES += armada-385-linksys-rango linksys,rango
endef
TARGET_DEVICES += linksys_wrt3200acm

define Device/linksys_wrt32x
  $(call Device/linksys)
  $(Device/kernel-size-migration)
  DEVICE_MODEL := WRT32X
  DEVICE_ALT0_VENDOR := Linksys
  DEVICE_ALT0_MODEL := Venom
  DEVICE_DTS := armada-385-linksys-venom
  DEVICE_PACKAGES += kmod-btmrvl kmod-mwifiex-sdio mwlwifi-firmware-88w8964 \
	kmod-dsa-mv88e6xxx
  KERNEL_SIZE := 6144k
  KERNEL := kernel-bin | append-dtb
  SUPPORTED_DEVICES += armada-385-linksys-venom linksys,venom
endef
TARGET_DEVICES += linksys_wrt32x

define Device/marvell_a385-db-ap
  $(Device/NAND-256K)
  DEVICE_VENDOR := Marvell
  DEVICE_MODEL := Armada 385 Development Board AP (DB-88F6820-AP)
  DEVICE_DTS := armada-385-db-ap
  IMAGES += factory.img
  IMAGE/factory.img := append-kernel | pad-to $$$$(KERNEL_SIZE) | \
	append-ubi | pad-to $$$$(PAGESIZE)
  KERNEL_SIZE := 8192k
  SUPPORTED_DEVICES += armada-385-db-ap
endef
TARGET_DEVICES += marvell_a385-db-ap

define Device/marvell_a388-rd
  DEVICE_VENDOR := Marvell
  DEVICE_MODEL := Armada 388 RD (RD-88F6820-AP)
  DEVICE_DTS := armada-388-rd
  IMAGES := firmware.bin
  IMAGE/firmware.bin := append-kernel | pad-to 256k | append-rootfs | pad-rootfs
  SUPPORTED_DEVICES := armada-388-rd marvell,a385-rd
endef
TARGET_DEVICES += marvell_a388-rd

define Device/solidrun_clearfog-base-a1
  DEVICE_VENDOR := SolidRun
  DEVICE_MODEL := ClearFog Base
  KERNEL_INSTALL := 1
  KERNEL := kernel-bin
  DEVICE_PACKAGES := mkf2fs e2fsprogs partx-utils kmod-dsa-mv88e6xxx
  IMAGES := sdcard.img.gz
  IMAGE/sdcard.img.gz := boot-scr | boot-img-ext4 | sdcard-img-ext4 | libdeflate-gzip | append-metadata
  DEVICE_DTS := armada-388-clearfog-base armada-388-clearfog-pro
  UBOOT := clearfog-u-boot-with-spl.kwb
  BOOT_SCRIPT := clearfog
  SUPPORTED_DEVICES += armada-388-clearfog-base
  DEVICE_COMPAT_VERSION := 1.1
  DEVICE_COMPAT_MESSAGE := Ethernet interface rename has been dropped
endef
TARGET_DEVICES += solidrun_clearfog-base-a1

define Device/solidrun_clearfog-pro-a1
  $(Device/dsa-migration)
  DEVICE_VENDOR := SolidRun
  DEVICE_MODEL := ClearFog Pro
  KERNEL_INSTALL := 1
  KERNEL := kernel-bin
  DEVICE_PACKAGES := mkf2fs e2fsprogs partx-utils kmod-dsa-mv88e6xxx
  IMAGES := sdcard.img.gz
  IMAGE/sdcard.img.gz := boot-scr | boot-img-ext4 | sdcard-img-ext4 | libdeflate-gzip | append-metadata
  DEVICE_DTS := armada-388-clearfog-pro armada-388-clearfog-base
  UBOOT := clearfog-u-boot-with-spl.kwb
  BOOT_SCRIPT := clearfog
  SUPPORTED_DEVICES += armada-388-clearfog armada-388-clearfog-pro
endef
TARGET_DEVICES += solidrun_clearfog-pro-a1

define Device/wd_cloud-ex2-ultra
  $(Device/NAND-128K)
  DEVICE_VENDOR := Western Digital
  DEVICE_MODEL := MyCloud EX2 Ultra
  DEVICE_PACKAGES += -uboot-envtools mkf2fs e2fsprogs \
	partx-utils kmod-hwmon-drivetemp -ppp -kmod-nft-offload -dnsmasq \
	-odhcpd-ipv6only
  DEVICE_DTS := armada-385-wd_cloud-ex2-ultra
  KERNEL_SIZE := 5120k
  KERNEL := kernel-bin | append-dtb | uImage none
  KERNEL_INITRAMFS := kernel-bin | append-dtb | uImage none
  IMAGES += image-cfs-factory.bin uImage-factory.bin
  IMAGE/image-cfs-factory.bin := append-ubi
  IMAGE/uImage-factory.bin := append-kernel
endef
TARGET_DEVICES += wd_cloud-ex2-ultra

define Device/wd_cloud-mirror-gen2
  $(Device/NAND-128K)
  DEVICE_VENDOR := Western Digital
  DEVICE_MODEL := MyCloud Mirror Gen 2 (BWVZ/Grand Teton)
  DEVICE_PACKAGES += -uboot-envtools mkf2fs e2fsprogs \
	partx-utils kmod-hwmon-drivetemp -ppp -kmod-nft-offload -dnsmasq \
	-odhcpd-ipv6only
  DEVICE_DTS := armada-385-wd_cloud-mirror-gen2
  KERNEL_SIZE := 5120k
  KERNEL := kernel-bin | append-dtb | uImage none
  KERNEL_INITRAMFS := kernel-bin | append-dtb | uImage none
  IMAGES += image-cfs-factory.bin uImage-factory.bin
  IMAGE/image-cfs-factory.bin := append-ubi
  IMAGE/uImage-factory.bin := append-kernel
endef
TARGET_DEVICES += wd_cloud-mirror-gen2
### automatically generated by split-neon.pl from upstream cortexa9.mk.
