#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

# embedded toolchain (GCC, GDB, and LIBC) is built using crosstool-NG
export ET_TOOLCHAIN_TREE := $(ET_BOARD_TOOLCHAIN_TREE)
export ET_TOOLCHAIN_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE)
toolchain_version = $(shell cd $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE)/ 2>/dev/null && git describe --tags 2>/dev/null)
export ET_TOOLCHAIN_VERSION := $(shell printf "%s" $(toolchain_version) | sed s,crosstool-ng-,,)
export ET_TOOLCHAIN_DIR := $(ET_DIR)/toolchain/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_BUILD_DIR := $(ET_DIR)/toolchain/build/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_TARBALLS_DIR := $(ET_TARBALLS_DIR)/toolchain
export ET_TOOLCHAIN_GENERATOR_DIR := $(ET_DIR)/toolchain/generator
export ET_TOOLCHAIN_GENERATOR := $(ET_TOOLCHAIN_GENERATOR_DIR)/bin/ct-ng
export ET_TOOLCHAIN_CONFIG := $(ET_CONFIG_DIR)/$(ET_TOOLCHAIN_TREE)/config
export ET_TOOLCHAIN_BUILD_CONFIG := $(ET_TOOLCHAIN_BUILD_DIR)/.config
export ET_TOOLCHAIN_TARGET_FINAL ?= $(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gdb

define toolchain-version
	@printf "ET_TOOLCHAIN_VERSION: $(ET_TOOLCHAIN_VERSION)\n"
endef

define toolchain-depends
	@mkdir -p $(ET_TOOLCHAIN_TARBALLS_DIR)
	@mkdir -p $(ET_TOOLCHAIN_BUILD_DIR)
endef

define toolchain-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_TOOLCHAIN_TREE) $(ET_TOOLCHAIN_VERSION) *****\n\n"
	$(call toolchain-depends)
	@if ! [ -f $(ET_TOOLCHAIN_BUILD_CONFIG) ] && [ -f $(ET_TOOLCHAIN_CONFIG) ]; then \
		rsync $(ET_TOOLCHAIN_CONFIG) $(ET_TOOLCHAIN_BUILD_CONFIG); \
	fi
	$(call toolchain-build,build)
	@if ! [ -f $(ET_TOOLCHAIN_TARGET_FINAL) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_TOOLCHAIN_TREE) build FAILED! *****\n"; \
		exit 2; \
	fi
	@if ! [ -d $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot.cache ]; then \
		if [ -d $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot ]; then \
			cp -a $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot.cache; \
		fi; \
	fi
	@if [ -n "$(shell diff -q $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_TOOLCHAIN_CONFIG) 2> /dev/null)" ]; then \
		rsync $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_TOOLCHAIN_CONFIG); \
	fi
endef

define toolchain-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain 'ct-ng $1' *****\n\n"
	$(call toolchain-depends)
	@(cd $(ET_TOOLCHAIN_BUILD_DIR) && CT_ARCH=$(ET_ARCH) $(ET_TOOLCHAIN_GENERATOR) $1)
	@if [ -n "$(shell printf "%s" $1 | grep config)" ]; then \
		if [ -f $(ET_TOOLCHAIN_BUILD_CONFIG) ]; then \
			rsync $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_TOOLCHAIN_CONFIG); \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_TOOLCHAIN_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
	fi
	@if [ -n "$(shell printf "%s" $1 | grep clean)" ]; then \
		$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/src; \
		$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/$(ET_CROSS_TUPLE); \
	fi
endef

define toolchain-config
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-config *****\n\n"
	$(call toolchain-depends)
	@if ! [ -f $(ET_TOOLCHAIN_CONFIG) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-config FAILED! *****\n"; \
		exit 2; \
	fi
	@rsync $(ET_TOOLCHAIN_CONFIG) $(ET_TOOLCHAIN_BUILD_CONFIG)
endef

define toolchain-generator
	$(call software-check,$(ET_TOOLCHAIN_TREE))
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-generator *****\n\n"
	@(cd $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE); \
		$(MAKE) distclean; \
		./bootstrap; \
		./configure --prefix=$(ET_DIR)/toolchain/generator; \
		$(MAKE); \
		$(MAKE) install)
	@if ! [ -f $(ET_TOOLCHAIN_GENERATOR) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-generator FAILED! *****\n"; \
		exit 2; \
	fi
endef

define toolchain-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-clean *****\n\n"
	$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/src
	$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/$(ET_CROSS_TUPLE)
endef

define toolchain-purge
	printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-purge *****\n\n"
	$(RM) -r $(ET_TOOLCHAIN_DIR)
	$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)
	$(RM) -r $(ET_TOOLCHAIN_GENERATOR_DIR)
endef

define toolchain-info
	@printf "========================================================================\n"
	@printf "ET_TOOLCHAIN_TREE: $(ET_TOOLCHAIN_TREE)\n"
	@printf "ET_TOOLCHAIN_VERSION: $(ET_TOOLCHAIN_VERSION)\n"
	@printf "ET_TOOLCHAIN_SOFTWARE_DIR: $(ET_TOOLCHAIN_SOFTWARE_DIR)\n"
	@printf "ET_TOOLCHAIN_GENERATOR: $(ET_TOOLCHAIN_GENERATOR)\n"
	@printf "ET_TOOLCHAIN_GENERATOR_DIR: $(ET_TOOLCHAIN_GENERATOR_DIR)\n"
	@printf "ET_TOOLCHAIN_TARBALLS_DIR: $(ET_TOOLCHAIN_TARBALLS_DIR)\n"
	@printf "ET_TOOLCHAIN_CONFIG: $(ET_TOOLCHAIN_CONFIG)\n"
	@printf "ET_TOOLCHAIN_BUILD_CONFIG: $(ET_TOOLCHAIN_BUILD_CONFIG)\n"
	@printf "ET_TOOLCHAIN_BUILD_DIR: $(ET_TOOLCHAIN_BUILD_DIR)\n"
	@printf "ET_TOOLCHAIN_DIR: $(ET_TOOLCHAIN_DIR)\n"
	@printf "ET_TOOLCHAIN_TARGET_FINAL: $(ET_TOOLCHAIN_TARGET_FINAL)\n"
endef

.PHONY: toolchain
toolchain: $(ET_TOOLCHAIN_TARGET_FINAL)
$(ET_TOOLCHAIN_TARGET_FINAL): $(ET_TOOLCHAIN_BUILD_CONFIG)
	$(call toolchain-targets)

toolchain-%: $(ET_TOOLCHAIN_BUILD_CONFIG)
	$(call toolchain-build,$(*F))

.PHONY: toolchain-config
toolchain-config: $(ET_TOOLCHAIN_BUILD_CONFIG)
$(ET_TOOLCHAIN_BUILD_CONFIG): $(ET_TOOLCHAIN_GENERATOR) $(ET_TOOLCHAIN_CONFIG)
ifeq ($(shell test -f $(ET_TOOLCHAIN_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call toolchain-config)
endif

.PHONY: toolchain-generator
toolchain-generator: $(ET_TOOLCHAIN_GENERATOR)
$(ET_TOOLCHAIN_GENERATOR):
	$(call toolchain-generator)

.PHONY: toolchain-clean
toolchain-clean:
ifeq ($(ET_CLEAN),yes)
	$(call toolchain-build,clean)
endif
	$(call $@)

.PHONY: toolchain-purge
toolchain-purge:
ifeq ($(ET_PURGE),yes)
	$(call $@)
endif

.PHONY: toolchain-version
toolchain-version:
	$(call $@)

.PHONY: toolchain-info
toolchain-info:
	$(call $@)
