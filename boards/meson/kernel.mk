ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -o libre),libre)
# Libre Computer 'libretech-linux' tree
export ET_KERNEL_VERSION := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) && make kernelversion | tr -d \\n)
export ET_KERNEL_LOCALVERSION := -libretech
endif

export ET_KERNEL_ARCH := arm64
export ET_KERNEL_VENDOR := amlogic/
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
	@if [ -d $(ET_BOARD_DIR)/its ] && [ -f $(ET_BOARD_DIR)/its/kernel.its ]; then \
		cp $(ET_BOARD_DIR)/its/kernel.its $(ET_KERNEL_DIR)/boot/; \
		(cd $(ET_KERNEL_DIR)/boot/ && \
			gzip -k Image && \
			mkimage -f kernel.its kernel.itb); \
	fi
endef

define kernel-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_KERNEL_VENDOR: $(ET_KERNEL_VENDOR)\n"
	@printf "ET_KERNEL_IMAGE: $(ET_KERNEL_IMAGE)\n"
	@printf "ET_KERNEL_BUILD_IMAGE: $(ET_KERNEL_BUILD_IMAGE)\n"
endef
