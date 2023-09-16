#
# Xilinx Zynq 7000, ARM Cortex-A9, board configuration file for 'etinker'
#
# Copyright (C) 2019-2023, Derald D. Woods <woods.technical@gmail.com>
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

ifeq ($(ET_BOARD),zynq)
$(error [ 'etinker' board 'zynq' is virtual ] ***)
endif

ifndef ET_BOARD_TYPE
$(error [ ET_BOARD_TYPE is undefined ] ***)
endif

ifneq ($(ET_BOARD_TYPE),zynq)
$(error [ ET_BOARD_TYPE is NOT 'zynq' ] ***)
endif

ifeq ($(shell test -d $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/sdk || echo missing),missing)
$(error [ Zynq FPGA build is missing! ( $(ET_DIR)/boards/$(ET_BOARD_TYPE)/fpga/sdk ) ] ***)
endif

ET_BOARD_KERNEL_ARCH := arm
ET_BOARD_KERNEL_VENDOR := xilinx/
ET_BOARD_KERNEL_LOADADDR ?= 0x02080000

ET_BOARD_BOOTLOADER_IMAGE ?= u-boot.img
ET_BOARD_BOOTLOADER_SPL_BINARY ?= boot.bin

# pull in a board toolchain
ET_BOARD_TOOLCHAIN_TYPE := arm-cortexa9-linux-gnueabihf
include $(ET_DIR)/boards/$(ET_BOARD_TOOLCHAIN_TYPE)/etinker.mk
