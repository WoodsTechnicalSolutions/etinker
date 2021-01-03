#
# AML-S905X-CC, ARM Cortex-A53, board configuration file for 'etinker'
#
# [references]
# ------------------------------------------------------------------------------
# https://libre.computer/products/boards/aml-s905x-cc/
# https://github.com/u-boot/u-boot/blob/master/configs/libretech-cc_defconfig
# https://github.com/u-boot/u-boot/blob/master/arch/arm/dts/meson-gxl-s905x-libretech-cc.dts
# https://github.com/torvalds/linux/blob/master/arch/arm64/configs/defconfig
# https://github.com/torvalds/linux/blob/master/arch/arm64/boot/dts/amlogic/meson-gxl-s905x-libretech-cc.dts
# ------------------------------------------------------------------------------
#
# Copyright (C) 2020-2021 Derald D. Woods
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

export ET_BOARD_TYPE := meson-rt

ET_BOARD_ALIAS ?= aml-s905x-cc

ET_BOARD_TOOLCHAIN_TYPE ?= meson
ET_BOARD_BOOTLOADER_TYPE ?= meson
ET_BOARD_ROOTFS_TYPE ?= meson

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux-rt
ET_BOARD_BOOTLOADER_TREE ?= u-boot
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyAML0

ET_BOARD_KERNEL_DT ?= meson-gxl-s905x-libretech-cc
