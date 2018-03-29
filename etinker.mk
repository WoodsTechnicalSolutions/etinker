#
# This is the GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ET_HOST_OS_ID ?= Ubuntu
ET_HOST_OS_CODENAME ?= bionic
ET_HOST_OS_RELEASE ?= 18.04
ET_HOST_OS_MESSAGE := [ 'etinker' requires $(ET_HOST_OS_ID) $(ET_HOST_OS_CODENAME) $(ET_HOST_OS_RELEASE) ] ***
ifneq ($(shell lsb_release -i|cut -d : -f 2|tr -d '\t'),$(ET_HOST_OS_ID))
$(error $(ET_HOST_OS_MESSAGE))
endif
ifneq ($(shell lsb_release -c|cut -d : -f 2|tr -d '\t'),$(ET_HOST_OS_CODENAME))
$(error $(ET_HOST_OS_MESSAGE))
endif
ifneq ($(shell lsb_release -r|cut -d : -f 2|tr -d '\t'),$(ET_HOST_OS_RELEASE))
$(error $(ET_HOST_OS_MESSAGE))
endif

# export 'etinker' items that get used in other make and shell contexts

export ET_BOARD ?= arm-bare-metal

export ET_DIR ?= $(shell readlink -e $(CURDIR))

# pull in board specific information
include $(ET_DIR)/boards/$(ET_BOARD)/etinker.mk

export ET_ARCH := $(ET_BOARD_ARCH)
export ET_VENDOR := $(ET_BOARD_VENDOR)
export ET_ABI := $(ET_BOARD_ABI)
export ET_CROSS_TUPLE := $(ET_BOARD_CROSS_TUPLE)
export ET_CROSS_COMPILE := $(ET_BOARD_CROSS_TUPLE)-

export ET_PATCH_DIR := $(ET_DIR)/patches
export ET_SOFTWARE_DIR := $(ET_DIR)/software
export ET_TARBALLS_DIR := $(ET_DIR)/tarballs

# all configuration files for a given board are stored here
export ET_CONFIG_DIR ?= $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config

# check for existence of a source tree
define software-check
	@if ! [ -d $(ET_SOFTWARE_DIR)/$(*F) ]; then \
		printf "\n"; \
		printf "*****  MISSING $(ET_SOFTWARE_DIR)/$(*F) DIRECTORY  *****\n"; \
		printf "===>  PLEASE ADD $(ET_SOFTWARE_DIR)/$(*F) SOFTWARE  <===\n"; \
		printf "\n"; \
		exit 2; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] USING $(ET_SOFTWARE_DIR)/$(*F) *****\n\n"
endef

# embedded toolchains (GCC, GDB, and LIBC) are built using crosstool-NG
export ET_TOOLCHAIN_TREE := crosstool-ng
export ET_TOOLCHAIN_VERSION := $(shell cd $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE)/ 2>/dev/null && git describe --tags 2>/dev/null)
export ET_TOOLCHAIN_DIR := $(ET_DIR)/toolchain/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_BUILD_DIR := $(ET_DIR)/toolchain/build/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_TARBALLS_DIR := $(ET_TARBALLS_DIR)/toolchain
export ET_TOOLCHAIN_GENERATOR_DIR := $(ET_DIR)/toolchain/generator
export ET_TOOLCHAIN_GENERATOR := $(ET_TOOLCHAIN_GENERATOR_DIR)/ct-ng
export ET_TOOLCHAIN_CONFIG := $(ET_CONFIG_DIR)/$(ET_TOOLCHAIN_TREE)/config
export ET_TOOLCHAIN_BUILD_CONFIG := $(ET_TOOLCHAIN_BUILD_DIR)/.config
export ET_TOOLCHAIN_TARGETS_FINAL ?= \
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

# allow users to find cross-compiler
export PATH := $(ET_TOOLCHAIN_DIR)/bin:$(PATH)

define etinker-version
	@printf "ET_TOOLCHAIN_VERSION: $(ET_TOOLCHAIN_VERSION)\n"
endef

define etinker-info
	@printf "ET_BOARD: $(ET_BOARD)\n"
	@printf "ET_ARCH: $(ET_ARCH)\n"
	@printf "ET_VENDOR: $(ET_VENDOR)\n"
	@printf "ET_ABI: $(ET_ABI)\n"
	@printf "ET_CROSS_TUPLE: $(ET_CROSS_TUPLE)\n"
	@printf "ET_HOST_OS_ID: $(ET_HOST_OS_ID)\n"
	@printf "ET_HOST_OS_CODENAME: $(ET_HOST_OS_CODENAME)\n"
	@printf "ET_HOST_OS_RELEASE: $(ET_HOST_OS_RELEASE)\n"
	@printf "ET_DIR: $(ET_DIR)\n"
	@printf "ET_PATCH_DIR: $(ET_PATCH_DIR)\n"
	@printf "ET_SOFTWARE_DIR: $(ET_SOFTWARE_DIR)\n"
	@printf "ET_TARBALLS_DIR: $(ET_TARBALLS_DIR)\n"
	@printf "ET_CONFIG_DIR: $(ET_CONFIG_DIR)\n"
	@printf "ET_TOOLCHAIN_TREE: $(ET_TOOLCHAIN_TREE)\n"
	@printf "ET_TOOLCHAIN_VERSION: $(ET_TOOLCHAIN_VERSION)\n"
	@printf "ET_TOOLCHAIN_GENERATOR: $(ET_TOOLCHAIN_GENERATOR)\n"
	@printf "ET_TOOLCHAIN_GENERATOR_DIR: $(ET_TOOLCHAIN_GENERATOR_DIR)\n"
	@printf "ET_TOOLCHAIN_TARBALLS_DIR: $(ET_TOOLCHAIN_TARBALLS_DIR)\n"
	@printf "ET_TOOLCHAIN_DIR: $(ET_TOOLCHAIN_DIR)\n"
	@printf "ET_TOOLCHAIN_BUILD_DIR: $(ET_TOOLCHAIN_BUILD_DIR)\n"
	@printf "ET_TOOLCHAIN_CONFIG: $(ET_TOOLCHAIN_CONFIG)\n"
	@printf "ET_TOOLCHAIN_BUILD_CONFIG: $(ET_TOOLCHAIN_BUILD_CONFIG)\n"
	@printf "ET_TOOLCHAIN_TARGETS_FINAL: $(ET_TOOLCHAIN_TARGETS_FINAL)\n"
	@printf "PATH: $(PATH)\n"
endef
