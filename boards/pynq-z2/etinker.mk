#
# PYNQ-Z2, ARM Cortex-A9, board configuration file for 'etinker'
#
# [references]
# ------------------------------------------------------------------------------
# http://www.tul.com.tw/ProductsPYNQ-Z2.html
# https://github.com/Xilinx/PYNQ/tree/master/boards/Pynq-Z2
# https://github.com/WoodsTechnicalSolutions/pynq-z2
# https://github.com/WoodsTechnicalSolutions/pynq-z2/blob/master/dts/linux/zynq-pynq-z2.dts
# https://github.com/WoodsTechnicalSolutions/pynq-z2/blob/master/dts/u-boot/zynq-pynq-z2.dts
# https://github.com/u-boot/u-boot/blob/master/configs/xilinx_zynq_virt_defconfig
# ------------------------------------------------------------------------------
#
# Copyright (C) 2019-2025, Derald D. Woods <woods.technical@gmail.com>
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

export ET_BOARD_TYPE := zynq

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux$(ET_KERNEL_VARIANT)
ET_BOARD_BOOTLOADER_TREE ?= u-boot
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyPS0

ET_BOARD_KERNEL_DT ?= zynq-pynq-z2

ET_BOARD_BOOTLOADER_DT ?= zynq-pynq-z2

ifdef ET_KERNEL_VARIANT
# fixup kernel version
export USE_KERNEL_TREE_VERSION := $(ET_KERNEL_VARIANT)
endif

ifdef ET_BOOTLOADER_VARIANT
	export ET_BOOTLOADER_VARIANT :=
endif
