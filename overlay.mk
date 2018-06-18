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

include packages/cryptodev-linux.mk
include packages/openssl.mk
include packages/wireless-regdb.mk

define overlay-version
	$(call cryptodev-linux-version)
	$(call openssl-version)
	$(call wireless-regdb-version)
endef

define overlay-clean
	$(call cryptodev-linux-clean)
	$(call openssl-clean)
	$(call wireless-regdb-clean)
endef

define overlay-purge
	$(call cryptodev-linux-purge)
	$(call openssl-purge)
	$(call wireless-regdb-purge)
endef

define overlay-info
	@printf "========================================================================\n"
	@printf "ET_OVERLAY_BUILD_DIR: $(ET_OVERLAY_BUILD_DIR)\n"
	@printf "ET_OVERLAY_DIR: $(ET_OVERLAY_DIR)\n"
	$(call cryptodev-linux-info)
	$(call openssl-info)
	$(call wireless-regdb-info)
endef

.PHONY: overlay
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
