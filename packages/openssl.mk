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
export ET_OPENSSL_BUILD_DIR := $(ET_OVERLAY_BUILD_DIR)/openssl
export ET_OPENSSL_BUILD_CONFIG := $(ET_OPENSSL_BUILD_DIR)/configdata.pm
export ET_OPENSSL_BUILD_CRYPTO_SO := $(ET_OPENSSL_BUILD_DIR)/libcrypto.so
export ET_OPENSSL_BUILD_SSL_SO := $(ET_OPENSSL_BUILD_DIR)/libssl.so
export ET_OPENSSL_BUILD_BIN := $(ET_OPENSSL_BUILD_DIR)/apps/openssl
export ET_OPENSSL_DIR := $(ET_OVERLAY_DIR)
export ET_OPENSSL_CRYPTO_SO := $(ET_OPENSSL_DIR)/usr/lib/libcrypto.so
export ET_OPENSSL_SSL_SO := $(ET_OPENSSL_DIR)/usr/lib/libssl.so
export ET_OPENSSL_BIN := $(ET_OPENSSL_DIR)/usr/bin/openssl
export ET_OPENSSL_TARGET_FINAL += $(ET_OPENSSL_BIN)

define openssl-version
	@printf "ET_OPENSSL_VERSION: $(ET_OPENSSL_VERSION)\n"
endef

define openssl-depends
	@mkdir -p $(ET_OPENSSL_DIR)
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

define openssl-config
	$(call software-check,$(ET_OPENSSL_TREE))
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] openssl-config *****\n\n"
	$(call openssl-depends)
	@cd $(ET_OPENSSL_BUILD_DIR) && \
		$(ET_OPENSSL_SOFTWARE_DIR)/Configure \
			linux-armv4 \
			--prefix=/usr \
			--openssldir=/etc/ssl \
			--cross-compile-prefix=$(ET_CROSS_COMPILE) \
			-I$(ET_ROOTFS_SYSROOT_DIR)/usr/include \
			-DHAVE_CRYPTODEV -DUSE_CRYPTODEV_DIGESTS \
			enable-weak-ssl-ciphers \
			threads \
			shared \
			zlib-dynamic \
			no-rc5 \
			enable-camellia \
			enable-mdc2 \
			enable-tlsext
	@if ! [ -f $(ET_OPENSSL_BUILD_DIR)/Makefile ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-config FAILED! *****\n\n"; \
		exit 2; \
	fi
endef

define openssl-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-build 'make $1' *****\n\n"
	@case "$1" in \
	install_dev) \
		sed -i s,DESTDIR=,DESTDIR=$$\(ET_ROOTFS_SYSROOT_DIR\), $(ET_OPENSSL_BUILD_DIR)/Makefile; \
		;; \
	*) \
		sed -i s,DESTDIR=,DESTDIR=$$\(ET_OPENSSL_DIR\), $(ET_OPENSSL_BUILD_DIR)/Makefile; \
		;; \
	esac
	@$(MAKE) -C $(ET_OPENSSL_BUILD_DIR) $1
	@case "$1" in \
	install_dev) \
		sed -i s,DESTDIR=$$\(ET_ROOTFS_SYSROOT_DIR\),DESTDIR=, $(ET_OPENSSL_BUILD_DIR)/Makefile; \
		;; \
	*) \
		sed -i s,DESTDIR=$$\(ET_OPENSSL_DIR\),DESTDIR=, $(ET_OPENSSL_BUILD_DIR)/Makefile; \
		if [ "$1" = "install_runtime" ]; then \
			cd $(ET_OPENSSL_DIR)/usr/lib/ && \
				ln -sf libcrypto*.so.* libcrypto.so && \
				ln -sf libssl*.so.* libssl.so; \
		fi; \
		;; \
	esac
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
endef

define openssl-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-clean *****\n\n"
	$(RM) $(ET_OPENSSL_TARGET_FINAL)
	$(RM) $(ET_OPENSSL_BUILD_CRYPTO_SO)
	$(RM) $(ET_OPENSSL_BUILD_SSL_SO)
	$(RM) $(ET_OPENSSL_BUILD_BIN)
	$(RM) $(ET_OPENSSL_DIR)/usr/lib/*ssl*
	$(RM) $(ET_OPENSSL_DIR)/usr/lib/*crypto*
	$(RM) $(ET_OPENSSL_DIR)/usr/lib/pkgconfig/*ssl*
	$(RM) $(ET_OPENSSL_DIR)/usr/lib/pkgconfig/*crypto*
	$(RM) -r $(ET_OPENSSL_DIR)/usr/lib/engines*
	$(RM) -r $(ET_ROOTFS_SYSROOT_DIR)/usr/include/openssl
endef

define openssl-purge
	$(call openssl-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call openssl-purge *****\n\n"
	$(RM) -r $(ET_OPENSSL_BUILD_DIR)
endef

define openssl-info
	@printf "ET_OPENSSL_TREE: $(ET_OPENSSL_TREE)\n"
	@printf "ET_OPENSSL_VERSION: $(ET_OPENSSL_VERSION)\n"
	@printf "ET_OPENSSL_SOFTWARE_DIR: $(ET_OPENSSL_SOFTWARE_DIR)\n"
	@printf "ET_OPENSSL_BUILD_CONFIG: $(ET_OPENSSL_BUILD_CONFIG)\n"
	@printf "ET_OPENSSL_BUILD_CRYPTO_SO: $(ET_OPENSSL_BUILD_CRYPTO_SO)\n"
	@printf "ET_OPENSSL_BUILD_SSL_SO: $(ET_OPENSSL_BUILD_SSL_SO)\n"
	@printf "ET_OPENSSL_BUILD_BIN: $(ET_OPENSSL_BUILD_BIN)\n"
	@printf "ET_OPENSSL_CRYPTO_SO: $(ET_OPENSSL_CRYPTO_SO)\n"
	@printf "ET_OPENSSL_SSL_SO: $(ET_OPENSSL_SSL_SO)\n"
	@printf "ET_OPENSSL_BIN: $(ET_OPENSSL_BIN)\n"
	@printf "ET_OPENSSL_DIR: $(ET_OPENSSL_DIR)\n"
	@printf "ET_OPENSSL_BUILD_DIR: $(ET_OPENSSL_BUILD_DIR)\n"
	@printf "ET_OPENSSL_TARGET_FINAL: $(ET_OPENSSL_TARGET_FINAL)\n"
endef

.PHONY: openssl
openssl: $(ET_OPENSSL_TARGET_FINAL)
$(ET_OPENSSL_TARGET_FINAL): $(ET_OPENSSL_BUILD_CONFIG)
	$(call openssl-targets)

.PHONY: openssl-config
openssl-config: $(ET_OPENSSL_BUILD_CONFIG)
$(ET_OPENSSL_BUILD_CONFIG): $(ET_CRYPTODEV_LINUX_TARGET_FINAL)
	$(call openssl-config)

openssl-%: $(ET_OPENSSL_BUILD_CONFIG)
	$(call openssl-build,$(*F))

.PHONY: openssl-clean
openssl-clean:
	$(call openssl-clean)

.PHONY: openssl-purge
openssl-purge:
	$(call openssl-purge)

.PHONY: openssl-version
openssl-version:
	$(call openssl-version)

.PHONY: openssl-info
openssl-info:
	$(call openssl-info)
