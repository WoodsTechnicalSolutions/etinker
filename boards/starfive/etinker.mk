#
# StarFive, RISC-V 64 bit, board configuration file for 'etinker'
#
# Copyright (C) 2024-2025, Derald D. Woods <woods.technical@gmail.com>
#
# [references]
# ------------------------------------------------------------------------------
# https://www.starfivetech.com/en
# https://github.com/riscv-software-src/opensbi
# https://github.com/riscv-software-src/opensbi/tree/master/platform/generic/starfive
# ------------------------------------------------------------------------------
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

ifeq ($(ET_BOARD),starfive)
$(error [ 'etinker' board 'starfive' is virtual ] ***)
endif

ifndef ET_BOARD_TYPE
$(error [ ET_BOARD_TYPE is undefined ] ***)
endif

ifneq ($(ET_BOARD_TYPE),starfive)
$(error [ ET_BOARD_TYPE is NOT 'starfive' ] ***)
endif

ET_BOARD_DT_PREFIX := starfive/

# Initial architectural BIOS components
ET_BOARD_BIOS_LIST := opensbi

ET_BOARD_KERNEL_ARCH := riscv
ET_BOARD_KERNEL_VENDOR := $(ET_BOARD_DT_PREFIX)
ET_BOARD_KERNEL_LOADADDR ?= 0x82000000

ET_BOARD_BOOTLOADER_IMAGE := u-boot.itb
ET_BOARD_BOOTLOADER_SPL_BINARY ?= u-boot-spl.bin.normal.out

# pull in a board toolchain
ET_BOARD_TOOLCHAIN_TYPE := riscv64-unknown-linux-gnu
include $(ET_DIR)/boards/$(ET_BOARD_TOOLCHAIN_TYPE)/etinker.mk
