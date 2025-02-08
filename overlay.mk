#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_ROOTFS_TREE

export ET_OVERLAY_BUILD_DIR := $(ET_DIR)/overlay/build/$(ET_ROOTFS_TYPE)/$(ET_CROSS_TUPLE)
export ET_OVERLAY_DIR := $(ET_DIR)/overlay/$(ET_BOARD)$(ET_ROOTFS_VARIANT)/$(ET_CROSS_TUPLE)

include $(ET_DIR)/packages/cryptodev-linux.mk
include $(ET_DIR)/packages/openssl.mk
include $(ET_DIR)/packages/wireless-regdb.mk
include $(ET_DIR)/packages/rt-tests.mk
include $(ET_DIR)/packages/trace-cmd.mk
include $(ET_DIR)/packages/luajit-riscv.mk

define overlay-depends
	@mkdir -p $(ET_OVERLAY_DIR)
endef

define overlay-software
	$(call cryptodev-linux-software)
	$(call openssl-software)
	$(call wireless-regdb-software)
	$(call rt-tests-software)
	$(call trace-cmd-software)
	$(call luajit-riscv-software)
endef

define overlay-version
	$(call cryptodev-linux-version)
	$(call openssl-version)
	$(call wireless-regdb-version)
	$(call rt-tests-version)
	$(call trace-cmd-version)
	$(call luajit-riscv-version)
endef

define overlay-clean
	$(call cryptodev-linux-clean)
	$(call openssl-clean)
	$(call wireless-regdb-clean)
#	$(call rt-tests-clean)
	$(call trace-cmd-clean)
	$(call luajit-riscv-clean)
endef

define overlay-purge
	$(call cryptodev-linux-purge)
	$(call openssl-purge)
	$(call wireless-regdb-purge)
#	$(call rt-tests-purge)
	$(call trace-cmd-purge)
	$(call luajit-riscv-purge)
endef

define overlay-info
	@printf "========================================================================\n"
	@printf "ET_OVERLAY_BUILD_DIR: $(ET_OVERLAY_BUILD_DIR)\n"
	@printf "ET_OVERLAY_DIR: $(ET_OVERLAY_DIR)\n"
	$(call cryptodev-linux-info)
	$(call openssl-info)
	$(call wireless-regdb-info)
	$(call rt-tests-info)
	$(call trace-cmd-info)
	$(call luajit-riscv-info)
endef

define overlay-sync
	$(call overlay-depends)
	@$(ET_DIR)/scripts/sync overlay $1
endef

define overlay-update
	@$(ET_MAKE) -C $(ET_DIR) overlay-clean
	@$(ET_MAKE) -C $(ET_DIR) overlay
endef

define overlay-all
	@$(ET_MAKE) -C $(ET_DIR) overlay
endef

.PHONY: overlay
overlay:
	$(call overlay-depends)
	$(call cryptodev-linux-all)
	$(call openssl-all)
	$(call wireless-regdb-all)
#	$(call rt-tests-all)
	$(call trace-cmd-all)
	$(call luajit-riscv-all)

.PHONY: overlay-clean
overlay-clean:
	$(call $@)

.PHONY: overlay-purge
overlay-purge:
	$(call $@)

.PHONY: overlay-version
overlay-version:
	$(call $@)

.PHONY: overlay-software
overlay-software:
	$(call $@)

.PHONY: overlay-info
overlay-info:
	$(call $@)

overlay-sync-%:
	$(call overlay-sync,$(*F))

.PHONY: overlay-update
overlay-update:
	$(call $@)

.PHONY: overlay-all
overlay-all:
	$(call $@)

endif
# ET_BOARD_ROOTFS_TREE
