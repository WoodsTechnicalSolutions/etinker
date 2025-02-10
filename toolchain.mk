#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://crosstool-ng.github.io
# - https://github.com/crosstool-ng/crosstool-ng
# - https://crosstool-ng.github.io/docs
#

ifndef ET_BOARD_TOOLCHAIN_TYPE
export ET_BOARD_TOOLCHAIN_TYPE := $(ET_BOARD_TYPE)
endif

# embedded toolchain (GCC, GDB, and LIBC) is built using crosstool-NG
export ET_TOOLCHAIN_TYPE := $(ET_BOARD_TOOLCHAIN_TYPE)
ifeq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
export ET_TOOLCHAIN_VERSION := $(ET_HOST_OS_ID)-$(ET_HOST_OS_RELEASE)
export ET_TOOLCHAIN_CACHED_VERSION := $(ET_HOST_OS_ID)-$(ET_HOST_OS_RELEASE)
export ET_TOOLCHAIN_DIR := /usr
else
export ET_TOOLCHAIN_TREE := $(ET_BOARD_TOOLCHAIN_TREE)
export ET_TOOLCHAIN_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE)
toolchain_version = $(shell cd $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE)/ $(ET_NOERR) && git describe --tags $(ET_NOERR))
export ET_TOOLCHAIN_VERSION := $(shell printf "%s" $(toolchain_version) | sed s,crosstool-ng-,,)
export ET_TOOLCHAIN_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) toolchain-ref)
export ET_TOOLCHAIN_DIR := $(ET_DIR)/toolchain/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_BUILD_DIR := $(ET_DIR)/toolchain/build/$(ET_CROSS_TUPLE)
export ET_TOOLCHAIN_SYSROOT_DIR := $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot
export ET_TOOLCHAIN_TARBALLS_DIR := $(ET_TARBALLS_DIR)/toolchain
export ET_TOOLCHAIN_GENERATOR_DIR := $(ET_TOOLCHAIN_BUILD_DIR)/generator
export ET_TOOLCHAIN_GENERATOR := $(ET_TOOLCHAIN_GENERATOR_DIR)/bin/ct-ng
export ET_TOOLCHAIN_BUILD_CONFIG := $(ET_TOOLCHAIN_BUILD_DIR)/.config
export ET_TOOLCHAIN_BUILD_DEFCONFIG := $(ET_TOOLCHAIN_BUILD_DIR)/defconfig
toolchain_defconfig := et_$(subst -,_,$(ET_TOOLCHAIN_TYPE))_defconfig
export ET_TOOLCHAIN_DEFCONFIG := $(ET_DIR)/boards/$(ET_TOOLCHAIN_TYPE)/config/$(ET_TOOLCHAIN_TREE)/$(toolchain_defconfig)
export ET_TOOLCHAIN_TARGET_FINAL ?= $(ET_TOOLCHAIN_DIR)/bin/$(ET_CROSS_TUPLE)-gdb
# configured component versions
export ET_TOOLCHAIN_GCC_VERSION := $(shell grep -oP 'CT_GCC_VERSION=[^"]*"\K[^"]*' $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_NOERR))
export ET_TOOLCHAIN_GDB_VERSION := $(shell grep -oP 'CT_GDB_VERSION=[^"]*"\K[^"]*' $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_NOERR))
export ET_TOOLCHAIN_BINUTILS_VERSION := $(shell grep -oP 'CT_BINUTILS_VERSION=[^"]*"\K[^"]*' $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_NOERR))
ifeq ($(CT_KERNEL),linux)
export ET_TOOLCHAIN_GLIBC_VERSION := $(shell grep -oP 'CT_GLIBC_VERSION=[^"]*"\K[^"]*' $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_NOERR))
export ET_TOOLCHAIN_LINUX_VERSION := $(shell grep -oP 'CT_LINUX_VERSION=[^"]*"\K[^"]*' $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_NOERR))
endif
ifeq ($(CT_KERNEL),bare-metal)
export ET_TOOLCHAIN_NEWLIB_NANO_VERSION := $(shell grep -oP 'CT_NEWLIB_NANO_VERSION=[^"]*"\K[^"]*' $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_NOERR))
export ET_TOOLCHAIN_PICOLIBC_VERSION := $(shell grep -oP 'CT_PICOLIBC_VERSION=[^"]*"\K[^"]*' $(ET_TOOLCHAIN_BUILD_CONFIG) $(ET_NOERR))
endif
endif

define toolchain-version
	@printf "ET_TOOLCHAIN_VERSION: \033[0;33m[$(ET_TOOLCHAIN_CACHED_VERSION)]\033[0m $(ET_TOOLCHAIN_VERSION)\n"
	@printf "ET_TOOLCHAIN_BINUTILS_VERSION: $(ET_TOOLCHAIN_BINUTILS_VERSION)\n"
	@printf "ET_TOOLCHAIN_GCC_VERSION: $(ET_TOOLCHAIN_GCC_VERSION)\n"
	@printf "ET_TOOLCHAIN_GDB_VERSION: $(ET_TOOLCHAIN_GDB_VERSION)\n"
	@if [ "bare-metal" = "$(CT_KERNEL)" ]; then \
		printf "ET_TOOLCHAIN_NEWLIB_NANO_VERSION: $(ET_TOOLCHAIN_NEWLIB_NANO_VERSION)\n"; \
		printf "ET_TOOLCHAIN_PICOLIBC_VERSION: $(ET_TOOLCHAIN_PICOLIBC_VERSION)\n"; \
	fi
	@if [ "linux" = "$(CT_KERNEL)" ]; then \
		printf "ET_TOOLCHAIN_GLIBC_VERSION: $(ET_TOOLCHAIN_GLIBC_VERSION)\n"; \
		printf "ET_TOOLCHAIN_LINUX_VERSION: $(ET_TOOLCHAIN_LINUX_VERSION)\n"; \
	fi
endef

define toolchain-software
	$(call software-check,$(ET_TOOLCHAIN_TREE),toolchain,fetch)
endef

define toolchain-depends
	$(call software-check,$(ET_TOOLCHAIN_TREE),toolchain)
	@mkdir -p $(ET_TOOLCHAIN_TARBALLS_DIR)
	@mkdir -p $(shell dirname $(ET_TOOLCHAIN_DEFCONFIG))
	@mkdir -p $(ET_TOOLCHAIN_BUILD_DIR)/samples/$(ET_CROSS_TUPLE)
	@if [ -f $(ET_TOOLCHAIN_DEFCONFIG) ]; then \
		rsync $(ET_TOOLCHAIN_DEFCONFIG) $(ET_TOOLCHAIN_BUILD_DIR)/samples/$(ET_CROSS_TUPLE)/crosstool.config; \
		printf "reporter_name=\"Woods Technical Solutions\"\n" > $(ET_TOOLCHAIN_BUILD_DIR)/samples/$(ET_CROSS_TUPLE)/reported.by; \
		printf "reporter_url=\"www.woodsts.org\"\n" >> $(ET_TOOLCHAIN_BUILD_DIR)/samples/$(ET_CROSS_TUPLE)/reported.by; \
		printf "reporter_comment=\"$(ET_CROSS_TUPLE) toolchain\"\n" >> $(ET_TOOLCHAIN_BUILD_DIR)/samples/$(ET_CROSS_TUPLE)/reported.by; \
	fi
endef

define toolchain-build
	$(call toolchain-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain 'ct-ng $1' *****\n\n"
	@case "$1" in \
	*config) \
		;; \
	*) \
		if ! [ -f $(ET_TOOLCHAIN_BUILD_CONFIG) ]; then \
			(cd $(ET_TOOLCHAIN_BUILD_DIR) && \
				CT_ARCH=$(ET_ARCH) \
				$(ET_TOOLCHAIN_GENERATOR) \
				$(ET_CROSS_TUPLE)); \
			if ! [ -f $(ET_TOOLCHAIN_BUILD_CONFIG) ]; then \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_TOOLCHAIN_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		;; \
	esac
	(cd $(ET_TOOLCHAIN_BUILD_DIR) && \
		CT_ARCH=$(ET_ARCH) \
		$(ET_TOOLCHAIN_GENERATOR) \
		--no-print-directory \
		$1)
	@case "$1" in \
	build) \
		if ! [ -f $(ET_TOOLCHAIN_TARGET_FINAL) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_TOOLCHAIN_TREE) build FAILED! *****\n"; \
			exit 2; \
		fi; \
		if [ "riscv" = "$(ET_ARCH)" ]; then \
			(cd $(ET_TOOLCHAIN_SYSROOT_DIR)/lib && \
				for f in $(shell ls $(ET_TOOLCHAIN_SYSROOT_DIR)/usr/lib64/lp64d/ $(ET_NOERR)); do \
					ln -sf ../usr/lib64/lp64d/$$f; \
				done); \
		fi; \
		if ! [ -d $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot.cache ]; then \
			if [ -d $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot ]; then \
				cp -a $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot.cache; \
			fi; \
		fi; \
		if [ -z "$(ET_TOOLCHAIN_DEBUG)" ] && \
				[ -z "$(shell echo $(ET_CROSS_TUPLE) | grep -o arm-none-eabi)" ] && \
				[ -z "$(shell echo $(ET_CROSS_TUPLE) | grep -o cortexr5)" ]; then \
			$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/src; \
			$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/$(ET_CROSS_TUPLE); \
		fi; \
		;; \
	*clean) \
		$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/src; \
		$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR)/$(ET_CROSS_TUPLE); \
		;; \
	*config) \
		if ! [ -f $(ET_TOOLCHAIN_BUILD_CONFIG) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_TOOLCHAIN_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
		if ! [ "$1" = "savedefconfig" ]; then \
			(cd $(ET_TOOLCHAIN_BUILD_DIR) && \
				CT_ARCH=$(ET_ARCH) \
				$(ET_TOOLCHAIN_GENERATOR) \
				--no-print-directory \
				savedefconfig); \
		fi; \
		if [ -f $(ET_TOOLCHAIN_BUILD_DEFCONFIG) ]; then \
			rsync $(ET_TOOLCHAIN_BUILD_DEFCONFIG) $(ET_TOOLCHAIN_DEFCONFIG); \
			$(RM) $(ET_TOOLCHAIN_BUILD_DEFCONFIG); \
		fi; \
		;; \
	*) \
		;; \
	esac
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain 'ct-ng $1' done. *****\n\n"
endef

define toolchain-config
	$(call toolchain-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-config *****\n\n"
	@(cd $(ET_TOOLCHAIN_BUILD_DIR) && \
		CT_ARCH=$(ET_ARCH) \
		$(ET_TOOLCHAIN_GENERATOR) \
		$(ET_CROSS_TUPLE))
endef

define toolchain-generator
	$(call toolchain-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-generator *****\n\n"
	@(cd $(ET_SOFTWARE_DIR)/$(ET_TOOLCHAIN_TREE); \
		if [ -f Makefile ]; then \
			$(MAKE) distclean; \
			$(RM) -r *~ configure autom4te.cache verbatim-data.mk; \
		fi; \
		./bootstrap && \
		./configure --prefix=$(ET_TOOLCHAIN_GENERATOR_DIR) && \
		$(MAKE) && \
		$(MAKE) install)
	@if ! [ -f $(ET_TOOLCHAIN_GENERATOR) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-generator FAILED! *****\n"; \
		exit 2; \
	fi
endef

define toolchain-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-clean *****\n\n"
	$(call toolchain-build,clean)
endef

define toolchain-purge
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call toolchain-purge [$(ET_PURGE)] *****\n\n"
	@if [ "yes" = "$(ET_PURGE)" ]; then \
		(set -x; \
			$(RM) -r $(ET_TOOLCHAIN_DIR); \
			$(RM) -r $(ET_TOOLCHAIN_BUILD_DIR); \
		); \
	fi
endef

define toolchain-info
	@printf "========================================================================\n"
	@if [ "$(ET_BOARD_VENDOR)" = "$(ET_HOST_OS_ID)" ]; then \
		printf "ET_TOOLCHAIN_VERSION: $(ET_TOOLCHAIN_VERSION)\n"; \
		printf "ET_TOOLCHAIN_DIR: $(ET_TOOLCHAIN_DIR)\n"; \
	else \
		printf "ET_TOOLCHAIN_TREE: $(ET_TOOLCHAIN_TREE)\n"; \
		printf "ET_TOOLCHAIN_VERSION: $(ET_TOOLCHAIN_VERSION)\n"; \
		printf "ET_TOOLCHAIN_BINUTILS_VERSION: $(ET_TOOLCHAIN_BINUTILS_VERSION)\n"; \
		printf "ET_TOOLCHAIN_GCC_VERSION: $(ET_TOOLCHAIN_GCC_VERSION)\n"; \
		printf "ET_TOOLCHAIN_GDB_VERSION: $(ET_TOOLCHAIN_GDB_VERSION)\n"; \
		if [ "$(CT_KERNEL)" = "linux" ]; then \
			printf "ET_TOOLCHAIN_GLIBC_VERSION: $(ET_TOOLCHAIN_GLIBC_VERSION)\n"; \
			printf "ET_TOOLCHAIN_LINUX_VERSION: $(ET_TOOLCHAIN_LINUX_VERSION)\n"; \
		fi; \
		if [ "$(CT_KERNEL)" = "bare-metal" ]; then \
			printf "ET_TOOLCHAIN_NEWLIB_NANO_VERSION: $(ET_TOOLCHAIN_NEWLIB_NANO_VERSION)\n"; \
			printf "ET_TOOLCHAIN_PICOLIBC_VERSION: $(ET_TOOLCHAIN_PICOLIBC_VERSION)\n"; \
		fi; \
		printf "ET_TOOLCHAIN_SOFTWARE_DIR: $(ET_TOOLCHAIN_SOFTWARE_DIR)\n"; \
		printf "ET_TOOLCHAIN_GENERATOR: $(ET_TOOLCHAIN_GENERATOR)\n"; \
		printf "ET_TOOLCHAIN_GENERATOR_DIR: $(ET_TOOLCHAIN_GENERATOR_DIR)\n"; \
		printf "ET_TOOLCHAIN_TARBALLS_DIR: $(ET_TOOLCHAIN_TARBALLS_DIR)\n"; \
		printf "ET_TOOLCHAIN_BUILD_DIR: $(ET_TOOLCHAIN_BUILD_DIR)\n"; \
		printf "ET_TOOLCHAIN_BUILD_CONFIG: $(ET_TOOLCHAIN_BUILD_CONFIG)\n"; \
		printf "ET_TOOLCHAIN_BUILD_DEFCONFIG: $(ET_TOOLCHAIN_BUILD_DEFCONFIG)\n"; \
		printf "ET_TOOLCHAIN_DEFCONFIG: $(ET_TOOLCHAIN_DEFCONFIG)\n"; \
		printf "ET_TOOLCHAIN_DIR: $(ET_TOOLCHAIN_DIR)\n"; \
		printf "ET_TOOLCHAIN_SYSROOT_DIR: $(ET_TOOLCHAIN_SYSROOT_DIR)\n"; \
		printf "ET_TOOLCHAIN_TARGET_FINAL: $(ET_TOOLCHAIN_TARGET_FINAL)\n"; \
	fi
endef

define toolchain-update
	@(if [ -f $(ET_TOOLCHAIN_BUILD_CONFIG) ]; then \
		$(ET_MAKE) -C $(ET_DIR) toolchain-clean; \
	fi)
	@$(ET_MAKE) -C $(ET_DIR) toolchain
endef

define toolchain-all
	@$(ET_MAKE) -C $(ET_DIR) toolchain
endef

ifdef ET_MCU_LIBC
define toolchain-mcu-libc
	@(cd $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE) && \
		mkdir -p base; \
		if ! [ -d base/lib ]; then \
			cp -a lib base/; \
		fi; \
		rm -rf lib; \
		cp -a base/lib .; \
		cp -a $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)/lib/* lib/; \
		(cd lib && \
			for f in `ls $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/lib/gcc/$(ET_CROSS_TUPLE)/$(ET_TOOLCHAIN_GCC_VERSION)/`; do \
				rm -f $$f; \
				ln -s $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/lib/gcc/$(ET_CROSS_TUPLE)/$(ET_TOOLCHAIN_GCC_VERSION)/$$f; \
			done; \
			if [ -f librdimon.a ]; then \
				ln -s librdimon.a librdimon_nano.a; \
			fi; \
		); \
		if ! [ -d base/include ]; then \
			cp -a include base/; \
		fi; \
		rm -rf include; \
		cp -a base/include .; \
		if [ -d $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)/include ]; then \
			cp -a $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)/include/* include/; \
		fi; \
		if ! [ -d base/sys-include ]; then \
			cp -a sys-include base/; \
		fi; \
		rm -rf sys-include; \
		cp -a base/sys-include .; \
		cp -a $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)/sys-include/* sys-include/; \
	)
endef
endif

.PHONY: toolchain
toolchain: $(ET_TOOLCHAIN_TARGET_FINAL)
ifneq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
$(ET_TOOLCHAIN_TARGET_FINAL): $(ET_TOOLCHAIN_BUILD_CONFIG)
	$(call toolchain-build,build)
endif

ifneq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
toolchain-%: $(ET_TOOLCHAIN_BUILD_CONFIG)
	$(call toolchain-build,$(*F))
endif

.PHONY: toolchain-config
ifneq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
toolchain-config: $(ET_TOOLCHAIN_BUILD_CONFIG)
$(ET_TOOLCHAIN_BUILD_CONFIG): $(ET_TOOLCHAIN_GENERATOR)
	$(call toolchain-config)
endif

.PHONY: toolchain-generator
ifneq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
toolchain-generator: $(ET_TOOLCHAIN_GENERATOR)
$(ET_TOOLCHAIN_GENERATOR):
	$(call toolchain-generator)
endif

.PHONY: toolchain-clean
ifneq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
toolchain-clean:
	$(call $@)
endif

.PHONY: toolchain-purge
ifneq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
toolchain-purge:
	$(call $@)
endif

.PHONY: toolchain-version
toolchain-version:
	$(call $@)

.PHONY: toolchain-software
toolchain-software:
	$(call $@)

.PHONY: toolchain-info
toolchain-info:
	$(call $@)

.PHONY: toolchain-update
toolchain-update:
	$(call $@)

.PHONY: toolchain-all
toolchain-all:
	$(call $@)
