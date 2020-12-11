export ET_BOOTLOADER_ARCH := arm

# Handle out-of-tree devicetree build (i.e. dtb-y += fsl-ls1043a-custom-board.dtb)
export DEVICE_TREE_MAKEFILE := -f $(ET_BOARD_DIR)/dts/u-boot/Makefile

define bootloader-depends-$(ET_BOARD_TYPE)
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
endef

define bootloader-info-$(ET_BOARD_TYPE)
endef
