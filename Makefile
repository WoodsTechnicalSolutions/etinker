#
# This is the GNU Makefile for 'etinker'.
#
# Copyright (C) 2018-2021 Derald D. Woods
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
	@$(ET_MAKE) -C $(ET_DIR) toolchain
ifdef ET_BOARD_KERNEL_TREE
	@$(ET_MAKE) -C $(ET_DIR) kernel
endif
ifdef ET_BOARD_BOOTLOADER_TREE
	@$(ET_MAKE) -C $(ET_DIR) bootloader
endif
ifdef ET_BOARD_ROOTFS_TREE
	@$(ET_MAKE) -C $(ET_DIR) rootfs
endif
	@$(ET_MAKE) -C $(ET_DIR) library
ifdef ET_BOARD_ROOTFS_TREE
	@$(ET_MAKE) -C $(ET_DIR) overlay
endif

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

# For partitioned and empty SD/MMC devices
.PHONY: sync
sync:
	@$(ET_MAKE) -C $(ET_DIR) rootfs-sync-mmc
	@$(ET_MAKE) -C $(ET_DIR) bootloader-sync-mmc
	@$(ET_MAKE) -C $(ET_DIR) kernel-sync-mmc
	@$(ET_MAKE) -C $(ET_DIR) library-sync-mmc
	@$(ET_MAKE) -C $(ET_DIR) overlay-sync-mmc

.PHONY: update
update: clean sandbox rootfs-update

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
	@printf "ET_PATCH_DIR: $(ET_PATCH_DIR)\n"
	@printf "ET_SCRIPTS_DIR: $(ET_SCRIPTS_DIR)\n"
	@printf "ET_SOFTWARE_DIR: $(ET_SOFTWARE_DIR)\n"
	@printf "ET_TARBALLS_DIR: $(ET_TARBALLS_DIR)\n"
	@printf "ET_BOARD_DIR: $(ET_BOARD_DIR)\n"
	@if [ -n "$(ET_SYSROOT_DIR)" ]; then \
		printf "ET_SYSROOT_DIR: $(ET_SYSROOT_DIR)\n"; \
	fi
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
