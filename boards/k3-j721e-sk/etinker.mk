#
# SK-TDA4VM, ARM Cortex-A72, board configuration file for 'etinker'
#
# Copyright (C) 2023-2025, Derald D. Woods <woods.technical@gmail.com>
#
# [references]
# ------------------------------------------------------------------------------
# https://www.ti.com/tool/SK-TDA4VM
# https://gitlab.com/u-boot/u-boot/blob/master/configs/j721e_evm_r5_defconfig
# https://gitlab.com/u-boot/u-boot/blob/master/configs/j721e_evm_a72_defconfig
# https://gitlab.com/u-boot/u-boot/-/tree/master/board/ti/j721e
# https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/boot/dts/ti/k3-j721e-mcu-wakeup.dtsi
# https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/boot/dts/ti/k3-j721e-main.dtsi
# https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/boot/dts/ti/k3-j721e.dtsi
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

export TI_K3_SOC := j721e
export TI_K3_SOC_TYPE := gp
export TI_K3_FW_TYPE := ti-fs
export TI_ARM64_CROSS_TUPLE := aarch64-cortexa72-linux-gnu

export ET_BOARD_TYPE := k3

ET_BOARD_TOOLCHAIN_TYPE ?= $(TI_ARM64_CROSS_TUPLE)

# BIOS components
ET_BOARD_BIOS_LIST := k3-$(TI_K3_SOC)-r5-sk

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux$(ET_KERNEL_VARIANT)
ET_BOARD_BOOTLOADER_TREE ?= u-boot$(ET_BOOTLOADER_VARIANT)
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS2

ET_BOARD_KERNEL_DT ?= k3-$(TI_K3_SOC)-sk

ifeq ($(ET_BOOTLOADER_VARIANT),-ti)
ET_BOARD_DT_PREFIX :=
unexport ET_BOARD_DT_PREFIX
endif
ET_BOARD_BOOTLOADER_DT ?= $(ET_BOARD_DT_PREFIX)k3-$(TI_K3_SOC)-sk

ifdef ET_KERNEL_VARIANT
# fixup kernel version
ifeq (no,$(shell [ "-rt" = "$(ET_KERNEL_VARIANT)" ] && echo rt || echo no))
export USE_KERNEL_TREE_VERSION := $(ET_KERNEL_VARIANT)
endif
endif

ifdef ET_BOOTLOADER_VARIANT
# fixup bootloader version
export USE_BOOTLOADER_TREE_VERSION := $(ET_BOOTLOADER_VARIANT)
endif
