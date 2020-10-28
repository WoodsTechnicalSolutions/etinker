#
# LS1043ARDB, ARM Cortex-A53, board configuration file for 'etinker'
#
# [references]
# ------------------------------------------------------------------------------
# https://www.nxp.com/design/qoriq-developer-resources/layerscape-ls1043a-reference-design-board:LS1043A-RDB
# https://github.com/u-boot/u-boot/blob/master/configs/ls1046ardb_defconfig
# https://github.com/u-boot/u-boot/blob/master/arch/arm/dts/fsl-ls1043a-rdb.dts
# https://github.com/torvalds/linux/blob/master/arch/arm64/configs/defconfig
# https://github.com/torvalds/linux/blob/master/arch/arm64/boot/dts/freescale/fsl-ls1043a-rdb.dts
# ------------------------------------------------------------------------------
#
# Copyright (C) 2020 Derald D. Woods
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

export ET_BOARD_TYPE := layerscape

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux
ET_BOARD_BOOTLOADER_TREE ?= u-boot-$(ET_BOARD)
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS0

ET_BOARD_KERNEL_DT ?= fsl-ls1043a-rdb

ET_BOARD_KERNEL_LOADADDR ?= 0x80080000
ET_BOARD_KERNEL_DEFCONFIG ?= et_$(subst -,_,$(ET_BOARD_TYPE))_defconfig

ET_BOARD_BOOTLOADER_DEFCONFIG ?= ls1043ardb_defconfig

ifeq ($(ET_USE_DEFCONFIG),yes)
ET_BOARD_DEFCONFIG := et_$(subst -,_,$(ET_BOARD))_defconfig
endif
