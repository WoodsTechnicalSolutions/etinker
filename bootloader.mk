#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2022 Derald D. Woods
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

et_board := $(ET_BOARD)

ifdef ET_BOARD_ALIAS
et_board := $(ET_BOARD_ALIAS)
endif

ifndef ET_BOARD_BOOTLOADER_TYPE
export ET_BOARD_BOOTLOADER_TYPE := $(ET_BOARD_TYPE)
endif

# embedded bootloader, for application processors, is Das U-Boot
export ET_BOOTLOADER_TYPE := $(ET_BOARD_BOOTLOADER_TYPE)
export ET_BOOTLOADER_TREE := $(ET_BOARD_BOOTLOADER_TREE)
export ET_BOOTLOADER_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_BOOTLOADER_TREE)
export ET_BOOTLOADER_CACHED_VERSION := $(shell grep -Po 'bootloader-ref:\K[^\n]*' $(ET_BOARD_DIR)/software.conf)

bootloader_defconfig := et_$(subst -,_,$(et_board))_defconfig

ifneq ($(shell ls $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null),)
bversion := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && make -s ubootversion | tr -d \\n)
bgithash := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && git rev-parse --short HEAD)
bgitdirty := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && git describe --dirty|grep -Po -e '-dirty')
blocalversion := -g$(bgithash)$(bgitdirty)

ifdef USE_BOOTLOADER_TREE_VERSION
ET_BOOTLOADER_VERSION := $(bversion)
ET_BOOTLOADER_LOCALVERSION := $(USE_BOOTLOADER_TREE_VERSION)$(blocalversion)
else
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
ifneq ($(ET_BOOTLOADER_LOCALVERSION),)
ifeq ($(ET_BOOTLOADER_LOCALVERSION),$(shell echo $(ET_BOOTLOADER_VERSION) | grep -Po -e '$(ET_BOOTLOADER_LOCALVERSION)'))
# split out localversion
ET_BOOTLOADER_VERSION := $(shell echo $(ET_BOOTLOADER_VERSION) | sed s,$(ET_BOOTLOADER_LOCALVERSION),,)
endif
endif
export ET_BOOTLOADER_VERSION
export ET_BOOTLOADER_LOCALVERSION
# [end] bootloader version magic
endif
endif

export ET_BOOTLOADER_BUILD_DIR := $(ET_DIR)/bootloader/build/$(et_board)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_BUILD_CONFIG := $(ET_BOOTLOADER_BUILD_DIR)/.config
export ET_BOOTLOADER_BUILD_DEFCONFIG := $(ET_BOOTLOADER_BUILD_DIR)/defconfig
export ET_BOOTLOADER_BUILD_SYSMAP := $(ET_BOOTLOADER_BUILD_DIR)/System.map
export ET_BOOTLOADER_DIR := $(ET_DIR)/bootloader/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_DEFCONFIG := $(ET_DIR)/boards/$(ET_BOOTLOADER_TYPE)/config/u-boot-$(et_board)/$(bootloader_defconfig)

export DEVICE_TREE := $(ET_BOARD_BOOTLOADER_DT)
# Handle out-of-tree devicetree build (i.e. dtb-y += custom-board.dtb)
ifneq ($(shell ls $(ET_BOARD_DIR)/dts/u-boot/Makefile 2> /dev/null),)
export DEVICE_TREE_MAKEFILE := -f $(ET_BOARD_DIR)/dts/u-boot/Makefile
endif

# Get board specific definitions
include $(ET_DIR)/boards/$(et_board)/bootloader.mk

export ET_BOOTLOADER_BUILD_IMAGE ?= $(ET_BOOTLOADER_BUILD_DIR)/$(ET_BOARD_BOOTLOADER_IMAGE)
export ET_BOOTLOADER_IMAGE ?= $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_IMAGE)
export ET_BOOTLOADER_TARGET_FINAL ?= $(ET_BOOTLOADER_IMAGE)

define bootloader-version
	@printf "ET_BOOTLOADER_VERSION: \033[0;33m[$(ET_BOOTLOADER_CACHED_VERSION)]\033[0m $(ET_BOOTLOADER_VERSION)\n"
	@printf "ET_BOOTLOADER_LOCALVERSION: $(ET_BOOTLOADER_LOCALVERSION)\n"
endef

define bootloader-depends
	@mkdir -p $(ET_BOOTLOADER_DIR)/boot
	@mkdir -p $(ET_BOOTLOADER_BUILD_DIR)
	@mkdir -p $(shell dirname $(ET_BOOTLOADER_DEFCONFIG))
	@if [ -d $(ET_BOARD_DIR)/dts ] && [ -n "`ls $(ET_BOARD_DIR)/dts/*.dts* 2> /dev/null`" ]; then \
		rsync -rP $(ET_BOARD_DIR)/dts/*.dts* \
			$(ET_BOOTLOADER_SOFTWARE_DIR)/arch/$(ET_BOOTLOADER_ARCH)/dts/; \
	fi
	@if [ -d $(ET_BOARD_DIR)/dts/u-boot ] && [ -n "`ls $(ET_BOARD_DIR)/dts/u-boot/*.dts* 2> /dev/null`" ]; then \
		rsync -rP $(ET_BOARD_DIR)/dts/u-boot/*.dts* \
			$(ET_BOOTLOADER_SOFTWARE_DIR)/arch/$(ET_BOOTLOADER_ARCH)/dts/; \
	fi
	@if [ -f $(ET_BOOTLOADER_DEFCONFIG) ]; then \
		rsync $(ET_BOOTLOADER_DEFCONFIG) $(ET_BOOTLOADER_SOFTWARE_DIR)/configs/ > /dev/null; \
	fi
	$(call bootloader-depends-$(ET_BOARD))
endef

define bootloader-prepare
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) $(ET_BOOTLOADER_VERSION) *****\n\n"
	$(call bootloader-depends)
	$(call bootloader-prepare-$(ET_BOARD))
endef

define bootloader-finalize
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*
	@if ! [ -f $(ET_BOOTLOADER_BUILD_IMAGE) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_IMAGE) build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@if [ -f $(ET_DIR)/boards/$(ET_BOOTLOADER_TYPE)/config/u-boot-$(et_board)/uEnv.txt ]; then \
		cp -av $(ET_DIR)/boards/$(ET_BOOTLOADER_TYPE)/config/u-boot-$(et_board)/uEnv*.txt $(ET_BOOTLOADER_DIR)/boot/; \
	fi
	@if [ -d $(ET_DIR)/boards/$(ET_BOOTLOADER_TYPE)/config/u-boot-$(et_board)/extlinux ]; then \
		cp -av $(ET_DIR)/boards/$(ET_BOOTLOADER_TYPE)/config/u-boot-$(et_board)/extlinux $(ET_BOOTLOADER_DIR)/boot/; \
	fi
	@cp -av $(ET_BOOTLOADER_BUILD_IMAGE) $(ET_BOOTLOADER_DIR)/boot/
	$(call bootloader-finalize-$(ET_BOARD))
	@if [ "$(ET_TFTP)" = "yes" ] && [ -d $(ET_TFTP_DIR) ]; then \
		if ! [ -d $(ET_TFTP_DIR)/$(ET_BOARD) ]; then \
			sudo mkdir -p $(ET_TFTP_DIR)/$(ET_BOARD); \
			sudo chown $(USER).$(USER) $(ET_TFTP_DIR)/$(ET_BOARD); \
		fi; \
		rsync -r $(ET_BOOTLOADER_DIR)/boot/* $(ET_TFTP_DIR)/$(ET_BOARD)/; \
	fi
endef

define bootloader-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-build 'make $1' *****\n\n"
	$(call bootloader-depends)
	@case "$1" in \
	*config) \
		;; \
	*) \
		if ! [ -f $(ET_BOOTLOADER_BUILD_CONFIG) ]; then \
			$(MAKE) --no-print-directory \
				CROSS_COMPILE=$(ET_CROSS_COMPILE) \
				O=$(ET_BOOTLOADER_BUILD_DIR) \
				-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
				$(bootloader_defconfig); \
			if ! [ -f $(ET_BOOTLOADERL_BUILD_CONFIG) ]; then \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		;; \
	esac
	(cd $(ET_BOOTLOADER_SOFTWARE_DIR) && \
		$(MAKE) --no-print-directory -j $(ET_CPUS) \
			CROSS_COMPILE=$(ET_CROSS_COMPILE) \
			DEVICE_TREE=$(DEVICE_TREE) \
			LOCALVERSION=$(ET_BOOTLOADER_LOCALVERSION) \
			O=$(ET_BOOTLOADER_BUILD_DIR) \
			$(DEVICE_TREE_MAKEFILE) \
			-f Makefile \
			$1)
	@case "$1" in \
	*clean) \
		$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*; \
		$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*; \
		$(RM) $(ET_BOOTLOADER_DIR)/boot/uEnv*; \
		$(RM) -r $(ET_BOOTLOADER_DIR)/boot/extlinux; \
		;; \
	*config) \
		if ! [ -f $(ET_BOOTLOADER_BUILD_CONFIG) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
		if ! [ "$1" = "savedefconfig" ]; then \
			$(MAKE) --no-print-directory \
				CROSS_COMPILE=$(ET_CROSS_COMPILE) \
				O=$(ET_BOOTLOADER_BUILD_DIR) \
				-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
				savedefconfig; \
		fi; \
		if [ -f $(ET_BOOTLOADER_BUILD_DEFCONFIG) ]; then \
			rsync $(ET_BOOTLOADER_BUILD_DEFCONFIG) $(ET_BOOTLOADER_DEFCONFIG); \
			$(RM) $(ET_BOOTLOADER_BUILD_DEFCONFIG); \
		fi; \
		;; \
	*) \
		;; \
	esac
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] bootloader-build 'make $1' done. *****\n\n"
endef

define bootloader-config
	$(call software-check,$(ET_BOOTLOADER_TREE),bootloader)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-config *****\n\n"
	$(call bootloader-depends)
	$(MAKE) --no-print-directory \
		CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		O=$(ET_BOOTLOADER_BUILD_DIR) \
		-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
		$(bootloader_defconfig)
endef

define bootloader-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-clean *****\n\n"
	$(RM) $(ET_BOOTLOADER_BUILD_CONFIG)
	$(RM) $(ET_BOOTLOADER_BUILD_DEFCONFIG)
	$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*
	$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
	$(RM) $(ET_BOOTLOADER_DIR)/boot/uEnv*
	$(RM) -r $(ET_BOOTLOADER_DIR)/boot/extlinux
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
	@printf "ET_BOOTLOADER_ARCH: $(ET_BOOTLOADER_ARCH)\n"
	@printf "ET_BOOTLOADER_SOFTWARE_DIR: $(ET_BOOTLOADER_SOFTWARE_DIR)\n"
	@printf "ET_BOOTLOADER_BUILD_CONFIG: $(ET_BOOTLOADER_BUILD_CONFIG)\n"
	@printf "ET_BOOTLOADER_BUILD_DEFCONFIG: $(ET_BOOTLOADER_BUILD_DEFCONFIG)\n"
	@printf "ET_BOOTLOADER_BUILD_SYSMAP: $(ET_BOOTLOADER_BUILD_SYSMAP)\n"
	@printf "ET_BOOTLOADER_BUILD_IMAGE: $(ET_BOOTLOADER_BUILD_IMAGE)\n"
	@printf "ET_BOOTLOADER_BUILD_DIR: $(ET_BOOTLOADER_BUILD_DIR)\n"
	@printf "ET_BOOTLOADER_DEFCONFIG: $(ET_BOOTLOADER_DEFCONFIG)\n"
	@printf "ET_BOOTLOADER_DIR: $(ET_BOOTLOADER_DIR)\n"
	@printf "ET_BOOTLOADER_IMAGE: $(ET_BOOTLOADER_IMAGE)\n"
	@printf "ET_BOOTLOADER_TARGET_FINAL: $(ET_BOOTLOADER_TARGET_FINAL)\n"
	$(call bootloader-info-$(ET_BOARD))
endef

define bootloader-sync
	@$(ET_DIR)/scripts/sync bootloader $1
endef

.PHONY: bootloader
bootloader: $(ET_BOOTLOADER_TARGET_FINAL)
$(ET_BOOTLOADER_TARGET_FINAL): $(ET_BOOTLOADER_BUILD_CONFIG)
	$(call bootloader-prepare)
	$(call bootloader-build)
	$(call bootloader-finalize)

bootloader-%: $(ET_BOOTLOADER_BUILD_CONFIG)
	$(call bootloader-build,$(*F))

.PHONY: bootloader-config
bootloader-config: $(ET_BOOTLOADER_BUILD_CONFIG)
$(ET_BOOTLOADER_BUILD_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
	$(call bootloader-config)

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

.PHONY: bootloader-update
bootloader-update: bootloader-clean bootloader
