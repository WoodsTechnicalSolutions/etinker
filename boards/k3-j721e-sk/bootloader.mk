include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/bootloader.mk

define bootloader-depends-$(ET_BOARD)
	$(call bootloader-depends-$(ET_BOARD_TYPE))
endef

define bootloader-prepare-$(ET_BOARD)
	$(call bootloader-prepare-$(ET_BOARD_TYPE))
endef

define bootloader-finalize-$(ET_BOARD)
	$(call bootloader-finalize-$(ET_BOARD_TYPE))
	@(cd $(ET_DIR)/bootloader/k3-$(TI_K3_SOC)-r5-sk/$(TI_R5_CROSS_TUPLE)/boot && \
		cp -v tiboot3.bin sysfw.itb $(ET_BOOTLOADER_DIR)/boot/)
endef

define bootloader-info-$(ET_BOARD)
	$(call bootloader-info-$(ET_BOARD_TYPE))
endef
