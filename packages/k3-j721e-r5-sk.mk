#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2024-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_BIOS_REQUIRED

PACKAGE_NAME := k3-j721e-r5-sk
PACKAGE_BOARD := ET_BOARD=$(PACKAGE_NAME)

define $(PACKAGE_NAME)-version
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-version"
endef

define $(PACKAGE_NAME)-software
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader-software"
endef

define $(PACKAGE_NAME)
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader"
endef

define $(PACKAGE_NAME)-build
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader"
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

define $(PACKAGE_NAME)-all
	@env -i bash -lc "$(PACKAGE_BOARD) $(ET_MAKE) -C $(ET_DIR) bootloader"
endef

.PHONY: $(PACKAGE_NAME)
$(PACKAGE_NAME):
	$(call $(PACKAGE_NAME))

.PHONY: $(PACKAGE_NAME)-config
$(PACKAGE_NAME)-config:
	$(call $@)

.PHONY: $(PACKAGE_NAME)-clean
$(PACKAGE_NAME)-clean:
	$(call $@)

.PHONY: $(PACKAGE_NAME)-purge
$(PACKAGE_NAME)-purge:
	$(call $@)

.PHONY: $(PACKAGE_NAME)-version
$(PACKAGE_NAME)-version:
	$(call $@)

.PHONY: $(PACKAGE_NAME)-software
$(PACKAGE_NAME)-software:
	$(call $@)

.PHONY: $(PACKAGE_NAME)-info
$(PACKAGE_NAME)-info:
	$(call $@)

.PHONY: $(PACKAGE_NAME)-update
$(PACKAGE_NAME)-update:
	$(call $@)

endif
# ET_BOARD_BIOS_REQUIRED
