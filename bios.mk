#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2024-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_BIOS_REQUIRED

export ET_BIOS_BUILD_DIR := $(ET_DIR)/bios/build/$(ET_BOARD_TYPE)$(ET_BIOS_VARIANT)/$(ET_CROSS_TUPLE)
export ET_BIOS_DIR := $(ET_DIR)/bios/$(ET_BOARD)$(ET_BIOS_VARIANT)/$(ET_CROSS_TUPLE)

include $(ET_BOARD_DIR)/bios.mk

export ET_BIOS_LIST := $(ET_BOARD_BIOS_LIST)

define bios-depends
	@mkdir -p $(ET_BIOS_DIR)
	@mkdir -p $(ET_BIOS_BUILD_DIR)
endef

define bios-software
	$(call bios-software-$(ET_BOARD))
endef

define bios-version
	$(call bios-version-$(ET_BOARD))
endef

define bios-clean
	$(call bios-clean-$(ET_BOARD))
endef

define bios-purge
	$(call bios-purge-$(ET_BOARD))
endef

define bios-info
	@printf "========================================================================\n"
	@printf "ET_BIOS_LIST: $(ET_BIOS_LIST)\n"
	@printf "ET_BIOS_TARGET_LIST: $(ET_BIOS_TARGET_LIST)\n"
	@printf "ET_BIOS_BUILD_DIR: $(ET_BIOS_BUILD_DIR)\n"
	@printf "ET_BIOS_DIR: $(ET_BIOS_DIR)\n"
	$(call bios-info-$(ET_BOARD))
endef

define bios-update
	$(call bios-update-$(ET_BOARD))
endef

define bios
	$(call bios-depends)
	$(call bios-$(ET_BOARD))
endef

define bios-all
	$(call bios)
endef

.PHONY: bios bios-all
bios bios-all:
	$(call $@)

bios-%:
	$(call bios-$(*F))

endif
# ET_BOARD_BIOS_REQUIRED
