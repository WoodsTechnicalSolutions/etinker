#
# sama5d3-xpld, ARM Cortex-A5, board configuration file for 'etinker'
#
# Copyright (C) 2018-2024, Derald D. Woods <woods.technical@gmail.com>
#
# [references]
# ------------------------------------------------------------------------------
# https://www.microchip.com/wwwproducts/en/ATSAMA5D36
# https://www.microchip.com/DevelopmentTools/ProductDetails/PartNO/ATSAMA5D3-XPLD
# https://github.com/u-boot/u-boot/blob/master/configs/sama5d3_xplained_mmc_defconfig
# https://github.com/u-boot/u-boot/blob/master/arch/arm/dts/at91-sama5d3_xplained.dts
# https://github.com/torvalds/linux/blob/master/arch/arm/configs/sama5_defconfig
# https://github.com/torvalds/linux/blob/master/arch/arm/boot/dts/at91-sama5d3_xplained.dts
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

export ET_BOARD_TYPE := sama5

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux$(ET_KERNEL_VARIANT)
ET_BOARD_BOOTLOADER_TREE ?= u-boot$(ET_BOOTLOADER_VARIANT)
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS0

ET_BOARD_KERNEL_DT ?= at91-sama5d3_xplained

ET_BOARD_BOOTLOADER_DT ?= at91-sama5d3_xplained
