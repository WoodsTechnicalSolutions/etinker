#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2024-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_BIOS_REQUIRED

export ET_OPENSBI_TREE := opensbi
export ET_OPENSBI_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_OPENSBI_TREE)
export ET_OPENSBI_VERSION := $(shell cd $(ET_OPENSBI_SOFTWARE_DIR) $(ET_NOERR) && git describe --long --dirty $(ET_NOERR))
export ET_OPENSBI_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) opensbi-ref)
export ET_OPENSBI_BUILD_DIR := $(ET_BIOS_BUILD_DIR)/$(ET_OPENSBI_TREE)
export ET_OPENSBI_BUILD_CONFIG := $(ET_OPENSBI_BUILD_DIR)/.configured
export ET_OPENSBI_TARGET_FINAL ?= $(ET_OPENSBI_BUILD_DIR)/platform/generic/firmware/fw_dynamic.bin

export ET_CFLAGS_BOOTLOADER += OPENSBI=$(ET_OPENSBI_TARGET_FINAL)

define opensbi-version
	@printf "ET_OPENSBI_VERSION: \033[0;33m[$(ET_OPENSBI_CACHED_VERSION)]\033[0m $(ET_OPENSBI_VERSION)\n"
endef

define opensbi-software
	$(call software-check,$(ET_OPENSBI_TREE),opensbi,fetch)
endef

define opensbi-depends
	$(call software-check,$(ET_OPENSBI_TREE),opensbi)
	@mkdir -p $(ET_OPENSBI_BUILD_DIR)
endef

define opensbi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
	$(call opensbi-build)
endef

define opensbi-build
	$(call opensbi-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 'make $1' *****\n\n"
	@$(MAKE) -C $(ET_OPENSBI_SOFTWARE_DIR) \
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
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 'make $1' FAILED! *****\n"; \
			exit 2; \
		fi; \
	fi
	@if [ "clean" = "$1" ]; then \
		$(RM) -v $(ET_OPENSBI_TARGET_FINAL); \
		$(RM) -v $(ET_OPENSBI_BUILD_CONFIG); \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 'make $1' done. *****\n\n"
endef

define opensbi-config
	$(call opensbi-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
	@touch $(ET_OPENSBI_BUILD_CONFIG)
endef

define opensbi-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
	$(RM) $(ET_OPENSBI_TARGET_FINAL)
	$(RM) $(ET_OPENSBI_BUILD_CONFIG)
endef

define opensbi-purge
	$(call opensbi-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
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
	@$(ET_MAKE) -C $(ET_DIR) opensbi-clean
	@$(ET_MAKE) -C $(ET_DIR) opensbi
endef

define opensbi-all
	@$(ET_MAKE) -C $(ET_DIR) opensbi
endef

.PHONY: opensbi
opensbi: $(ET_OPENSBI_TARGET_FINAL)
$(ET_OPENSBI_TARGET_FINAL): $(ET_OPENSBI_BUILD_CONFIG)
	$(call opensbi)

opensbi-%: $(ET_OPENSBI_BUILD_CONFIG)
	$(call opensbi-build,$(*F))

.PHONY: opensbi-config
opensbi-config: $(ET_OPENSBI_BUILD_CONFIG)
$(ET_OPENSBI_BUILD_CONFIG):
ifeq ($(shell test -f $(ET_OPENSBI_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call opensbi-config)
endif

.PHONY: opensbi-clean
opensbi-clean:
ifeq ($(ET_CLEAN),yes)
	$(call opensbi-build,clean)
endif
	$(call $@)

.PHONY: opensbi-purge
opensbi-purge:
	$(call $@)

.PHONY: opensbi-version
opensbi-version:
	$(call $@)

.PHONY: opensbi-software
opensbi-software:
	$(call $@)

.PHONY: opensbi-info
opensbi-info:
	$(call $@)

.PHONY: opensbi-update
opensbi-update:
	$(call $@)

endif
# ET_BOARD_BIOS_REQUIRED
