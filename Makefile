#
# This is the GNU Makefile for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

include etinker.mk

.PHONY: all
all: toolchain

.PHONY: info
info:
	$(call etinker-info)

.PHONY: version
version:
	$(call etinker-version)

.PHONY: toolchain
toolchain: $(ET_TOOLCHAIN_TARGETS_FINAL)
$(ET_TOOLCHAIN_TARGETS_FINAL):
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_TOOLCHAIN_TREE) $(ET_TOOLCHAIN_VERSION) *****\n"
	$(MAKE) toolchain-menuconfig
	$(MAKE) toolchain-build

toolchain-%: $(ET_TOOLCHAIN_BUILD_CONFIG)
	$(call toolchain-build)

.PHONY: toolchain-config
toolchain-config: $(ET_TOOLCHAIN_BUILD_CONFIG)
$(ET_TOOLCHAIN_BUILD_CONFIG): $(ET_TOOLCHAIN_CONFIG)
	$(call toolchain-config)

.PHONY: toolchain-generator
toolchain-generator: $(ET_TOOLCHAIN_GENERATOR)
$(ET_TOOLCHAIN_GENERATOR):
	$(call toolchain-generator)

.PHONY: clean
clean:
	$(call toolchain-$@)

.PHONY: purge
purge:
	$(call toolchain-$@)

software-%:
	$(call software-check)

.PHONY: software-development
software-development:
	$(call software-development)
