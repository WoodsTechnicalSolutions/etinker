#
# x86_64-pc-linux-gnu toolchain configuration file for 'etinker'
#
# NOTE: This is just a wrapper for the host OS toolchain [Arch Linux]
#
# Copyright (C) 2021-2023, Derald D. Woods <woods.technical@gmail.com>
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

ET_BOARD_ARCH ?= x86_64
ET_BOARD_VENDOR ?= $(ET_HOST_OS_ID)
ET_BOARD_OS ?= linux
ET_BOARD_ABI ?= gnu
ET_BOARD_CROSS_TUPLE := $(ET_BOARD_ARCH)-pc-$(ET_BOARD_OS)-$(ET_BOARD_ABI)

ifeq ($(shell which $(ET_BOARD_CROSS_TUPLE)-gcc 2> /dev/null),)
$(error [ ET_BOARD=$(ET_BOARD) requires desktop compiler $(ET_BOARD_CROSS_TUPLE)-gcc ] ***)
endif

ifeq ($(ET_BOARD),$(ET_BOARD_CROSS_TUPLE))
export ET_BOARD_TYPE := $(ET_BOARD_CROSS_TUPLE)
endif

export CT_KERNEL = linux
