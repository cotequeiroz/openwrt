BOARDNAME:=MIPS 74K
CPU_TYPE:=74kc

DEFAULT_PACKAGES += wpad-basic-mbedtls

define Target/Description
	Build firmware images for generic Atheros AR71xx/AR913x/AR934x based boards
	optimized for the MIPS 74K CPU.
endef
