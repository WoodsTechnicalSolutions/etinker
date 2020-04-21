#
# TI OMAP3 BeagleBoard xM, ARM Cortex-A8, board configuration file for 'etinker'
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

export ET_BOARD_TYPE := omap2plus

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux
ET_BOARD_BOOTLOADER_TREE ?= u-boot-$(ET_BOARD)
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS2

ET_BOARD_KERNEL_DT ?= omap3-beagle-xm

ET_BOARD_KERNEL_LOADADDR ?= 0x82000000
ET_BOARD_KERNEL_DEFCONFIG ?= omap2plus_defconfig
ET_BOARD_KERNEL_DEFCONFIG_CACHED := et_$(subst -,_,$(ET_BOARD_TYPE))_defconfig

ET_BOARD_BOOTLOADER_SPL_BINARY ?= MLO
ET_BOARD_BOOTLOADER_DEFCONFIG ?= omap3_beagle_defconfig
