export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_SPL := $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_SPL_BINARY)

define bootloader-depends-$(ET_BOARD_TYPE)
	@printf ""
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*
	@if ! [ -f $(ET_BOOTLOADER_BUILD_SPL) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@cp -av $(ET_BOOTLOADER_BUILD_SPL) $(ET_BOOTLOADER_DIR)/boot/
	@if ! [ -f $(ET_BOOTLOADER_BUILD_IMAGE) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_IMAGE) build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@cp -av $(ET_BOOTLOADER_BUILD_IMAGE) $(ET_BOOTLOADER_DIR)/boot/
	@if [ -f $(ET_BOOTLOADER_BUILD_DTB) ]; then \
		cp -av $(ET_BOOTLOADER_BUILD_DTB) $(ET_BOOTLOADER_DIR)/boot/; \
	fi
	@if [ -f $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/uEnv.txt ]; then \
		cp -av $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/uEnv.txt $(ET_BOOTLOADER_DIR)/boot/; \
	fi
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
endef
