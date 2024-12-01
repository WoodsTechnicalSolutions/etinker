#
# StarFive VisionFive2, RISC-V 64 bit, board configuration file for 'etinker'
#
# Copyright (C) 2020-2024, Derald D. Woods <woods.technical@gmail.com>
#
# [references]
# ------------------------------------------------------------------------------
# https://www.starfivetech.com/en/site/soc [JH7110 64bit quad-core]
# https://www.starfivetech.com/en/site/boards [VisionFive2]
# https://docs.u-boot.org/en/latest/board/starfive/visionfive2.html
# https://wiki.debian.org/InstallingDebianOn/StarFive/VisionFiveV2
# https://github.com/u-boot/u-boot/blob/master/configs/starfive_visionfive2_defconfig
# https://github.com/u-boot/u-boot/blob/master/arch/riscv/dts/jh7110-starfive-visionfive-2.dts
# https://github.com/torvalds/linux/blob/master/arch/riscv/configs/defconfig
# https://github.com/torvalds/linux/blob/master/arch/riscv/configs/64-bit.config
# https://github.com/torvalds/linux/blob/master/arch/riscv/boot/dts/starfive/jh7110-starfive-visionfive-2-v1.3b.dts
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

export ET_BOARD_TYPE := starfive

export ET_BOARD_BIOS_REQUIRED := yes

include $(ET_DIR)/boards/$(ET_BOARD_TYPE)/etinker.mk

# Append board specific BIOS components
#ET_BOARD_BIOS_LIST +=

ET_BOARD_TOOLCHAIN_TREE ?= crosstool-ng
ET_BOARD_KERNEL_TREE ?= linux$(ET_KERNEL_VARIANT)
ET_BOARD_BOOTLOADER_TREE ?= u-boot$(ET_BOOTLOADER_VARIANT)
ET_BOARD_ROOTFS_TREE ?= buildroot

ET_BOARD_HOSTNAME ?= $(ET_BOARD)
ET_BOARD_GETTY_PORT ?= ttyS0

ET_BOARD_KERNEL_DT ?= jh7110-starfive-visionfive-2-v1.3b

ET_BOARD_BOOTLOADER_DT ?= jh7110-starfive-visionfive-2
