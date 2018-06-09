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

define overlay-version
	$(call cryptodev-linux-version)
	$(call openssl-version)
endef

define overlay-info
	$(call cryptodev-linux-info)
	$(call openssl-info)
endef

define overlay-clean
	$(call cryptodev-linux-clean)
	$(call openssl-clean)
endef

define overlay-purge
	$(call cryptodev-linux-purge)
	$(call openssl-purge)
endef

.PHONY: overlay
overlay: cryptodev-linux openssl
