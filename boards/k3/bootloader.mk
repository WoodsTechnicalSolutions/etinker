ifndef TI_K3_SOC
$(info *** [ 'k3' requires TI_K3_SOC definition ] ***)
$(error ABORTING ***)
endif

ifndef TI_K3_SOC_TYPE
$(info *** [ 'k3' requires TI_K3_SOC_TYPE definition ] ***)
$(error ABORTING ***)
endif

ifndef TI_K3_FW_TYPE
$(info *** [ 'k3' requires TI_K3_FW_TYPE definition ] ***)
$(error ABORTING ***)
endif

export ET_BOOTLOADER_ARCH := $(ET_BOARD_ARCH)

export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_SPL := $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_SPL_BINARY)

export TI_ARM_CROSS_TUPLE := arm-none-eabihf

export TI_K3_BOOT_FIRMWARE_DIR := $(ET_SOFTWARE_DIR)/ti/ti-linux-firmware
export TI_K3_BOOT_FIRMWARE_VERSION ?= 09.01.00.008

export TI_K3_OPTEE_OS_DIR := $(ET_SOFTWARE_DIR)/ti/ti-optee-os
export TI_K3_OPTEE_OS_VERSION ?= 09.01.00.008
export TI_K3_OPTEE_OS_PLATFORM ?= k3-$(TI_K3_SOC)

export TI_K3_ATF_DIR := $(ET_SOFTWARE_DIR)/ti/arm-trusted-firmware
export TI_K3_ATF_VERSION ?= 09.01.00.008

export TI_R5_CROSS_TUPLE := arm-cortexr5-eabihf
export TI_R5_UBOOT_BUILD_DIR := $(ET_DIR)/bootloader/build/$(ET_BOOTLOADER_TYPE)/$(TI_R5_CROSS_TUPLE)
export TI_R5_UBOOT_BUILD_CONFIG := $(TI_R5_UBOOT_BUILD_DIR)/.config
export TI_R5_UBOOT_DIR := $(ET_DIR)/bootloader/$(ET_BOOTLOADER_TYPE)/$(TI_R5_CROSS_TUPLE)
export TI_R5_UBOOT_DEFCONFIG ?= j721e_evm_r5_defconfig

export PATH := $(ET_DIR)/toolchain/$(TI_ARM_CROSS_TUPLE)/bin:$(ET_DIR)/toolchain/$(TI_R5_CROSS_TUPLE)/bin:$(PATH)

export ET_CFLAGS_BOOTLOADER := BINMAN_INDIRS=$(TI_K3_BOOT_FIRMWARE_DIR) \
				BL31=$(TI_K3_ATF_DIR)/build/k3/generic/release/bl31.bin \
				TEE=$(TI_K3_OPTEE_OS_DIR)/out/arm-plat-k3/core/tee-pager_v2.bin

define bootloader-depends-$(ET_BOARD_TYPE)
	@mkdir -p $(ET_SOFTWARE_DIR)/ti
	@mkdir -p $(TI_R5_UBOOT_DIR)/boot
	@mkdir -p $(TI_R5_UBOOT_BUILD_DIR)
	@(if ! [ -f $(ET_DIR)/toolchain/$(TI_R5_CROSS_TUPLE)/bin/$(TI_R5_CROSS_TUPLE)-gcc ]; then \
		ET_BOARD=$(TI_R5_CROSS_TUPLE) make -C $(ET_DIR) toolchain; \
	fi)
	@if ! [ -f $(ET_DIR)/toolchain/$(TI_R5_CROSS_TUPLE)/bin/$(TI_R5_CROSS_TUPLE)-gcc ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) Missing '$(TI_R5_CROSS_TUPLE)' toolchain! *****\n\n"; \
		exit 2; \
	fi
	@(if ! [ -f $(ET_DIR)/toolchain/$(TI_ARM_CROSS_TUPLE)/bin/$(TI_ARM_CROSS_TUPLE)-gcc ]; then \
		ET_BOARD=$(TI_ARM_CROSS_TUPLE) make -C $(ET_DIR) toolchain; \
	fi)
	@if ! [ -f $(ET_DIR)/toolchain/$(TI_ARM_CROSS_TUPLE)/bin/$(TI_ARM_CROSS_TUPLE)-gcc ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) Missing '$(TI_ARM_CROSS_TUPLE)' toolchain! *****\n\n"; \
		exit 2; \
	fi
endef

define bootloader-prepare-$(ET_BOARD_TYPE)
	@mkdir -p $(ET_SOFTWARE_DIR)/ti
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(TI_K3_BOOT_FIRMWARE_VERSION) of 'ti-linux-firmware' *****\n\n"
	@if ! [ -d $(TI_K3_BOOT_FIRMWARE_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/ti && \
			git clone https://git.ti.com/git/processor-firmware/ti-linux-firmware.git); \
		if ! [ -d $(TI_K3_BOOT_FIRMWARE_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(TI_K3_BOOT_FIRMWARE_VERSION) of 'ti-linux-firmware' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	(cd $(TI_K3_BOOT_FIRMWARE_DIR) && echo && \
		if git fetch --all; then \
			git checkout $(TI_K3_BOOT_FIRMWARE_VERSION); \
		fi)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building $(TI_K3_OPTEE_OS_VERSION) of 'ti-optee-os' *****\n\n"
	@if ! [ -d $(TI_K3_OPTEE_OS_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/ti && \
			git clone https://git.ti.com/git/optee/ti-optee-os.git); \
		if ! [ -d $(TI_K3_OPTEE_OS_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(TI_K3_OPTEE_OS_VERSION) of 'ti-optee-os' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	(cd $(TI_K3_OPTEE_OS_DIR) && echo && \
		if git fetch --all; then \
			git checkout $(TI_K3_OPTEE_OS_VERSION); \
		fi; \
		$(MAKE) --no-print-directory \
			CROSS_COMPILE=$(TI_ARM_CROSS_TUPLE)- \
			CROSS_COMPILE64=$(ET_CROSS_COMPILE) \
			PLATFORM=$(TI_K3_OPTEE_OS_PLATFORM) \
			CFG_ARM64_core=y \
			-C $(TI_K3_OPTEE_OS_DIR))
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building $(TI_K3_ATF_VERSION) of 'arm-trusted-firmware' *****\n\n"
	@if ! [ -d $(TI_K3_ATF_DIR) ]; then \
		(cd $(ET_SOFTWARE_DIR)/ti && \
			git clone https://git.ti.com/git/atf/arm-trusted-firmware.git); \
		if ! [ -d $(TI_K3_ATF_DIR) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Getting $(TI_K3_ATF_VERSION) of 'arm-trusted-firmware' FAILED! *****\n\n"; \
			exit 2; \
		fi; \
	fi
	(cd $(TI_K3_ATF_DIR) && echo && \
		if git fetch --all; then \
			git checkout $(TI_K3_ATF_VERSION); \
		fi; \
		$(MAKE) --no-print-directory \
			CROSS_COMPILE=$(ET_CROSS_COMPILE) \
			PLAT=k3 \
			TARGET_BOARD=generic \
			SPD=opteed)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building TI K3 Arm Cortex-R5 $(ET_BOOTLOADER_VERSION) of 'u-boot' *****\n\n"
	@if ! [ -f $(TI_R5_UBOOT_BUILD_CONFIG) ]; then \
		$(MAKE) --no-print-directory \
			$(ET_CFLAGS_BOOTLOADER) \
			CROSS_COMPILE=$(TI_R5_CROSS_TUPLE)- \
			O=$(TI_R5_UBOOT_BUILD_DIR) \
			-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
			$(TI_R5_UBOOT_DEFCONFIG); \
	else \
		yes '' | $(MAKE) --no-print-directory \
			$(ET_CFLAGS_BOOTLOADER) \
			CROSS_COMPILE=$(TI_R5_CROSS_TUPLE)- \
			O=$(TI_R5_UBOOT_BUILD_DIR) \
			-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
			oldconfig; \
	fi
	$(MAKE) --no-print-directory \
		$(ET_CFLAGS_BOOTLOADER) \
		CROSS_COMPILE=$(TI_R5_CROSS_TUPLE)- \
		O=$(TI_R5_UBOOT_BUILD_DIR) \
		-C $(ET_BOOTLOADER_SOFTWARE_DIR)
endef

define bootloader-finalize-$(ET_BOARD_TYPE)
	@if ! [ -f $(ET_BOOTLOADER_BUILD_SPL) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@cp -v $(TI_R5_UBOOT_BUILD_DIR)/sysfw.itb $(ET_BOOTLOADER_DIR)/boot/
	@cp -v $(TI_R5_UBOOT_BUILD_DIR)/tiboot3.bin $(ET_BOOTLOADER_DIR)/boot/
	@cp -av $(ET_BOOTLOADER_BUILD_SPL) $(ET_BOOTLOADER_DIR)/boot/
endef

define bootloader-info-$(ET_BOARD_TYPE)
	@printf "========================================================================\n"
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
endef
