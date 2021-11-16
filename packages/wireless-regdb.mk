#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2021 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://wireless.wiki.kernel.org/en/developers/Regulatory/wireless-regdb
# - https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git
# - https://git.busybox.net/buildroot/tree/package/wireless-regdb/wireless-regdb.mk
#

ifndef ET_BOARD_ROOTFS_TREE
$(error [ 'etinker' packages requires buildroot rootfs ] ***)
endif

export ET_WIRELESS_REGDB_TREE := wireless-regdb
export ET_WIRELESS_REGDB_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_WIRELESS_REGDB_TREE)
export ET_WIRELESS_REGDB_VERSION := $(shell cd $(ET_WIRELESS_REGDB_SOFTWARE_DIR) 2>/dev/null && git describe --long --dirty 2>/dev/null)
export ET_WIRELESS_REGDB_CACHED_VERSION := $(shell grep -Po 'wireless-regdb-ref:\K[^\n]*' $(ET_BOARD_DIR)/software.conf)
export ET_WIRELESS_REGDB_BUILD_X509_PEM := $(ET_WIRELESS_REGDB_SOFTWARE_DIR)/sforshee.x509.pem
export ET_WIRELESS_REGDB_BUILD_PUB_PEM := $(ET_WIRELESS_REGDB_SOFTWARE_DIR)/sforshee.key.pub.pem
export ET_WIRELESS_REGDB_BUILD_DB_P7S := $(ET_WIRELESS_REGDB_SOFTWARE_DIR)/regulatory.db.p7s
export ET_WIRELESS_REGDB_BUILD_DB := $(ET_WIRELESS_REGDB_SOFTWARE_DIR)/regulatory.db
export ET_WIRELESS_REGDB_BUILD_BIN := $(ET_WIRELESS_REGDB_SOFTWARE_DIR)/regulatory.bin
export ET_WIRELESS_REGDB_BUILD_CONFIG := $(ET_WIRELESS_REGDB_BUILD_BIN)
export ET_WIRELESS_REGDB_X509_PEM := $(ET_OVERLAY_DIR)/etc/wireless-regdb/pubkeys/sforshee.x509.pem
export ET_WIRELESS_REGDB_PUB_PEM := $(ET_OVERLAY_DIR)/etc/wireless-regdb/pubkeys/sforshee.key.pub.pem
export ET_WIRELESS_REGDB_DB_P7S := $(ET_OVERLAY_DIR)/usr/lib/firmware/regulatory.db.p7s
export ET_WIRELESS_REGDB_DB := $(ET_OVERLAY_DIR)/usr/lib/firmware/regulatory.db
export ET_WIRELESS_REGDB_BIN := $(ET_OVERLAY_DIR)/usr/lib/crda/regulatory.bin
export ET_WIRELESS_REGDB_TARGET_FINAL ?= $(ET_WIRELESS_REGDB_BIN)

define wireless-regdb-version
	@printf "ET_WIRELESS_REGDB_VERSION: \033[0;33m[$(ET_WIRELESS_REGDB_CACHED_VERSION)]\033[0m $(ET_WIRELESS_REGDB_VERSION)\n"
endef

define wireless-regdb-depends
	@mkdir -p $(ET_OVERLAY_DIR)/usr/lib/firmware
	@mkdir -p $(ET_OVERLAY_DIR)/usr/lib/crda
	@mkdir -p $(ET_OVERLAY_DIR)/etc/wireless-regdb/pubkeys
endef

define wireless-regdb-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb *****\n\n"
	$(call wireless-regdb-build,all)
endef

define wireless-regdb-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call wireless-regdb-build 'make $1' *****\n\n"
	$(call wireless-regdb-depends)
	@if [ "$1" = "all" ]; then \
		if ! [ -f $(ET_WIRELESS_REGDB_BUILD_X509_PEM) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb sforshee.x509.pem FAILED! *****\n"; \
			exit 2; \
		fi; \
		if ! [ -f $(ET_WIRELESS_REGDB_BUILD_PUB_PEM) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb sforshee.key.pub.pem FAILED! *****\n"; \
			exit 2; \
		fi; \
		if ! [ -f $(ET_WIRELESS_REGDB_BUILD_DB_P7S) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb regulatory.db.p7s FAILED! *****\n"; \
			exit 2; \
		fi; \
		if ! [ -f $(ET_WIRELESS_REGDB_BUILD_DB) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb regulatory.db FAILED! *****\n"; \
			exit 2; \
		fi; \
		if ! [ -f $(ET_WIRELESS_REGDB_BUILD_BIN) ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb regulatory.bin FAILED! *****\n"; \
			exit 2; \
		fi; \
		cp -av $(ET_WIRELESS_REGDB_BUILD_X509_PEM) $(ET_WIRELESS_REGDB_X509_PEM); \
		cp -av $(ET_WIRELESS_REGDB_BUILD_PUB_PEM) $(ET_WIRELESS_REGDB_PUB_PEM); \
		cp -av $(ET_WIRELESS_REGDB_BUILD_DB_P7S) $(ET_WIRELESS_REGDB_DB_P7S); \
		cp -av $(ET_WIRELESS_REGDB_BUILD_DB) $(ET_WIRELESS_REGDB_DB); \
		cp -av $(ET_WIRELESS_REGDB_BUILD_BIN) $(ET_WIRELESS_REGDB_BIN); \
	fi
	@if [ -n "$(shell printf "%s" $1 | grep clean)" ]; then \
		$(RM) $(ET_WIRELESS_REGDB_X509_PEM); \
		$(RM) $(ET_WIRELESS_REGDB_PUB_PEM); \
		$(RM) $(ET_WIRELESS_REGDB_DB_P7S); \
		$(RM) $(ET_WIRELESS_REGDB_DB); \
		$(RM) $(ET_WIRELESS_REGDB_BIN); \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb-build 'make $1' done. *****\n\n"
endef

define wireless-regdb-config
	$(call software-check,$(ET_WIRELESS_REGDB_TREE),wireless-regdb)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] wireless-regdb-config *****\n\n"
	$(call wireless-regdb-depends)
endef

define wireless-regdb-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call wireless-regdb-clean *****\n\n"
	$(RM) $(ET_WIRELESS_REGDB_X509_PEM)
	$(RM) $(ET_WIRELESS_REGDB_PUB_PEM)
	$(RM) $(ET_WIRELESS_REGDB_DB_P7S)
	$(RM) $(ET_WIRELESS_REGDB_DB)
	$(RM) $(ET_WIRELESS_REGDB_BIN)
endef

define wireless-regdb-purge
	$(call wireless-regdb-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call wireless-regdb-purge *****\n\n"
endef

define wireless-regdb-info
	@printf "========================================================================\n"
	@printf "ET_WIRELESS_REGDB_TREE: $(ET_WIRELESS_REGDB_TREE)\n"
	@printf "ET_WIRELESS_REGDB_VERSION: $(ET_WIRELESS_REGDB_VERSION)\n"
	@printf "ET_WIRELESS_REGDB_SOFTWARE_DIR: $(ET_WIRELESS_REGDB_SOFTWARE_DIR)\n"
	@printf "ET_WIRELESS_REGDB_BUILD_X509_PEM: $(ET_WIRELESS_REGDB_BUILD_X509_PEM)\n"
	@printf "ET_WIRELESS_REGDB_BUILD_PUB_PEM: $(ET_WIRELESS_REGDB_BUILD_PUB_PEM)\n"
	@printf "ET_WIRELESS_REGDB_BUILD_DB_P7S: $(ET_WIRELESS_REGDB_BUILD_DB_P7S)\n"
	@printf "ET_WIRELESS_REGDB_BUILD_DB: $(ET_WIRELESS_REGDB_BUILD_DB)\n"
	@printf "ET_WIRELESS_REGDB_BUILD_BIN: $(ET_WIRELESS_REGDB_BUILD_BIN)\n"
	@printf "ET_WIRELESS_REGDB_BUILD_CONFIG: $(ET_WIRELESS_REGDB_BUILD_CONFIG)\n"
	@printf "ET_WIRELESS_REGDB_X509_PEM: $(ET_WIRELESS_REGDB_X509_PEM)\n"
	@printf "ET_WIRELESS_REGDB_PUB_PEM: $(ET_WIRELESS_REGDB_PUB_PEM)\n"
	@printf "ET_WIRELESS_REGDB_DB_P7S: $(ET_WIRELESS_REGDB_DB_P7S)\n"
	@printf "ET_WIRELESS_REGDB_DB: $(ET_WIRELESS_REGDB_DB)\n"
	@printf "ET_WIRELESS_REGDB_BIN: $(ET_WIRELESS_REGDB_BIN)\n"
	@printf "ET_WIRELESS_REGDB_TARGET_FINAL: $(ET_WIRELESS_REGDB_TARGET_FINAL)\n"
endef

.PHONY: wireless-regdb
wireless-regdb: $(ET_WIRELESS_REGDB_TARGET_FINAL)
$(ET_WIRELESS_REGDB_TARGET_FINAL): $(ET_WIRELESS_REGDB_BUILD_CONFIG)
	$(call wireless-regdb-targets)

wireless-regdb-%: $(ET_WIRELESS_REGDB_BUILD_CONFIG)
	$(call wireless-regdb-build,$(*F))

.PHONY: wireless-regdb-config
wireless-regdb-config: $(ET_WIRELESS_REGDB_BUILD_CONFIG)
$(ET_WIRELESS_REGDB_BUILD_CONFIG):
ifeq ($(shell test -f $(ET_WIRELESS_REGDB_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call wireless-regdb-config)
endif

.PHONY: wireless-regdb-clean
wireless-regdb-clean:
ifeq ($(ET_CLEAN),yes)
	$(call wireless-regdb-build,clean)
endif
	$(call $@)

.PHONY: wireless-regdb-purge
wireless-regdb-purge:
	$(call $@)

.PHONY: wireless-regdb-version
wireless-regdb-version:
	$(call $@)

.PHONY: wireless-regdb-info
wireless-regdb-info:
	$(call $@)

.PHONY: wireless-regdb-update
wireless-regdb-update: wireless-regdb-clean wireless-regdb
