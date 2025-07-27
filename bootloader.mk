#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://www.denx.de/wiki/U-Boot
# - https://gitlab.denx.de/u-boot/u-boot
# - https://gitlab.denx.de/u-boot/u-boot/-/tree/master/doc
#

ifdef ET_BOARD_BOOTLOADER_TREE

ifndef ET_BOARD_BOOTLOADER_TYPE
export ET_BOARD_BOOTLOADER_TYPE := $(ET_BOARD)$(ET_BOOTLOADER_VARIANT)
endif

# embedded bootloader, for application processors, is Das U-Boot
export ET_BOOTLOADER_TYPE := $(ET_BOARD_BOOTLOADER_TYPE)
export ET_BOOTLOADER_TREE := $(ET_BOARD_BOOTLOADER_TREE)
export ET_BOOTLOADER_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_BOOTLOADER_TREE)
export ET_BOOTLOADER_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) bootloader$(ET_BOOTLOADER_VARIANT)-ref)

bootloader_defconfig := et_$(subst -,_,$(ET_BOOTLOADER_TYPE))_defconfig

# [start] bootloader version magic
ifneq ($(shell ls $(ET_BOOTLOADER_SOFTWARE_DIR) $(ET_NOERR)),)
bversion := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) $(ET_NOERR) && make -s ubootversion | tr -d \\n)
bgithash := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) $(ET_NOERR) && git rev-parse --short HEAD)
bgitdirty := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) $(ET_NOERR) && git describe --dirty|grep -oe '-dirty')
blocalversion := -g$(bgithash)$(bgitdirty)
ifdef USE_BOOTLOADER_TREE_VERSION
ET_BOOTLOADER_VERSION := $(bversion)
ET_BOOTLOADER_LOCALVERSION := $(USE_BOOTLOADER_TREE_VERSION)$(blocalversion)
else
ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) $(ET_NOERR) && git describe --dirty $(ET_NOERR) | tr -d v)
ET_BOOTLOADER_LOCALVERSION := -$(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) $(ET_NOERR) && git describe --dirty $(ET_NOERR) | cut -d '-' -f 2-5)
# RC version (i.e. v2018.09-rc1)
ifeq ($(shell echo $(ET_BOOTLOADER_LOCALVERSION) | sed s,[0-9].*,,),-rc)
rcversion := $(shell printf "%s" $(ET_BOOTLOADER_LOCALVERSION) | cut -d '-' -f 2)
rclocalversion := -$(shell printf "%s" $(ET_BOOTLOADER_LOCALVERSION) | cut -d '-' -f 3-5)
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-$(rcversion)$(rclocalversion))
ET_BOOTLOADER_LOCALVERSION := $(rclocalversion)
endif
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-$(rcversion))
ET_BOOTLOADER_LOCALVERSION :=
endif
endif
# empty local version
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-)
ET_BOOTLOADER_LOCALVERSION :=
endif
# exact tag in series (i.e. v2018.09)
ifeq ($(ET_BOOTLOADER_LOCALVERSION),-v$(ET_BOOTLOADER_VERSION))
ET_BOOTLOADER_LOCALVERSION :=
endif
ifneq ($(ET_BOOTLOADER_LOCALVERSION),)
# split out localversion
ifeq ($(ET_BOOTLOADER_LOCALVERSION),$(shell echo $(ET_BOOTLOADER_VERSION) | grep -oe '$(ET_BOOTLOADER_LOCALVERSION)'))
ET_BOOTLOADER_VERSION := $(shell echo $(ET_BOOTLOADER_VERSION) | sed s,$(ET_BOOTLOADER_LOCALVERSION),,)
endif
endif
endif
endif
# [end] bootloader version magic

export ET_BOOTLOADER_VERSION
export ET_BOOTLOADER_LOCALVERSION

export ET_BOOTLOADER_BUILD_DIR := $(ET_DIR)/bootloader/build/$(ET_BOOTLOADER_TYPE)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_BUILD_CONFIG := $(ET_BOOTLOADER_BUILD_DIR)/.config
export ET_BOOTLOADER_BUILD_DEFCONFIG := $(ET_BOOTLOADER_BUILD_DIR)/defconfig
export ET_BOOTLOADER_BUILD_SYSMAP := $(ET_BOOTLOADER_BUILD_DIR)/System.map
export ET_BOOTLOADER_DIR := $(ET_DIR)/bootloader/$(ET_BOOTLOADER_TYPE)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_DEFCONFIG := $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/u-boot-$(ET_BOOTLOADER_TYPE)/$(bootloader_defconfig)
export ET_BOOTLOADER_DT := $(ET_BOARD_BOOTLOADER_DT)

export DEVICE_TREE := $(ET_BOOTLOADER_DT)
# Handle out-of-tree devicetree build (i.e. dtb-y += custom-board.dtb)
ifneq ($(shell ls $(ET_BOARD_DIR)/dts/u-boot/Makefile $(ET_NOERR)),)
export DEVICE_TREE_MAKEFILE := -f $(ET_BOARD_DIR)/dts/u-boot/Makefile
endif

# Get board specific definitions
include $(ET_DIR)/boards/$(ET_BOARD)/bootloader.mk

export ET_BOOTLOADER_BUILD_IMAGE ?= $(ET_BOOTLOADER_BUILD_DIR)/$(ET_BOARD_BOOTLOADER_IMAGE)
export ET_BOOTLOADER_IMAGE ?= $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_IMAGE)
export ET_BOOTLOADER_TARGET_FINAL ?= $(ET_BOOTLOADER_IMAGE)

define bootloader-version
	@printf "ET_BOOTLOADER_VERSION: \033[0;33m[$(ET_BOOTLOADER_CACHED_VERSION)]\033[0m $(ET_BOOTLOADER_VERSION)\n"
	@printf "ET_BOOTLOADER_LOCALVERSION: $(ET_BOOTLOADER_LOCALVERSION)\n"
endef

define bootloader-software
	$(call software-check,$(ET_BOOTLOADER_TREE),bootloader$(ET_BOOTLOADER_VARIANT),fetch)
endef

define bootloader-depends
	$(call software-check,$(ET_BOOTLOADER_TREE),bootloader$(ET_BOOTLOADER_VARIANT))
	@mkdir -p $(ET_BOOTLOADER_DIR)/boot
	@mkdir -p $(ET_BOOTLOADER_BUILD_DIR)
	@mkdir -p $(shell dirname $(ET_BOOTLOADER_DEFCONFIG))
	@if [ -d $(ET_BOARD_DIR)/dts ] && [ -n "`ls $(ET_BOARD_DIR)/dts/*.dts* $(ET_NOERR)`" ]; then \
		cp -v $(ET_BOARD_DIR)/dts/*.dts* \
			$(ET_BOOTLOADER_SOFTWARE_DIR)/arch/$(ET_BOOTLOADER_ARCH)/dts/; \
	fi
	@if [ -d $(ET_BOARD_DIR)/dts/u-boot ] && [ -n "`ls $(ET_BOARD_DIR)/dts/u-boot/*.dts* $(ET_NOERR)`" ]; then \
		cp -v $(ET_BOARD_DIR)/dts/u-boot/*.dts* \
			$(ET_BOOTLOADER_SOFTWARE_DIR)/arch/$(ET_BOOTLOADER_ARCH)/dts/; \
		if [ -d $(ET_BOOTLOADER_SOFTWARE_DIR)/dts/upstream/src/$(ET_BOOTLOADER_ARCH)/$(ET_BOARD_DT_PREFIX) ]; then \
			cp -v $(ET_BOARD_DIR)/dts/u-boot/*.dts* \
				$(ET_BOOTLOADER_SOFTWARE_DIR)/dts/upstream/src/$(ET_ARCH)/$(ET_BOARD_DT_PREFIX); \
		fi; \
	fi
	@if [ -f $(ET_BOOTLOADER_DEFCONFIG) ]; then \
		rsync $(ET_BOOTLOADER_DEFCONFIG) $(ET_BOOTLOADER_SOFTWARE_DIR)/configs/ $(ET_NULL); \
	fi
	$(call bootloader-depends-$(ET_BOARD))
endef

define bootloader-prepare
	$(call bootloader-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) $(ET_BOOTLOADER_VERSION) *****\n\n"
	$(call bootloader-prepare-$(ET_BOARD))
endef

define bootloader-finalize
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
	@$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*
	@if ! [ -f $(ET_BOOTLOADER_BUILD_IMAGE) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_BUILD_IMAGE) build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@if [ -f $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/u-boot-$(ET_BOOTLOADER_TYPE)/uEnv.txt ]; then \
		cp -av $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/u-boot-$(ET_BOOTLOADER_TYPE)/uEnv*.txt $(ET_BOOTLOADER_DIR)/boot/; \
	fi
	@if [ -d $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/u-boot-$(ET_BOOTLOADER_TYPE)/extlinux ]; then \
		cp -av $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/u-boot-$(ET_BOOTLOADER_TYPE)/extlinux $(ET_BOOTLOADER_DIR)/boot/; \
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
	$(call bootloader-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-build 'make $1' *****\n\n"
	@case "$1" in \
	*config) \
		;; \
	*) \
		if ! [ -f $(ET_BOOTLOADER_BUILD_CONFIG) ]; then \
			$(MAKE) --no-print-directory \
				$(ET_CFLAGS_BOOTLOADER) \
				CROSS_COMPILE=$(ET_CROSS_COMPILE) \
				O=$(ET_BOOTLOADER_BUILD_DIR) \
				-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
				$(bootloader_defconfig) $(ET_BOOTLOADER_DEFCONFIG_N); \
			if ! [ -f $(ET_BOOTLOADERL_BUILD_CONFIG) ]; then \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		;; \
	esac
	(cd $(ET_BOOTLOADER_SOFTWARE_DIR) && \
		$(MAKE) --no-print-directory -j $(ET_CPUS) \
			$(ET_CFLAGS_BOOTLOADER) \
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
				$(ET_CFLAGS_BOOTLOADER) \
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
	$(call bootloader-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-config *****\n\n"
	$(MAKE) --no-print-directory \
		$(ET_CFLAGS_BOOTLOADER) \
		CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		O=$(ET_BOOTLOADER_BUILD_DIR) \
		-C $(ET_BOOTLOADER_SOFTWARE_DIR) \
		$(bootloader_defconfig)
endef

define bootloader-clean
	@for p in $(ET_BIOS_LIST); do \
		$(ET_MAKE) -C $(ET_DIR) $$p-clean; \
	done
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-clean *****\n\n"
	$(RM) $(ET_BOOTLOADER_BUILD_CONFIG)
	$(RM) $(ET_BOOTLOADER_BUILD_DEFCONFIG)
	$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*
	$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
	$(RM) $(ET_BOOTLOADER_DIR)/boot/uEnv*
	$(RM) -r $(ET_BOOTLOADER_DIR)/boot/extlinux
endef

define bootloader-purge
	@for p in $(ET_BIOS_LIST); do \
		$(ET_MAKE) -C $(ET_DIR) $$p-purge; \
	done
	$(call bootloader-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-purge *****\n\n"
	$(RM) -r $(ET_BOOTLOADER_BUILD_DIR)
endef

define bootloader-info
	@for p in $(ET_BIOS_LIST); do \
		$(ET_MAKE) -C $(ET_DIR) $$p-info; \
	done
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
	@printf "ET_BOOTLOADER_DT: $(ET_BOOTLOADER_DT)\n"
	@printf "ET_BOOTLOADER_IMAGE: $(ET_BOOTLOADER_IMAGE)\n"
	@printf "ET_BOOTLOADER_TARGET_FINAL: $(ET_BOOTLOADER_TARGET_FINAL)\n"
	$(call bootloader-info-$(ET_BOARD))
endef

define bootloader-sync
	@$(ET_DIR)/scripts/sync bootloader $1
endef

define bootloader-update
	@$(ET_MAKE) -C $(ET_DIR) bootloader-clean
	@$(ET_MAKE) -C $(ET_DIR) bootloader
endef

define bootloader-all
	@$(ET_MAKE) -C $(ET_DIR) bootloader
endef

.PHONY: bootloader
bootloader: $(ET_BIOS_LIST) $(ET_BOOTLOADER_TARGET_FINAL)
$(ET_BOOTLOADER_TARGET_FINAL): $(ET_BOOTLOADER_BUILD_CONFIG)
	$(call bootloader-prepare)
	$(call bootloader-build)
	$(call bootloader-finalize)

bootloader-%: $(ET_BIOS_LIST) $(ET_BOOTLOADER_BUILD_CONFIG)
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

.PHONY: bootloader-software
bootloader-software:
	$(call $@)

.PHONY: bootloader-info
bootloader-info:
	$(call $@)

bootloader-sync-%:
	$(call bootloader-sync,$(*F))

.PHONY: bootloader-update
bootloader-update:
	$(call $@)

.PHONY: bootloader-all
bootloader-all:
	$(call $@)

endif
# ET_BOARD_BOOTLOADER_TREE
