ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -o xlnx),xlnx)
# Xilinx 'linux-xlnx' tree
export ET_KERNEL_VERSION := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) && make kernelversion | tr -d \\n)
export ET_KERNEL_LOCALVERSION := -$(ET_KERNEL_CACHED_VERSION)
endif
export ET_KERNEL_BUILD_UIMAGE := $(ET_KERNEL_BUILD_BOOT_DIR)/uImage
export ET_KERNEL_BUILD_ZIMAGE := $(ET_KERNEL_BUILD_BOOT_DIR)/zImage
export ET_KERNEL_UIMAGE := $(ET_KERNEL_DIR)/boot/uImage
export ET_KERNEL_ZIMAGE := $(ET_KERNEL_DIR)/boot/zImage

define kernel-depends-$(ET_BOARD_TYPE)
	@if [ -d $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/sdk ]; then \
		rsync -r $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/dts $(ET_BOARD_DIR)/ $(ET_NULL); \
	else \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] FPGA BUILD IS MISSING! *****\n"; \
		exit 2; \
	fi
endef

define kernel-prepare-$(ET_BOARD_TYPE)
endef

define kernel-build-$(ET_BOARD_TYPE)
	$(call kernel-build,zImage)
	$(call kernel-build,uImage)
endef

define kernel-finalize-$(ET_BOARD_TYPE)
	$(call cadence-ttc-pwm-config)
	$(call cadence-ttc-pwm-clean)
	$(call cadence-ttc-pwm-targets)
	@if [ -d $(ET_BOARD_DIR)/its ] && [ -f $(ET_BOARD_DIR)/its/kernel.its ]; then \
		cp $(ET_BOARD_DIR)/its/kernel.its $(ET_KERNEL_DIR)/boot/; \
		(cd $(ET_KERNEL_DIR)/boot/ && \
			gzip -k Image && \
			mkimage -f kernel.its kernel.itb); \
	fi
endef

define kernel-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_KERNEL_UIMAGE: $(ET_KERNEL_UIMAGE)\n"
	@printf "ET_KERNEL_ZIMAGE: $(ET_KERNEL_ZIMAGE)\n"
	@printf "ET_KERNEL_BUILD_UIMAGE: $(ET_KERNEL_BUILD_UIMAGE)\n"
	@printf "ET_KERNEL_BUILD_ZIMAGE: $(ET_KERNEL_BUILD_ZIMAGE)\n"
endef
