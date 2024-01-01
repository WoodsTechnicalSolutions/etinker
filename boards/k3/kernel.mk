export ET_KERNEL_ARCH := arm64
export ET_KERNEL_VENDOR := ti/
export ET_KERNEL_BUILD_IMAGE := $(ET_KERNEL_BUILD_BOOT_DIR)/Image
export ET_KERNEL_IMAGE := $(ET_KERNEL_DIR)/boot/Image

define kernel-depends-$(ET_BOARD_TYPE)
endef

define kernel-prepare-$(ET_BOARD_TYPE)
endef

define kernel-build-$(ET_BOARD_TYPE)
	$(call kernel-build,Image)
endef

define kernel-finalize-$(ET_BOARD_TYPE)
	@mkdir -p $(ET_KERNEL_DIR)/boot/dtb/ti
	@mv -v $(ET_KERNEL_DIR)/boot/*.dtb $(ET_KERNEL_DIR)/boot/dtb/ti/
	@if [ -d $(ET_BOARD_DIR)/its ] && [ -f $(ET_BOARD_DIR)/its/kernel.its ]; then \
		cp $(ET_BOARD_DIR)/its/kernel.its $(ET_KERNEL_DIR)/boot/; \
		(cd $(ET_KERNEL_DIR)/boot/ && \
			gzip -k Image && \
			mkimage -f kernel.its kernel.itb); \
	fi
	@if [ -d $(TI_K3_BOOT_FIRMWARE_DIR) ]; then \
		mkdir -p $(ET_KERNEL_DIR)/usr/lib/firmware/ti-eth; \
		cp -a $(TI_K3_BOOT_FIRMWARE_DIR)/ti-eth/$(TI_K3_SOC) $(ET_KERNEL_DIR)/usr/lib/firmware/ti-eth/; \
		(cd $(ET_KERNEL_DIR)/usr/lib/firmware && \
			rm -f j7-*fw && \
			ln -sf ti-eth/$(TI_K3_SOC)/app_remoteswitchcfg_server_strip.xer5f j7-main-r5f0_0-fw); \
		mkdir -p $(ET_KERNEL_DIR)/usr/lib/firmware/ti-ipc; \
		cp -a $(TI_K3_BOOT_FIRMWARE_DIR)/ti-ipc/$(TI_K3_SOC) $(ET_KERNEL_DIR)/usr/lib/firmware/ti-ipc/; \
		(cd $(ET_KERNEL_DIR)/usr/lib/firmware && \
			ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_c66xdsp_1_release_strip.xe66 j7-c66_0-fw && \
			ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_c66xdsp_2_release_strip.xe66 j7-c66_1-fw && \
			ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_c7x_1_release_strip.xe71 j7-c71_0-fw && \
			ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu1_1_release_strip.xer5f j7-mcu-r5f0_1-fw && \
			ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu2_1_release_strip.xer5f j7-main-r5f0_1-fw && \
			ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu3_0_release_strip.xer5f j7-main-r5f1_0-fw && \
			ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu3_1_release_strip.xer5f j7-main-r5f1_1-fw); \
	fi
endef

define kernel-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_KERNEL_VENDOR: $(ET_KERNEL_VENDOR)\n"
	@printf "ET_KERNEL_IMAGE: $(ET_KERNEL_IMAGE)\n"
	@printf "ET_KERNEL_BUILD_IMAGE: $(ET_KERNEL_BUILD_IMAGE)\n"
endef
