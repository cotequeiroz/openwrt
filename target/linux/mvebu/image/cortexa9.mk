# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2012-2016 OpenWrt.org
# Copyright (C) 2016 LEDE-project.org

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

define Device/dsa-migration
  DEVICE_COMPAT_VERSION := 1.1
  DEVICE_COMPAT_MESSAGE := Config cannot be migrated from swconfig to DSA
endef

define Device/kernel-size-migration
  DEVICE_COMPAT_VERSION := 2.0
  DEVICE_COMPAT_MESSAGE := Partition design has changed compared to older versions (up to 19.07) due to kernel size restrictions. \
	Upgrade via sysupgrade mechanism is not possible, so new installation via factory style image is required.
endef

define Device/buffalo_ls220de
  $(Device/NAND-128K)
  DEVICE_VENDOR := Buffalo
  DEVICE_MODEL := LinkStation LS220DE
  KERNEL_UBIFS_OPTS = -m $$(PAGESIZE) -e 124KiB -c 172 -x none
  KERNEL := kernel-bin | append-dtb | uImage none | buffalo-kernel-ubifs
  KERNEL_INITRAMFS := kernel-bin | append-dtb | uImage none
  DEVICE_DTS := armada-370-buffalo-ls220de
  DEVICE_PACKAGES :=  \
    kmod-hwmon-gpiofan kmod-hwmon-drivetemp kmod-linkstation-poweroff \
    kmod-md-mod kmod-md-raid0 kmod-md-raid1 kmod-md-raid10 kmod-fs-xfs \
    mdadm mkf2fs e2fsprogs partx-utils
endef
TARGET_DEVICES += buffalo_ls220de

define Device/buffalo_ls421de
  $(Device/NAND-128K)
  DEVICE_VENDOR := Buffalo
  DEVICE_MODEL := LinkStation LS421DE
  SUBPAGESIZE :=
  KERNEL_SIZE := 33554432
  FILESYSTEMS := squashfs ubifs
  KERNEL := kernel-bin | append-dtb | uImage none | buffalo-kernel-jffs2
  KERNEL_INITRAMFS := kernel-bin | append-dtb | uImage none
  DEVICE_DTS := armada-370-buffalo-ls421de
  DEVICE_PACKAGES :=  \
    kmod-rtc-rs5c372a kmod-hwmon-gpiofan kmod-hwmon-drivetemp kmod-usb3 \
    kmod-linkstation-poweroff kmod-md-raid0 kmod-md-raid1 kmod-md-mod \
    kmod-fs-xfs mkf2fs e2fsprogs partx-utils
endef
TARGET_DEVICES += buffalo_ls421de

define Device/ctera_c200-v2
  PAGESIZE := 2048
  SUBPAGESIZE := 512
  BLOCKSIZE := 128k
  DEVICE_VENDOR := Ctera
  DEVICE_MODEL := C200
  DEVICE_VARIANT := V2
  SOC := armada-370
  KERNEL := kernel-bin | append-dtb | uImage none | ctera-firmware
  KERNEL_IN_UBI :=
  KERNEL_SUFFIX := -factory.firm
  DEVICE_PACKAGES :=  \
    kmod-gpio-button-hotplug kmod-hwmon-drivetemp kmod-hwmon-nct7802 \
    kmod-rtc-s35390a kmod-usb3 kmod-usb-ledtrig-usbport
  IMAGES := sysupgrade.bin
endef
TARGET_DEVICES += ctera_c200-v2

define Device/globalscale_mirabox
  $(Device/NAND-512K)
  DEVICE_VENDOR := Globalscale
  DEVICE_MODEL := Mirabox
  SOC := armada-370
  SUPPORTED_DEVICES += mirabox
endef
TARGET_DEVICES += globalscale_mirabox

define Device/linksys
  $(Device/NAND-128K)
  DEVICE_VENDOR := Linksys
  DEVICE_PACKAGES := kmod-mwlwifi wpad-basic-mbedtls
  IMAGES += factory.img
  IMAGE/factory.img := append-kernel | pad-to $$$$(KERNEL_SIZE) | \
	append-ubi | pad-to $$$$(PAGESIZE)
  KERNEL_SIZE := 6144k
endef

define Device/linksys_wrt1900ac-v1
  $(call Device/linksys)
  $(Device/kernel-size-migration)
  DEVICE_MODEL := WRT1900AC
  DEVICE_VARIANT := v1
  DEVICE_ALT0_VENDOR := Linksys
  DEVICE_ALT0_MODEL := Mamba
  DEVICE_DTS := armada-xp-linksys-mamba
  DEVICE_PACKAGES += mwlwifi-firmware-88w8864
  KERNEL_SIZE := 4096k
  SUPPORTED_DEVICES += armada-xp-linksys-mamba linksys,mamba
endef
TARGET_DEVICES += linksys_wrt1900ac-v1

define Device/marvell_a370-db
  $(Device/NAND-512K)
  DEVICE_VENDOR := Marvell
  DEVICE_MODEL := Armada 370 Development Board (DB-88F6710-BP-DDR3)
  DEVICE_DTS := armada-370-db
  SUPPORTED_DEVICES += armada-370-db
endef
TARGET_DEVICES += marvell_a370-db

define Device/marvell_a370-rd
  $(Device/NAND-512K)
  DEVICE_VENDOR := Marvell
  DEVICE_MODEL := Armada 370 RD (RD-88F6710-A1)
  DEVICE_DTS := armada-370-rd
  SUPPORTED_DEVICES += armada-370-rd
endef
TARGET_DEVICES += marvell_a370-rd

define Device/marvell_axp-db
  $(Device/NAND-512K)
  DEVICE_VENDOR := Marvell
  DEVICE_MODEL := Armada XP Development Board (DB-78460-BP)
  DEVICE_DTS := armada-xp-db
  SUPPORTED_DEVICES += armada-xp-db
endef
TARGET_DEVICES += marvell_axp-db

define Device/marvell_axp-gp
  $(Device/NAND-512K)
  DEVICE_VENDOR := Marvell
  DEVICE_MODEL := Armada Armada XP GP (DB-MV784MP-GP)
  DEVICE_DTS := armada-xp-gp
  SUPPORTED_DEVICES += armada-xp-gp
endef
TARGET_DEVICES += marvell_axp-gp

define Device/plathome_openblocks-ax3-4
  DEVICE_VENDOR := Plat'Home
  DEVICE_MODEL := OpenBlocks AX3
  DEVICE_VARIANT := 4 ports
  SOC := armada-xp
  SUPPORTED_DEVICES += openblocks-ax3-4
  BLOCKSIZE := 128k
  PAGESIZE := 1
  IMAGES += factory.img
  IMAGE/factory.img := append-kernel | pad-to $$(BLOCKSIZE) | append-ubi
endef
TARGET_DEVICES += plathome_openblocks-ax3-4

### automatically generated by split-neon.pl from upstream cortexa9.mk.
