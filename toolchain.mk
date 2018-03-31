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
export ET_TOOLCHAIN_VERSION := $(shell cd $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE)/ 2>/dev/null && git describe --tags 2>/dev/null)
export ET_TOOLCHAIN_DIR := $(ET_DIR)/toolchain/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_BUILD_DIR := $(ET_DIR)/toolchain/build/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_TARBALLS_DIR := $(ET_TARBALLS_DIR)/toolchain
export ET_TOOLCHAIN_GENERATOR_DIR := $(ET_DIR)/toolchain/generator
export ET_TOOLCHAIN_GENERATOR := $(ET_TOOLCHAIN_GENERATOR_DIR)/ct-ng
export ET_TOOLCHAIN_CONFIG := $(ET_CONFIG_DIR)/$(ET_TOOLCHAIN_TREE)/config
export ET_TOOLCHAIN_BUILD_CONFIG := $(ET_TOOLCHAIN_BUILD_DIR)/.config
export ET_TOOLCHAIN_TARGETS_FINAL += \
	$(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gcc \
	$(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gdb
define toolchain-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] make toolchain-clean *****\n\n"
	@$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/src
	@$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/$(ET_CROSS_TUPLE)
endef
define toolchain-purge
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] make toolchain-purge *****\n\n"
	@$(RM) -r $(ET_TOOLCHAIN_DIR)
	@$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)
	@$(RM) -r $(ET_TOOLCHAIN_GENERATOR_DIR)
endef
