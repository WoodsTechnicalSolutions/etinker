#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2024-2026, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_BIOS_REQUIRED

ifeq (opensbi,$(shell echo $(ET_BOARD_BIOS_LIST) | grep -oe opensbi))

export ET_OPENSBI_TREE := opensbi
export ET_OPENSBI_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_OPENSBI_TREE)
export ET_OPENSBI_VERSION := $(shell cd $(ET_OPENSBI_SOFTWARE_DIR) $(ET_NOERR) && git describe --long --dirty $(ET_NOERR))
export ET_OPENSBI_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) opensbi-ref)
export ET_OPENSBI_BUILD_DIR := $(ET_BIOS_BUILD_DIR)/$(ET_OPENSBI_TREE)
export ET_OPENSBI_BUILD_CONFIG := $(ET_OPENSBI_BUILD_DIR)/.configured
export ET_OPENSBI_TARGET_FINAL ?= $(ET_OPENSBI_BUILD_DIR)/platform/generic/firmware/fw_dynamic.bin

# required for bios.mk
export ET_BIOS_TARGET_LIST += $(ET_OPENSBI_TARGET_FINAL)

export ET_CFLAGS_BOOTLOADER += OPENSBI=$(ET_OPENSBI_TARGET_FINAL)

define opensbi-version
	@printf "ET_OPENSBI_VERSION: \033[0;33m[$(ET_OPENSBI_CACHED_VERSION)]\033[0m $(ET_OPENSBI_VERSION)\n"
endef

define opensbi-software
	@$(call software-check,$(ET_OPENSBI_TREE),opensbi,fetch)
endef

define opensbi-depends
	@mkdir -p $(ET_OPENSBI_BUILD_DIR)
endef

define opensbi-config
	$(call software-check,$(ET_OPENSBI_TREE),opensbi)
	@touch $(ET_OPENSBI_BUILD_CONFIG)
endef

define opensbi-clean
	$(if $(shell [ "$(ET_CLEAN)" = "yes" ] && echo -n yes),$(call opensbi,clean))
	$(RM) $(ET_OPENSBI_TARGET_FINAL)
	$(RM) $(ET_OPENSBI_BUILD_CONFIG)
endef

define opensbi-purge
	$(call opensbi-clean)
	$(RM) -r $(ET_OPENSBI_BUILD_DIR)
endef

define opensbi-info
	@printf "========================================================================\n"
	@printf "ET_OPENSBI_TREE: $(ET_OPENSBI_TREE)\n"
	@printf "ET_OPENSBI_VERSION: $(ET_OPENSBI_VERSION)\n"
	@printf "ET_OPENSBI_SOFTWARE_DIR: $(ET_OPENSBI_SOFTWARE_DIR)\n"
	@printf "ET_OPENSBI_BUILD_CONFIG: $(ET_OPENSBI_BUILD_CONFIG)\n"
	@printf "ET_OPENSBI_BUILD_DIR: $(ET_OPENSBI_BUILD_DIR)\n"
	@printf "ET_OPENSBI_TARGET_FINAL: $(ET_OPENSBI_TARGET_FINAL)\n"
endef

define opensbi-update
	$(call opensbi-clean)
	$(call opensbi)
endef

define opensbi
	$(call opensbi-depends)
	@$(ET_MAKE) -C $(ET_OPENSBI_SOFTWARE_DIR) \
		O=$(ET_OPENSBI_BUILD_DIR) \
		CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		FW_TEXT_START=0x40000000 \
		FW_OPTIONS=0 \
		FW_DYNAMIC=y \
		PLATFORM=generic \
		PLATFORM_RISCV_XLEN=64 \
		$1
	@if [ -z "$1" ]; then \
		if ! [ -f $(ET_OPENSBI_TARGET_FINAL) ]; then \
			exit 2; \
		fi; \
	fi
	@if [ "clean" = "$1" ]; then \
		$(RM) -v $(ET_OPENSBI_TARGET_FINAL); \
		$(RM) -v $(ET_OPENSBI_BUILD_CONFIG); \
	fi
endef

.PHONY: opensbi
opensbi: $(ET_OPENSBI_TARGET_FINAL)
$(ET_OPENSBI_TARGET_FINAL): $(ET_OPENSBI_BUILD_CONFIG)
	$(call opensbi)

.PHONY: opensbi-config
opensbi-config: $(ET_OPENSBI_BUILD_CONFIG)
$(ET_OPENSBI_BUILD_CONFIG):
ifeq (CONFIGURE,$(shell test -f $(ET_OPENSBI_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"))
	$(call $@)
endif

opensbi-%: $(ET_OPENSBI_BUILD_CONFIG)
	$(call opensbi-$(*F))

opensbi-build-%: $(ET_OPENSBI_BUILD_CONFIG)
	$(call opensbi,$(*F))

endif
# opensbi in list

endif
# ET_BOARD_BIOS_REQUIRED
