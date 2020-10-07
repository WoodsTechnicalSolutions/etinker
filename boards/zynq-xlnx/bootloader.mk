export ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && make -s ubootversion | tr -d \\n)
export ET_BOOTLOADER_LOCALVERSION := -$(ET_BOOTLOADER_CACHED_VERSION)
export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/spl/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_SPL := $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_SPL_BINARY)

# Handle out-of-tree devicetree build (i.e. dtb-y += zynq-custom-board.dtb)
export DEVICE_TREE_MAKEFILE := -f $(ET_BOARD_DIR)/dts/Makefile

define bootloader-depends-$(ET_BOARD_TYPE)
	@if [ -d $(ET_BOARD_DIR)/fpga/sdk ]; then \
		rsync -r $(ET_BOARD_DIR)/fpga/dts $(ET_BOARD_DIR)/; \
		rsync -r $(ET_BOARD_DIR)/fpga/sdk/ps*_init_gpl.* \
			$(ET_BOOTLOADER_SOFTWARE_DIR)/board/xilinx/zynq/$(ET_BOARD_KERNEL_DT)/; \
	else \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] FPGA BUILD IS MISSING! *****\n"; \
		exit 2; \
	fi
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
	@if ! [ -f $(ET_BOOTLOADER_BUILD_SPL) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@cp -av $(ET_BOOTLOADER_BUILD_SPL) $(ET_BOOTLOADER_DIR)/boot/
	@if [ -f $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/uEnv.txt ]; then \
		cp -av $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/uEnv.txt $(ET_BOOTLOADER_DIR)/boot/; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Generating Xilinx 'system.bit.bin' *****\n\n"
	@(cd $(ET_BOARD_DIR)/fpga && \
		$(ET_SCRIPTS_DIR)/fpga-bit-to-bin.py -f "`ls sdk/*.bit | tr -d \\\n`" \
		$(ET_BOOTLOADER_DIR)/boot/system.bit.bin)
	@if ! [ -f $(ET_BOOTLOADER_DIR)/boot/system.bit.bin ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Xilinx 'system.bit.bin' build FAILED! *****\n\n"; \
		exit 2; \
	fi
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
endef
