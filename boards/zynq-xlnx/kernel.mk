export ET_KERNEL_VERSION := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && make kernelversion | tr -d \\n)
export ET_KERNEL_LOCALVERSION := -$(ET_KERNEL_CACHED_VERSION)
export ET_KERNEL_BUILD_UIMAGE := $(ET_KERNEL_BUILD_BOOT_DIR)/uImage
export ET_KERNEL_BUILD_ZIMAGE := $(ET_KERNEL_BUILD_BOOT_DIR)/zImage
export ET_KERNEL_UIMAGE := $(ET_KERNEL_DIR)/boot/uImage
export ET_KERNEL_ZIMAGE := $(ET_KERNEL_DIR)/boot/zImage

define kernel-depends-$(ET_BOARD_TYPE)
	@if [ -d $(ET_BOARD_DIR)/fpga/sdk ]; then \
		rsync -r $(ET_BOARD_DIR)/fpga/dts $(ET_BOARD_DIR)/ > /dev/null; \
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
endef

define kernel-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_KERNEL_UIMAGE: $(ET_KERNEL_UIMAGE)\n"
	@printf "ET_KERNEL_ZIMAGE: $(ET_KERNEL_ZIMAGE)\n"
	@printf "ET_KERNEL_BUILD_UIMAGE: $(ET_KERNEL_BUILD_UIMAGE)\n"
	@printf "ET_KERNEL_BUILD_ZIMAGE: $(ET_KERNEL_BUILD_ZIMAGE)\n"
endef
