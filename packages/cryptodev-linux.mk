#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - http://cryptodev-linux.org
# - https://github.com/cryptodev-linux/cryptodev-linux
# - https://git.busybox.net/buildroot/tree/package/cryptodev-linux/cryptodev-linux.mk
#

ifdef ET_BOARD_ROOTFS_TREE
ifdef ET_BOARD_KERNEL_TREE

module_build_dir := $(ET_DIR)/overlay/build/$(ET_KERNEL_TYPE)/$(ET_CROSS_TUPLE)

export ET_CRYPTODEV_LINUX_TREE := cryptodev-linux
export ET_CRYPTODEV_LINUX_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_CRYPTODEV_LINUX_TREE)
export ET_CRYPTODEV_LINUX_VERSION := $(shell cd $(ET_CRYPTODEV_LINUX_SOFTWARE_DIR) $(ET_NOERR) && git describe --long --dirty $(ET_NOERR))
export ET_CRYPTODEV_LINUX_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) cryptodev-linux-ref)
export ET_CRYPTODEV_LINUX_BUILD_DIR := $(module_build_dir)/$(ET_CRYPTODEV_LINUX_TREE)
export ET_CRYPTODEV_LINUX_BUILD_CONFIG := $(ET_CRYPTODEV_LINUX_BUILD_DIR)/.configured
export ET_CRYPTODEV_LINUX_BUILD_KO := $(ET_CRYPTODEV_LINUX_BUILD_DIR)/cryptodev.ko
export ET_CRYPTODEV_LINUX_KO := $(ET_KERNEL_DIR)/usr/lib/modules/$(ET_KERNEL_VERSION)*/updates/cryptodev.ko
export ET_CRYPTODEV_LINUX_TARGET_FINAL ?= $(ET_CRYPTODEV_LINUX_KO)

define cryptodev-linux-version
	@printf "ET_CRYPTODEV_LINUX_VERSION: \033[0;33m[$(ET_CRYPTODEV_LINUX_CACHED_VERSION)]\033[0m $(ET_CRYPTODEV_LINUX_VERSION)\n"
endef

define cryptodev-linux-software
	$(call software-check,$(ET_CRYPTODEV_LINUX_TREE),cryptodev-linux,fetch)
endef

define cryptodev-linux-depends
	$(call software-check,$(ET_CRYPTODEV_LINUX_TREE),cryptodev-linux)
	@mkdir -p $(shell dirname $(ET_CRYPTODEV_LINUX_BUILD_DIR))
endef

define cryptodev-linux-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cryptodev-linux *****\n\n"
	$(call cryptodev-linux-build,build)
	$(call cryptodev-linux-build,install)
endef

define cryptodev-linux-build
	$(call cryptodev-linux-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call cryptodev-linux-build 'make $1' *****\n\n"
	@$(MAKE) -C $(ET_CRYPTODEV_LINUX_BUILD_DIR) \
		ARCH=$(ET_BOARD_KERNEL_ARCH) CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		$1 \
		prefix=$(ET_ROOTFS_SYSROOT_DIR)/usr \
		INSTALL_MOD_PATH=$(ET_KERNEL_DIR)/usr \
		KERNEL_DIR=$(ET_KERNEL_BUILD_DIR)
	@if [ "$1" = "build" ]; then \
		if ! [ -f $(ET_CRYPTODEV_LINUX_BUILD_KO) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_CRYPTODEV_LINUX_TREE) $1 FAILED! *****\n"; \
			exit 2; \
		fi; \
	fi
	@if [ -n "$(shell printf "%s" $1 | grep clean)" ]; then \
		$(RM) $(ET_CRYPTODEV_LINUX_TARGET_FINAL); \
		$(RM) $(ET_ROOTFS_SYSROOT_DIR)/usr/include/crypto/cryptodev.h; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cryptodev-linux-build 'make $1' done. *****\n\n"
endef

define cryptodev-linux-config
	$(call cryptodev-linux-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cryptodev-linux-config *****\n\n"
	@if ! [ -d $(ET_CRYPTODEV_LINUX_BUILD_DIR) ]; then \
		cp -a $(ET_CRYPTODEV_LINUX_SOFTWARE_DIR) $(shell dirname $(ET_CRYPTODEV_LINUX_BUILD_DIR))/; \
		printf "%s\n" "$(shell date)" > $(ET_CRYPTODEV_LINUX_BUILD_CONFIG); \
	fi
endef

define cryptodev-linux-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call cryptodev-linux-clean *****\n\n"
	$(RM) $(ET_CRYPTODEV_LINUX_TARGET_FINAL)
	$(RM) $(ET_CRYPTODEV_LINUX_BUILD_KO)
	$(RM) $(ET_ROOTFS_SYSROOT_DIR)/usr/include/crypto/cryptodev.h
endef

define cryptodev-linux-purge
	$(call cryptodev-linux-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call cryptodev-linux-purge *****\n\n"
	$(RM) -r $(ET_CRYPTODEV_LINUX_BUILD_DIR)
	$(call cryptodev-linux-config)
endef

define cryptodev-linux-info
	@printf "========================================================================\n"
	@printf "ET_CRYPTODEV_LINUX_TREE: $(ET_CRYPTODEV_LINUX_TREE)\n"
	@printf "ET_CRYPTODEV_LINUX_VERSION: $(ET_CRYPTODEV_LINUX_VERSION)\n"
	@printf "ET_CRYPTODEV_LINUX_SOFTWARE_DIR: $(ET_CRYPTODEV_LINUX_SOFTWARE_DIR)\n"
	@printf "ET_CRYPTODEV_LINUX_BUILD_CONFIG: $(ET_CRYPTODEV_LINUX_BUILD_CONFIG)\n"
	@printf "ET_CRYPTODEV_LINUX_BUILD_KO: $(ET_CRYPTODEV_LINUX_BUILD_KO)\n"
	@printf "ET_CRYPTODEV_LINUX_BUILD_DIR: $(ET_CRYPTODEV_LINUX_BUILD_DIR)\n"
	@printf "ET_CRYPTODEV_LINUX_KO: $(ET_CRYPTODEV_LINUX_KO)\n"
	@printf "ET_CRYPTODEV_LINUX_TARGET_FINAL: $(ET_CRYPTODEV_LINUX_TARGET_FINAL)\n"
endef

define cryptodev-linux-update
	@$(ET_MAKE) -C $(ET_DIR) cryptodev-linux-clean
	@$(ET_MAKE) -C $(ET_DIR) cryptodev-linux
endef

define cryptodev-linux-all
	@$(ET_MAKE) -C $(ET_DIR) cryptodev-linux
endef

.PHONY: cryptodev-linux
cryptodev-linux: $(ET_CRYPTODEV_LINUX_TARGET_FINAL)
$(ET_CRYPTODEV_LINUX_TARGET_FINAL): $(ET_CRYPTODEV_LINUX_BUILD_CONFIG)
	$(call cryptodev-linux-targets)

cryptodev-linux-%: $(ET_CRYPTODEV_LINUX_BUILD_CONFIG)
	$(call cryptodev-linux-build,$(*F))

.PHONY: cryptodev-linux-config
cryptodev-linux-config: $(ET_CRYPTODEV_LINUX_BUILD_CONFIG)
$(ET_CRYPTODEV_LINUX_BUILD_CONFIG): $(ET_KERNEL_TARGET_FINAL)
ifeq ($(shell test -f $(ET_CRYPTODEV_LINUX_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call cryptodev-linux-config)
endif

.PHONY: cryptodev-linux-clean
cryptodev-linux-clean:
ifeq ($(ET_CLEAN),yes)
	$(call cryptodev-linux-build,clean)
endif
	$(call $@)

.PHONY: cryptodev-linux-purge
cryptodev-linux-purge:
	$(call $@)

.PHONY: cryptodev-linux-version
cryptodev-linux-version:
	$(call $@)

.PHONY: cryptodev-linux-software
cryptodev-linux-software:
	$(call $@)

.PHONY: cryptodev-linux-info
cryptodev-linux-info:
	$(call $@)

.PHONY: cryptodev-linux-update
cryptodev-linux-update:
	$(call $@)

.PHONY: cryptodev-linux-all
cryptodev-linux-all:
	$(call $@)

endif
# ET_BOARD_KERNEL_TREE
endif
# ET_BOARD_ROOTFS_TREE
