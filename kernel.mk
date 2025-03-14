#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://www.kernel.org
# - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
# - https://www.kernel.org/doc/html/latest/kbuild/index.html
#

ifdef ET_BOARD_KERNEL_TREE

ifndef ET_BOARD_KERNEL_TYPE
export ET_BOARD_KERNEL_TYPE := $(ET_BOARD_TYPE)$(ET_KERNEL_VARIANT)
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
export ET_KERNEL_HEADERS_DIR ?= $(ET_TOOLCHAIN_SYSROOT_DIR)/usr/include
export ET_KERNEL_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) kernel$(ET_KERNEL_VARIANT)-ref)
export ET_KERNEL_CROSS_PARAMS := ARCH=$(ET_KERNEL_ARCH) CROSS_COMPILE=$(ET_CROSS_COMPILE)

kernel_defconfig := et_$(subst -,_,$(ET_KERNEL_TYPE))_defconfig
# kludge to capture trailing '/' for RISCV
kernel_vendor := $(ET_BOARD_KERNEL_VENDOR)

# [start] kernel version magic (only because I encounter incomplete Git trees)
kversion := $(shell $(ET_MAKE) kernelversion -C $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) | tr -d \\n)
# check kernel tree for typical Git info
gittag := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) && git describe $(ET_NOERR))
ifeq (gittag,$(shell test -n "$(gittag)" && printf gittag || printf empty))
githash := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) && git rev-parse --short HEAD)
gitdirty := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) && git describe --dirty $(ET_NOERR) | grep -oe '-dirty')
gitversion := -g$(githash)$(gitdirty)
ET_KERNEL_VERSION := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) && git describe --dirty $(ET_NOERR) | tr -d v | cut -d '-' -f 1)
ifneq ($(gittag),v$(ET_KERNEL_VERSION))
ET_KERNEL_LOCALVERSION := -$(shell cd $(ET_KERNEL_SOFTWARE_DIR) $(ET_NOERR) && git describe --dirty $(ET_NOERR) | tr -d v | cut -d '-' -f 2-5)
endif
ifeq (unknown,$(shell test -z "$(ET_KERNEL_VERSION)" && printf unknown || printf normal))
ET_KERNEL_VERSION := $(kversion)
endif
localversion := $(ET_KERNEL_LOCALVERSION)
else # no git describe info found
ET_KERNEL_VERSION := $(kversion)
endif
# first in release series (i.e. v6.9)
ifeq ($(shell printf $(ET_KERNEL_VERSION) | cut -d '.' -f 3),)
ET_KERNEL_VERSION := $(ET_KERNEL_VERSION).0
endif
# linux-rt
ifeq (linux-rt,$(shell [ -f $(ET_KERNEL_SOFTWARE_DIR)/localversion-rt ] && echo linux-rt || echo no))
localversion-rt := $(shell cat $(ET_KERNEL_SOFTWARE_DIR)/localversion-rt)
localversion := $(shell echo $(ET_KERNEL_LOCALVERSION) | sed s/$(localversion-rt)//)
ET_KERNEL_VERSION := $(kversion)
# RC version
ifeq (rc,$(shell echo -n $(kversion) | grep -qe "-rc" && echo rc || echo no))
rcversion := -$(shell echo $(ET_KERNEL_VERSION) | cut -d '-' -f 2)
ET_KERNEL_LOCALVERSION := $(shell echo $(localversion) | sed s/$(rcversion)//)
endif
localversion := $(ET_KERNEL_LOCALVERSION)
endif
# linux-next
ifeq (linux-next,$(shell [ -f $(ET_KERNEL_SOFTWARE_DIR)/localversion-next ] && echo linux-next || echo no))
ET_KERNEL_VERSION := $(kversion)
ET_KERNEL_LOCALVERSION := $(shell cat $(ET_KERNEL_SOFTWARE_DIR)/localversion-next)
localversion :=
endif
# final override
ifdef USE_KERNEL_TREE_VERSION
ET_KERNEL_VERSION := $(kversion)
ET_KERNEL_LOCALVERSION := $(USE_KERNEL_TREE_VERSION)
localversion := $(ET_KERNEL_LOCALVERSION)
endif
# [end] kernel version magic

export ET_KERNEL_VERSION
export ET_KERNEL_LOCALVERSION

export ET_KERNEL_BUILD_DIR := $(ET_DIR)/kernel/build/$(ET_KERNEL_TYPE)/$(ET_CROSS_TUPLE)
export ET_KERNEL_BUILD_BOOT_DIR := $(ET_KERNEL_BUILD_DIR)/arch/$(ET_KERNEL_ARCH)/boot
export ET_KERNEL_BUILD_CONFIG := $(ET_KERNEL_BUILD_DIR)/.config
export ET_KERNEL_BUILD_DEFCONFIG := $(ET_KERNEL_BUILD_DIR)/defconfig
export ET_KERNEL_BUILD_SYSMAP := $(ET_KERNEL_BUILD_DIR)/System.map
export ET_KERNEL_BUILD_DTB := $(ET_KERNEL_BUILD_BOOT_DIR)/dts/$(ET_KERNEL_VENDOR)$(ET_KERNEL_DT).dtb
export ET_KERNEL_DIR := $(ET_DIR)/kernel/$(ET_BOARD)$(ET_KERNEL_VARIANT)/$(ET_CROSS_TUPLE)
export ET_KERNEL_DEFCONFIG := $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/linux/$(kernel_defconfig)
export ET_KERNEL_SYSMAP := $(ET_KERNEL_DIR)/boot/System.map
export ET_KERNEL_DTB := $(ET_KERNEL_DIR)/boot/$(ET_KERNEL_DT).dtb

# get board specific definitions
include $(ET_DIR)/boards/$(ET_BOARD)/kernel.mk

export ET_KERNEL_MODULES := $(ET_KERNEL_DIR)/usr/lib/modules/$(ET_KERNEL_VERSION)*/modules.dep
export ET_KERNEL_TARGET_FINAL ?= $(ET_KERNEL_MODULES)

export CT_LINUX_CUSTOM_LOCATION := ${ET_KERNEL_SOFTWARE_DIR}

define kernel-version
	@printf "ET_KERNEL_VERSION: \033[0;33m[$(ET_KERNEL_CACHED_VERSION)]\033[0m $(ET_KERNEL_VERSION)\n"
	@printf "ET_KERNEL_LOCALVERSION: $(ET_KERNEL_LOCALVERSION)\n"
endef

define kernel-software
	$(call software-check,$(ET_KERNEL_TREE),kernel$(ET_KERNEL_VARIANT),fetch)
endef

define kernel-depends
	$(call software-check,$(ET_KERNEL_TREE),kernel$(ET_KERNEL_VARIANT))
	@mkdir -p $(ET_KERNEL_DIR)/boot
	@mkdir -p $(ET_KERNEL_DIR)/usr/lib/modules
	@mkdir -p $(ET_KERNEL_BUILD_BOOT_DIR)
	@mkdir -p $(shell dirname $(ET_KERNEL_DEFCONFIG))
	@if [ -d $(ET_BOARD_DIR)/dts ] && [ -n "`ls $(ET_BOARD_DIR)/dts/*.dts* $(ET_NOERR)`" ]; then \
		cp -v $(ET_BOARD_DIR)/dts/*.dts* \
			$(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/boot/dts/$(ET_KERNEL_VENDOR) $(ET_NULL); \
	fi
	@if [ -d $(ET_BOARD_DIR)/dts/linux ] && [ -n "`ls $(ET_BOARD_DIR)/dts/linux/*.dts* $(ET_NOERR)`" ]; then \
		cp -v $(ET_BOARD_DIR)/dts/linux/*.dts* \
			$(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/boot/dts/$(ET_KERNEL_VENDOR) $(ET_NULL); \
	fi
	@if [ -n "`ls $(ET_BOARD_DIR)/dts/linux/$(ET_KERNEL_VENDOR)*.dts* $(ET_NOERR)`" ]; then \
		cp -v $(ET_BOARD_DIR)/dts/linux/$(ET_KERNEL_VENDOR)*.dts* \
			$(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/boot/dts/$(ET_KERNEL_VENDOR) $(ET_NULL); \
	fi
	@if [ -f $(ET_KERNEL_DEFCONFIG) ]; then \
		cp -v $(ET_KERNEL_DEFCONFIG) $(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/configs/ $(ET_NULL); \
	fi
	@if [ -n "$(ET_KERNEL_DEFCONFIG_N)" ]; then \
		cp -v $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config/linux/$(ET_KERNEL_DEFCONFIG_N) \
			$(ET_KERNEL_SOFTWARE_DIR)/arch/$(ET_KERNEL_ARCH)/configs/; \
	fi
	$(call kernel-depends-$(ET_BOARD))
endef

define kernel-prepare
	$(call kernel-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION)$(ET_KERNEL_LOCALVERSION) *****\n\n"
	$(call kernel-prepare-$(ET_BOARD))
endef

define kernel-finalize
	$(call kernel-finalize-$(ET_BOARD))
	@if [ "$(ET_TFTP)" = "yes" ] && [ -d $(ET_TFTP_DIR) ]; then \
		if ! [ -d $(ET_TFTP_DIR)/$(ET_BOARD) ]; then \
			sudo mkdir -p $(ET_TFTP_DIR)/$(ET_BOARD); \
			sudo chown $(USER).$(USER) $(ET_TFTP_DIR)/$(ET_BOARD); \
		fi; \
		rsync -r $(ET_KERNEL_DIR)/boot/* $(ET_TFTP_DIR)/$(ET_BOARD)/; \
	fi
	$(call cryptodev-linux-config)
	$(call cryptodev-linux-clean)
	$(call cryptodev-linux-targets)
endef

define kernel-build
	$(call kernel-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call kernel-build 'make $1' *****\n\n"
	@case "$1" in \
	*config) \
		;; \
	*) \
		if ! [ -f $(ET_KERNEL_BUILD_CONFIG) ]; then \
			$(ET_MAKE) \
				$(ET_CFLAGS_KERNEL) \
				$(ET_KERNEL_CROSS_PARAMS) \
				O=$(ET_KERNEL_BUILD_DIR) \
				-C $(ET_KERNEL_SOFTWARE_DIR) \
				$(kernel_defconfig) $(ET_KERNEL_DEFCONFIG_N); \
			if ! [ -f $(ET_KERNEL_BUILD_CONFIG) ]; then \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		;; \
	esac
	$(ET_MAKE) -j $(ET_CPUS) \
		$(ET_CFLAGS_KERNEL) \
		$(ET_KERNEL_CROSS_PARAMS) \
		LOCALVERSION=$(localversion) \
		LOADADDR=$(ET_KERNEL_LOADADDR) \
		INSTALL_MOD_PATH=$(ET_KERNEL_DIR)/usr \
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
		if [ -d $(ET_KERNEL_DIR)/usr/lib/modules ]; then \
			find $(ET_KERNEL_DIR)/usr/lib/modules -type l -exec rm -f {} \; ; \
		fi; \
		;; \
	*clean) \
		$(RM) $(ET_KERNEL_DIR)/boot/*; \
		$(RM) -r $(ET_KERNEL_DIR)/usr/lib/modules/*; \
		;; \
	*config) \
		if ! [ -f $(ET_KERNEL_BUILD_CONFIG) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
		if ! [ "$1" = "savedefconfig" ]; then \
			$(ET_MAKE) \
				$(ET_CFLAGS_KERNEL) \
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
	$(call kernel-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call kernel-config *****\n\n"
	$(ET_MAKE) \
		$(ET_CFLAGS_KERNEL) \
		$(ET_KERNEL_CROSS_PARAMS) \
		O=$(ET_KERNEL_BUILD_DIR) \
		-C $(ET_KERNEL_SOFTWARE_DIR) \
		$(kernel_defconfig) $(ET_KERNEL_DEFCONFIG_N)
endef

define kernel-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call kernel-clean *****\n\n"
	$(RM) $(ET_KERNEL_BUILD_CONFIG)
	$(RM) $(ET_KERNEL_BUILD_DEFCONFIG)
	$(RM) -r $(ET_KERNEL_DIR)/boot/*
	$(RM) -r $(ET_KERNEL_DIR)/usr/lib/modules/*
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
	@printf "ET_KERNEL_VENDOR: $(ET_KERNEL_VENDOR)\n"
	@printf "ET_KERNEL_DT: $(ET_KERNEL_DT)\n"
	@if [ -n "$(shell echo $(ET_KERNEL_DT_ETINKER))" ]; then \
		printf "ET_KERNEL_DT_ETINKER: $(ET_KERNEL_DT_ETINKER)\n"; \
	fi
	@printf "ET_KERNEL_SOFTWARE_DIR: $(ET_KERNEL_SOFTWARE_DIR)\n"
	@printf "ET_KERNEL_BUILD_DIR: $(ET_KERNEL_BUILD_DIR)\n"
	@printf "ET_KERNEL_BUILD_CONFIG: $(ET_KERNEL_BUILD_CONFIG)\n"
	@printf "ET_KERNEL_BUILD_DEFCONFIG: $(ET_KERNEL_BUILD_DEFCONFIG)\n"
	@printf "ET_KERNEL_BUILD_DTB: $(ET_KERNEL_BUILD_DTB)\n"
	@printf "ET_KERNEL_BUILD_SYSMAP: $(ET_KERNEL_BUILD_SYSMAP)\n"
	@printf "ET_KERNEL_DEFCONFIG: $(ET_KERNEL_DEFCONFIG)\n"
	@if [ -n "$(shell echo $(ET_KERNEL_DEFCONFIG_N))" ]; then \
		printf "ET_KERNEL_DEFCONFIG_N: $(ET_KERNEL_DEFCONFIG_N)\n"; \
	fi
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

define kernel-update
	@$(ET_MAKE) -C $(ET_DIR) kernel-clean
	@$(ET_MAKE) -C $(ET_DIR) kernel
endef

define kernel-all
	@$(ET_MAKE) -C $(ET_DIR) kernel
endef

.PHONY: kernel
kernel: $(ET_KERNEL_TARGET_FINAL)
$(ET_KERNEL_TARGET_FINAL): $(ET_KERNEL_BUILD_CONFIG)
	$(call kernel-prepare)
	$(call kernel-build-$(ET_BOARD))
	$(call kernel-build,$(kernel_vendor)$(ET_KERNEL_DT).dtb)
ifdef ET_KERNEL_DT_ETINKER
	$(foreach dts,$(ET_KERNEL_DT_ETINKER),$(call kernel-build,$(kernel_vendor)$(dts).dtb))
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

.PHONY: kernel-software
kernel-software:
	$(call $@)

.PHONY: kernel-info
kernel-info:
	$(call $@)

kernel-sync-%:
	$(call kernel-sync,$(*F))

.PHONY: kernel-update
kernel-update:
	$(call $@)

.PHONY: kernel-all
kernel-all:
	$(call $@)

endif
# ET_BOARD_KERNEL_TREE
