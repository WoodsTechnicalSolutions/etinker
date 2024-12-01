#
# riscv64-unknown-linux-gnu toolchain configuration file for 'etinker'
#
# Copyright (C) 2024, Derald D. Woods <woods.technical@gmail.com>
#
# [references]
# ------------------------------------------------------------------------------
# https://riscv.org/
# https://github.com/riscv
# https://en.wikipedia.org/wiki/RISC-V
# https://www.starfivetech.com/en/site/soc [JH7110 64bit quad-core]
# https://www.starfivetech.com/en/site/boards [VisionFive2]
# https://github.com/riscv-collab/riscv-gnu-toolchain
# https://readthedocs.org/projects/risc-v-getting-started-guide/downloads/pdf/latest/
# https://wiki.debian.org/RISC-V
# https://wiki.debian.org/InstallingDebianOn/StarFive/VisionFiveV2
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

ET_BOARD_ARCH ?= riscv
ET_BOARD_ARCH_EXT ?= 64
ET_BOARD_VENDOR ?= unknown
ET_BOARD_OS ?= linux
ET_BOARD_ABI ?= gnu
ET_BOARD_CROSS_TUPLE := $(ET_BOARD_ARCH)$(ET_BOARD_ARCH_EXT)-$(ET_BOARD_VENDOR)-$(ET_BOARD_OS)-$(ET_BOARD_ABI)

ET_BOARD_TOOLCHAIN_TREE := crosstool-ng

# final item built for the configured toolchain
ET_TOOLCHAIN_TARGET_FINAL := \
	$(ET_DIR)/toolchain/$(ET_BOARD_CROSS_TUPLE)/$(ET_BOARD_CROSS_TUPLE)/debug-root/usr/bin/strace

ifeq ($(ET_BOARD),$(ET_BOARD_CROSS_TUPLE))
export ET_BOARD_TYPE := $(ET_BOARD_CROSS_TUPLE)
endif

export CT_KERNEL = linux
