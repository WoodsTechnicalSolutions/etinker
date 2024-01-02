#
# arm-cortexa8-linux-gnueabihf toolchain configuration file for 'etinker'
#
# Copyright (C) 2021-2024, Derald D. Woods <woods.technical@gmail.com>
#
# This file is made available under the Creative Commons CC0 1.0
# Universal Public Domain Dedication.
#
# The person who associated a work with this deed has dedicated
# the work to the public domain by waiving all of his or her rights
# to the work worldwide under copyright law, including all related
# and neighboring rights, to the extent allowed by law. You can copy,
# modify, distribute and perform the work, even for commercial purposes,
# all without asking permission.
#
# The board configs are intended to be adapted for use with your project,
# which may be proprietary.  So unlike the project itself, they are
# licensed Public Domain.
#

ET_BOARD_ARCH ?= arm
ET_BOARD_VENDOR ?= cortexa8
ET_BOARD_OS ?= linux
ET_BOARD_ABI ?= gnueabihf
ET_BOARD_CROSS_TUPLE := $(ET_BOARD_ARCH)-$(ET_BOARD_VENDOR)-$(ET_BOARD_OS)-$(ET_BOARD_ABI)

ET_BOARD_TOOLCHAIN_TREE := crosstool-ng

# final item built for the configured toolchain
ET_TOOLCHAIN_TARGET_FINAL := \
	$(ET_DIR)/toolchain/$(ET_BOARD_CROSS_TUPLE)/$(ET_BOARD_CROSS_TUPLE)/debug-root/usr/bin/strace

ifeq ($(ET_BOARD),$(ET_BOARD_CROSS_TUPLE))
export ET_BOARD_TYPE := $(ET_BOARD_CROSS_TUPLE)
endif

export CT_KERNEL = linux
