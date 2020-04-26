#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_BOARD_ROOTFS_TREE
$(error [ 'etinker' overlay packages require buildroot rootfs ] ***)
endif

export ET_OVERLAY_BUILD_DIR := $(ET_DIR)/overlay/build/$(ET_BOARD_TYPE)/$(ET_CROSS_TUPLE)
export ET_OVERLAY_DIR := $(ET_DIR)/overlay/$(ET_BOARD)/$(ET_CROSS_TUPLE)

include $(ET_DIR)/packages/cadence-ttc-pwm.mk
include $(ET_DIR)/packages/cryptodev-linux.mk
include $(ET_DIR)/packages/openssl.mk
include $(ET_DIR)/packages/wireless-regdb.mk

define overlay-version
	$(call cadence-ttc-pwm-version)
	$(call cryptodev-linux-version)
	$(call openssl-version)
	$(call wireless-regdb-version)
endef

define overlay-clean
	$(call cadence-ttc-pwm-clean)
	$(call cryptodev-linux-clean)
	$(call openssl-clean)
	$(call wireless-regdb-clean)
endef

define overlay-purge
	$(call cadence-ttc-pwm-purge)
	$(call cryptodev-linux-purge)
	$(call openssl-purge)
	$(call wireless-regdb-purge)
endef

define overlay-info
	@printf "========================================================================\n"
	@printf "ET_OVERLAY_BUILD_DIR: $(ET_OVERLAY_BUILD_DIR)\n"
	@printf "ET_OVERLAY_DIR: $(ET_OVERLAY_DIR)\n"
	$(call cadence-ttc-pwm-info)
	$(call cryptodev-linux-info)
	$(call openssl-info)
	$(call wireless-regdb-info)
endef

define overlay-sync
	@printf "exclude\n"            > $(ET_OVERLAY_DIR)/exclude
	@printf "usr/include\n"       >> $(ET_OVERLAY_DIR)/exclude
	@printf "usr/lib/pkgconfig\n" >> $(ET_OVERLAY_DIR)/exclude
	@$(ET_DIR)/scripts/sync overlay $1
endef

.PHONY: overlay
ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -Po zynq),zynq)
overlay: cadence-ttc-pwm 
endif
overlay: cryptodev-linux openssl wireless-regdb

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
