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
all: toolchain kernel

.PHONY: info
info:
	$(call etinker-info)

.PHONY: version
version:
	$(call etinker-version)

.PHONY: toolchain
toolchain: $(ET_TOOLCHAIN_TARGET_FINAL)
$(ET_TOOLCHAIN_TARGET_FINAL): $(ET_TOOLCHAIN_CONFIGURED)
	$(call toolchain-targets)

toolchain-%: $(ET_TOOLCHAIN_BUILD_CONFIG)
	$(call toolchain-build,$(*F))

.PHONY: toolchain-config
toolchain-config: $(ET_TOOLCHAIN_BUILD_CONFIG)
$(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_TOOLCHAIN_CONFIGURED): $(ET_TOOLCHAIN_GENERATOR) $(ET_TOOLCHAIN_CONFIG)
	$(call toolchain-config)
	@touch $(ET_TOOLCHAIN_CONFIGURED)

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

.PHONY: kernel
kernel: $(ET_KERNEL_TARGET_FINAL)
$(ET_KERNEL_TARGET_FINAL): $(ET_KERNEL_CONFIGURED)
	$(call kernel-targets)

kernel-%: $(ET_KERNEL_BUILD_CONFIG)
	$(call kernel-build,$(*F))

.PHONY: kernel-config
kernel-config: $(ET_KERNEL_BUILD_CONFIG)
$(ET_KERNEL_BUILD_CONFIG) $(ET_KERNEL_CONFIGURED): $(ET_TOOLCHAIN_TARGET_FINAL) $(ET_KERNEL_CONFIG)
	$(call kernel-config)
	@touch $(ET_KERNEL_CONFIGURED)

.PHONY: kernel-info
kernel-info:
	$(call $@)

.PHONY: kernel-purge
kernel-purge:
	$(call $@)

.PHONY: clean
clean:
	$(call toolchain-$@)
	$(call kernel-$@)

.PHONY: purge
purge:
	$(call toolchain-$@)
	$(call kernel-$@)

.PHONY: software-development
software-development:
	$(call $@)
