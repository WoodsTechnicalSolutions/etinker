#
# nrf52840 USB Dongle, ARM Cortex-M4F, board configuration file for 'etinker'
#
# Copyright (C) 2020-2022 Derald D. Woods
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

export ET_BOARD_MCU := nrf52840
export ET_BOARD_MCU_EXT := _xxaa
export ET_BOARD_MCU_DEFINE := $(shell echo $(ET_BOARD_MCU)$(ET_BOARD_MCU_EXT) | tr '[:lower:]' '[:upper:]')

# pull in a board toolchain
ET_BOARD_TOOLCHAIN_TYPE := arm-none-eabihf
include $(ET_DIR)/boards/$(ET_BOARD_TOOLCHAIN_TYPE)/etinker.mk
