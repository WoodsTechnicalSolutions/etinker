ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -Po libre),libre)
# Libre Computer 'libretech-u-boot' tree
export ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && make -s ubootversion | tr -d \\n)
export ET_BOOTLOADER_LOCALVERSION := -libretech
endif

export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/spl/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_SPL := $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_SPL_BINARY)

define bootloader-depends-$(ET_BOARD_TYPE)
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
	$(call software-check,gxlimg,gxlimg)
	$(call software-check,arm-trusted-firmware,arm-trusted-firmware)
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
	@(cd $(ET_SOFTWARE_DIR)/gxlimg && \
		$(MAKE) --no-print-directory \
			clean \
			image \
			UBOOT=$(ET_BOOTLOADER_BUILD_IMAGE) && \
		cp -av build/fip/gxl/u-boot.bin.enc $(ET_BOOTLOADER_DIR)/boot/u-boot.bin && \
		cp -av build/gxl-boot.bin $(ET_BOOTLOADER_DIR)/boot/)
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
endef
