include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/kernel.mk

define kernel-depends-$(ET_BOARD)
	$(call kernel-depends-$(ET_BOARD_TYPE))
endef

define kernel-prepare-$(ET_BOARD)
	$(call kernel-prepare-$(ET_BOARD_TYPE))
endef

define kernel-build-$(ET_BOARD)
	$(call kernel-build-$(ET_BOARD_TYPE))
endef

define kernel-finalize-$(ET_BOARD)
	@if [ -d "$(ET_KERNEL_DIR)/usr/lib/firmware" ]; then \
		(cd $(ET_KERNEL_DIR)/usr/lib/firmware && \
			rm -f am62-mcu-*fw && \
			rm -rf ti-ipc/$(TI_K3_SOC)x); \
	fi
	$(call kernel-finalize-$(ET_BOARD_TYPE))
	@mkdir -p $(ET_KERNEL_DIR)/usr/lib/firmware
	@cp -a $(TI_K3_BOOT_FIRMWARE_DIR)/ti-ipc/$(TI_K3_SOC)x $(ET_KERNEL_DIR)/usr/lib/firmware/ti-ipc/
	@(cd $(ET_KERNEL_DIR)/usr/lib/firmware && \
		ln -sf ti-ipc/$(TI_K3_SOC)x/am62-mcu-m4f0_0-fw)
endef

define kernel-info-$(ET_BOARD)
	$(call kernel-info-$(ET_BOARD_TYPE))
endef
