#
# TI AM3517 EVM, ARM Cortex-A8, board configuration file for 'etinker'
#
# Copyright (C) 2018-2021 Derald D. Woods
#
# [references]
# ------------------------------------------------------------------------------
# https://beaconembedded.com/project/am3517-som-m2/
# https://beaconembedded.com/wp-content/uploads/2020/01/1014288E_AM3517_EXP_Brief.pdf
# https://github.com/u-boot/u-boot/blob/master/configs/am3517_evm_defconfig
# https://github.com/u-boot/u-boot/blob/master/arch/arm/dts/am3517-evm.dts
# https://github.com/torvalds/linux/blob/master/arch/arm/configs/omap2plus_defconfig
# https://github.com/torvalds/linux/blob/master/arch/arm/boot/dts/am3517-evm.dts
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

export ET_BOARD_TYPE := omap2plus

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux
ET_BOARD_BOOTLOADER_TREE ?= u-boot
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS2

ET_BOARD_KERNEL_DT ?= am3517-evm
