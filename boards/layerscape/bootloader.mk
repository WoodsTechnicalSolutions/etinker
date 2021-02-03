export ET_BOOTLOADER_ARCH := arm

# Handle out-of-tree devicetree build (i.e. dtb-y += fsl-ls1043a-custom-board.dtb)
export DEVICE_TREE_MAKEFILE := -f $(ET_BOARD_DIR)/dts/u-boot/Makefile

export LSDK_VERSION ?= LSDK-20.12
export LSDK_VERSION_URL ?= lsdk2012
export LSDK_MACHINE ?= ls1043ardb
export LSDK_BOOTTYPE ?= sd
export LSDK_FIRMWARE_BIN ?= $(ET_SOFTWARE_DIR)/qoriq/firmware_$(LSDK_MACHINE)_uboot_$(LSDK_BOOTTYPE)boot-$(LSDK_VERSION_URL).img
export LSDK_SRK_HASH ?= $(ET_SOFTWARE_DIR)/qoriq/srk_hash-$(LSDK_VERSION_URL).txt
export LSDK_SRK_PRI ?= $(ET_SOFTWARE_DIR)/qoriq/srk-$(LSDK_VERSION_URL).pri
export LSDK_SRK_PUB ?= $(ET_SOFTWARE_DIR)/qoriq/srk-$(LSDK_VERSION_URL).pub

define bootloader-depends-$(ET_BOARD_TYPE)
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
	@echo
	@mkdir -p $(ET_SOFTWARE_DIR)/qoriq
	@if ! [ -f $(LSDK_FIRMWARE_BIN) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) QorIQ Composite Firmware Image *****\n\n"; \
		wget -O $(LSDK_FIRMWARE_BIN) \
			https://www.nxp.com/lgfiles/sdk/$(LSDK_VERSION_URL)/firmware_$(LSDK_MACHINE)_uboot_$(LSDK_BOOTTYPE)boot.img; \
		if ! [ -f $(LSDK_FIRMWARE_BIN) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) QorIQ Firmware FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@if ! [ -f $(LSDK_SRK_HASH) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) QorIQ Security Files *****\n\n"; \
		wget -O $(LSDK_SRK_HASH) https://www.nxp.com/lgfiles/sdk/$(LSDK_VERSION_URL)/srk_hash.txt; \
		if ! [ -f $(LSDK_SRK_HASH) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) $(LSDK_SRK_HASH) FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@if ! [ -f $(LSDK_SRK_PRI) ]; then \
		wget -O $(LSDK_SRK_PRI) https://www.nxp.com/lgfiles/sdk/$(LSDK_VERSION_URL)/srk.pri; \
		if ! [ -f $(LSDK_SRK_PRI) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) $(LSDK_SRK_PRI) FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	@if ! [ -f $(LSDK_SRK_PUB) ]; then \
		wget -O $(LSDK_SRK_PUB) https://www.nxp.com/lgfiles/sdk/$(LSDK_VERSION_URL)/srk.pub; \
		if ! [ -f $(LSDK_SRK_PUB) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(LSDK_VERSION) $(LSDK_SRK_PUB) FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "LSDK_VERSION: $(LSDK_VERSION)\n"
	@printf "LSDK_VERSION_URL: $(LSDK_VERSION_URL)\n"
	@printf "LSDK_MACHINE: $(LSDK_MACHINE)\n"
	@printf "LSDK_BOOTTYPE: $(LSDK_BOOTTYPE)\n"
	@printf "LSDK_FIRMWARE_BIN: $(LSDK_FIRMWARE_BIN)\n"
	@printf "LSDK_SRK_HASH: $(LSDK_SRK_HASH)\n"
	@printf "LSDK_SRK_PRI: $(LSDK_SRK_PRI)\n"
	@printf "LSDK_SRK_PUB: $(LSDK_SRK_PUB)\n"
endef
