include $(ET_DIR)/boards/k3/common.mk

define bootloader-depends-$(ET_BOARD_TYPE)
	@$(call bootloader-depends-common)
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
	@$(call bootloader-prepare-common)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
	@$(call bootloader-finalize-common)
	@if [ -f $(ET_BOOTLOADER_BUILD_DIR)/sysfw.itb ]; then \
		cp -v $(ET_BOOTLOADER_BUILD_DIR)/sysfw.itb $(ET_BOOTLOADER_DIR)/boot/; \
	fi
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@$(call bootloader-info-common)
endef
