export ET_BOOTLOADER_ARCH := $(ET_BOARD_ARCH)

ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -o xlnx),xlnx)
# Xilinx 'u-boot-xlnx' tree
export ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) $(ET_NOERR) && make -s ubootversion | tr -d \\n)
export ET_BOOTLOADER_LOCALVERSION := -$(ET_BOOTLOADER_CACHED_VERSION)
endif
export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/spl/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_SPL := $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_SPL_BINARY)

export XILINX_VERSION := 2025.1
export XILINX_VITIS_DIR := /tools/Xilinx/$(XILINX_VERSION)/Vitis

ifeq ($(shell [ -f $(XILINX_VITIS_DIR)/bin/bootgen ] && echo found || echo missing),missing)
$(error MISSING Xilinx Vitis 'bootgen' ***)
endif

define bootloader-depends-$(ET_BOARD_TYPE)
	@if [ -d $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/sdk ]; then \
		rsync -r $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/dts $(ET_BOARD_DIR)/; \
		rsync -r $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/sdk/ps*_init_gpl.* \
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
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Fetching Xilinx 'fpga.bin' *****\n\n"
	@cp -av $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/sdk/*.bin $(ET_BOOTLOADER_DIR)/boot/fpga.bin
	@if ! [ -f $(ET_BOOTLOADER_DIR)/boot/fpga.bin ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Xilinx 'fpga.bin' build FAILED! *****\n\n"; \
		exit 2; \
	fi
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
endef
