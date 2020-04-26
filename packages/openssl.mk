#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_BOARD_ROOTFS_TREE
$(error [ 'etinker' packages requires buildroot rootfs ] ***)
endif

export ET_OPENSSL_TREE := openssl
export ET_OPENSSL_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_OPENSSL_TREE)
export ET_OPENSSL_VERSION := $(shell cd $(ET_OPENSSL_SOFTWARE_DIR) 2>/dev/null && git describe --long --dirty 2>/dev/null)
export ET_OPENSSL_CACHED_VERSION := $(shell grep -Po 'openssl-ref:\K[^\n]*' $(ET_BOARD_DIR)/software.conf)
export ET_OPENSSL_BUILD_DIR := $(ET_OVERLAY_BUILD_DIR)/openssl
export ET_OPENSSL_BUILD_CONFIG := $(ET_OPENSSL_BUILD_DIR)/configdata.pm
export ET_OPENSSL_BUILD_CRYPTO_SO := $(ET_OPENSSL_BUILD_DIR)/libcrypto.so
export ET_OPENSSL_BUILD_SSL_SO := $(ET_OPENSSL_BUILD_DIR)/libssl.so
export ET_OPENSSL_BUILD_BIN := $(ET_OPENSSL_BUILD_DIR)/apps/openssl
export ET_OPENSSL_CRYPTO_SO := $(ET_OVERLAY_DIR)/usr/lib/libcrypto.so
export ET_OPENSSL_SSL_SO := $(ET_OVERLAY_DIR)/usr/lib/libssl.so
export ET_OPENSSL_BIN := $(ET_OVERLAY_DIR)/usr/bin/openssl
export ET_OPENSSL_TARGET_FINAL ?= $(ET_OPENSSL_BIN)

define openssl-version
	@printf "ET_OPENSSL_VERSION: \033[0;33m[$(ET_OPENSSL_CACHED_VERSION)]\033[0m $(ET_OPENSSL_VERSION)\n"
endef

define openssl-depends
	@mkdir -p $(ET_OVERLAY_DIR)
	@mkdir -p $(ET_OVERLAY_DIR)/usr/bin
	@mkdir -p $(ET_OVERLAY_DIR)/usr/lib
	@mkdir -p $(ET_OPENSSL_BUILD_DIR)
endef

define openssl-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] openssl *****\n\n"
	$(call openssl-build,all)
	$(call openssl-build,install_dev)
	$(call openssl-build,install_engines)
	$(call openssl-build,install_runtime)
	$(call openssl-build,install_ssldirs)
endef

define openssl-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-build 'make $1' *****\n\n"
	$(call openssl-depends)
	$(call openssl-config,$1)
	sed -i s,DESTDIR=,DESTDIR=$$\(ET_OVERLAY_DIR\), $(ET_OPENSSL_BUILD_DIR)/Makefile
	@$(MAKE) -C $(ET_OPENSSL_BUILD_DIR) $1
	sed -i s,DESTDIR=$$\(ET_OVERLAY_DIR\),DESTDIR=, $(ET_OPENSSL_BUILD_DIR)/Makefile
	@if [ "$1" = "install_runtime" ]; then \
		cd $(ET_OVERLAY_DIR)/usr/lib/ && \
			ln -sf libcrypto*.so.* libcrypto.so && \
			ln -sf libssl*.so.* libssl.so; \
	fi
	@if [ "$1" = "all" ]; then \
		if ! [ -f $(ET_OPENSSL_BUILD_CRYPTO_SO) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] openssl crypto library build FAILED! *****\n"; \
			exit 2; \
		fi; \
		if ! [ -f $(ET_OPENSSL_BUILD_SSL_SO) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] openssl SSL library build FAILED! *****\n"; \
			exit 2; \
		fi; \
		if ! [ -f $(ET_OPENSSL_BUILD_BIN) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] openssl binary build FAILED! *****\n"; \
			exit 2; \
		fi; \
	fi
	@if [ -n "$(shell printf "%s" $1 | grep clean)" ]; then \
		$(RM) $(ET_OPENSSL_TARGET_FINAL); \
		$(RM) $(ET_OPENSSL_BUILD_CRYPTO_SO); \
		$(RM) $(ET_OPENSSL_BUILD_SSL_SO); \
		$(RM) $(ET_OPENSSL_BUILD_BIN); \
		$(RM) $(ET_OVERLAY_DIR)/usr/lib/*ssl* ; \
		$(RM) $(ET_OVERLAY_DIR)/usr/lib/*crypto* ; \
		$(RM) $(ET_OVERLAY_DIR)/usr/lib/pkgconfig/*ssl* ; \
		$(RM) $(ET_OVERLAY_DIR)/usr/lib/pkgconfig/*crypto* ; \
		$(RM) -r $(ET_OVERLAY_DIR)/usr/lib/engines* ; \
		$(RM) -r $(ET_OVERLAY_DIR)/usr/include/openssl; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] openssl-build 'make $1' done. *****\n\n"
endef

define openssl-config
	$(call software-check,$(ET_OPENSSL_TREE),openssl)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] openssl-config *****\n\n"
	$(call openssl-depends)
	@if [ -z "$1" ] || ! [ -f $(ET_OPENSSL_BUILD_DIR)/Makefile ]; then \
		cd $(ET_OPENSSL_BUILD_DIR) && \
			$(ET_OPENSSL_SOFTWARE_DIR)/Configure \
				linux-armv4 \
				--prefix=/usr \
				--openssldir=/etc/ssl \
				--cross-compile-prefix=$(ET_CROSS_COMPILE) \
				-I$(ET_ROOTFS_SYSROOT_DIR)/usr/include \
				-latomic \
				threads \
				shared \
				zlib-dynamic \
				enable-devcryptoeng \
				enable-weak-ssl-ciphers \
				no-tests \
				no-fuzz-libfuzzer \
				no-fuzz-afl \
				no-rc5 \
				enable-camellia \
				enable-mdc2; \
	fi
	@if ! [ -f $(ET_OPENSSL_BUILD_DIR)/Makefile ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-config FAILED! *****\n\n"; \
		exit 2; \
	fi
endef

define openssl-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-clean *****\n\n"
	$(RM) $(ET_OPENSSL_TARGET_FINAL)
	$(RM) $(ET_OPENSSL_BUILD_CRYPTO_SO)
	$(RM) $(ET_OPENSSL_BUILD_SSL_SO)
	$(RM) $(ET_OPENSSL_BUILD_BIN)
	$(RM) $(ET_OVERLAY_DIR)/usr/lib/*ssl*
	$(RM) $(ET_OVERLAY_DIR)/usr/lib/*crypto*
	$(RM) $(ET_OVERLAY_DIR)/usr/lib/pkgconfig/*ssl*
	$(RM) $(ET_OVERLAY_DIR)/usr/lib/pkgconfig/*crypto*
	$(RM) -r $(ET_OVERLAY_DIR)/usr/lib/engines*
	$(RM) -r $(ET_OVERLAY_DIR)/usr/include/openssl
endef

define openssl-purge
	$(call openssl-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-purge *****\n\n"
	$(RM) -r $(ET_OPENSSL_BUILD_DIR)
endef

define openssl-info
	@printf "========================================================================\n"
	@printf "ET_OPENSSL_TREE: $(ET_OPENSSL_TREE)\n"
	@printf "ET_OPENSSL_VERSION: $(ET_OPENSSL_VERSION)\n"
	@printf "ET_OPENSSL_SOFTWARE_DIR: $(ET_OPENSSL_SOFTWARE_DIR)\n"
	@printf "ET_OPENSSL_CRYPTO_SO: $(ET_OPENSSL_CRYPTO_SO)\n"
	@printf "ET_OPENSSL_SSL_SO: $(ET_OPENSSL_SSL_SO)\n"
	@printf "ET_OPENSSL_BIN: $(ET_OPENSSL_BIN)\n"
	@printf "ET_OPENSSL_BUILD_CONFIG: $(ET_OPENSSL_BUILD_CONFIG)\n"
	@printf "ET_OPENSSL_BUILD_CRYPTO_SO: $(ET_OPENSSL_BUILD_CRYPTO_SO)\n"
	@printf "ET_OPENSSL_BUILD_SSL_SO: $(ET_OPENSSL_BUILD_SSL_SO)\n"
	@printf "ET_OPENSSL_BUILD_BIN: $(ET_OPENSSL_BUILD_BIN)\n"
	@printf "ET_OPENSSL_BUILD_DIR: $(ET_OPENSSL_BUILD_DIR)\n"
	@printf "ET_OPENSSL_TARGET_FINAL: $(ET_OPENSSL_TARGET_FINAL)\n"
endef

.PHONY: openssl
openssl: $(ET_OPENSSL_TARGET_FINAL)
$(ET_OPENSSL_TARGET_FINAL): $(ET_OPENSSL_BUILD_CONFIG)
	$(call openssl-targets)

openssl-%: $(ET_OPENSSL_BUILD_CONFIG)
	$(call openssl-build,$(*F))

.PHONY: openssl-config
openssl-config: $(ET_OPENSSL_BUILD_CONFIG)
$(ET_OPENSSL_BUILD_CONFIG): $(ET_ROOTFS_TARGET_FINAL) $(ET_CRYPTODEV_LINUX_TARGET_FINAL)
ifeq ($(shell test -f $(ET_OPENSSL_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call openssl-config)
endif

.PHONY: openssl-clean
openssl-clean:
ifeq ($(ET_CLEAN),yes)
	$(call openssl-build,clean)
endif
	$(call $@)

.PHONY: openssl-purge
openssl-purge:
	$(call $@)

.PHONY: openssl-version
openssl-version:
	$(call $@)

.PHONY: openssl-info
openssl-info:
	$(call $@)
