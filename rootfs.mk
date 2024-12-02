#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2024, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://buildroot.org
# - https://git.busybox.net/buildroot
# - https://buildroot.org/docs.html
#

ifdef ET_BOARD_ROOTFS_TREE

ifndef ET_BOARD_ROOTFS_TYPE
export ET_BOARD_ROOTFS_TYPE := $(ET_BOARD_TYPE)
endif

# embedded rootfs, for application processors, is Buildroot
export ET_ROOTFS_TYPE := $(ET_BOARD_ROOTFS_TYPE)
export ET_ROOTFS_TREE := $(ET_BOARD_ROOTFS_TREE)
export ET_ROOTFS_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_ROOTFS_TREE)
export ET_ROOTFS_HOSTNAME := $(ET_BOARD_HOSTNAME)
export ET_ROOTFS_GETTY_PORT := $(ET_BOARD_GETTY_PORT)
export ET_ROOTFS_ISSUE := $(shell printf "etinker: $(ET_BOARD)")
export ET_ROOTFS_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) rootfs-ref)

rootfs_defconfig := et_$(subst -,_,$(ET_ROOTFS_TYPE))_defconfig
rootfs_type := $(ET_ROOTFS_TYPE)
ifneq ($(ET_ROOTFS_VARIANT),)
rootfs_type := $(subst $(ET_ROOTFS_VARIANT),,$(ET_ROOTFS_TYPE))
endif

# [start] rootfs version magic
ifneq ($(shell ls $(ET_ROOTFS_SOFTWARE_DIR) $(ET_NOERR)),)
ET_ROOTFS_VERSION := $(shell cd $(ET_ROOTFS_SOFTWARE_DIR) $(ET_NOERR) && git describe --long --dirty $(ET_NOERR) | tr -d v)
ifeq ($(shell echo $(ET_ROOTFS_VERSION) | cut -d '-' -f 2),0)
ET_ROOTFS_VERSION := $(shell cd $(ET_ROOTFS_SOFTWARE_DIR) $(ET_NOERR) && git describe --dirty $(ET_NOERR) | tr -d v)
endif
endif
# [end] rootfs version magic

export ET_ROOTFS_VERSION

export ET_ROOTFS_BUSYBOX_VERSION := $(shell sed -n 's/BUSYBOX_VERSION\ =\ //p' $(ET_ROOTFS_SOFTWARE_DIR)/package/busybox/busybox.mk $(ET_NOERR))

export ET_ROOTFS_BUILD_DIR := $(ET_DIR)/rootfs/build/$(ET_ROOTFS_TYPE)/$(ET_CROSS_TUPLE)
export ET_ROOTFS_BUILD_CONFIG := $(ET_ROOTFS_BUILD_DIR)/.config
export ET_ROOTFS_BUILD_BUSYBOX_CONFIG := $(ET_ROOTFS_BUILD_DIR)/build/busybox-$(busybox_version)/.config
export ET_ROOTFS_BUILD_IMAGE := $(ET_ROOTFS_BUILD_DIR)/images/rootfs.tar
export ET_ROOTFS_TARBALLS_DIR := $(ET_TARBALLS_DIR)/rootfs
export ET_ROOTFS_DIR := $(ET_DIR)/rootfs/$(ET_BOARD)$(ET_ROOTFS_VARIANT)/$(ET_CROSS_TUPLE)
export ET_ROOTFS_DEFCONFIG := $(ET_DIR)/boards/$(rootfs_type)/config/$(ET_ROOTFS_TREE)/$(rootfs_defconfig)
export ET_ROOTFS_BUSYBOX_CONFIG := $(ET_DIR)/boards/$(rootfs_type)/config/$(ET_ROOTFS_TREE)/busybox.config
export ET_ROOTFS_IMAGE := $(ET_ROOTFS_DIR)/images/rootfs.tar
export ET_ROOTFS_TARGET_FINAL ?= $(ET_ROOTFS_IMAGE)

export ET_ROOTFS_SYSROOT_DIR := $(ET_ROOTFS_BUILD_DIR)/host/$(ET_ARCH)$(ET_ARCH_EXT)-buildroot-$(ET_OS)-$(ET_ABI)/sysroot

export BR_DEFCONFIG := $(ET_ROOTFS_DEFCONFIG)

define rootfs-version
	@printf "ET_ROOTFS_VERSION: \033[0;33m[$(ET_ROOTFS_CACHED_VERSION)]\033[0m $(ET_ROOTFS_VERSION)\n"
	@printf "ET_ROOTFS_BUSYBOX_VERSION: $(ET_ROOTFS_BUSYBOX_VERSION)\n"
endef

define rootfs-software
	$(call software-check,$(ET_ROOTFS_TREE),rootfs,fetch)
	$(call software-check,$(ET_OPENSSL_TREE),openssl,fetch)
	$(call software-check,luajit,luajit,fetch)
endef

define rootfs-depends
	$(call software-check,luajit,luajit)
	$(call software-check,$(ET_OPENSSL_TREE),openssl)
	$(call software-check,$(ET_ROOTFS_TREE),rootfs)
	@mkdir -p $(ET_KERNEL_DIR)
	@mkdir -p $(ET_BOOTLOADER_DIR)
	@mkdir -p $(ET_OVERLAY_DIR)
	@mkdir -p $(ET_LIBRARY_DIR)
	@mkdir -p $(ET_ROOTFS_DIR)
	@mkdir -p $(ET_ROOTFS_BUILD_DIR)
	@mkdir -p $(ET_ROOTFS_TARBALLS_DIR)
	@mkdir -p $(shell dirname $(ET_ROOTFS_DEFCONFIG))
	@if [ -f $(ET_ROOTFS_DEFCONFIG) ]; then \
		rsync $(ET_ROOTFS_DEFCONFIG) $(ET_ROOTFS_SOFTWARE_DIR)/configs/ $(ET_NULL); \
	fi
	@printf "LIBOPENSSL_OVERRIDE_SRCDIR = $(ET_SOFTWARE_DIR)/openssl\n" > $(ET_ROOTFS_BUILD_DIR)/local.mk
	@printf "LUAJIT_OVERRIDE_SRCDIR = $(ET_SOFTWARE_DIR)/luajit\n" >> $(ET_ROOTFS_BUILD_DIR)/local.mk
endef

define rootfs-build
	$(call rootfs-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-build 'make $1' *****\n\n"
	@case "$1" in \
	*config) \
		;; \
	*) \
		if ! [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
			$(MAKE) --no-print-directory \
				$(ET_CFLAGS_ROOTFS) \
				CROSS_COMPILE=$(ET_CROSS_COMPILE) \
				O=$(ET_ROOTFS_BUILD_DIR) \
				-C $(ET_ROOTFS_SOFTWARE_DIR) \
				$(rootfs_defconfig); \
			if ! [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
				printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_TREE) .config MISSING! *****\n"; \
				exit 2; \
			fi; \
		fi; \
		;; \
	esac
	@if [ "riscv" = "$(ET_ARCH)" ] && ! [ -d "$(ET_ROOTFS_BUILD_DIR)/host" ]; then \
		$(MAKE) --no-print-directory \
			$(ET_CFLAGS_ROOTFS) \
			CROSS_COMPILE=$(ET_CROSS_COMPILE) \
			O=$(ET_ROOTFS_BUILD_DIR) \
			-C $(ET_ROOTFS_SOFTWARE_DIR) \
			toolchain; \
		$(ET_SCRIPTS_DIR)/rootfs/$(ET_ARCH)/fix-broken-libs $(ET_ROOTFS_SYSROOT_DIR); \
	fi
	$(MAKE) --no-print-directory \
		$(ET_CFLAGS_ROOTFS) \
		CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		O=$(ET_ROOTFS_BUILD_DIR) \
		-C $(ET_ROOTFS_SOFTWARE_DIR) \
		$1
	@case "$1" in \
	*clean) \
		$(RM) -r $(ET_ROOTFS_DIR)/images; \
		;; \
	*config) \
		if ! [ -f $(ET_ROOTFS_BUILD_CONFIG) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_TREE) .config MISSING! *****\n"; \
			exit 2; \
		fi; \
		if ! [ "$1" = "savedefconfig" ]; then \
			$(MAKE) --no-print-directory \
				$(ET_CFLAGS_ROOTFS) \
				CROSS_COMPILE=$(ET_CROSS_COMPILE) \
				O=$(ET_ROOTFS_BUILD_DIR) \
				-C $(ET_ROOTFS_SOFTWARE_DIR) \
				savedefconfig; \
		fi; \
		echo; \
		cp -av $(ET_ROOTFS_SOFTWARE_DIR)/configs/$(rootfs_defconfig) $(ET_ROOTFS_DEFCONFIG); \
		if [ -f $(ET_ROOTFS_BUSYBOX_CONFIG) ]; then \
			$(MAKE) --no-print-directory \
				$(ET_CFLAGS_ROOTFS) \
				CROSS_COMPILE=$(ET_CROSS_COMPILE) \
				O=$(ET_ROOTFS_BUILD_DIR) \
				-C $(ET_ROOTFS_SOFTWARE_DIR) \
				busybox-update-config; \
		fi; \
		;; \
	*) \
		;; \
	esac
	@if [ -z "$1" ]; then \
		if ! [ -f $(ET_ROOTFS_BUILD_IMAGE) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_ROOTFS_BUILD_IMAGE) build FAILED! *****\n\n"; \
			exit 2; \
		fi; \
		$(RM) -r $(ET_ROOTFS_DIR)/images; \
		cp -av $(ET_ROOTFS_BUILD_DIR)/images $(ET_ROOTFS_DIR)/; \
		if [ "$(ET_TFTP)" = "yes" ] && [ -d $(ET_TFTP_DIR) ]; then \
			if ! [ -d $(ET_TFTP_DIR)/$(ET_BOARD) ]; then \
				sudo mkdir -p $(ET_TFTP_DIR)/$(ET_BOARD); \
				sudo chown $(USER).$(USER) $(ET_TFTP_DIR)/$(ET_BOARD); \
			fi; \
			rsync -r $(ET_ROOTFS_DIR)/images/* $(ET_TFTP_DIR)/$(ET_BOARD)/; \
		fi; \
	fi
	@if [ -n "$(shell diff $(ET_ROOTFS_SOFTWARE_DIR)/configs/$(rootfs_defconfig) $(ET_ROOTFS_DEFCONFIG) $(ET_NOERR))" ]; then \
		echo; \
		cp -av $(ET_ROOTFS_SOFTWARE_DIR)/configs/$(rootfs_defconfig) $(ET_ROOTFS_DEFCONFIG); \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] rootfs-build 'make $1' done. *****\n\n"
endef

define rootfs-config
	$(call rootfs-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-config *****\n\n"
	$(MAKE) --no-print-directory \
		$(ET_CFLAGS_ROOTFS) \
		CROSS_COMPILE=$(ET_CROSS_COMPILE) \
		O=$(ET_ROOTFS_BUILD_DIR) \
		-C $(ET_ROOTFS_SOFTWARE_DIR) \
		$(rootfs_defconfig)
endef

define rootfs-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-clean *****\n\n"
	$(RM) $(ET_ROOTFS_BUILD_DIR)/build/busybox-*/.stamp_built
	$(RM) $(ET_ROOTFS_BUILD_DIR)/build/busybox-*/.stamp*installed
	$(RM) $(ET_ROOTFS_BUILD_CONFIG)
	$(RM) -r $(ET_ROOTFS_DIR)/images
endef

define rootfs-purge
	$(call rootfs-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rootfs-purge *****\n\n"
	$(RM) -r $(ET_ROOTFS_BUILD_DIR)
endef

define rootfs-info
	@printf "========================================================================\n"
	@printf "ET_ROOTFS_TREE: $(ET_ROOTFS_TREE)\n"
	@printf "ET_ROOTFS_VERSION: $(ET_ROOTFS_VERSION)\n"
	@printf "ET_ROOTFS_BUSYBOX_VERSION: $(ET_ROOTFS_BUSYBOX_VERSION)\n"
	@printf "ET_ROOTFS_HOSTNAME: $(ET_ROOTFS_HOSTNAME)\n"
	@printf "ET_ROOTFS_GETTY_PORT: $(ET_ROOTFS_GETTY_PORT)\n"
	@printf "ET_ROOTFS_ISSUE: $(ET_ROOTFS_ISSUE)\n"
	@printf "ET_ROOTFS_SOFTWARE_DIR: $(ET_ROOTFS_SOFTWARE_DIR)\n"
	@printf "ET_ROOTFS_TARBALLS_DIR: $(ET_ROOTFS_TARBALLS_DIR)\n"
	@printf "ET_ROOTFS_BUILD_DIR: $(ET_ROOTFS_BUILD_DIR)\n"
	@printf "ET_ROOTFS_BUILD_CONFIG: $(ET_ROOTFS_BUILD_CONFIG)\n"
	@printf "ET_ROOTFS_BUILD_IMAGE: $(ET_ROOTFS_BUILD_IMAGE)\n"
	@printf "ET_ROOTFS_DEFCONFIG: $(ET_ROOTFS_DEFCONFIG)\n"
	@printf "ET_ROOTFS_BUSYBOX_CONFIG: $(ET_ROOTFS_BUSYBOX_CONFIG)\n"
	@printf "ET_ROOTFS_DIR: $(ET_ROOTFS_DIR)\n"
	@printf "ET_ROOTFS_SYSROOT_DIR: $(ET_ROOTFS_SYSROOT_DIR)\n"
	@printf "ET_ROOTFS_IMAGE: $(ET_ROOTFS_IMAGE)\n"
	@printf "ET_ROOTFS_TARGET_FINAL: $(ET_ROOTFS_TARGET_FINAL)\n"
endef

define rootfs-sync
	@$(ET_DIR)/scripts/sync rootfs $1
endef

define rootfs-update
	@$(ET_MAKE) -C $(ET_DIR) rootfs-clean
	@$(ET_MAKE) -C $(ET_DIR) rootfs
endef

define rootfs-all
	@$(ET_MAKE) -C $(ET_DIR) rootfs
endef

.PHONY: rootfs
rootfs: $(ET_ROOTFS_TARGET_FINAL)
$(ET_ROOTFS_TARGET_FINAL): $(ET_ROOTFS_BUILD_CONFIG)
	$(call rootfs-build)

rootfs-%: $(ET_ROOTFS_BUILD_CONFIG)
	$(call rootfs-build,$(*F))

.PHONY: rootfs-config
rootfs-config: $(ET_ROOTFS_BUILD_CONFIG)
$(ET_ROOTFS_BUILD_CONFIG): $(ET_TOOLCHAIN_TARGET_FINAL)
	$(call rootfs-config)

.PHONY: rootfs-clean
rootfs-clean:
	$(call $@)

.PHONY: rootfs-purge
rootfs-purge:
	$(call $@)

.PHONY: rootfs-version
rootfs-version:
	$(call $@)

.PHONY: rootfs-software
rootfs-software:
	$(call $@)

.PHONY: rootfs-info
rootfs-info:
	$(call $@)

rootfs-sync-%:
	$(call rootfs-sync,$(*F))

.PHONY: rootfs-update
rootfs-update:
	$(call $@)

.PHONY: rootfs-all
rootfs-all:
	$(call $@)

endif
# ET_BOARD_ROOTFS_TREE
