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
