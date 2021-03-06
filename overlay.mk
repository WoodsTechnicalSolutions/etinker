#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2021 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_BOARD_ROOTFS_TREE
$(error [ 'etinker' overlay packages require buildroot rootfs ] ***)
endif

ifeq ($(ET_INITRAMFS),yes)
rootfs_type := $(subst -initramfs,,$(ET_ROOTFS_TYPE))
endif
export ET_OVERLAY_BUILD_DIR := $(ET_DIR)/overlay/build/$(rootfs_type)/$(ET_CROSS_TUPLE)
export ET_OVERLAY_DIR := $(ET_DIR)/overlay/$(ET_BOARD)/$(ET_CROSS_TUPLE)

include $(ET_DIR)/packages/cadence-ttc-pwm.mk
include $(ET_DIR)/packages/cryptodev-linux.mk
include $(ET_DIR)/packages/openssl.mk
include $(ET_DIR)/packages/wireless-regdb.mk
include $(ET_DIR)/packages/rt-tests.mk

define overlay-depends
	@mkdir -p $(ET_OVERLAY_DIR)
	@printf "exclude\n"            > $(ET_OVERLAY_DIR)/exclude
	@printf "usr/include\n"       >> $(ET_OVERLAY_DIR)/exclude
	@printf "usr/lib/pkgconfig\n" >> $(ET_OVERLAY_DIR)/exclude
	@printf "usr/lib/*.a\n"       >> $(ET_OVERLAY_DIR)/exclude
endef

define overlay-version
	$(call cadence-ttc-pwm-version)
	$(call cryptodev-linux-version)
	$(call openssl-version)
	$(call wireless-regdb-version)
	$(call rt-tests-version)
endef

define overlay-clean
	$(call cadence-ttc-pwm-clean)
	$(call cryptodev-linux-clean)
	$(call openssl-clean)
	$(call wireless-regdb-clean)
	$(call rt-tests-clean)
endef

define overlay-purge
	$(call cadence-ttc-pwm-purge)
	$(call cryptodev-linux-purge)
	$(call openssl-purge)
	$(call wireless-regdb-purge)
	$(call rt-tests-purge)
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
endef

define overlay-sync
	$(call overlay-depends)
	@$(ET_DIR)/scripts/sync overlay $1
endef

.PHONY: overlay
ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -Po zynq),zynq)
overlay: cadence-ttc-pwm 
endif
overlay: cryptodev-linux openssl wireless-regdb rt-tests
	$(call overlay-depends)

.PHONY: overlay-clean
overlay-clean:
	$(call $@)

.PHONY: overlay-purge
overlay-purge:
	$(call $@)

.PHONY: overlay-version
overlay-version:
	$(call $@)

.PHONY: overlay-info
overlay-info:
	$(call $@)

overlay-sync-%:
	$(call overlay-sync,$(*F))

.PHONY: overlay-update
overlay-update: overlay-clean overlay
