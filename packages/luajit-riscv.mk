#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2024, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifdef ET_BOARD_ROOTFS_TREE

ifeq (riscv,$(shell echo $(ET_ARCH) | grep -o riscv))

export ET_LUAJIT_RISCV_TREE := luajit-riscv
export ET_LUAJIT_RISCV_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_LUAJIT_RISCV_TREE)
export ET_LUAJIT_RISCV_VERSION := $(shell cd $(ET_LUAJIT_RISCV_SOFTWARE_DIR) $(ET_NOERR) && git describe --long --dirty $(ET_NOERR))
export ET_LUAJIT_RISCV_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) luajit-riscv-ref)
export ET_LUAJIT_RISCV_BUILD_DIR := $(ET_LUAJIT_RISCV_SOFTWARE_DIR)
export ET_LUAJIT_RISCV_BUILD_CONFIG := $(ET_LUAJIT_RISCV_BUILD_DIR)/.configured
export ET_LUAJIT_RISCV_TARGET_FINAL ?= $(ET_LUAJIT_RISCV_SOFTWARE_DIR)/src/luajit

export ET_CFLAGS_BOOTLOADER += LUAJIT_RISCV=$(ET_LUAJIT_RISCV_TARGET_FINAL)

define luajit-riscv-version
	@printf "ET_LUAJIT_RISCV_VERSION: \033[0;33m[$(ET_LUAJIT_RISCV_CACHED_VERSION)]\033[0m $(ET_LUAJIT_RISCV_VERSION)\n"
endef

define luajit-riscv-software
	$(call software-check,$(ET_LUAJIT_RISCV_TREE),luajit-riscv,fetch)
endef

define luajit-riscv-depends
	$(call software-check,$(ET_LUAJIT_RISCV_TREE),luajit-riscv)
	@mkdir -p $(ET_OVERLAY_DIR)/usr/bin
	@mkdir -p $(ET_OVERLAY_DIR)/usr/lib
	@mkdir -p $(ET_LUAJIT_RISCV_BUILD_DIR)
endef

define luajit-riscv
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
	$(call luajit-riscv-build)
endef

define luajit-riscv-build
	$(call luajit-riscv-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 'make $1' *****\n\n"
	@$(MAKE) -C $(ET_LUAJIT_RISCV_SOFTWARE_DIR) \
		PREFIX="/usr" \
		STATIC_CC="$(ET_CROSS_COMPILE)gcc" \
		DYNAMIC_CC="$(ET_CROSS_COMPILE)gcc -fPIC" \
		TARGET_LD="$(ET_CROSS_COMPILE)gcc" \
		TARGET_AR="$(ET_CROSS_COMPILE)ar rcus" \
		TARGET_STRIP=true \
		TARGET_CFLAGS="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Os -g2 " \
		TARGET_LDFLAGS="" \
		HOST_CC="$(ET_ROOTFS_BUILD_DIR)/host/bin/ccache /usr/lib/ccache/gcc" \
		HOST_CFLAGS="-O2 -I$(ET_ROOTFS_BUILD_DIR)/host/include" \
		HOST_LDFLAGS="-L$(ET_ROOTFS_BUILD_DIR)/host/lib -Wl,-rpath,$(ET_ROOTFS_BUILD_DIR)/host/lib" \
		XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT" \
		BUILDMODE=dynamic \
		amalg
	@if [ -z "$1" ]; then \
		if ! [ -f $(ET_LUAJIT_RISCV_TARGET_FINAL) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 'make $1' FAILED! *****\n"; \
			exit 2; \
		fi; \
		$(MAKE) -C $(ET_LUAJIT_RISCV_SOFTWARE_DIR) \
			PREFIX="/usr" \
			DESTDIR="$(ET_ROOTFS_SYSROOT_DIR)" \
			LDCONFIG=true \
			install; \
		$(MAKE) -C $(ET_LUAJIT_RISCV_SOFTWARE_DIR) \
			PREFIX="/usr" \
			DESTDIR="$(ET_OVERLAY_DIR)" \
			LDCONFIG=true \
			install; \
		(cd $(ET_OVERLAY_DIR)/usr/bin && \
	       		ln -sf luajit lua); \
	fi
	@if [ "clean" = "$1" ]; then \
		$(MAKE) -C $(ET_LUAJIT_RISCV_SOFTWARE_DIR) \
			PREFIX="/usr" \
			DESTDIR="$(ET_ROOTFS_SYSROOT_DIR)" \
			LDCONFIG=true \
			clean; \
		$(MAKE) -C $(ET_LUAJIT_RISCV_SOFTWARE_DIR) \
			PREFIX="/usr" \
			DESTDIR="$(ET_OVERLAY_DIR)" \
			LDCONFIG=true \
			clean; \
		$(RM) -v $(ET_LUAJIT_RISCV_TARGET_FINAL); \
		$(RM) -v $(ET_LUAJIT_RISCV_BUILD_CONFIG); \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 'make $1' done. *****\n\n"
endef

define luajit-riscv-config
	$(call luajit-riscv-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
	@touch $(ET_LUAJIT_RISCV_BUILD_CONFIG)
endef

define luajit-riscv-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
	$(RM) $(ET_LUAJIT_RISCV_TARGET_FINAL)
	$(RM) $(ET_LUAJIT_RISCV_BUILD_CONFIG)
endef

define luajit-riscv-purge
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call $0 *****\n\n"
	$(MAKE) -C $(ET_LUAJIT_RISCV_SOFTWARE_DIR) clean
	$(RM) $(ET_LUAJIT_RISCV_TARGET_FINAL)
	$(RM) $(ET_LUAJIT_RISCV_BUILD_CONFIG)
endef

define luajit-riscv-info
	@printf "========================================================================\n"
	@printf "ET_LUAJIT_RISCV_TREE: $(ET_LUAJIT_RISCV_TREE)\n"
	@printf "ET_LUAJIT_RISCV_VERSION: $(ET_LUAJIT_RISCV_VERSION)\n"
	@printf "ET_LUAJIT_RISCV_SOFTWARE_DIR: $(ET_LUAJIT_RISCV_SOFTWARE_DIR)\n"
	@printf "ET_LUAJIT_RISCV_BUILD_CONFIG: $(ET_LUAJIT_RISCV_BUILD_CONFIG)\n"
	@printf "ET_LUAJIT_RISCV_BUILD_DIR: $(ET_LUAJIT_RISCV_BUILD_DIR)\n"
	@printf "ET_LUAJIT_RISCV_TARGET_FINAL: $(ET_LUAJIT_RISCV_TARGET_FINAL)\n"
endef

define luajit-riscv-update
	@$(ET_MAKE) -C $(ET_DIR) luajit-riscv-clean
	@$(ET_MAKE) -C $(ET_DIR) luajit-riscv
endef

define luajit-riscv-all
	@$(ET_MAKE) -C $(ET_DIR) luajit-riscv
endef

.PHONY: luajit-riscv
luajit-riscv: $(ET_LUAJIT_RISCV_TARGET_FINAL)
$(ET_LUAJIT_RISCV_TARGET_FINAL): $(ET_LUAJIT_RISCV_BUILD_CONFIG)
	$(call luajit-riscv)

luajit-riscv-%: $(ET_LUAJIT_RISCV_BUILD_CONFIG)
	$(call luajit-riscv-build,$(*F))

.PHONY: luajit-riscv-config
luajit-riscv-config: $(ET_LUAJIT_RISCV_BUILD_CONFIG)
$(ET_LUAJIT_RISCV_BUILD_CONFIG):
ifeq ($(shell test -f $(ET_LUAJIT_RISCV_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call luajit-riscv-config)
endif

.PHONY: luajit-riscv-clean
luajit-riscv-clean:
ifeq ($(ET_CLEAN),yes)
	$(call luajit-riscv-build,clean)
endif
	$(call $@)

.PHONY: luajit-riscv-purge
luajit-riscv-purge:
	$(call $@)

.PHONY: luajit-riscv-version
luajit-riscv-version:
	$(call $@)

.PHONY: luajit-riscv-software
luajit-riscv-software:
	$(call $@)

.PHONY: luajit-riscv-info
luajit-riscv-info:
	$(call $@)

.PHONY: luajit-riscv-update
luajit-riscv-update:
	$(call $@)

# ET_ARCH == riscv
endif
# ET_BOARD_ROOTFS_TREE
endif
