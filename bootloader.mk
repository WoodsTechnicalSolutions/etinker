#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://www.denx.de/wiki/U-Boot
# - https://gitlab.denx.de/u-boot/u-boot
# - https://gitlab.denx.de/u-boot/u-boot/-/tree/master/doc
#

ifndef ET_BOARD_BOOTLOADER_TREE
$(error [ 'etinker' bootloader build requires ET_BOARD_BOOTLOADER_TREE ] ***)
endif

# embedded bootloader, for application processors, is Das U-Boot
export ET_BOOTLOADER_TREE := $(ET_BOARD_BOOTLOADER_TREE)
export ET_BOOTLOADER_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_BOOTLOADER_TREE)
export ET_BOOTLOADER_CACHED_VERSION := $(shell grep -Po 'bootloader-ref:\K[^\n]*' $(ET_BOARD_DIR)/software.conf)
ifeq ($(ET_BOARD_DEFCONFIG),)
et_bootloader_defconfig := $(ET_BOARD_BOOTLOADER_DEFCONFIG)
else
et_bootloader_defconfig := $(ET_BOARD_DEFCONFIG)
endif
# [start] bootloader version magic
ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | tr -d v)
ET_BOOTLOADER_LOCALVERSION := -$(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | cut -d '-' -f 2-5)
ifeq ($(shell echo $(ET_BOOTLOADER_LOCALVERSION) | sed s,[0-9].*,,),-rc)
# RC version (i.e. v2018.09-rc1)
rcversion := $(shell printf "%s" $(ET_BOOTLOADER_LOCALVERSION) | cut -d '-' -f 2)
rclocalversion := -$(shell printf "%s" $(ET_BOOTLOADER_LOCALVERSION) | cut -d '-' -f 3-5)
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-$(rcversion)$(rclocalversion))
ET_BOOTLOADER_LOCALVERSION := $(rclocalversion)
endif
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-$(rcversion))
ET_BOOTLOADER_LOCALVERSION :=
endif
endif
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-)
# empty local version
ET_BOOTLOADER_LOCALVERSION :=
endif
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-v$(ET_BOOTLOADER_VERSION))
# exact tag in series (i.e. v2018.09)
ET_BOOTLOADER_LOCALVERSION :=
endif
ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -Po xlnx),xlnx)
# Xilinx 'u-boot-xlnx' tree
ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && make -s ubootversion | tr -d \\n)
ET_BOOTLOADER_LOCALVERSION := -$(ET_BOOTLOADER_CACHED_VERSION)
endif
export ET_BOOTLOADER_VERSION
export ET_BOOTLOADER_LOCALVERSION
# [end] bootloader version magic
export ET_BOOTLOADER_BUILD_DIR := $(ET_DIR)/bootloader/build/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_BUILD_CONFIG := $(ET_BOOTLOADER_BUILD_DIR)/.config
export ET_BOOTLOADER_BUILD_DEFCONFIG := $(ET_BOOTLOADER_BUILD_DIR)/defconfig
export ET_BOOTLOADER_BUILD_SYSMAP := $(ET_BOOTLOADER_BUILD_DIR)/System.map
ifeq ($(shell echo $(ET_BOARD_TYPE)|grep omap2plus|cut -d '-' -f 1),omap2plus)
export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
else
export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/spl/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
endif
export ET_BOOTLOADER_BUILD_DTB := $(ET_BOOTLOADER_BUILD_DIR)/u-boot-dtb.img
export ET_BOOTLOADER_BUILD_IMAGE := $(ET_BOOTLOADER_BUILD_DIR)/u-boot.img
export ET_BOOTLOADER_DIR := $(ET_DIR)/bootloader/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_CONFIG := $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/config
export ET_BOOTLOADER_DEFCONFIG := $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/$(et_bootloader_defconfig)
export ET_BOOTLOADER_SYSMAP := $(ET_BOOTLOADER_DIR)/System.map
export ET_BOOTLOADER_SPL := $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_DTB := $(ET_BOOTLOADER_DIR)/boot/u-boot-dtb.img
export ET_BOOTLOADER_IMAGE := $(ET_BOOTLOADER_DIR)/boot/u-boot.img
export ET_BOOTLOADER_TARGET_FINAL ?= $(ET_BOOTLOADER_IMAGE)

export DEVICE_TREE := $(ET_BOARD_KERNEL_DT)
ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -Po zynq),zynq)
# Handle out-of-tree devicetree build (i.e. dtb-y += zynq-custom-board.dtb)
DEVICE_TREE_MAKEFILE := -f $(ET_BOARD_DIR)/dts/Makefile
endif

define bootloader-version
	@printf "ET_BOOTLOADER_VERSION: \033[0;33m[$(ET_BOOTLOADER_CACHED_VERSION)]\033[0m $(ET_BOOTLOADER_VERSION)\n"
	@printf "ET_BOOTLOADER_LOCALVERSION: $(ET_BOOTLOADER_LOCALVERSION)\n"
endef

define bootloader-depends
	@mkdir -p $(ET_BOOTLOADER_DIR)/boot
	@mkdir -p $(ET_BOOTLOADER_BUILD_DIR)
	@mkdir -p $(shell dirname $(ET_BOOTLOADER_CONFIG))
	@case "$(ET_BOARD_TYPE)" in \
	zynq|zynq-xlnx) \
		if [ -d $(ET_BOARD_DIR)/fpga/sdk ]; then \
			rsync -r $(ET_BOARD_DIR)/fpga/dts $(ET_BOARD_DIR)/; \
			rsync -r $(ET_BOARD_DIR)/fpga/sdk/ps*_init_gpl.* \
				$(ET_BOOTLOADER_SOFTWARE_DIR)/board/xilinx/zynq/$(ET_BOARD_KERNEL_DT)/; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] FPGA BUILD IS MISSING! *****\n"; \
			exit 2; \
		fi \
		;; \
	*) \
		;; \
	esac
	@if [ -d $(ET_BOARD_DIR)/dts ] && [ -n "`ls $(ET_BOARD_DIR)/dts/*.dts* 2> /dev/null`" ]; then \
		rsync -rP $(ET_BOARD_DIR)/dts/*.dts* \
			$(ET_BOOTLOADER_SOFTWARE_DIR)/arch/$(ET_ARCH)/dts/; \
	fi
	@if [ -d $(ET_BOARD_DIR)/dts/u-boot ] && [ -n "`ls $(ET_BOARD_DIR)/dts/u-boot/*.dts* 2> /dev/null`" ]; then \
		rsync -rP $(ET_BOARD_DIR)/dts/u-boot/*.dts* \
			$(ET_BOOTLOADER_SOFTWARE_DIR)/arch/$(ET_ARCH)/dts/; \
	fi
	@if [ -f $(ET_BOOTLOADER_DEFCONFIG) ]; then \
		rsync $(ET_BOOTLOADER_DEFCONFIG) $(ET_BOOTLOADER_SOFTWARE_DIR)/configs/ > /dev/null; \
	fi
endef

define bootloader-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) $(ET_BOOTLOADER_VERSION) *****\n\n"
	$(call bootloader-depends)
	@if ! [ -f $(ET_BOOTLOADER_BUILD_CONFIG) ]; then \
		if [ -f $(ET_BOOTLOADER_CONFIG) ]; then \
			rsync $(ET_BOOTLOADER_CONFIG) $(ET_BOOTLOADER_BUILD_CONFIG); \
		else \
			$(MAKE) --no-print-directory $(ET_CROSS_PARAMS) \
				O=$(ET_BOOTLOADER_BUILD_DIR) \
				-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
				$(et_bootloader_defconfig); \
		fi; \
	fi
	$(call bootloader-build)
endef

define bootloader-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-build 'make $1' *****\n\n"
	$(call bootloader-depends)
	@if [ -f $(ET_BOOTLOADER_CONFIG) ] && ! [ "$1" = "$(et_bootloader_defconfig)" ]; then \
		case "$1" in \
		*config) \
			rsync $(ET_BOOTLOADER_CONFIG) $(ET_BOOTLOADER_BUILD_CONFIG); \
			;; \
		*) \
			;; \
		esac; \
	fi
	(cd $(ET_BOOTLOADER_SOFTWARE_DIR) && \
		$(MAKE) --no-print-directory -j $(ET_CPUS) $(ET_CROSS_PARAMS) \
			DEVICE_TREE=$(DEVICE_TREE) \
			LOCALVERSION=$(ET_BOOTLOADER_LOCALVERSION) \
			O=$(ET_BOOTLOADER_BUILD_DIR) \
			$(DEVICE_TREE_MAKEFILE) \
			-f Makefile \
			$1)
	@if [ -n "$1" ]; then \
		if [ -n "$(shell printf "%s" $1 | grep config)" ]; then \
			if [ -f $(ET_BOOTLOADER_BUILD_CONFIG) ]; then \
				rsync $(ET_BOOTLOADER_BUILD_CONFIG) $(ET_BOOTLOADER_CONFIG); \
			else \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		if [ -n "$(shell printf "%s" $1 | grep clean)" ]; then \
			$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*; \
			$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*; \
		fi; \
	else \
		$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*; \
		$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*; \
		if ! [ -f $(ET_BOOTLOADER_BUILD_SPL) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_SPL) build FAILED! *****\n\n"; \
			exit 2; \
		fi; \
		cp -av $(ET_BOOTLOADER_BUILD_SPL) $(ET_BOOTLOADER_DIR)/boot/; \
		if ! [ -f $(ET_BOOTLOADER_BUILD_IMAGE) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_IMAGE) build FAILED! *****\n\n"; \
			exit 2; \
		fi; \
		cp -av $(ET_BOOTLOADER_BUILD_IMAGE) $(ET_BOOTLOADER_DIR)/boot/; \
		if [ -f $(ET_BOOTLOADER_BUILD_DTB) ]; then \
			cp -av $(ET_BOOTLOADER_BUILD_DTB) $(ET_BOOTLOADER_DIR)/boot/; \
		fi; \
		if [ -f $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/uEnv.txt ]; then \
			cp -av $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/uEnv.txt $(ET_BOOTLOADER_DIR)/boot/; \
		fi; \
		case "$(ET_BOARD_TYPE)" in \
		zynq*) \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Generating Xilinx 'system.bit.bin' *****\n\n"; \
			(cd $(ET_BOARD_DIR)/fpga && \
				$(ET_SCRIPTS_DIR)/fpga-bit-to-bin.py -f "`ls sdk/*.bit | tr -d \\\n`" \
				$(ET_BOOTLOADER_DIR)/boot/system.bit.bin); \
			if ! [ -f $(ET_BOOTLOADER_DIR)/boot/system.bit.bin ]; then \
				printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Xilinx 'system.bit.bin' build FAILED! *****\n\n"; \
				exit 2; \
			fi; \
			;; \
		*) \
			;; \
		esac; \
	fi
	@if [ -f $(ET_BOOTLOADER_BUILD_CONFIG) ]; then \
		if [ -n "$(shell diff -q $(ET_BOOTLOADER_BUILD_CONFIG) $(ET_BOOTLOADER_CONFIG) 2> /dev/null)" ]; then \
			rsync $(ET_BOOTLOADER_BUILD_CONFIG) $(ET_BOOTLOADER_CONFIG); \
		fi; \
		if [ -f $(ET_BOOTLOADER_BUILD_DEFCONFIG) ]; then \
			rsync $(ET_BOOTLOADER_BUILD_DEFCONFIG) $(ET_BOOTLOADER_DEFCONFIG); \
		fi; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] bootloader-build 'make $1' done. *****\n\n"
endef

define bootloader-config
	$(call software-check,$(ET_BOOTLOADER_TREE),bootloader)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-config *****\n\n"
	$(call bootloader-depends)
	@if ! [ -f $(ET_BOOTLOADER_CONFIG) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-config FAILED! *****\n\n"; \
		exit 2; \
	fi
	@rsync $(ET_BOOTLOADER_CONFIG) $(ET_BOOTLOADER_BUILD_CONFIG)
endef

define bootloader-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-clean *****\n\n"
	$(RM) $(ET_BOOTLOADER_BUILD_CONFIG)
	$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*
	$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
endef

define bootloader-purge
	$(call bootloader-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-purge *****\n\n"
	$(RM) -r $(ET_BOOTLOADER_BUILD_DIR)
endef

define bootloader-info
	@printf "========================================================================\n"
	@printf "ET_BOOTLOADER_TREE: $(ET_BOOTLOADER_TREE)\n"
	@printf "ET_BOOTLOADER_VERSION: $(ET_BOOTLOADER_VERSION)\n"
	@printf "ET_BOOTLOADER_LOCALVERSION: $(ET_BOOTLOADER_LOCALVERSION)\n"
	@printf "ET_BOOTLOADER_SOFTWARE_DIR: $(ET_BOOTLOADER_SOFTWARE_DIR)\n"
	@printf "ET_BOOTLOADER_SYSMAP: $(ET_BOOTLOADER_SYSMAP)\n"
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_DTB: $(ET_BOOTLOADER_DTB)\n"
	@printf "ET_BOOTLOADER_IMAGE: $(ET_BOOTLOADER_IMAGE)\n"
	@printf "ET_BOOTLOADER_CONFIG: $(ET_BOOTLOADER_CONFIG)\n"
	@printf "et_bootloader_defconfig: $(et_bootloader_defconfig)\n"
	@printf "ET_BOOTLOADER_DEFCONFIG: $(ET_BOOTLOADER_DEFCONFIG)\n"
	@printf "ET_BOOTLOADER_BUILD_CONFIG: $(ET_BOOTLOADER_BUILD_CONFIG)\n"
	@printf "ET_BOOTLOADER_BUILD_DEFCONFIG: $(ET_BOOTLOADER_BUILD_DEFCONFIG)\n"
	@printf "ET_BOOTLOADER_BUILD_SYSMAP: $(ET_BOOTLOADER_BUILD_SYSMAP)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_DTB: $(ET_BOOTLOADER_BUILD_DTB)\n"
	@printf "ET_BOOTLOADER_BUILD_IMAGE: $(ET_BOOTLOADER_BUILD_IMAGE)\n"
	@printf "ET_BOOTLOADER_BUILD_DIR: $(ET_BOOTLOADER_BUILD_DIR)\n"
	@printf "ET_BOOTLOADER_DIR: $(ET_BOOTLOADER_DIR)\n"
	@printf "ET_BOOTLOADER_TARGET_FINAL: $(ET_BOOTLOADER_TARGET_FINAL)\n"
endef

define bootloader-sync
	@$(ET_DIR)/scripts/sync bootloader $1
endef

.PHONY: bootloader
bootloader: $(ET_BOOTLOADER_TARGET_FINAL)
$(ET_BOOTLOADER_TARGET_FINAL): $(ET_BOOTLOADER_BUILD_CONFIG)
	$(call bootloader-targets)

bootloader-%: $(ET_BOOTLOADER_BUILD_CONFIG)
	$(call bootloader-build,$(*F))

.PHONY: bootloader-config
bootloader-config: $(ET_BOOTLOADER_BUILD_CONFIG)
$(ET_BOOTLOADER_BUILD_CONFIG): $(ET_BOOTLOADER_CONFIG)
ifeq ($(shell test -f $(ET_BOOTLOADER_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call bootloader-config)
endif

$(ET_BOOTLOADER_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
ifeq ($(shell test -f $(ET_BOOTLOADER_CONFIG) && printf "EXISTS" || printf "DEFAULT"),DEFAULT)
	$(call bootloader-build,$(et_bootloader_defconfig))
endif

.PHONY: bootloader-clean
bootloader-clean:
ifeq ($(ET_CLEAN),yes)
	$(call bootloader-build,clean)
endif
	$(call $@)

.PHONY: bootloader-purge
bootloader-purge:
	$(call $@)

.PHONY: bootloader-version
bootloader-version:
	$(call $@)

.PHONY: bootloader-info
bootloader-info:
	$(call $@)

bootloader-sync-%:
	$(call bootloader-sync,$(*F))
