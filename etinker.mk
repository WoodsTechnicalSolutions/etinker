#
# This is the GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2021 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://elinux.org/Main_Page
# - https://www.gnu.org/software/make
# - https://www.oreilly.com/openbook/make3/book/index.csp
# - https://github.com/WoodsTechnicalSolutions/etinker
#

ET_HOST_OS_ID ?= Ubuntu
ET_HOST_OS_CODENAME ?= focal
ET_HOST_OS_RELEASE ?= 20.04
ET_HOST_OS_MESSAGE := [ 'etinker' requires $(ET_HOST_OS_ID) $(ET_HOST_OS_CODENAME) $(ET_HOST_OS_RELEASE) ] ***
ifneq ($(shell lsb_release -i|cut -f 2|tr -d \\n),$(ET_HOST_OS_ID))
$(error $(ET_HOST_OS_MESSAGE))
endif
ifneq ($(shell lsb_release -c|cut -f 2|tr -d \\n),$(ET_HOST_OS_CODENAME))
$(error $(ET_HOST_OS_MESSAGE))
endif
ifneq ($(shell lsb_release -r|cut -f 2|tr -d \\n),$(ET_HOST_OS_RELEASE))
$(error $(ET_HOST_OS_MESSAGE))
endif

ifndef ET_BOARD
$(info *** [ 'etinker' requires ET_BOARD definition ] ***)
$(info *** [ USAGE: ET_BOARD=<board> make <target>  ] ***)
$(error ABORTING ***)
endif

# export 'etinker' items that get used in other make and shell contexts

export ET_DIR ?= $(shell readlink -e $(CURDIR))

export ET_CPUS := $(shell nproc --all | tr -d \\n)

export ET_TFTP_DIR ?= /srv/tftp

export ET_CLEAN ?= no
export ET_PURGE ?= no
export ET_RELEASE ?= no

# pull in board specific information
include $(ET_DIR)/boards/$(ET_BOARD)/etinker.mk

export ET_ARCH := $(ET_BOARD_ARCH)
export ET_VENDOR := $(ET_BOARD_VENDOR)
export ET_OS := $(ET_BOARD_OS)
export ET_ABI := $(ET_BOARD_ABI)
export ET_CROSS_TUPLE := $(ET_BOARD_CROSS_TUPLE)
export ET_CROSS_COMPILE := $(ET_BOARD_CROSS_TUPLE)-
export ET_CROSS_PARAMS := ARCH=$(ET_ARCH) CROSS_COMPILE=$(ET_CROSS_COMPILE)

export ET_PATCH_DIR := $(ET_DIR)/patches
export ET_SOFTWARE_DIR := $(ET_DIR)/software
export ET_TARBALLS_DIR := $(ET_DIR)/tarballs
export ET_SCRIPTS_DIR := $(ET_DIR)/scripts
export ET_CUSTOM_DIR :=

export ET_BOARD_DIR ?= $(ET_DIR)/boards/$(ET_BOARD)

# pull in etinker component information
include $(ET_DIR)/software.mk
include $(ET_DIR)/toolchain.mk
ifdef ET_BOARD_KERNEL_TREE
export ET_SYSROOT_DIR ?= $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot
include $(ET_DIR)/kernel.mk
endif
ifdef ET_BOARD_BOOTLOADER_TREE
include $(ET_DIR)/bootloader.mk
endif
ifdef ET_BOARD_ROOTFS_TREE
include $(ET_DIR)/rootfs.mk
include $(ET_DIR)/overlay.mk
endif

# allow users to find cross-compiler
export PATH := $(ET_TOOLCHAIN_DIR)/bin:$(PATH)
