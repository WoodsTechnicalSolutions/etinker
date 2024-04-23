#
# TI K3 SoC's Arm Cortex-R5 MCU configuration file for 'etinker'
#
# Copyright (C) 2024, Derald D. Woods <woods.technical@gmail.com>
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

export ET_BOARD_TYPE := k3-r5

ET_BOARD_TOOLCHAIN_TYPE ?= arm-cortexr5-eabihf

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_BOOTLOADER_TREE ?= u-boot$(ET_BOOTLOADER_VARIANT)

ET_BOARD_BOOTLOADER_DT ?= k3-$(TI_K3_SOC)-r5-common-proc-board

ifeq ("$(ET_BOOTLOADER_VARIANT)","-ti")
# fixup bootloader version
export USE_BOOTLOADER_TREE_VERSION := $(ET_BOOTLOADER_VARIANT)
endif
