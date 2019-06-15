#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_BOARD_ROOTFS_TREE
$(error [ 'etinker' packages requires buildroot rootfs ] ***)
endif

ifndef ET_BOARD_KERNEL_TREE
$(error [ 'etinker' packages requires linux kernel ] ***)
endif

export ET_CRYPTODEV_LINUX_TREE := cryptodev-linux
export ET_CRYPTODEV_LINUX_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_CRYPTODEV_LINUX_TREE)
export ET_CRYPTODEV_LINUX_VERSION := $(shell cd $(ET_CRYPTODEV_LINUX_SOFTWARE_DIR) 2>/dev/null && git describe --long --dirty 2>/dev/null)
export ET_CRYPTODEV_LINUX_BUILD_DIR := $(ET_OVERLAY_BUILD_DIR)/cryptodev-linux
export ET_CRYPTODEV_LINUX_BUILD_CONFIG := $(ET_CRYPTODEV_LINUX_BUILD_DIR)/.configured
export ET_CRYPTODEV_LINUX_BUILD_KO := $(ET_CRYPTODEV_LINUX_BUILD_DIR)/cryptodev.ko
export ET_CRYPTODEV_LINUX_KO := $(ET_KERNEL_DIR)/lib/modules/$(ET_KERNEL_VERSION)$(ET_KERNEL_LOCALVERSION)/extra/cryptodev.ko
export ET_CRYPTODEV_LINUX_TARGET_FINAL ?= $(ET_CRYPTODEV_LINUX_KO)

define cryptodev-linux-version
	@printf "ET_CRYPTODEV_LINUX_VERSION: $(ET_CRYPTODEV_LINUX_VERSION)\n"
endef

define cryptodev-linux-depends
	@mkdir -p $(shell dirname $(ET_CRYPTODEV_LINUX_BUILD_DIR))
endef

define cryptodev-linux-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cryptodev-linux *****\n\n"
	$(call cryptodev-linux-depends)
	$(call cryptodev-linux-build,build)
	$(call cryptodev-linux-build,modules_install)
endef

define cryptodev-linux-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call cryptodev-linux-build 'make $1' *****\n\n"
	@$(MAKE) -C $(ET_CRYPTODEV_LINUX_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		$1 \
		prefix=$(ET_ROOTFS_SYSROOT_DIR)/usr \
		INSTALL_MOD_PATH=$(ET_KERNEL_DIR) \
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
	$(call software-check,$(ET_CRYPTODEV_LINUX_TREE),cryptodev-linux)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cryptodev-linux-config *****\n\n"
	$(call cryptodev-linux-depends)
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
endef

define cryptodev-linux-info
	@printf "========================================================================\n"
	@printf "ET_CRYPTODEV_LINUX_TREE: $(ET_CRYPTODEV_LINUX_TREE)\n"
	@printf "ET_CRYPTODEV_LINUX_VERSION: $(ET_CRYPTODEV_LINUX_VERSION)\n"
	@printf "ET_CRYPTODEV_LINUX_SOFTWARE_DIR: $(ET_CRYPTODEV_LINUX_SOFTWARE_DIR)\n"
	@printf "ET_CRYPTODEV_LINUX_KO: $(ET_CRYPTODEV_LINUX_KO)\n"
	@printf "ET_CRYPTODEV_LINUX_BUILD_CONFIG: $(ET_CRYPTODEV_LINUX_BUILD_CONFIG)\n"
	@printf "ET_CRYPTODEV_LINUX_BUILD_KO: $(ET_CRYPTODEV_LINUX_BUILD_KO)\n"
	@printf "ET_CRYPTODEV_LINUX_BUILD_DIR: $(ET_CRYPTODEV_LINUX_BUILD_DIR)\n"
	@printf "ET_CRYPTODEV_LINUX_TARGET_FINAL: $(ET_CRYPTODEV_LINUX_TARGET_FINAL)\n"
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

.PHONY: cryptodev-linux-info
cryptodev-linux-info:
	$(call $@)
