#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2019-2024, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
# [references]
# - https://ip.cadence.com/ipportfolio/ip-portfolio-overview/systems-peripherals/bus-ip/pwm-ip
# - https://github.com/woodsts/cadence-ttc-pwm
#

ifeq ($(shell echo $(ET_BOARD_TYPE) | grep -o zynq),zynq)
ifdef ET_BOARD_ROOTFS_TREE
ifdef ET_BOARD_KERNEL_TREE

module_build_dir := $(ET_DIR)/overlay/build/$(ET_KERNEL_TYPE)/$(ET_CROSS_TUPLE)

export ET_CADENCE_TTC_PWM_TREE := cadence-ttc-pwm
export ET_CADENCE_TTC_PWM_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_CADENCE_TTC_PWM_TREE)
export ET_CADENCE_TTC_PWM_VERSION := $(shell cd $(ET_CADENCE_TTC_PWM_SOFTWARE_DIR) $(ET_NOERR) && git describe --always --long --dirty $(ET_NOERR))
export ET_CADENCE_TTC_PWM_CACHED_VERSION := $(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) cadence-ttc-pwm-ref)
export ET_CADENCE_TTC_PWM_BUILD_DIR := $(module_build_dir)/$(ET_CADENCE_TTC_PWM_TREE)
export ET_CADENCE_TTC_PWM_BUILD_CONFIG := $(ET_CADENCE_TTC_PWM_BUILD_DIR)/Makefile
export ET_CADENCE_TTC_PWM_BUILD_KO := $(ET_CADENCE_TTC_PWM_BUILD_DIR)/pwm-cadence.ko
export ET_CADENCE_TTC_PWM_KO := $(ET_KERNEL_DIR)/usr/lib/modules/$(ET_KERNEL_VERSION)$(ET_KERNEL_LOCALVERSION)/updates/pwm-cadence.ko
export ET_CADENCE_TTC_PWM_TARGET_FINAL ?= $(ET_CADENCE_TTC_PWM_KO)

define cadence-ttc-pwm-version
	@printf "ET_CADENCE_TTC_PWM_VERSION: \033[0;33m[$(ET_CADENCE_TTC_PWM_CACHED_VERSION)]\033[0m $(ET_CADENCE_TTC_PWM_VERSION)\n"
endef

define cadence-ttc-pwm-software
	$(call software-check,$(ET_CADENCE_TTC_PWM_TREE),cadence-ttc-pwm,fetch)
endef

define cadence-ttc-pwm-depends
	$(call software-check,$(ET_CADENCE_TTC_PWM_TREE),cadence-ttc-pwm)
	@mkdir -p $(shell dirname $(ET_CADENCE_TTC_PWM_BUILD_DIR))
endef

define cadence-ttc-pwm-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cadence-ttc-pwm *****\n\n"
	$(call cadence-ttc-pwm-config)
	$(call cadence-ttc-pwm-build,build)
endef

define cadence-ttc-pwm-build
	$(call cadence-ttc-pwm-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call cadence-ttc-pwm-build 'make $1' *****\n\n"
	@$(MAKE) -C $(ET_CADENCE_TTC_PWM_BUILD_DIR) $1
	@if ! [ -f $(ET_CADENCE_TTC_PWM_BUILD_KO) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_CADENCE_TTC_PWM_TREE) $1 FAILED! *****\n"; \
		exit 2; \
	fi
	@if [ -n "$(shell printf "%s" $1 | grep clean)" ]; then \
		$(RM) $(ET_CADENCE_TTC_PWM_TARGET_FINAL); \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cadence-ttc-pwm-build 'make $1' done. *****\n\n"
endef

define cadence-ttc-pwm-config
	$(call cadence-ttc-pwm-depends)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] cadence-ttc-pwm-config *****\n\n"
	@if ! [ -d $(ET_CADENCE_TTC_PWM_BUILD_DIR) ]; then \
		mkdir $(ET_CADENCE_TTC_PWM_BUILD_DIR); \
		cp -a $(ET_CADENCE_TTC_PWM_SOFTWARE_DIR)/src/kernel/pwm-cadence.c $(ET_CADENCE_TTC_PWM_BUILD_DIR)/; \
		printf "obj-m += pwm-cadence.o\n\n"          > $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "ccflags-y += -Wno-date-time\n\n"          >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "ccflags-y += -Wno-missing-attributes\n\n" >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "build: all\n\n"                     >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "all: install\n\n"                   >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "install: modules\n"                 >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "\tmake -C $(ET_KERNEL_BUILD_DIR) "  >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "M=$(ET_CADENCE_TTC_PWM_BUILD_DIR) " >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "$(ET_CROSS_PARAMS) "                >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "INSTALL_MOD_PATH=$(ET_KERNEL_DIR)/usr " >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "modules_install\n\n"                >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "modules:\n"                         >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "\tmake -C $(ET_KERNEL_BUILD_DIR) "  >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "M=$(ET_CADENCE_TTC_PWM_BUILD_DIR) " >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "$(ET_CROSS_PARAMS) "                >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "modules\n\n"                        >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "clean:\n"                           >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "\tmake -C $(ET_KERNEL_BUILD_DIR) "  >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "M=$(ET_CADENCE_TTC_PWM_BUILD_DIR) " >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "$(ET_CROSS_PARAMS) "                >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
		printf "clean\n"                            >> $(ET_CADENCE_TTC_PWM_BUILD_CONFIG); \
	fi
	@if ! [ -f $(ET_CADENCE_TTC_PWM_BUILD_CONFIG) ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_CADENCE_TTC_PWM_TREE) configuration FAILED! *****\n"; \
		exit 2; \
	fi
endef

define cadence-ttc-pwm-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call cadence-ttc-pwm-clean *****\n\n"
	$(RM) $(ET_CADENCE_TTC_PWM_TARGET_FINAL)
	$(RM) $(ET_CADENCE_TTC_PWM_BUILD_KO)
endef

define cadence-ttc-pwm-purge
	$(call cadence-ttc-pwm-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call cadence-ttc-pwm-purge *****\n\n"
	$(RM) -r $(ET_CADENCE_TTC_PWM_BUILD_DIR)
	$(call cadence-ttc-pwm-config)
endef

define cadence-ttc-pwm-info
	@printf "========================================================================\n"
	@printf "ET_CADENCE_TTC_PWM_TREE: $(ET_CADENCE_TTC_PWM_TREE)\n"
	@printf "ET_CADENCE_TTC_PWM_VERSION: $(ET_CADENCE_TTC_PWM_VERSION)\n"
	@printf "ET_CADENCE_TTC_PWM_SOFTWARE_DIR: $(ET_CADENCE_TTC_PWM_SOFTWARE_DIR)\n"
	@printf "ET_CADENCE_TTC_PWM_BUILD_CONFIG: $(ET_CADENCE_TTC_PWM_BUILD_CONFIG)\n"
	@printf "ET_CADENCE_TTC_PWM_BUILD_KO: $(ET_CADENCE_TTC_PWM_BUILD_KO)\n"
	@printf "ET_CADENCE_TTC_PWM_BUILD_DIR: $(ET_CADENCE_TTC_PWM_BUILD_DIR)\n"
	@printf "ET_CADENCE_TTC_PWM_KO: $(ET_CADENCE_TTC_PWM_KO)\n"
	@printf "ET_CADENCE_TTC_PWM_TARGET_FINAL: $(ET_CADENCE_TTC_PWM_TARGET_FINAL)\n"
endef

define cadence-ttc-pwm-update
	@$(ET_MAKE) -C $(ET_DIR) cadence-ttc-pwm-clean
	@$(ET_MAKE) -C $(ET_DIR) cadence-ttc-pwm
endef

define cadence-ttc-pwm-all
	@$(ET_MAKE) -C $(ET_DIR) cadence-ttc-pwm
endef

.PHONY: cadence-ttc-pwm
cadence-ttc-pwm: $(ET_CADENCE_TTC_PWM_TARGET_FINAL)
$(ET_CADENCE_TTC_PWM_TARGET_FINAL): $(ET_CADENCE_TTC_PWM_BUILD_CONFIG)
	$(call cadence-ttc-pwm-targets)

cadence-ttc-pwm-%: $(ET_CADENCE_TTC_PWM_BUILD_CONFIG)
	$(call cadence-ttc-pwm-build,$(*F))

.PHONY: cadence-ttc-pwm-config
cadence-ttc-pwm-config: $(ET_CADENCE_TTC_PWM_BUILD_CONFIG)
$(ET_CADENCE_TTC_PWM_BUILD_CONFIG): $(ET_KERNEL_TARGET_FINAL)
ifeq ($(shell test -f $(ET_CADENCE_TTC_PWM_BUILD_CONFIG) && printf "DONE" || printf "CONFIGURE"),CONFIGURE)
	$(call cadence-ttc-pwm-config)
endif

.PHONY: cadence-ttc-pwm-clean
cadence-ttc-pwm-clean:
ifeq ($(ET_CLEAN),yes)
	$(call cadence-ttc-pwm-build,clean)
endif
	$(call $@)

.PHONY: cadence-ttc-pwm-purge
cadence-ttc-pwm-purge:
	$(call $@)

.PHONY: cadence-ttc-pwm-version
cadence-ttc-pwm-version:
	$(call $@)

.PHONY: cadence-ttc-pwm-software
cadence-ttc-pwm-software:
	$(call $@)

.PHONY: cadence-ttc-pwm-info
cadence-ttc-pwm-info:
	$(call $@)

.PHONY: cadence-ttc-pwm-update
cadence-ttc-pwm-update:
	$(call $@)

.PHONY: cadence-ttc-pwm-all
cadence-ttc-pwm-all:
	$(call $@)

endif
# ET_BOARD_KERNEL_TREE
endif
# ET_BOARD_ROOTFS_TREE
endif
# zynq
