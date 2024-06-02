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

export TI_K3_BOOT_FIRMWARE_DIR := $(ET_SOFTWARE_DIR)/ti/ti-linux-firmware
export TI_K3_BOOT_FIRMWARE_VERSION ?= origin/ti-linux-firmware

export TI_K3_ATF_DIR := $(ET_SOFTWARE_DIR)/ti/arm-trusted-firmware
export TI_K3_ATF_VERSION ?= 09.02.00.009

export TI_K3_OPTEE_OS_DIR := $(ET_SOFTWARE_DIR)/ti/ti-optee-os
export TI_K3_OPTEE_OS_VERSION ?= $(TI_K3_ATF_VERSION)
export TI_K3_OPTEE_OS_PLATFORM ?= k3-$(TI_K3_SOC)

export TI_ARM_CROSS_TUPLE := arm-none-eabihf
export TI_R5_CROSS_TUPLE := arm-cortexr5-eabihf
export TI_ARM64_CROSS_COMPILE := 

export ET_CFLAGS_BOOTLOADER := BINMAN_INDIRS=$(TI_K3_BOOT_FIRMWARE_DIR) \
				BL31=$(TI_K3_ATF_DIR)/build/k3/generic/release/bl31.bin \
				TEE=$(TI_K3_OPTEE_OS_DIR)/out/arm-plat-k3/core/tee-pager_v2.bin

export PATH := $(ET_DIR)/toolchain/$(TI_ARM64_CROSS_TUPLE)/bin:$(ET_DIR)/toolchain/$(TI_ARM_CROSS_TUPLE)/bin:$(PATH)

define bootloader-depends-common
	@(if ! [ -f $(ET_DIR)/toolchain/$(TI_ARM_CROSS_TUPLE)/bin/$(TI_ARM_CROSS_TUPLE)-gcc ]; then \
		ET_BOARD=$(TI_ARM_CROSS_TUPLE) make -C $(ET_DIR) toolchain; \
	fi)
	@if ! [ -f $(ET_DIR)/toolchain/$(TI_ARM_CROSS_TUPLE)/bin/$(TI_ARM_CROSS_TUPLE)-gcc ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) Missing '$(TI_ARM_CROSS_TUPLE)' toolchain! *****\n\n"; \
		exit 2; \
	fi
endef

define bootloader-prepare-common
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
			CROSS_COMPILE64=$(TI_ARM64_CROSS_TUPLE)- \
			PLATFORM=$(TI_K3_OPTEE_OS_PLATFORM) \
			CFG_ARM64_core=y \
			all)
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
			CROSS_COMPILE=$(TI_ARM64_CROSS_TUPLE)- \
			PLAT=k3 \
			TARGET_BOARD=generic \
			SPD=opteed \
			all)
endef

define bootloader-finalize-common
	@if ! [ -f $(ET_BOOTLOADER_BUILD_SPL) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@cp -v $(ET_BOOTLOADER_BUILD_SPL) $(ET_BOOTLOADER_DIR)/boot/
endef

define bootloader-info-common
	@printf "========================================================================\n"
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
endef
