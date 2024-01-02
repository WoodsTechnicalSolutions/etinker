#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2024, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git/
# - https://git.busybox.net/buildroot/tree/package/rt-tests/rt-tests.mk
# - https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests
#

ifdef ET_BOARD_ROOTFS_TREE

export ET_RT_TESTS_TREE := rt-tests
export ET_RT_TESTS_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_RT_TESTS_TREE)
export ET_RT_TESTS_VERSION := $(shell cd $(ET_RT_TESTS_SOFTWARE_DIR) 2>/dev/null && git describe --long --dirty 2>/dev/null)
export ET_RT_TESTS_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) rt-tests-ref)
export ET_RT_TESTS_BUILD_DIR := $(ET_OVERLAY_BUILD_DIR)/$(ET_RT_TESTS_TREE)
export ET_RT_TESTS_BUILD_CONFIG := $(ET_RT_TESTS_BUILD_DIR)/.configured
export ET_RT_TESTS_BUILD_BIN := $(ET_RT_TESTS_BUILD_DIR)/bld/oslat
export ET_RT_TESTS_BIN := $(ET_OVERLAY_DIR)/usr/bin/oslat
export ET_RT_TESTS_TARGET_FINAL ?= $(ET_RT_TESTS_BIN)

export ET_RT_TESTS_PROGRAMS := cyclictest \
	hackbench \
	pip_stress \
	pi_stress \
	pmqtest \
	ptsematest \
	rt-migrate-test \
	signaltest \
	sigwaittest \
	svsematest \
	cyclicdeadline \
	deadline_test \
	queuelat \
	ssdd \
	oslat

define rt-tests-version
	@printf "ET_RT_TESTS_VERSION: \033[0;33m[$(ET_RT_TESTS_CACHED_VERSION)]\033[0m $(ET_RT_TESTS_VERSION)\n"
endef

define rt-tests-software
	$(call software-check,$(ET_RT_TESTS_TREE),rt-tests,fetch)
endef

define rt-tests-depends
	$(call software-check,$(ET_RT_TESTS_TREE),rt-tests)
	@mkdir -p $(ET_OVERLAY_DIR)
	@mkdir -p $(ET_OVERLAY_DIR)/usr/bin
	@mkdir -p $(ET_OVERLAY_DIR)/usr/lib
endef

define rt-tests-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] rt-tests *****\n\n"
	$(call rt-tests-build,cyclictest)
	$(call rt-tests-build,hackbench)
	$(call rt-tests-build,pip_stress)
	$(call rt-tests-build,pi_stress)
	$(call rt-tests-build,pmqtest)
	$(call rt-tests-build,ptsematest)
	$(call rt-tests-build,rt-migrate-test)
	$(call rt-tests-build,signaltest)
	$(call rt-tests-build,sigwaittest)
	$(call rt-tests-build,svsematest)
	$(call rt-tests-build,cyclicdeadline)
	$(call rt-tests-build,deadline_test)
	$(call rt-tests-build,queuelat)
	$(call rt-tests-build,ssdd)
	$(call rt-tests-build,oslat)
	@for p in $(ET_RT_TESTS_PROGRAMS); do \
		if ! [ -f $(ET_RT_TESTS_BUILD_DIR)/$$p ]; then \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] rt-tests $$p build FAILED! *****\n"; \
			exit 2; \
		fi; \
		cp $(ET_RT_TESTS_BUILD_DIR)/$$p $(ET_OVERLAY_DIR)/usr/bin/; \
	done
endef

define rt-tests-build
	$(call rt-tests-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rt-tests-build 'make $1' *****\n\n"
	if [ -d $(ET_RT_TESTS_BUILD_DIR) ]; then \
		$(ET_MAKE) -C $(ET_RT_TESTS_BUILD_DIR) \
			prefix=$(ET_OVERLAY_DIR)/usr \
			CROSS_COMPILE=$(ET_CROSS_COMPILE) \
			CFLAGS="-Wall -Wno-nonnull -I$(ET_ROOTFS_BUILD_DIR)/staging/usr/include" \
			LDFLAGS="-L$(ET_ROOTFS_BUILD_DIR)/staging/usr/lib" \
			$1; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] rt-tests-build 'make $1' done. *****\n\n"
endef

define rt-tests-config
	$(call rt-tests-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] rt-tests-config *****\n\n"
	@if ! [ -d $(ET_RT_TESTS_BUILD_DIR) ] || ! [ -f $(ET_RT_TESTS_BUILD_CONFIG) ]; then \
		rsync -aP $(ET_RT_TESTS_SOFTWARE_DIR) $(shell dirname $(ET_RT_TESTS_BUILD_DIR))/; \
		printf "%s\n" "$(shell date)" > $(ET_RT_TESTS_BUILD_CONFIG); \
	fi
endef

define rt-tests-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rt-tests-clean *****\n\n"
	$(call rt-tests-build,clean)
	@for p in $(ET_RT_TESTS_PROGRAMS); do \
		$(RM) -v $(ET_OVERLAY_DIR)/usr/bin/$$p; \
	done
	$(RM) $(ET_RT_TESTS_BUILD_CONFIG)
endef

define rt-tests-purge
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call rt-tests-purge *****\n\n"
	$(call rt-tests-clean)
	$(RM) -r $(ET_RT_TESTS_BUILD_DIR)
endef

define rt-tests-info
	@printf "========================================================================\n"
	@printf "ET_RT_TESTS_TREE: $(ET_RT_TESTS_TREE)\n"
	@printf "ET_RT_TESTS_VERSION: $(ET_RT_TESTS_VERSION)\n"
	@printf "ET_RT_TESTS_SOFTWARE_DIR: $(ET_RT_TESTS_SOFTWARE_DIR)\n"
	@printf "ET_RT_TESTS_BUILD_CONFIG: $(ET_RT_TESTS_BUILD_CONFIG)\n"
	@printf "ET_RT_TESTS_BUILD_BIN: $(ET_RT_TESTS_BUILD_BIN)\n"
	@printf "ET_RT_TESTS_BUILD_DIR: $(ET_RT_TESTS_BUILD_DIR)\n"
	@printf "ET_RT_TESTS_BIN: $(ET_RT_TESTS_BIN)\n"
	@printf "ET_RT_TESTS_PROGRAMS: $(ET_RT_TESTS_PROGRAMS)\n"
	@printf "ET_RT_TESTS_TARGET_FINAL: $(ET_RT_TESTS_TARGET_FINAL)\n"
endef

define rt-tests-update
	@$(ET_MAKE) -C $(ET_DIR) rt-tests-clean
	@$(ET_MAKE) -C $(ET_DIR) rt-tests
endef

define rt-tests-all
	@$(ET_MAKE) -C $(ET_DIR) rt-tests
endef

.PHONY: rt-tests
rt-tests: $(ET_RT_TESTS_TARGET_FINAL)
$(ET_RT_TESTS_TARGET_FINAL): $(ET_RT_TESTS_BUILD_CONFIG)
	$(call rt-tests-targets)

rt-tests-%: $(ET_RT_TESTS_BUILD_CONFIG)
	$(call rt-tests-build,$(*F))

.PHONY: rt-tests-config
rt-tests-config: $(ET_RT_TESTS_BUILD_CONFIG)
$(ET_RT_TESTS_BUILD_CONFIG): $(ET_ROOTFS_TARGET_FINAL)
ifeq ($(shell test -f $(ET_RT_TESTS_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call rt-tests-config)
endif

.PHONY: rt-tests-clean
rt-tests-clean:
	$(call $@)

.PHONY: rt-tests-purge
rt-tests-purge:
	$(call $@)

.PHONY: rt-tests-version
rt-tests-version: $(ET_RT_TESTS_BUILD_CONFIG)
	$(call $@)

.PHONY: rt-tests-software
rt-tests-software: $(ET_RT_TESTS_BUILD_CONFIG)
	$(call $@)

.PHONY: rt-tests-info
rt-tests-info: $(ET_RT_TESTS_BUILD_CONFIG)
	$(call $@)

.PHONY: rt-tests-update
rt-tests-update:
	$(call $@)

.PHONY: rt-tests-all
rt-tests-all:
	$(call $@)

endif
# ET_BOARD_ROOTFS_TREE
