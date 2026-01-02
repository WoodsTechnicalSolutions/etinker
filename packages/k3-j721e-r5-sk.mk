#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2024-2026, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_BIOS_REQUIRED

ifeq (k3-j721e-r5-sk,$(shell echo $(ET_BOARD_BIOS_LIST) | grep -oe k3-j721e-r5-sk))

PACKAGE_NAME := k3-j721e-r5-sk
PACKAGE_BOARD := ET_BOARD=$(PACKAGE_NAME)

# required for bios.mk
export ET_BIOS_TARGET_LIST += $(ET_BOOTLOADER_TARGET_FINAL)

define $(PACKAGE_NAME)-version
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-version"
endef

define $(PACKAGE_NAME)-software
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-software"
endef

define $(PACKAGE_NAME)-depends
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-depends"
endef

define $(PACKAGE_NAME)-config
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-config"
endef

define $(PACKAGE_NAME)-clean
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-clean"
endef

define $(PACKAGE_NAME)-purge
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-purge"
endef

define $(PACKAGE_NAME)-info
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-info"
endef

define $(PACKAGE_NAME)-update
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-update"
endef

define $(PACKAGE_NAME)
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader"
endef

.PHONY: $(PACKAGE_NAME)
$(PACKAGE_NAME):
	$(call $(PACKAGE_NAME))

$(PACKAGE_NAME)-%:
	$(call $(PACKAGE_NAME)-$(*F))

endif
# opensbi in list

endif
# ET_BOARD_BIOS_REQUIRED
