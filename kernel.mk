#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2021 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://www.kernel.org
# - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
# - https://www.kernel.org/doc/html/latest/kbuild/index.html
#

ifndef ET_BOARD_KERNEL_TREE
$(error [ 'etinker' kernel build requires ET_BOARD_KERNEL_TREE ] ***)
endif

ifndef ET_BOARD_KERNEL_TYPE
export ET_BOARD_KERNEL_TYPE := $(ET_BOARD_TYPE)
endif

# embedded kernel, for application processors, is GNU Linux
export ET_KERNEL_TYPE := $(ET_BOARD_KERNEL_TYPE)
export ET_KERNEL_ARCH := $(ET_BOARD_KERNEL_ARCH)
export ET_KERNEL_VENDOR := $(ET_BOARD_KERNEL_VENDOR)
export ET_KERNEL_TREE := $(ET_BOARD_KERNEL_TREE)
export ET_KERNEL_DT := $(ET_BOARD_KERNEL_DT)
ifdef ET_BOARD_KERNEL_DT_ETINKER
export ET_KERNEL_DT_ETINKER := $(ET_BOARD_KERNEL_DT_ETINKER)
endif
export ET_KERNEL_LOADADDR := $(ET_BOARD_KERNEL_LOADADDR)
export ET_KERNEL_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_KERNEL_TREE)
export ET_KERNEL_HEADERS_DIR ?= $(ET_SYSROOT_DIR)/usr/include
export ET_KERNEL_CACHED_VERSION := $(shell grep -Po 'kernel-ref:\K[^\n]*' $(ET_BOARD_DIR)/software.conf)
export ET_KERNEL_CROSS_PARAMS := ARCH=$(ET_KERNEL_ARCH) CROSS_COMPILE=$(ET_CROSS_COMPILE)

kernel_defconfig := et_$(subst -,_,$(ET_KERNEL_TYPE))_defconfig

# [start] kernel version magic
ET_KERNEL_VERSION := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | tr -d v | cut -d '-' -f 1)
ET_KERNEL_LOCALVERSION := -$(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | cut -d '-' -f 2-5)
ifeq ($(ET_KERNEL_LOCALVERSION),-)
# empty local version
ET_KERNEL_LOCALVERSION :=
endif
ifeq ($(ET_KERNEL_VERSION),next)
# linux-next
nextversion := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && make kernelversion | tr -d \\n)
nextlocalversion := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null)
ET_KERNEL_VERSION := $(nextversion)-$(nextlocalversion)
ET_KERNEL_LOCALVERSION :=
endif
# linux-rt
ifeq ($(shell echo $(ET_KERNEL_LOCALVERSION) | sed s,[0-9].*,,),-rt)
ET_KERNEL_VERSION := $(ET_KERNEL_VERSION)$(shell cat $(ET_KERNEL_SOFTWARE_DIR)/localversion-rt | tr -d \\n)
ET_KERNEL_LOCALVERSION :=
endif
ifeq ($(shell echo $(ET_KERNEL_LOCALVERSION) | sed s,[0-9].*,,),-rc)
# RC version (i.e. v4.14-rc1)
rcversion := $(shell printf "%s" $(ET_KERNEL_LOCALVERSION) | cut -d '-' -f 2)
ET_KERNEL_VERSION := $(ET_KERNEL_VERSION).0-$(rcversion)
rclocalversion := -$(shell printf "%s" $(ET_KERNEL_LOCALVERSION) | cut -d '-' -f 3-5)
ifeq ($(ET_KERNEL_LOCALVERSION),-$(rcversion)$(rclocalversion))
ET_KERNEL_LOCALVERSION := $(rclocalversion)
endif
ifeq ($(ET_KERNEL_LOCALVERSION),-$(rcversion))
ET_KERNEL_LOCALVERSION :=
endif
endif
ifeq ($(ET_KERNEL_LOCALVERSION),-v$(ET_KERNEL_VERSION))
# exact tag in series (i.e. v4.14.1)
ET_KERNEL_LOCALVERSION :=
endif
ifeq ($(shell printf "%s" $(ET_KERNEL_VERSION)|cut -d '.' -f 3),)
# first in release series (i.e. v4.14)
ET_KERNEL_VERSION := $(ET_KERNEL_VERSION).0
endif
export ET_KERNEL_VERSION
export ET_KERNEL_LOCALVERSION
# [end] kernel version magic

export ET_KERNEL_BUILD_DIR := $(ET_DIR)/kernel/build/$(ET_KERNEL_TYPE)/$(ET_CROSS_TUPLE)
export ET_KERNEL_BUILD_BOOT_DIR := $(ET_KERNEL_BUILD_DIR)/arch/$(ET_KERNEL_ARCH)/boot
export ET_KERNEL_BUILD_CONFIG := $(ET_KERNEL_BUILD_DIR)/.config
export ET_KERNEL_BUILD_DEFCONFIG := $(ET_KERNEL_BUILD_DIR)/defconfig
export ET_KERNEL_BUILD_SYSMAP := $(ET_KERNEL_BUILD_DIR)/System.map
export ET_KERNEL_BUILD_DTB := $(ET_KERNEL_BUILD_BOOT_DIR)/dts/$(ET_KERNEL_VENDOR)$(ET_KERNEL_DT).dtb
export ET_KERNEL_DIR := $(ET_DIR)/kernel/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_KERNEL_DEFCONFIG := $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/$(ET_KERNEL_TREE)/$(kernel_defconfig)
export ET_KERNEL_SYSMAP := $(ET_KERNEL_DIR)/boot/System.map
export ET_KERNEL_DTB := $(ET_KERNEL_DIR)/boot/$(ET_KERNEL_DT).dtb

# get board specific definitions
include $(ET_DIR)/boards/$(ET_BOARD)/kernel.mk

export ET_KERNEL_MODULES := $(ET_KERNEL_DIR)/lib/modules/$(ET_KERNEL_VERSION)$(ET_KERNEL_LOCALVERSION)/modules.dep
export ET_KERNEL_TARGET_FINAL ?= $(ET_KERNEL_MODULES)

export CT_LINUX_CUSTOM_LOCATION := ${ET_KERNEL_SOFTWARE_DIR}

define kernel-version
	@printf "ET_KERNEL_VERSION: \033[0;33m[$(ET_KERNEL_CACHED_VERSION)]\033[0m $(ET_KERNEL_VERSION)\n"
	@printf "ET_KERNEL_LOCALVERSION: $(ET_KERNEL_LOCALVERSION)\n"
endef

define kernel-depends
	@mkdir -p $(ET_KERNEL_DIR)/boot
	@mkdir -p $(ET_KERNEL_DIR)/lib/modules
	@mkdir -p $(ET_KERNEL_BUILD_BOOT_DIR)
	@mkdir -p $(shell dirname $(ET_KERNEL_DEFCONFIG))
	@if [ -d $(ET_BOARD_DIR)/dts ] && [ -n "`ls $(ET_BOARD_DIR)/dts/*.dts* 2> /dev/null`" ]; then \
		rsync -r $(ET_BOARD_DIR)/dts/*.dts* \
			$(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/boot/dts/$(ET_KERNEL_VENDOR) > /dev/null; \
	fi
	@if [ -d $(ET_BOARD_DIR)/dts/linux ] && [ -n "`ls $(ET_BOARD_DIR)/dts/linux/*.dts* 2> /dev/null`" ]; then \
		rsync -r $(ET_BOARD_DIR)/dts/linux/*.dts* \
			$(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/boot/dts/$(ET_KERNEL_VENDOR) > /dev/null; \
	fi
	@if [ -f $(ET_KERNEL_DEFCONFIG) ]; then \
		rsync $(ET_KERNEL_DEFCONFIG) $(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/configs/ > /dev/null; \
	fi
	$(call kernel-depends-$(ET_BOARD))
endef

define kernel-prepare
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION)$(ET_KERNEL_LOCALVERSION) *****\n\n"
	$(call kernel-depends)
	$(call kernel-prepare-$(ET_BOARD))
endef

define kernel-finalize
	$(call kernel-finalize-$(ET_BOARD))
	@if [ -d $(ET_TFTP_DIR) ]; then \
		if ! [ -d $(ET_TFTP_DIR)/$(ET_BOARD) ]; then \
			sudo mkdir -p $(ET_TFTP_DIR)/$(ET_BOARD); \
			sudo chown $(USER).$(USER) $(ET_TFTP_DIR)/$(ET_BOARD); \
		fi; \
		rsync -r $(ET_KERNEL_DIR)/boot/* $(ET_TFTP_DIR)/$(ET_BOARD)/; \
	fi
endef

define kernel-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call kernel-build 'make $1' *****\n\n"
	$(call kernel-depends)
	@case "$1" in \
	*config) \
		;; \
	*) \
		if ! [ -f $(ET_KERNEL_BUILD_CONFIG) ]; then \
			$(MAKE) --no-print-directory \
				$(ET_KERNEL_CROSS_PARAMS) \
				O=$(ET_KERNEL_BUILD_DIR) \
				-C $(ET_KERNEL_SOFTWARE_DIR) \
				$(kernel_defconfig); \
			if ! [ -f $(ET_KERNEL_BUILD_CONFIG) ]; then \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		;; \
	esac
	$(MAKE) --no-print-directory -j $(ET_CPUS) $(ET_KERNEL_CROSS_PARAMS) \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION) \
		LOADADDR=$(ET_KERNEL_LOADADDR) \
		INSTALL_MOD_PATH=$(ET_KERNEL_DIR) \
		INSTALL_HDR_PATH=$(ET_KERNEL_HEADERS_DIR) \
		O=$(ET_KERNEL_BUILD_DIR) \
		-C $(ET_KERNEL_SOFTWARE_DIR) \
		$1
	@echo
	@case "$1" in \
	Image) \
		if [ -f $(ET_KERNEL_BUILD_IMAGE) ]; then \
			$(RM) $(ET_KERNEL_IMAGE) \
				$(ET_KERNEL_DIR)/boot/System.map; \
		        cp -av $(ET_KERNEL_BUILD_IMAGE) \
				$(ET_KERNEL_BUILD_SYSMAP) \
				$(ET_KERNEL_DIR)/boot/; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) Image FAILED! *****\n"; \
			exit 2; \
		fi; \
		;; \
	zImage) \
		if [ -f $(ET_KERNEL_BUILD_ZIMAGE) ]; then \
			$(RM) $(ET_KERNEL_ZIMAGE) \
				$(ET_KERNEL_DIR)/boot/System.map; \
		        cp -av $(ET_KERNEL_BUILD_ZIMAGE) \
				$(ET_KERNEL_BUILD_SYSMAP) \
				$(ET_KERNEL_DIR)/boot/; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) zImage FAILED! *****\n"; \
			exit 2; \
		fi; \
		;; \
	uImage) \
		if [ -f $(ET_KERNEL_BUILD_UIMAGE) ]; then \
			$(RM) $(ET_KERNEL_UIMAGE); \
		        cp -av $(ET_KERNEL_BUILD_UIMAGE) \
				$(ET_KERNEL_DIR)/boot/; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) uImage FAILED! *****\n"; \
			exit 2; \
		fi; \
		;; \
	*.dtb) \
		if [ -f $(ET_KERNEL_BUILD_BOOT_DIR)/dts/$1 ]; then \
			$(RM) $(ET_KERNEL_DIR)/boot/$1; \
			cp -av $(ET_KERNEL_BUILD_BOOT_DIR)/dts/$1 $(ET_KERNEL_DIR)/boot/; \
			case "$(ET_BOARD_TYPE)" in \
			zynq*) \
				cp -av $(ET_KERNEL_BUILD_BOOT_DIR)/dts/$1 $(ET_KERNEL_DIR)/boot/system.dtb; \
				;; \
			*) \
				;; \
			esac; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_DT).dtb FAILED! *****\n"; \
			exit 2; \
		fi; \
		;; \
	modules_install) \
		if [ -d $(ET_KERNEL_DIR)/lib/modules ]; then \
			find $(ET_KERNEL_DIR)/lib/modules -type l -exec rm -f {} \; ; \
		fi; \
		;; \
	*clean) \
		$(RM) $(ET_KERNEL_DIR)/boot/*; \
		$(RM) -r $(ET_KERNEL_DIR)/lib/modules/*; \
		;; \
	*config) \
		if ! [ -f $(ET_KERNEL_BUILD_CONFIG) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
		if ! [ "$1" = "savedefconfig" ]; then \
			$(MAKE) --no-print-directory \
				$(ET_KERNEL_CROSS_PARAMS) \
				O=$(ET_KERNEL_BUILD_DIR) \
				-C $(ET_KERNEL_SOFTWARE_DIR) \
				savedefconfig; \
		fi; \
		if [ -f $(ET_KERNEL_BUILD_DEFCONFIG) ]; then \
			rsync $(ET_KERNEL_BUILD_DEFCONFIG) $(ET_KERNEL_DEFCONFIG); \
			$(RM) $(ET_KERNEL_BUILD_DEFCONFIG); \
		fi; \
		;; \
	*) \
		;; \
	esac
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] kernel-build 'make $1' done. *****\n\n"
endef

define kernel-config
	$(call software-check,$(ET_KERNEL_TREE),kernel)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call kernel-config *****\n\n"
	$(call kernel-depends)
	$(MAKE) --no-print-directory \
		$(ET_KERNEL_CROSS_PARAMS) \
		O=$(ET_KERNEL_BUILD_DIR) \
		-C $(ET_KERNEL_SOFTWARE_DIR) \
		$(kernel_defconfig)
endef

define kernel-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call kernel-clean *****\n\n"
	$(RM) $(ET_KERNEL_BUILD_CONFIG)
	$(RM) $(ET_KERNEL_BUILD_DEFCONFIG)
	$(RM) $(ET_KERNEL_DIR)/boot/*
	$(RM) -r $(ET_KERNEL_DIR)/lib/modules/*
endef

define kernel-purge
	$(call kernel-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call kernel-purge *****\n\n"
	$(RM) -r $(ET_KERNEL_BUILD_DIR)
endef

define kernel-info
	@printf "========================================================================\n"
	@printf "ET_KERNEL_TREE: $(ET_KERNEL_TREE)\n"
	@printf "ET_KERNEL_VERSION: $(ET_KERNEL_VERSION)\n"
	@printf "ET_KERNEL_LOCALVERSION: $(ET_KERNEL_LOCALVERSION)\n"
	@printf "ET_KERNEL_ARCH: $(ET_KERNEL_ARCH)\n"
	@printf "ET_KERNEL_DT: $(ET_KERNEL_DT)\n"
	@printf "ET_KERNEL_DT_ETINKER: $(ET_KERNEL_DT_ETINKER)\n"
	@printf "ET_KERNEL_SOFTWARE_DIR: $(ET_KERNEL_SOFTWARE_DIR)\n"
	@printf "ET_KERNEL_BUILD_DIR: $(ET_KERNEL_BUILD_DIR)\n"
	@printf "ET_KERNEL_BUILD_CONFIG: $(ET_KERNEL_BUILD_CONFIG)\n"
	@printf "ET_KERNEL_BUILD_DEFCONFIG: $(ET_KERNEL_BUILD_DEFCONFIG)\n"
	@printf "ET_KERNEL_BUILD_DTB: $(ET_KERNEL_BUILD_DTB)\n"
	@printf "ET_KERNEL_BUILD_SYSMAP: $(ET_KERNEL_BUILD_SYSMAP)\n"
	@printf "ET_KERNEL_DEFCONFIG: $(ET_KERNEL_DEFCONFIG)\n"
	@printf "ET_KERNEL_DIR: $(ET_KERNEL_DIR)\n"
	@printf "ET_KERNEL_DTB: $(ET_KERNEL_DTB)\n"
	@printf "ET_KERNEL_SYSMAP: $(ET_KERNEL_SYSMAP)\n"
	@printf "ET_KERNEL_MODULES: $(ET_KERNEL_MODULES)\n"
	@printf "ET_KERNEL_TARGET_FINAL: $(ET_KERNEL_TARGET_FINAL)\n"
	$(call kernel-info-$(ET_BOARD))
endef

define kernel-sync
	@$(ET_DIR)/scripts/sync kernel $1
endef

.PHONY: kernel
kernel: $(ET_KERNEL_TARGET_FINAL)
$(ET_KERNEL_TARGET_FINAL): $(ET_KERNEL_BUILD_CONFIG)
	$(call kernel-prepare)
	$(call kernel-build-$(ET_BOARD))
	$(call kernel-build,$(ET_KERNEL_VENDOR)$(ET_KERNEL_DT).dtb)
ifdef ET_KERNEL_DT_ETINKER
	$(call kernel-build,$(ET_KERNEL_VENDOR)$(ET_KERNEL_DT_ETINKER).dtb)
endif
	$(call kernel-build,modules)
	$(call kernel-build,modules_install)
	$(call kernel-finalize)

kernel-%: $(ET_KERNEL_BUILD_CONFIG)
	$(call kernel-build,$(*F))

.PHONY: kernel-config
kernel-config: $(ET_KERNEL_BUILD_CONFIG)
$(ET_KERNEL_BUILD_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
	$(call kernel-config)

.PHONY: kernel-clean
kernel-clean:
ifeq ($(ET_CLEAN),yes)
	$(call kernel-build,clean)
endif
	$(call $@)

.PHONY: kernel-purge
kernel-purge:
	$(call $@)

.PHONY: kernel-version
kernel-version:
	$(call $@)

.PHONY: kernel-info
kernel-info:
	$(call $@)

kernel-sync-%:
	$(call kernel-sync,$(*F))

.PHONY: kernel-update
kernel-update: kernel-clean kernel
