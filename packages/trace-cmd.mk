#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2023, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://www.trace-cmd.org/
# - https://git.kernel.org/pub/scm/utils/trace-cmd/trace-cmd.git/
# - https://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git/
# - https://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git/
# - https://git.busybox.net/buildroot/tree/package/pkg-meson.mk
#   * Generates $(HOST_DIR)/etc/meson/cross-compilation.conf
#

ifdef ET_BOARD_ROOTFS_TREE

export ET_TRACE_CMD_TREE := trace-cmd
export ET_TRACE_CMD_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_TRACE_CMD_TREE)
export ET_TRACE_CMD_VERSION := $(shell cd $(ET_TRACE_CMD_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null)
export ET_TRACE_CMD_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) trace-cmd-ref)
export ET_TRACE_CMD_BUILD_DIR := $(ET_OVERLAY_BUILD_DIR)/$(ET_TRACE_CMD_TREE)
export ET_TRACE_CMD_BUILD_CONFIG := $(ET_TRACE_CMD_BUILD_DIR)/.configured
export ET_TRACE_CMD_BUILD_BIN := $(ET_TRACE_CMD_BUILD_DIR)/bin/trace-cmd
export ET_TRACE_CMD_BIN := $(ET_OVERLAY_DIR)/usr/bin/trace-cmd
export ET_TRACE_CMD_TARGET_FINAL ?= $(ET_TRACE_CMD_BIN)

export ET_TRACE_EVENT_TREE := libtraceevent
export ET_TRACE_EVENT_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_TRACE_EVENT_TREE)
export ET_TRACE_EVENT_VERSION := $(shell cd $(ET_TRACE_EVENT_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null)
export ET_TRACE_EVENT_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) libtraceevent-ref)
export ET_TRACE_EVENT_BUILD_DIR := $(ET_OVERLAY_BUILD_DIR)/$(ET_TRACE_EVENT_TREE)
export ET_TRACE_EVENT_BUILD_CONFIG := $(ET_TRACE_EVENT_BUILD_DIR)/.configured
export ET_TRACE_EVENT_BUILD_LIB := $(ET_TRACE_EVENT_BUILD_DIR)/lib/libtraceevent.so.$(ET_TRACE_EVENT_VERSION)
export ET_TRACE_EVENT_LIB := $(ET_OVERLAY_DIR)/usr/lib/libtraceevent.so.$(ET_TRACE_EVENT_VERSION)
export ET_TRACE_EVENT_TARGET_FINAL ?= $(ET_TRACE_EVENT_LIB)

export ET_TRACE_FS_TREE := libtracefs
export ET_TRACE_FS_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_TRACE_FS_TREE)
export ET_TRACE_FS_VERSION := $(shell cd $(ET_TRACE_FS_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null)
export ET_TRACE_FS_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) libtracefs-ref)
export ET_TRACE_FS_BUILD_DIR := $(ET_OVERLAY_BUILD_DIR)/$(ET_TRACE_FS_TREE)
export ET_TRACE_FS_BUILD_CONFIG := $(ET_TRACE_FS_BUILD_DIR)/.configured
export ET_TRACE_FS_BUILD_LIB := $(ET_TRACE_FS_BUILD_DIR)/lib/libtracefs.so.$(ET_TRACE_FS_VERSION)
export ET_TRACE_FS_LIB := $(ET_OVERLAY_DIR)/usr/lib/libtracefs.so.$(ET_TRACE_FS_VERSION)
export ET_TRACE_FS_TARGET_FINAL ?= $(ET_TRACE_FS_LIB)

define trace-cmd-version
	@printf "ET_TRACE_EVENT_VERSION: \033[0;33m[$(ET_TRACE_EVENT_CACHED_VERSION)]\033[0m $(ET_TRACE_EVENT_VERSION)\n"
	@printf "ET_TRACE_FS_VERSION: \033[0;33m[$(ET_TRACE_FS_CACHED_VERSION)]\033[0m $(ET_TRACE_FS_VERSION)\n"
	@printf "ET_TRACE_CMD_VERSION: \033[0;33m[$(ET_TRACE_CMD_CACHED_VERSION)]\033[0m $(ET_TRACE_CMD_VERSION)\n"
endef

define trace-cmd-software
	$(call software-check,$(ET_TRACE_EVENT_TREE),libtraceevent,fetch)
	$(call software-check,$(ET_TRACE_FS_TREE),libtracefs,fetch)
	$(call software-check,$(ET_TRACE_CMD_TREE),trace-cmd,fetch)
endef

define trace-cmd-depends
	$(call software-check,$(ET_TRACE_EVENT_TREE),libtraceevent)
	$(call software-check,$(ET_TRACE_FS_TREE),libtracefs)
	$(call software-check,$(ET_TRACE_CMD_TREE),trace-cmd)
	@mkdir -p $(ET_OVERLAY_DIR)
	@mkdir -p $(ET_OVERLAY_DIR)/usr/bin
	@mkdir -p $(ET_OVERLAY_DIR)/usr/lib
	@mkdir -p $(ET_OVERLAY_BUILD_DIR)
endef

define trace-cmd-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] trace-cmd-targets '$1' *****\n\n"
	$(call trace-cmd-build,$1)
	$(call trace-cmd-build,$1,install)
endef

define trace-cmd-build
	$(call trace-cmd-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call trace-cmd-build 'ninja $1 $2' *****\n\n"
	@case "$1" in \
	libtraceevent) \
		if [ -d $(ET_TRACE_EVENT_BUILD_DIR)/build ]; then \
			PATH="$(ET_ROOTFS_BUILD_DIR)/host/bin:$(ET_ROOTFS_BUILD_DIR)/host/sbin:$(PATH)" \
			PYTHONNOUSERSITE=y \
			DESTDIR=$(ET_OVERLAY_DIR) \
				$(ET_ROOTFS_BUILD_DIR)/host/bin/ninja -C $(ET_TRACE_EVENT_BUILD_DIR)/build $2 || exit 2; \
			rsync -a $(ET_OVERLAY_DIR)/* $(ET_ROOTFS_SYSROOT_DIR)/; \
		fi; \
		;; \
	libtracefs) \
		if [ -d $(ET_TRACE_FS_BUILD_DIR)/build ]; then \
			PATH="$(ET_ROOTFS_BUILD_DIR)/host/bin:$(ET_ROOTFS_BUILD_DIR)/host/sbin:$(PATH)" \
			PYTHONNOUSERSITE=y \
			DESTDIR=$(ET_OVERLAY_DIR) \
				$(ET_ROOTFS_BUILD_DIR)/host/bin/ninja -C $(ET_TRACE_FS_BUILD_DIR)/build $2 || exit 2; \
			rsync -a $(ET_OVERLAY_DIR)/* $(ET_ROOTFS_SYSROOT_DIR)/; \
		fi; \
		;; \
	trace-cmd) \
		if [ -d $(ET_TRACE_CMD_BUILD_DIR)/build ]; then \
			PATH="$(ET_ROOTFS_BUILD_DIR)/host/bin:$(ET_ROOTFS_BUILD_DIR)/host/sbin:$(PATH)" \
			PYTHONNOUSERSITE=y \
			DESTDIR=$(ET_OVERLAY_DIR) \
				$(ET_ROOTFS_BUILD_DIR)/host/bin/ninja -C $(ET_TRACE_CMD_BUILD_DIR)/build $2 || exit 2; \
			rsync -a $(ET_OVERLAY_DIR)/* $(ET_ROOTFS_SYSROOT_DIR)/; \
		fi; \
		;; \
	*) \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] trace-cmd-build 'ninja $1' done. *****\n\n"; \
		exit 2; \
		;; \
	esac
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] trace-cmd-build 'ninja $1 $2' done. *****\n\n"
endef

define trace-cmd-config
	$(call trace-cmd-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] trace-cmd-config 'meson setup $1' *****\n\n"
	@case "$1" in \
	libtraceevent) \
		if ! [ -d $(ET_TRACE_EVENT_BUILD_DIR) ] || ! [ -f $(ET_TRACE_EVENT_BUILD_CONFIG) ]; then \
			rsync -a --cvs-exclude $(ET_TRACE_EVENT_SOFTWARE_DIR) $(shell dirname $(ET_TRACE_EVENT_BUILD_DIR))/; \
			echo; \
			count="`grep -n samples $(ET_TRACE_EVENT_BUILD_DIR)/meson.build | cut -d ':' -f 1`" && \
			export count="$$(($$count - 1))"; \
			head -"$$count" $(ET_TRACE_EVENT_BUILD_DIR)/meson.build > $(ET_TRACE_EVENT_BUILD_DIR)/_meson.build; \
			mv $(ET_TRACE_EVENT_BUILD_DIR)/_meson.build $(ET_TRACE_EVENT_BUILD_DIR)/meson.build; \
			PATH="$(ET_ROOTFS_BUILD_DIR)/host/bin:$(ET_ROOTFS_BUILD_DIR)/host/sbin:$(PATH)" \
			CC_FOR_BUILD="$(ET_ROOTFS_BUILD_DIR)/host/bin/ccache /usr/lib/ccache/gcc" \
			CXX_FOR_BUILD="$(ET_ROOTFS_BUILD_DIR)/host/bin/ccache /usr/lib/ccache/g++" \
			PYTHONNOUSERSITE=y \
			$(ET_ROOTFS_BUILD_DIR)/host/bin/meson setup \
				--prefix=/usr \
				--libdir=lib \
				--default-library=shared \
				--buildtype=debug \
				--cross-file=$(ET_ROOTFS_BUILD_DIR)/host/etc/meson/cross-compilation.conf \
				-Db_pie=false \
				-Dstrip=false \
				-Dbuild.pkg_config_path=$(ET_ROOTFS_BUILD_DIR)/host/lib/pkgconfig \
				-Dbuild.cmake_prefix_path=$(ET_ROOTFS_BUILD_DIR)/host/lib/cmake \
				$(ET_TRACE_EVENT_BUILD_DIR)/ \
				$(ET_TRACE_EVENT_BUILD_DIR)/build || exit 2; \
			printf "%s\n" "$(shell date)" > $(ET_TRACE_EVENT_BUILD_CONFIG); \
		fi; \
		;; \
	libtracefs) \
		if ! [ -d $(ET_TRACE_FS_BUILD_DIR) ] || ! [ -f $(ET_TRACE_FS_BUILD_CONFIG) ]; then \
			rsync -a --cvs-exclude $(ET_TRACE_FS_SOFTWARE_DIR) $(shell dirname $(ET_TRACE_FS_BUILD_DIR))/; \
			echo; \
			count="`grep -n samples $(ET_TRACE_FS_BUILD_DIR)/meson.build | cut -d ':' -f 1`" && \
			export count="$$(($$count - 1))"; \
			head -"$$count" $(ET_TRACE_FS_BUILD_DIR)/meson.build > $(ET_TRACE_FS_BUILD_DIR)/_meson.build; \
			mv $(ET_TRACE_FS_BUILD_DIR)/_meson.build $(ET_TRACE_FS_BUILD_DIR)/meson.build; \
			PATH="$(ET_ROOTFS_BUILD_DIR)/host/bin:$(ET_ROOTFS_BUILD_DIR)/host/sbin:$(PATH)" \
			CC_FOR_BUILD="$(ET_ROOTFS_BUILD_DIR)/host/bin/ccache /usr/lib/ccache/gcc" \
			CXX_FOR_BUILD="$(ET_ROOTFS_BUILD_DIR)/host/bin/ccache /usr/lib/ccache/g++" \
			PYTHONNOUSERSITE=y \
			$(ET_ROOTFS_BUILD_DIR)/host/bin/meson setup \
				--prefix=/usr \
				--libdir=lib \
				--default-library=shared \
				--buildtype=debug \
				--cross-file=$(ET_ROOTFS_BUILD_DIR)/host/etc/meson/cross-compilation.conf \
				-Db_pie=false \
				-Dstrip=false \
				-Dbuild.pkg_config_path=$(ET_ROOTFS_BUILD_DIR)/host/lib/pkgconfig \
				-Dbuild.cmake_prefix_path=$(ET_ROOTFS_BUILD_DIR)/host/lib/cmake \
				$(ET_TRACE_FS_BUILD_DIR)/ \
				$(ET_TRACE_FS_BUILD_DIR)/build || exit 2; \
			printf "%s\n" "$(shell date)" > $(ET_TRACE_FS_BUILD_CONFIG); \
		fi; \
		;; \
	trace-cmd) \
		if ! [ -d $(ET_TRACE_CMD_BUILD_DIR) ] || ! [ -f $(ET_TRACE_CMD_BUILD_CONFIG) ]; then \
			rsync -a --cvs-exclude $(ET_TRACE_CMD_SOFTWARE_DIR) $(shell dirname $(ET_TRACE_CMD_BUILD_DIR))/; \
			echo; \
			count="`grep -n python $(ET_TRACE_CMD_BUILD_DIR)/meson.build | cut -d ':' -f 1`" && \
			export count="$$(($$count - 1))"; \
			head -"$$count" $(ET_TRACE_CMD_BUILD_DIR)/meson.build > $(ET_TRACE_CMD_BUILD_DIR)/_meson.build; \
			mv $(ET_TRACE_CMD_BUILD_DIR)/_meson.build $(ET_TRACE_CMD_BUILD_DIR)/meson.build; \
			PATH="$(ET_ROOTFS_BUILD_DIR)/host/bin:$(ET_ROOTFS_BUILD_DIR)/host/sbin:$(PATH)" \
			CC_FOR_BUILD="$(ET_ROOTFS_BUILD_DIR)/host/bin/ccache /usr/lib/ccache/gcc" \
			CXX_FOR_BUILD="$(ET_ROOTFS_BUILD_DIR)/host/bin/ccache /usr/lib/ccache/g++" \
			PYTHONNOUSERSITE=y \
			$(ET_ROOTFS_BUILD_DIR)/host/bin/meson setup \
				--prefix=/usr \
				--libdir=lib \
				--default-library=shared \
				--buildtype=debug \
				--cross-file=$(ET_ROOTFS_BUILD_DIR)/host/etc/meson/cross-compilation.conf \
				-Db_pie=false \
				-Dstrip=false \
				-Dbuild.pkg_config_path=$(ET_ROOTFS_BUILD_DIR)/host/lib/pkgconfig \
				-Dbuild.cmake_prefix_path=$(ET_ROOTFS_BUILD_DIR)/host/lib/cmake \
				$(ET_TRACE_CMD_BUILD_DIR)/ \
				$(ET_TRACE_CMD_BUILD_DIR)/build || exit 2; \
			printf "%s\n" "$(shell date)" > $(ET_TRACE_CMD_BUILD_CONFIG); \
		fi; \
	;; \
	*) \
		;; \
	esac
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] trace-cmd-config 'meson setup $1' done. *****\n\n"
endef

define trace-cmd-clean-overlay
	$(RM) -r $(ET_OVERLAY_DIR)/usr/lib/libtraceevent*
	$(RM) -r $(ET_OVERLAY_DIR)/usr/include/traceevent
	$(RM) -r $(ET_OVERLAY_DIR)/usr/lib/pkgconfig/libtrace*
	$(RM) -r $(ET_OVERLAY_DIR)/usr/include/libtracefs
	$(RM) -r $(ET_OVERLAY_DIR)/usr/lib/libtracefs*
	$(RM) $(ET_OVERLAY_DIR)/usr/bin/trace-cmd
	$(RM) $(ET_OVERLAY_DIR)/usr/share/bash-completion/completions/trace-cmd.bash
endef

define trace-cmd-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call trace-cmd-clean *****\n\n"
	$(call trace-cmd-build,trace-cmd,clean)
	$(call trace-cmd-build,libtracefs,clean)
	$(call trace-cmd-build,libtraceevent,clean)
	$(call trace-cmd-clean-overlay)
endef

define trace-cmd-purge
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call trace-cmd-purge *****\n\n"
	$(RM) -r $(ET_TRACE_EVENT_BUILD_DIR)
	$(RM) -r $(ET_TRACE_CMD_BUILD_DIR)
	$(RM) -r $(ET_TRACE_FS_BUILD_DIR)
	$(call trace-cmd-clean-overlay)
endef

define trace-cmd-info
	@printf "========================================================================\n"
	@printf "ET_TRACE_CMD_TREE: $(ET_TRACE_CMD_TREE)\n"
	@printf "ET_TRACE_CMD_VERSION: $(ET_TRACE_CMD_VERSION)\n"
	@printf "ET_TRACE_CMD_SOFTWARE_DIR: $(ET_TRACE_CMD_SOFTWARE_DIR)\n"
	@printf "ET_TRACE_CMD_BUILD_CONFIG: $(ET_TRACE_CMD_BUILD_CONFIG)\n"
	@printf "ET_TRACE_CMD_BUILD_BIN: $(ET_TRACE_CMD_BUILD_BIN)\n"
	@printf "ET_TRACE_CMD_BUILD_DIR: $(ET_TRACE_CMD_BUILD_DIR)\n"
	@printf "ET_TRACE_CMD_BIN: $(ET_TRACE_CMD_BIN)\n"
	@printf "ET_TRACE_CMD_TARGET_FINAL: $(ET_TRACE_CMD_TARGET_FINAL)\n"
	@printf "ET_TRACE_EVENT_TREE: $(ET_TRACE_EVENT_TREE)\n"
	@printf "ET_TRACE_EVENT_VERSION: $(ET_TRACE_EVENT_VERSION)\n"
	@printf "ET_TRACE_EVENT_SOFTWARE_DIR: $(ET_TRACE_EVENT_SOFTWARE_DIR)\n"
	@printf "ET_TRACE_EVENT_BUILD_CONFIG: $(ET_TRACE_EVENT_BUILD_CONFIG)\n"
	@printf "ET_TRACE_EVENT_BUILD_LIB: $(ET_TRACE_EVENT_BUILD_LIB)\n"
	@printf "ET_TRACE_EVENT_BUILD_DIR: $(ET_TRACE_EVENT_BUILD_DIR)\n"
	@printf "ET_TRACE_EVENT_LIB: $(ET_TRACE_EVENT_LIB)\n"
	@printf "ET_TRACE_EVENT_TARGET_FINAL: $(ET_TRACE_EVENT_TARGET_FINAL)\n"
	@printf "ET_TRACE_FS_TREE: $(ET_TRACE_FS_TREE)\n"
	@printf "ET_TRACE_FS_VERSION: $(ET_TRACE_FS_VERSION)\n"
	@printf "ET_TRACE_FS_SOFTWARE_DIR: $(ET_TRACE_FS_SOFTWARE_DIR)\n"
	@printf "ET_TRACE_FS_BUILD_CONFIG: $(ET_TRACE_FS_BUILD_CONFIG)\n"
	@printf "ET_TRACE_FS_BUILD_LIB: $(ET_TRACE_FS_BUILD_LIB)\n"
	@printf "ET_TRACE_FS_BUILD_DIR: $(ET_TRACE_FS_BUILD_DIR)\n"
	@printf "ET_TRACE_FS_LIB: $(ET_TRACE_FS_LIB)\n"
	@printf "ET_TRACE_FS_TARGET_FINAL: $(ET_TRACE_FS_TARGET_FINAL)\n"
endef

define trace-cmd-update
	@$(ET_MAKE) -C $(ET_DIR) trace-cmd-clean
	@$(ET_MAKE) -C $(ET_DIR) trace-cmd
endef

define trace-cmd-all
	@$(ET_MAKE) -C $(ET_DIR) trace-cmd
endef

.PHONY: trace-cmd
trace-cmd: $(ET_TRACE_EVENT_TARGET_FINAL) $(ET_TRACE_FS_TARGET_FINAL) $(ET_TRACE_CMD_TARGET_FINAL)

$(ET_TRACE_EVENT_TARGET_FINAL): $(ET_TRACE_EVENT_BUILD_CONFIG)
	$(call trace-cmd-targets,libtraceevent)

$(ET_TRACE_FS_TARGET_FINAL): $(ET_TRACE_EVENT_TARGET_FINAL) $(ET_TRACE_FS_BUILD_CONFIG)
	$(call trace-cmd-targets,libtracefs)

$(ET_TRACE_CMD_TARGET_FINAL): $(ET_TRACE_FS_TARGET_FINAL) $(ET_TRACE_CMD_BUILD_CONFIG)
	$(call trace-cmd-targets,trace-cmd)

.PHONY: trace-cmd-config
trace-cmd-config: $(ET_TRACE_EVENT_BUILD_CONFIG) $(ET_TRACE_FS_BUILD_CONFIG) $(ET_TRACE_CMD_BUILD_CONFIG)

$(ET_TRACE_EVENT_BUILD_CONFIG): $(ET_ROOTFS_TARGET_FINAL)
ifeq ($(shell test -f $(ET_TRACE_EVENT_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call trace-cmd-config,libtraceevent)
endif

$(ET_TRACE_FS_BUILD_CONFIG): $(ET_ROOTFS_TARGET_FINAL) $(ET_TRACE_EVENT_TARGET_FINAL)
ifeq ($(shell test -f $(ET_TRACE_FS_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call trace-cmd-config,libtracefs)
endif

$(ET_TRACE_CMD_BUILD_CONFIG): $(ET_ROOTFS_TARGET_FINAL) $(ET_TRACE_EVENT_TARGET_FINAL) $(ET_TRACE_FS_TARGET_FINAL)
ifeq ($(shell test -f $(ET_TRACE_CMD_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call trace-cmd-config,trace-cmd)
endif

.PHONY: trace-cmd-clean
trace-cmd-clean:
	$(call $@)

.PHONY: trace-cmd-purge
trace-cmd-purge:
	$(call $@)

.PHONY: trace-cmd-version
trace-cmd-version:
	$(call $@)

.PHONY: trace-cmd-software
trace-cmd-software:
	$(call $@)

.PHONY: trace-cmd-info
trace-cmd-info:
	$(call $@)

.PHONY: trace-cmd-update
trace-cmd-update:
	$(call $@)

.PHONY: trace-cmd-all
trace-cmd-all:
	$(call $@)

endif
# ET_BOARD_ROOTFS_TREE
