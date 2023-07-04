#
# This is the GNU Makefile for 'etinker'.
#
# Copyright (C) 2018-2023, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

.PHONY: all
all:
	$(error USAGE: 'ET_BOARD=<board> make sandbox' ***)

include etinker.mk

.PHONY: sandbox
sandbox:
	$(call toolchain-all)
	$(call kernel-all)
	$(call bootloader-all)
	$(call rootfs-all)
	$(call library-all)
	$(call overlay-all)
	$(call rootfs-update)

.PHONY: software
software:
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)
	$(call rootfs-$@)
	$(call overlay-$@)

.PHONY: version
version:
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)
	$(call rootfs-$@)
	$(call library-$@)
	$(call overlay-$@)

.PHONY: clean
clean:
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)
	$(call rootfs-$@)
	$(call library-$@)
	$(call overlay-$@)

.PHONY: purge
purge:
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)
	$(call rootfs-$@)
	$(call library-$@)
	$(call overlay-$@)

.PHONY: update
update:
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)
	$(call rootfs-$@)
	$(call library-$@)
	$(call overlay-$@)
	$(call rootfs-$@)

.PHONY: sync
sync:
	$(call rootfs-sync,mmc)
	$(call bootloader-sync,mmc)
	$(call kernel-sync,mmc)
	$(call library-sync,mmc)
	$(call overlay-sync,mmc)

.PHONY: info
info:
	@printf "========================================================================\n"
	@printf "ET_BOARD: $(ET_BOARD)\n"
	@printf "ET_BOARD_TYPE: $(ET_BOARD_TYPE)\n"
	@if [ -n "$(ET_BOARD_MCU)" ]; then \
		printf "ET_BOARD_MCU: $(ET_BOARD_MCU)\n"; \
	fi
	@printf "ET_ARCH: $(ET_ARCH)\n"
	@printf "ET_VENDOR: $(ET_VENDOR)\n"
	@if [ -n "$(ET_OS)" ]; then \
		printf "ET_OS: $(ET_OS)\n"; \
	fi
	@printf "ET_ABI: $(ET_ABI)\n"
	@printf "ET_CROSS_TUPLE: $(ET_CROSS_TUPLE)\n"
	@printf "ET_HOST_OS_ID: $(ET_HOST_OS_ID)\n"
	@printf "ET_HOST_OS_CODENAME: $(ET_HOST_OS_CODENAME)\n"
	@printf "ET_HOST_OS_RELEASE: $(ET_HOST_OS_RELEASE)\n"
	@printf "ET_CLEAN: $(ET_CLEAN)\n"
	@printf "ET_PURGE: $(ET_PURGE)\n"
	@printf "ET_CPUS: $(ET_CPUS) [ make -j $(ET_CPUS) ]\n"
	@printf "ET_DIR: $(ET_DIR)\n"
	@printf "ET_BOARD_DIR: $(ET_BOARD_DIR)\n"
	@printf "ET_PATCH_DIR: $(ET_PATCH_DIR)\n"
	@printf "ET_SCRIPTS_DIR: $(ET_SCRIPTS_DIR)\n"
	@printf "ET_SOFTWARE_DIR: $(ET_SOFTWARE_DIR)\n"
	@printf "ET_TARBALLS_DIR: $(ET_TARBALLS_DIR)\n"
	@if [ -n "$(ET_CUSTOM_DIR)" ]; then \
		printf "ET_CUSTOM_DIR: $(ET_CUSTOM_DIR)\n"; \
	fi
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)
	$(call rootfs-$@)
	$(call library-$@)
	$(call overlay-$@)
	@printf "========================================================================\n"
	@printf "PATH: $(PATH)\n"
	@printf "========================================================================\n"
