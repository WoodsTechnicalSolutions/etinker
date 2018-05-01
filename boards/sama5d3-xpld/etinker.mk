#
# sama5d3-xpld, ARM Cortex-A5, board configuration file for 'etinker'
#
# Copyright (C) 2018 Derald D. Woods
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

ET_BOARD_TYPE := $(ET_BOARD)

ET_BOARD_ARCH ?= arm
ET_BOARD_VENDOR ?= cortexa5
ET_BOARD_OS ?= linux
ET_BOARD_ABI ?= gnueabihf
ET_BOARD_CROSS_TUPLE := $(ET_BOARD_ARCH)-$(ET_BOARD_VENDOR)-$(ET_BOARD_OS)-$(ET_BOARD_ABI)

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux
ET_BOARD_BOOTLOADER_TREE ?= u-boot

ET_BOARD_KERNEL_DT ?= at91-sama5d3_xplained

ET_BOARD_KERNEL_LOADADDR ?= 0x22000000

ET_BOARD_BOOTLOADER_SPL_BINARY := boot.bin
ET_BOARD_BOOTLOADER_DEFCONFIG := sama5d3_xplained_mmc_defconfig 

# final item built for the configured toolchain
ET_TOOLCHAIN_TARGET_FINAL := \
	$(ET_DIR)/toolchain/$(ET_BOARD_CROSS_TUPLE)/$(ET_BOARD_CROSS_TUPLE)/debug-root/usr/bin/strace

export CT_KERNEL = linux
