#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_BOARD_ROOTFS_TREE
$(error [ 'etinker' rootfs build requires ET_BOARD_ROOTFS_TREE ] ***)
endif

# embedded rootfs, for application processors, is Buildroot
export ET_ROOTFS_TREE := $(ET_BOARD_ROOTFS_TREE)
export ET_ROOTFS_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_ROOTFS_TREE)
export ET_ROOTFS_HOSTNAME := $(ET_BOARD_HOSTNAME)
export ET_ROOTFS_GETTY_PORT := $(ET_BOARD_GETTY_PORT)
export ET_ROOTFS_ISSUE := $(shell printf "etinker: $(ET_BOARD)")
# [start] rootfs version magic
ET_ROOTFS_VERSION := $(shell cd $(ET_ROOTFS_SOFTWARE_DIR) 2>/dev/null && git describe --long --dirty 2>/dev/null | tr -d v)
ifeq ($(shell echo $(ET_ROOTFS_VERSION) | cut -d '-' -f 2),0)
ET_ROOTFS_VERSION := $(shell cd $(ET_ROOTFS_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | tr -d v)
endif
export ET_ROOTFS_VERSION
# [end] rootfs version magic
export ET_ROOTFS_BUILD_DIR := $(ET_DIR)/rootfs/build/$(ET_BOARD_TYPE)/$(ET_CROSS_TUPLE)
export ET_ROOTFS_BUILD_CONFIG := $(ET_ROOTFS_BUILD_DIR)/.config
export ET_ROOTFS_BUILD_IMAGE := $(ET_ROOTFS_BUILD_DIR)/images/rootfs.tar
export ET_ROOTFS_TARBALLS_DIR := $(ET_TARBALLS_DIR)/rootfs
export ET_ROOTFS_DIR := $(ET_DIR)/rootfs/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_ROOTFS_CONFIG := $(ET_CONFIG_DIR)/$(ET_ROOTFS_TREE)/config
export ET_ROOTFS_IMAGE := $(ET_ROOTFS_DIR)/images/rootfs.tar
export ET_ROOTFS_TARGET_FINAL += $(ET_ROOTFS_IMAGE)

export ET_ROOTFS_SYSROOT_DIR := $(ET_ROOTFS_BUILD_DIR)/host/$(ET_ARCH)-buildroot-$(ET_OS)-$(ET_ABI)/sysroot

define rootfs-version
	@printf "ET_ROOTFS_VERSION: $(ET_ROOTFS_VERSION)\n"
endef

define rootfs-depends
	@mkdir -p $(ET_ROOTFS_DIR)
	@mkdir -p $(ET_ROOTFS_BUILD_DIR)
	@mkdir -p $(ET_ROOTFS_TARBALLS_DIR)
	@mkdir -p $(shell dirname $(ET_ROOTFS_CONFIG))
endef

define rootfs-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_TREE) $(ET_ROOTFS_VERSION) *****\n\n"
	$(call rootfs-depends)
	@if ! [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
		if [ -f $(ET_ROOTFS_CONFIG) ]; then \
			cat $(ET_ROOTFS_CONFIG) > $(ET_ROOTFS_BUILD_CONFIG); \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_CONFIG) MISSING! *****\n"; \
			exit 2; \
		fi; \
	fi
	$(call rootfs-build)
	@if [ -n "$(shell diff -q $(ET_ROOTFS_BUILD_CONFIG) $(ET_ROOTFS_CONFIG) 2> /dev/null)" ]; then \
		cat $(ET_ROOTFS_BUILD_CONFIG) > $(ET_ROOTFS_CONFIG); \
	fi
endef

define rootfs-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-build 'make $1' *****\n\n"
	$(call rootfs-depends)
	@if ! [ -n "$(shell printf "%s" $1 | grep clean)" ]; then \
		$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_ROOTFS_SOFTWARE_DIR) O=$(ET_ROOTFS_BUILD_DIR) \
			$(ET_CROSS_PARAMS) $1; \
	fi
	@case "$1" in \
	*clean) \
		$(RM) -r $(ET_ROOTFS_DIR)/images; \
		;; \
	*config) \
		if [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
			cat $(ET_ROOTFS_BUILD_CONFIG) > $(ET_ROOTFS_CONFIG); \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
		;; \
	*) \
		;; \
	esac
	@if [ "$1empty" = "empty" ]; then \
		if ! [ -f $(ET_ROOTFS_BUILD_IMAGE) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_BUILD_IMAGE) build FAILED! *****\n\n"; \
			exit 2; \
		fi; \
		$(RM) -r $(ET_ROOTFS_DIR)/images; \
		cp -av $(ET_ROOTFS_BUILD_DIR)/images $(ET_ROOTFS_DIR)/; \
	fi
endef

define rootfs-config
	$(call software-check,$(ET_ROOTFS_TREE))
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-config *****\n\n"
	$(call rootfs-depends)
	@if ! [ -f $(ET_ROOTFS_CONFIG) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-config FAILED! *****\n\n"; \
		exit 2; \
	fi
	@cat $(ET_ROOTFS_CONFIG) > $(ET_ROOTFS_BUILD_CONFIG)
endef

define rootfs-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-clean *****\n\n"
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
	@printf "ET_ROOTFS_IMAGE: $(ET_ROOTFS_IMAGE)\n"
	@printf "ET_ROOTFS_CONFIG: $(ET_ROOTFS_CONFIG)\n"
	@printf "ET_ROOTFS_BUILD_CONFIG: $(ET_ROOTFS_BUILD_CONFIG)\n"
	@printf "ET_ROOTFS_BUILD_IMAGE: $(ET_ROOTFS_BUILD_IMAGE)\n"
	@printf "ET_ROOTFS_DIR: $(ET_ROOTFS_DIR)\n"
	@printf "ET_ROOTFS_BUILD_DIR: $(ET_ROOTFS_BUILD_DIR)\n"
	@printf "ET_ROOTFS_TARGET_FINAL: $(ET_ROOTFS_TARGET_FINAL)\n"
endef

.PHONY: rootfs
rootfs: $(ET_ROOTFS_TARGET_FINAL)
$(ET_ROOTFS_TARGET_FINAL):
	$(call rootfs-targets)

rootfs-%: $(ET_ROOTFS_BUILD_CONFIG)
	$(call rootfs-build,$(*F))

.PHONY: rootfs-config
rootfs-config: $(ET_ROOTFS_BUILD_CONFIG)
$(ET_ROOTFS_BUILD_CONFIG): $(ET_ROOTFS_CONFIG)
	$(call rootfs-config)

$(ET_ROOTFS_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
	$(call rootfs-build,$(ET_ROOTFS_DEFCONFIG))

.PHONY: rootfs-info
rootfs-info:
	$(call $@)

.PHONY: rootfs-clean
rootfs-clean:
	$(call $@)

.PHONY: rootfs-purge
rootfs-purge:
	$(call $@)

.PHONY: rootfs-version
rootfs-version:
	$(call $@)