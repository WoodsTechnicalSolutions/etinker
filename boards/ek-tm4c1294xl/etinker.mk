#
# ek-tm4c1294xl, ARM Cortex-M4F, board configuration file for 'etinker'
#
# Copyright (C) 2018-2021 Derald D. Woods
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

export ET_BOARD_TYPE := $(ET_BOARD)

export ET_BOARD_MCU := tm4c1294ncpdt

ET_BOARD_ARCH ?= arm
ET_BOARD_VENDOR ?= none
ET_BOARD_ABI ?= eabihf
ET_BOARD_CROSS_TUPLE := $(ET_BOARD_ARCH)-$(ET_BOARD_VENDOR)-$(ET_BOARD_ABI)

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng

ET_BOARD_TOOLCHAIN_TYPE ?= ek-tm4c123gxl

export CT_KERNEL = bare-metal
