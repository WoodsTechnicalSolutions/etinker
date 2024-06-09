include $(ET_DIR)/boards/k3/common.mk

define bootloader-depends-$(ET_BOARD_TYPE)
ifneq (exists,$(shell test -f $(ET_DIR)/bootloader/k3-$(TI_K3_SOC)-r5/$(TI_R5_CROSS_TUPLE)/boot/tiboot3.bin && echo exists))
$(error ET_BOARD=k3-$(TI_K3_SOC)-r5 MUST BE BUILT FIRST! ***)
endif
	@$(call bootloader-depends-common)
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
	@$(call bootloader-prepare-common)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
	@$(call bootloader-finalize-common)
	@cp -v $(ET_DIR)/bootloader/k3-$(TI_K3_SOC)-r5/$(TI_R5_CROSS_TUPLE)/boot/{tiboot3.bin,sysfw.itb} $(ET_BOOTLOADER_DIR)/boot/
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@$(call bootloader-info-common)
endef
