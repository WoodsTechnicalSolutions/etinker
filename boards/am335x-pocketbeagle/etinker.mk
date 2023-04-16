#
# AM335X PocketBeagle, ARM Cortex-A8, board configuration file for 'etinker'
#
# Copyright (C) 2018-2023, Derald D. Woods <woods.technical@gmail.com>
#
# [ Linux kernel commit (047905376a16dd7235fced6ecf4020046f9665e9) ]
# ----------------------------------------------------------------------
# ARM: dts: Add am335x-pocketbeagle
#
# PocketBeagle is an ultra-tiny-yet-complete open-source USB-key-fob computer.
#
# This board family can be indentified by the A335PBGL in the at24 eeprom:
# A2: [aa 55 33 ee 41 33 33 35  50 42 47 4c 30 30 41 32 |.U3.A335PBGL00A2|]
#
# [references]
# ----------------------------------------------------------------------
# http://beagleboard.org/pocket
# https://github.com/beagleboard/pocketbeagle
# https://eewiki.net/display/linuxonarm/PocketBeagle
# https://github.com/u-boot/u-boot/blob/master/configs/am335x_evm_defconfig
# https://github.com/u-boot/u-boot/blob/master/arch/arm/dts/am335x-pocketbeagle.dts
# https://github.com/torvalds/linux/blob/master/arch/arm/configs/omap2plus_defconfig
# https://github.com/torvalds/linux/blob/master/arch/arm/boot/dts/am335x-pocketbeagle.dts
# ----------------------------------------------------------------------
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
ET_BOARD_BOOTLOADER_TREE ?= u-boot
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS0

ET_BOARD_KERNEL_DT ?= am335x-pocketbeagle

ET_BOARD_BOOTLOADER_DT ?= am335x-pocketbeagle
