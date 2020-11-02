#
# Xilinx Zynq 7000, ARM Cortex-A9, board configuration file for 'etinker'
#
# Copyright (C) 2019 Derald D. Woods
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

ifeq ($(ET_BOARD),zynq)
$(error [ 'etinker' board 'zynq' is virtual ] ***)
endif

ifndef ET_BOARD_TYPE
$(error [ ET_BOARD_TYPE is undefined ] ***)
endif

ifneq ($(ET_BOARD_TYPE),zynq)
$(error [ ET_BOARD_TYPE is NOT 'zynq' ] ***)
endif

ET_BOARD_ARCH ?= arm
ET_BOARD_VENDOR ?= cortexa9
ET_BOARD_OS ?= linux
ET_BOARD_ABI ?= gnueabihf
ET_BOARD_CROSS_TUPLE := $(ET_BOARD_ARCH)-$(ET_BOARD_VENDOR)-$(ET_BOARD_OS)-$(ET_BOARD_ABI)

ET_BOARD_KERNEL_ARCH := $(ET_BOARD_ARCH)
ET_BOARD_KERNEL_LOADADDR ?= 0x02080000

ET_BOARD_BOOTLOADER_IMAGE ?= u-boot.img
ET_BOARD_BOOTLOADER_SPL_BINARY ?= boot.bin

# final item built for the configured toolchain
ET_TOOLCHAIN_TARGET_FINAL := \
	$(ET_DIR)/toolchain/$(ET_BOARD_CROSS_TUPLE)/$(ET_BOARD_CROSS_TUPLE)/debug-root/usr/bin/strace

export CT_KERNEL = linux
