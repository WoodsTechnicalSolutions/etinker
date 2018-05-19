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

export ET_CPUS := $(shell nproc --all | tr -d \\n)

# pull in board specific information
include $(ET_DIR)/boards/$(ET_BOARD)/etinker.mk

export ET_ARCH := $(ET_BOARD_ARCH)
export ET_VENDOR := $(ET_BOARD_VENDOR)
export ET_ABI := $(ET_BOARD_ABI)
export ET_CROSS_TUPLE := $(ET_BOARD_CROSS_TUPLE)
export ET_CROSS_COMPILE := $(ET_BOARD_CROSS_TUPLE)-
export ET_CROSS_PARAMS := ARCH=$(ET_ARCH) CROSS_COMPILE=$(ET_CROSS_COMPILE)

export ET_PATCH_DIR := $(ET_DIR)/patches
export ET_SOFTWARE_DIR := $(ET_DIR)/software
export ET_TARBALLS_DIR := $(ET_DIR)/tarballs

export ET_SYSROOT_DIR ?= $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot

# all configuration files for a given board are stored here
export ET_CONFIG_DIR ?= $(ET_DIR)/boards/$(ET_BOARD_TYPE)/config

# pull in etinker component information
include $(ET_DIR)/software.mk
include $(ET_DIR)/toolchain.mk
ifdef ET_BOARD_KERNEL_TREE
include $(ET_DIR)/kernel.mk
endif
ifdef ET_BOARD_BOOTLOADER_TREE
include $(ET_DIR)/bootloader.mk
endif

# allow users to find cross-compiler
export PATH := $(ET_TOOLCHAIN_DIR)/bin:$(PATH)

define etinker-version
	@printf "ET_TOOLCHAIN_VERSION: $(ET_TOOLCHAIN_VERSION)\n"
	@if [ -n "$(ET_BOARD_KERNEL_TREE)" ]; then \
		printf "ET_KERNEL_VERSION: $(ET_KERNEL_VERSION)\n"; \
		printf "ET_KERNEL_LOCALVERSION: $(ET_KERNEL_LOCALVERSION)\n"; \
	fi
	@if [ -n "$(ET_BOARD_BOOTLOADER_TREE)" ]; then \
		printf "ET_BOOTLOADER_VERSION: $(ET_BOOTLOADER_VERSION)\n"; \
	fi
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
	$(call toolchain-info)
	$(call kernel-info)
	$(call bootloader-info)
	@printf "PATH: $(PATH)\n"
endef
