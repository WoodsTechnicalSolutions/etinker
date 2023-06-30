#
# FRDM-LS1012A, ARM Cortex-A53, board configuration file for 'etinker'
#
# NOTE: This board is no longer directly supported by NXP in their LSDK tools
#
# Copyright (C) 2021-2023, Derald D. Woods <woods.technical@gmail.com>
#
# [references]
# ------------------------------------------------------------------------------
# https://www.nxp.com/products/no-longer-manufactured/frdm-ls1012a-board:FRDM-LS1012A
# https://github.com/nxp-qoriq/u-boot/blob/integration/configs/ls1012afrdm_qspi_defconfig
# https://github.com/nxp-qoriq/u-boot/blob/integration/arch/arm/dts/fsl-ls1012a-frdm.dts
# https://github.com/nxp-qoriq/linux/blob/linux-5.4/arch/arm64/configs/defconfig
# https://github.com/nxp-qoriq/linux/blob/linux-5.4/arch/arm64/configs/lsdk.config
# https://github.com/nxp-qoriq/linux/blob/linux-5.4/arch/arm64/boot/dts/freescale/fsl-ls1012a-frdm.dts
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

export ET_BOARD_TYPE := layerscape

ET_BOARD_KERNEL_TYPE ?= layerscape-qoriq
ET_BOARD_ROOTFS_TYPE ?= meson
ifeq ($(ET_INITRAMFS),yes)
export ET_ROOTFS_VARIANT := -initramfs
ET_BOARD_ROOTFS_TYPE := meson$(ET_ROOTFS_VARIANT)
endif

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux-qoriq
ET_BOARD_BOOTLOADER_TREE ?= u-boot-qoriq
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS0

ET_BOARD_KERNEL_DT ?= fsl-ls1012a-frdm
ET_BOARD_KERNEL_DT_ETINKER ?= fsl-ls1012a-frdm-etinker

ET_BOARD_BOOTLOADER_DT ?= fsl-ls1012a-frdm-etinker

LSDK_VERSION := LSDK-18.03
LSDK_VERSION_URL := lsdk1803
LSDK_MACHINE := ls1012afrdm
LSDK_BOOTTYPE := qspi
LSDK_FIRMWARE_URL := https://www.nxp.com/lgfiles/sdk/$(LSDK_VERSION_URL)/firmware_$(LSDK_MACHINE)_uboot_$(LSDK_BOOTTYPE)boot.img
LSDK_FIRMWARE_BIN := $(ET_DIR)/software/qoriq/firmware/firmware_$(LSDK_MACHINE)_uboot_$(LSDK_BOOTTYPE)boot-$(LSDK_VERSION_URL).img

# fixup kernel version
export USE_KERNEL_TREE_VERSION := -qoriq
# fixup bootloader version
export USE_BOOTLOADER_TREE_VERSION := -qoriq
