#
# This is the GNU Makefile for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Platform, and is made
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
export ET_CROSS_COMPILE := $(ET_BOARD_CROSS_COMPILE)

export ET_PATCH_DIR := $(ET_DIR)/patches
export ET_SOFTWARE_DIR := $(ET_DIR)/software
export ET_TARBALLS_DIR := $(ET_DIR)/tarballs
export ET_CONFIG_DIR := $(ET_DIR)/boards/$(ET_BOARD)/config
export ET_TOOLCHAIN_DIR := $(ET_DIR)/toolchain/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_BUILD_DIR := $(ET_DIR)/toolchain/build/$(ET_CROSS_TUPLE)

export PATH := $(ET_TOOLCHAIN_DIR)/bin:$(PATH)

.PHONY: all
all: toolchain

# embedded toolchains (GCC, GDB, and LIBC) are built using crosstool-NG

ET_TOOLCHAIN_TARGETS_FINAL ?= \
	$(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gcc \
	$(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gdb
ET_TOOLCHAIN_GENERATOR_DIR := $(ET_DIR)/toolchain/generator
ET_TOOLCHAIN_GENERATOR := $(ET_TOOLCHAIN_GENERATOR_DIR)/ct-ng
ET_TOOLCHAIN_CONFIG := $(ET_CONFIG_DIR)/crosstool-ng/config
ET_TOOLCHAIN_BUILD_CONFIG := $(ET_TOOLCHAIN_BUILD_DIR)/.config

.PHONY: toolchain
toolchain: $(ET_TOOLCHAIN_TARGETS_FINAL)
$(ET_TOOLCHAIN_TARGETS_FINAL):
	$(MAKE) toolchain-build

toolchain-%: $(ET_TOOLCHAIN_BUILD_CONFIG)
	@mkdir -p $(ET_TOOLCHAIN_BUILD_DIR)
	@(cd $(ET_TOOLCHAIN_BUILD_DIR) && CT_ARCH=$(ET_ARCH) $(ET_TOOLCHAIN_GENERATOR) $(*F))
	@tail -n +5 $< > $(ET_TOOLCHAIN_CONFIG)

.PHONY: toolchain-config
toolchain-config: $(ET_TOOLCHAIN_BUILD_CONFIG)
$(ET_TOOLCHAIN_BUILD_CONFIG): $(ET_TOOLCHAIN_CONFIG)
	@mkdir -p $(ET_TARBALLS_DIR)
	@mkdir -p $(ET_TOOLCHAIN_BUILD_DIR)
	@cat $< > $@
	@$(MAKE) toolchain-generator
	@$(MAKE) toolchain-oldconfig

.PHONY: toolchain-generator
toolchain-generator: $(ET_TOOLCHAIN_GENERATOR)
$(ET_TOOLCHAIN_GENERATOR):
	@if ! [ -d $(ET_TOOLCHAIN_GENERATOR_DIR) ]; then \
		mkdir -p $(ET_DIR)/toolchain; \
		cp -a $(ET_SOFTWARE_DIR)/crosstool-ng $(ET_TOOLCHAIN_GENERATOR_DIR); \
	fi
	@(cd $(ET_TOOLCHAIN_GENERATOR_DIR); \
		if ! [ -f .patched ]; then \
			for f in $(shell ls $(ET_PATCH_DIR)/crosstool-ng/*.patch); do \
				patch -p1 < $$f; \
			done; \
			touch .patched; \
		fi; \
		./bootstrap; \
		./configure --enable-local; \
		sed -i s,-dirty,, Makefile; \
		$(MAKE))
	@if ! [ -f $@ ]; then \
		printf "***** crosstool-NG 'ct-ng' build FAILED! *****\n"; \
		exit 2; \
	fi

.PHONY: clean
clean:
	@$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/src $(ET_TOOLCHAIN_BUILD_DIR)/$(ET_CROSS_TUPLE)

.PHONY: purge
purge:
	@$(RM) -r $(ET_TOOLCHAIN_DIR)
	@$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)
	@$(RM) -r $(ET_TOOLCHAIN_GENERATOR_DIR)
