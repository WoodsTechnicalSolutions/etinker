#
# This is the GNU Makefile for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

include etinker.mk

.PHONY: all
all: toolchain kernel bootloader

.PHONY: version
version:
	$(call toolchain-version)
	$(call kernel-version)
	$(call bootloader-version)

.PHONY: toolchain
toolchain: $(ET_TOOLCHAIN_TARGET_FINAL)
$(ET_TOOLCHAIN_TARGET_FINAL):
	$(call toolchain-targets)

toolchain-%: $(ET_TOOLCHAIN_BUILD_CONFIG)
	$(call toolchain-build,$(*F))

.PHONY: toolchain-config
toolchain-config: $(ET_TOOLCHAIN_BUILD_CONFIG)
$(ET_TOOLCHAIN_BUILD_CONFIG): $(ET_TOOLCHAIN_GENERATOR) $(ET_TOOLCHAIN_CONFIG)
	$(call toolchain-config)

.PHONY: toolchain-generator
toolchain-generator: $(ET_TOOLCHAIN_GENERATOR)
$(ET_TOOLCHAIN_GENERATOR):
	$(call toolchain-generator)

.PHONY: toolchain-info
toolchain-info:
	$(call $@)

.PHONY: toolchain-purge
toolchain-purge:
	$(call $@)

.PHONY: toolchain-version
toolchain-version:
	$(call $@)

.PHONY: kernel
kernel: $(ET_KERNEL_TARGET_FINAL)
$(ET_KERNEL_TARGET_FINAL):
	$(call kernel-targets)

kernel-%: $(ET_KERNEL_BUILD_CONFIG)
	$(call kernel-build,$(*F))

.PHONY: kernel-config
kernel-config: $(ET_KERNEL_BUILD_CONFIG)
$(ET_KERNEL_BUILD_CONFIG): $(ET_KERNEL_CONFIG)
	$(call kernel-config)

$(ET_KERNEL_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
	$(call kernel-build,$(ET_KERNEL_DEFCONFIG))

.PHONY: kernel-info
kernel-info:
	$(call $@)

.PHONY: kernel-purge
kernel-purge:
	$(call $@)

.PHONY: kernel-version
kernel-version:
	$(call $@)

.PHONY: bootloader
bootloader: $(ET_BOOTLOADER_TARGET_FINAL)
$(ET_BOOTLOADER_TARGET_FINAL):
	$(call bootloader-targets)

bootloader-%: $(ET_BOOTLOADER_BUILD_CONFIG)
	$(call bootloader-build,$(*F))

.PHONY: bootloader-config
bootloader-config: $(ET_BOOTLOADER_BUILD_CONFIG)
$(ET_BOOTLOADER_BUILD_CONFIG): $(ET_BOOTLOADER_CONFIG)
	$(call bootloader-config)

$(ET_BOOTLOADER_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
	$(call bootloader-build,$(ET_BOOTLOADER_DEFCONFIG))

.PHONY: bootloader-info
bootloader-info:
	$(call $@)

.PHONY: bootloader-purge
bootloader-purge:
	$(call $@)

.PHONY: bootloader-version
bootloader-version:
	$(call $@)

.PHONY: clean
clean:
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)

.PHONY: purge
purge:
	$(call toolchain-$@)
	$(call kernel-$@)
	$(call bootloader-$@)

.PHONY: software-development
software-development:
	$(call $@)

.PHONY: info
info:
	@printf "ET_BOARD: $(ET_BOARD)\n"
	@printf "ET_ARCH: $(ET_ARCH)\n"
	@printf "ET_VENDOR: $(ET_VENDOR)\n"
	@printf "ET_ABI: $(ET_ABI)\n"
	@printf "ET_CROSS_TUPLE: $(ET_CROSS_TUPLE)\n"
	@printf "ET_HOST_OS_ID: $(ET_HOST_OS_ID)\n"
	@printf "ET_HOST_OS_CODENAME: $(ET_HOST_OS_CODENAME)\n"
	@printf "ET_HOST_OS_RELEASE: $(ET_HOST_OS_RELEASE)\n"
	@printf "ET_DIR: $(ET_DIR)\n"
	@printf "ET_PATCH_DIR: $(ET_PATCH_DIR)\n"
	@printf "ET_SOFTWARE_DIR: $(ET_SOFTWARE_DIR)\n"
	@printf "ET_TARBALLS_DIR: $(ET_TARBALLS_DIR)\n"
	@printf "ET_CONFIG_DIR: $(ET_CONFIG_DIR)\n"
	$(call toolchain-info)
	$(call kernel-info)
	$(call bootloader-info)
	@printf "PATH: $(PATH)\n"
