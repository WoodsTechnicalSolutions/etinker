#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2021 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://buildroot.org
# - https://git.busybox.net/buildroot
# - https://buildroot.org/docs.html
#

ifndef ET_BOARD_ROOTFS_TREE
$(error [ 'etinker' rootfs build requires ET_BOARD_ROOTFS_TREE ] ***)
endif

ifndef ET_BOARD_ROOTFS_TYPE
export ET_BOARD_ROOTFS_TYPE := $(ET_BOARD_TYPE)
endif

# embedded rootfs, for application processors, is Buildroot
export ET_ROOTFS_TYPE := $(ET_BOARD_ROOTFS_TYPE)
export ET_ROOTFS_TREE := $(ET_BOARD_ROOTFS_TREE)
export ET_ROOTFS_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_ROOTFS_TREE)
export ET_ROOTFS_HOSTNAME := $(ET_BOARD_HOSTNAME)
export ET_ROOTFS_GETTY_PORT := $(ET_BOARD_GETTY_PORT)
export ET_ROOTFS_ISSUE := $(shell printf "etinker: $(ET_BOARD)")
export ET_ROOTFS_CACHED_VERSION := $(shell grep -Po 'rootfs-ref:\K[^\n]*' $(ET_BOARD_DIR)/software.conf)

rootfs_defconfig := et_$(subst -,_,$(ET_ROOTFS_TYPE))_defconfig

# [start] rootfs version magic
ET_ROOTFS_VERSION := $(shell cd $(ET_ROOTFS_SOFTWARE_DIR) 2>/dev/null && git describe --long --dirty 2>/dev/null | tr -d v)
ifeq ($(shell echo $(ET_ROOTFS_VERSION) | cut -d '-' -f 2),0)
ET_ROOTFS_VERSION := $(shell cd $(ET_ROOTFS_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | tr -d v)
endif
export ET_ROOTFS_VERSION
# [end] rootfs version magic

export ET_ROOTFS_BUILD_DIR := $(ET_DIR)/rootfs/build/$(ET_ROOTFS_TYPE)/$(ET_CROSS_TUPLE)
export ET_ROOTFS_BUILD_CONFIG := $(ET_ROOTFS_BUILD_DIR)/.config
export ET_ROOTFS_BUILD_IMAGE := $(ET_ROOTFS_BUILD_DIR)/images/rootfs.tar
export ET_ROOTFS_TARBALLS_DIR := $(ET_TARBALLS_DIR)/rootfs
export ET_ROOTFS_DIR := $(ET_DIR)/rootfs/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_ROOTFS_DEFCONFIG := $(ET_DIR)/boards/$(ET_ROOTFS_TYPE)/config/$(ET_ROOTFS_TREE)/$(rootfs_defconfig)
export ET_ROOTFS_BUSYBOX_CONFIG := $(ET_DIR)/boards/$(ET_ROOTFS_TYPE)/config/$(ET_ROOTFS_TREE)/busybox.config
export ET_ROOTFS_IMAGE := $(ET_ROOTFS_DIR)/images/rootfs.tar
export ET_ROOTFS_TARGET_FINAL ?= $(ET_ROOTFS_IMAGE)

export ET_ROOTFS_SYSROOT_DIR := $(ET_ROOTFS_BUILD_DIR)/host/$(ET_ARCH)-buildroot-$(ET_OS)-$(ET_ABI)/sysroot

export BR_DEFCONFIG := $(ET_ROOTFS_DEFCONFIG)

define rootfs-version
	@printf "ET_ROOTFS_VERSION: \033[0;33m[$(ET_ROOTFS_CACHED_VERSION)]\033[0m $(ET_ROOTFS_VERSION)\n"
endef

define rootfs-depends
	@mkdir -p $(ET_ROOTFS_DIR)
	@mkdir -p $(ET_ROOTFS_BUILD_DIR)
	@mkdir -p $(ET_ROOTFS_TARBALLS_DIR)
	@mkdir -p $(shell dirname $(ET_ROOTFS_DEFCONFIG))
	@if [ -f $(ET_ROOTFS_DEFCONFIG) ]; then \
		rsync $(ET_ROOTFS_DEFCONFIG) $(ET_ROOTFS_SOFTWARE_DIR)/configs/ > /dev/null; \
	fi
endef

define rootfs-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_TREE) $(ET_ROOTFS_VERSION) *****\n\n"
	$(call rootfs-depends)
	$(call rootfs-build)
endef

define rootfs-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-build 'make $1' *****\n\n"
	$(call rootfs-depends)
	@case "$1" in \
	*config) \
		;; \
	*) \
		if ! [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
			$(MAKE) --no-print-directory \
				CROSS_COMPILE=$(ET_CROSS_COMPILE) \
				O=$(ET_ROOTFS_BUILD_DIR) \
				-C $(ET_ROOTFS_SOFTWARE_DIR) \
				$(rootfs_defconfig); \
			if ! [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		;; \
	esac
	$(MAKE) --no-print-directory -j $(ET_CPUS) \
		CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		O=$(ET_ROOTFS_BUILD_DIR) \
		-C $(ET_ROOTFS_SOFTWARE_DIR) \
		$1
	@case "$1" in \
	*clean) \
		$(RM) -r $(ET_ROOTFS_DIR)/images; \
		;; \
	*config) \
		if [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
			if ! [ "$1" = "savedefconfig" ]; then \
				$(MAKE) --no-print-directory \
					CROSS_COMPILE=$(ET_CROSS_COMPILE) \
					O=$(ET_ROOTFS_BUILD_DIR) \
					-C $(ET_ROOTFS_SOFTWARE_DIR) \
					savedefconfig; \
			fi; \
			echo; \
			cp -av $(ET_ROOTFS_SOFTWARE_DIR)/configs/$(rootfs_defconfig) $(ET_ROOTFS_DEFCONFIG); \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
		;; \
	*) \
		;; \
	esac
	@if [ -z "$1" ]; then \
		if ! [ -f $(ET_ROOTFS_BUILD_IMAGE) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_BUILD_IMAGE) build FAILED! *****\n\n"; \
			exit 2; \
		fi; \
		$(RM) -r $(ET_ROOTFS_DIR)/images; \
		cp -av $(ET_ROOTFS_BUILD_DIR)/images $(ET_ROOTFS_DIR)/; \
	fi
	@if [ -n "$(shell diff $(ET_ROOTFS_BUILD_DIR)/build/busybox-*/.config $(ET_ROOTFS_BUSYBOX_CONFIG) 2> /dev/null)" ] || \
							[ "$(shell echo $1 | grep -Po busybox)" = "busybox" ]; then \
		echo; \
		cp -av $(ET_ROOTFS_BUILD_DIR)/build/busybox-*/.config $(ET_ROOTFS_BUSYBOX_CONFIG); \
	fi
	@if [ -n "$(shell diff $(ET_ROOTFS_SOFTWARE_DIR)/configs/$(rootfs_defconfig) $(ET_ROOTFS_DEFCONFIG) 2> /dev/null)" ]; then \
		echo; \
		cp -av $(ET_ROOTFS_SOFTWARE_DIR)/configs/$(rootfs_defconfig) $(ET_ROOTFS_DEFCONFIG); \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] rootfs-build 'make $1' done. *****\n\n"
endef

define rootfs-config
	$(call software-check,$(ET_ROOTFS_TREE),rootfs)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-config *****\n\n"
	$(call rootfs-depends)
	$(MAKE) --no-print-directory \
		CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		O=$(ET_ROOTFS_BUILD_DIR) \
		-C $(ET_ROOTFS_SOFTWARE_DIR) \
		$(rootfs_defconfig)
endef

define rootfs-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-clean *****\n\n"
	$(RM) $(ET_ROOTFS_BUILD_DIR)/build/busybox-*/.config
	$(RM) $(ET_ROOTFS_BUILD_CONFIG)
	$(RM) -r $(ET_ROOTFS_DIR)/images
endef

define rootfs-purge
	$(call rootfs-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-purge *****\n\n"
	$(RM) -r $(ET_ROOTFS_BUILD_DIR)
endef

define rootfs-info
	@printf "========================================================================\n"
	@printf "ET_ROOTFS_TREE: $(ET_ROOTFS_TREE)\n"
	@printf "ET_ROOTFS_VERSION: $(ET_ROOTFS_VERSION)\n"
	@printf "ET_ROOTFS_HOSTNAME: $(ET_ROOTFS_HOSTNAME)\n"
	@printf "ET_ROOTFS_GETTY_PORT: $(ET_ROOTFS_GETTY_PORT)\n"
	@printf "ET_ROOTFS_ISSUE: $(ET_ROOTFS_ISSUE)\n"
	@printf "ET_ROOTFS_SOFTWARE_DIR: $(ET_ROOTFS_SOFTWARE_DIR)\n"
	@printf "ET_ROOTFS_TARBALLS_DIR: $(ET_ROOTFS_TARBALLS_DIR)\n"
	@printf "ET_ROOTFS_BUILD_DIR: $(ET_ROOTFS_BUILD_DIR)\n"
	@printf "ET_ROOTFS_BUILD_CONFIG: $(ET_ROOTFS_BUILD_CONFIG)\n"
	@printf "ET_ROOTFS_BUILD_IMAGE: $(ET_ROOTFS_BUILD_IMAGE)\n"
	@printf "ET_ROOTFS_DEFCONFIG: $(ET_ROOTFS_DEFCONFIG)\n"
	@printf "ET_ROOTFS_BUSYBOX_CONFIG: $(ET_ROOTFS_BUSYBOX_CONFIG)\n"
	@printf "ET_ROOTFS_DIR: $(ET_ROOTFS_DIR)\n"
	@printf "ET_ROOTFS_IMAGE: $(ET_ROOTFS_IMAGE)\n"
	@printf "ET_ROOTFS_TARGET_FINAL: $(ET_ROOTFS_TARGET_FINAL)\n"
endef

define rootfs-sync
	@$(ET_DIR)/scripts/sync rootfs $1
endef

.PHONY: rootfs
rootfs: $(ET_ROOTFS_TARGET_FINAL)
$(ET_ROOTFS_TARGET_FINAL): $(ET_ROOTFS_BUILD_CONFIG)
	$(call rootfs-targets)

rootfs-%: $(ET_ROOTFS_BUILD_CONFIG)
	$(call rootfs-build,$(*F))

.PHONY: rootfs-config
rootfs-config: $(ET_ROOTFS_BUILD_CONFIG)
$(ET_ROOTFS_BUILD_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
	$(call rootfs-config)

.PHONY: rootfs-clean
rootfs-clean:
	$(call $@)

.PHONY: rootfs-purge
rootfs-purge:
	$(call $@)

.PHONY: rootfs-version
rootfs-version:
	$(call $@)

.PHONY: rootfs-info
rootfs-info:
	$(call $@)

rootfs-sync-%:
	$(call rootfs-sync,$(*F))

.PHONY: rootfs-update
rootfs-update: rootfs-clean rootfs
