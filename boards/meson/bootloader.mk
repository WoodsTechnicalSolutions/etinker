export ET_BOOTLOADER_ARCH := arm

export FIP_DIR := $(ET_SOFTWARE_DIR)/gxlimg
export FIP_BUILD_DIR := $(FIP_DIR)/build/fip/gxl

define bootloader-depends-$(ET_BOARD_TYPE)
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
endef

# https://github.com/repk/gxlimg [BSD-2-Clause]
define bootloader-finalize-$(ET_BOARD_TYPE)
	$(call software-check,gxlimg,gxlimg)
	@(cd $(ET_SOFTWARE_DIR)/gxlimg && \
		$(MAKE) --no-print-directory \
			clean \
			image \
			UBOOT=$(ET_BOOTLOADER_BUILD_DIR)/u-boot-dtb.bin && \
		cp -av $(FIP_BUILD_DIR)/u-boot.bin.enc $(ET_BOOTLOADER_DIR)/boot/u-boot.bin && \
		cp -av $(FIP_DIR)/build/gxl-boot.bin $(ET_BOOTLOADER_DIR)/boot/)
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "FIP_DIR: $(FIP_DIR)\n"
	@printf "FIP_BUILD_DIR: $(FIP_BUILD_DIR)\n"
endef
