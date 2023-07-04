#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2023, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_ROOTFS_TREE

export ET_OVERLAY_BUILD_DIR := $(ET_DIR)/overlay/build/$(ET_ROOTFS_TYPE)/$(ET_CROSS_TUPLE)
export ET_OVERLAY_DIR := $(ET_DIR)/overlay/$(ET_BOARD)$(ET_ROOTFS_VARIANT)/$(ET_CROSS_TUPLE)

include $(ET_DIR)/packages/cadence-ttc-pwm.mk
include $(ET_DIR)/packages/cryptodev-linux.mk
include $(ET_DIR)/packages/openssl.mk
include $(ET_DIR)/packages/wireless-regdb.mk
include $(ET_DIR)/packages/rt-tests.mk
include $(ET_DIR)/packages/trace-cmd.mk

define overlay-depends
	@mkdir -p $(ET_OVERLAY_DIR)
	@printf "exclude\n"            > $(ET_OVERLAY_DIR)/exclude
	@printf "usr/include\n"       >> $(ET_OVERLAY_DIR)/exclude
	@printf "usr/lib/pkgconfig\n" >> $(ET_OVERLAY_DIR)/exclude
	@printf "usr/lib/*.a\n"       >> $(ET_OVERLAY_DIR)/exclude
endef

define overlay-software
	$(call cadence-ttc-pwm-software)
	$(call cryptodev-linux-software)
	$(call openssl-software)
	$(call wireless-regdb-software)
	$(call rt-tests-software)
	$(call trace-cmd-software)
endef

define overlay-version
	$(call cadence-ttc-pwm-version)
	$(call cryptodev-linux-version)
	$(call openssl-version)
	$(call wireless-regdb-version)
	$(call rt-tests-version)
	$(call trace-cmd-version)
endef

define overlay-clean
	$(call cadence-ttc-pwm-clean)
	$(call cryptodev-linux-clean)
	$(call openssl-clean)
	$(call wireless-regdb-clean)
	$(call rt-tests-clean)
	$(call trace-cmd-clean)
endef

define overlay-purge
	$(call cadence-ttc-pwm-purge)
	$(call cryptodev-linux-purge)
	$(call openssl-purge)
	$(call wireless-regdb-purge)
	$(call rt-tests-purge)
	$(call trace-cmd-purge)
endef

define overlay-info
	@printf "========================================================================\n"
	@printf "ET_OVERLAY_BUILD_DIR: $(ET_OVERLAY_BUILD_DIR)\n"
	@printf "ET_OVERLAY_DIR: $(ET_OVERLAY_DIR)\n"
	$(call cadence-ttc-pwm-info)
	$(call cryptodev-linux-info)
	$(call openssl-info)
	$(call wireless-regdb-info)
	$(call rt-tests-info)
	$(call trace-cmd-info)
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
	$(call cadence-ttc-pwm-all)
	$(call cryptodev-linux-all)
	$(call openssl-all)
	$(call wireless-regdb-all)
	$(call rt-tests-all)
	$(call trace-cmd-all)

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
