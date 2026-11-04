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
			rm -f j7-*fw && \
			rm -rf ti-eth/$(TI_K3_SOC) && \
			rm -rf ti-ipc/$(TI_K3_SOC)); \
	fi
	$(call kernel-finalize-$(ET_BOARD_TYPE))
	@mkdir -p $(ET_KERNEL_DIR)/usr/lib/firmware
	@(cd $(ET_KERNEL_DIR)/usr/lib/firmware && \
		ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_c7x_1_release_strip.xe71 j7-c71_0-fw && \
		ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_c66xdsp_1_release_strip.xe66 j7-c66_0-fw && \
		ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_c66xdsp_2_release_strip.xe66 j7-c66_1-fw && \
		ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu1_1_release_strip.xer5f j7-mcu-r5f0_1-fw && \
		ln -sf ti-eth/$(TI_K3_SOC)/app_remoteswitchcfg_server_strip.xer5f j7-main-r5f0_0-fw && \
		ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu2_1_release_strip.xer5f j7-main-r5f0_1-fw && \
		ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu3_0_release_strip.xer5f j7-main-r5f1_0-fw && \
		ln -sf ti-ipc/$(TI_K3_SOC)/ipc_echo_test_mcu3_1_release_strip.xer5f j7-main-r5f1_1-fw)
endef

define kernel-info-$(ET_BOARD)
	$(call kernel-info-$(ET_BOARD_TYPE))
endef
