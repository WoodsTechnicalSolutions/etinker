#
# TI K3 Multicore SoC board configuration file for 'etinker'
#
# Copyright (C) 2023-2024, Derald D. Woods <woods.technical@gmail.com>
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

ifeq ($(ET_BOARD),k3)
$(error [ 'etinker' board 'k3' is virtual ] ***)
endif

ifndef ET_BOARD_TYPE
$(error [ ET_BOARD_TYPE is undefined ] ***)
endif

ifneq ($(ET_BOARD_TYPE),k3)
$(error [ ET_BOARD_TYPE is NOT 'k3' ] ***)
endif

ET_BOARD_DT_PREFIX := ti/

ET_BOARD_KERNEL_ARCH := arm64
ET_BOARD_KERNEL_VENDOR := $(ET_BOARD_DT_PREFIX)
ET_BOARD_KERNEL_LOADADDR ?= 0x08080000

ET_BOARD_BOOTLOADER_IMAGE := u-boot.img
ET_BOARD_BOOTLOADER_SPL_BINARY ?= tispl.bin

# pull in a board toolchain
ET_BOARD_TOOLCHAIN_TYPE ?= aarch64-cortexa53-linux-gnu
include $(ET_DIR)/boards/$(ET_BOARD_TOOLCHAIN_TYPE)/etinker.mk

ET_KERNEL_DEFCONFIG_N := ti_arm64_prune.config
