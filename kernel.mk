#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_BOARD_KERNEL_TREE
$(error [ 'etinker' kernel build requires ET_BOARD_KERNEL_TREE ] ***)
endif

# embedded kernel, for application processors, is GNU Linux
export ET_KERNEL_TREE := $(ET_BOARD_KERNEL_TREE)
export ET_KERNEL_DT := $(ET_BOARD_KERNEL_DT)
export ET_KERNEL_LOADADDR := $(ET_BOARD_KERNEL_LOADADDR)
export ET_KERNEL_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_BOARD_KERNEL_TREE)
# [start] kernel version magic
ET_KERNEL_VERSION := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | tr -d v | cut -d '-' -f 1)
ET_KERNEL_LOCALVERSION := -$(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | cut -d '-' -f 2-5)
ifeq ($(ET_KERNEL_LOCALVERSION),-)
ET_KERNEL_LOCALVERSION :=
endif
ifeq ($(ET_KERNEL_VERSION),next)
kversion := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && make kernelversion | tr -d \\n)
klocalversion := $(shell cd $(ET_KERNEL_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null)
ET_KERNEL_VERSION := $(kversion)-$(klocalversion)
ET_KERNEL_LOCALVERSION :=
endif
ifeq ($(shell echo $(ET_KERNEL_LOCALVERSION) | sed s,[0-9],,),-rc)
ET_KERNEL_VERSION := $(ET_KERNEL_VERSION).0$(ET_KERNEL_LOCALVERSION)
ET_KERNEL_LOCALVERSION :=
endif
ifeq ($(ET_KERNEL_LOCALVERSION),-v$(ET_KERNEL_VERSION))
ET_KERNEL_VERSION := $(ET_KERNEL_VERSION).0
ET_KERNEL_LOCALVERSION :=
endif
export ET_KERNEL_VERSION
export ET_KERNEL_LOCALVERSION
# [end] kernel version magic
export ET_KERNEL_DIR := $(ET_DIR)/kernel/$(ET_BOARD_TYPE)/$(ET_CROSS_TUPLE)
export ET_KERNEL_BUILD_DIR := $(ET_DIR)/kernel/build/$(ET_BOARD_TYPE)/$(ET_CROSS_TUPLE)
export ET_KERNEL_BUILD_BOOT_DIR := $(ET_KERNEL_BUILD_DIR)/arch/$(ET_ARCH)/boot
export ET_KERNEL_CONFIG := $(ET_CONFIG_DIR)/$(ET_KERNEL_TREE)/config
export ET_KERNEL_SYSMAP := $(ET_KERNEL_DIR)/boot/System.map
export ET_KERNEL_DTB := $(ET_KERNEL_DIR)/boot/$(ET_KERNEL_DT).dtb
export ET_KERNEL_UIMAGE := $(ET_KERNEL_DIR)/boot/uImage
export ET_KERNEL_ZIMAGE := $(ET_KERNEL_DIR)/boot/zImage
export ET_KERNEL_CONFIGURED := $(ET_KERNEL_BUILD_DIR)/configured
export ET_KERNEL_BUILD_CONFIG := $(ET_KERNEL_BUILD_DIR)/.config
export ET_KERNEL_BUILD_SYSMAP := $(ET_KERNEL_BUILD_DIR)/System.map
export ET_KERNEL_BUILD_DTB := $(ET_KERNEL_BUILD_BOOT_DIR)/dts/$(ET_KERNEL_DT).dtb
export ET_KERNEL_BUILD_UIMAGE := $(ET_KERNEL_BUILD_BOOT_DIR)/uImage
export ET_KERNEL_BUILD_ZIMAGE := $(ET_KERNEL_BUILD_BOOT_DIR)/zImage
export ET_KERNEL_TARGET_FINAL += $(ET_KERNEL_DTB)

export CT_LINUX_CUSTOM_LOCATION := ${ET_KERNEL_SOFTWARE_DIR}

define kernel-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION) *****\n\n"
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_KERNEL_SOFTWARE_DIR) O=$(ET_KERNEL_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		zImage \
		LOADADDR=$(ET_KERNEL_LOADADDR) \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION)
	@if [ -f $(ET_KERNEL_BUILD_ZIMAGE) ]; then \
		$(RM) $(ET_KERNEL_ZIMAGE) $(ET_KERNEL_SYSMAP); \
	        cp -av $(ET_KERNEL_BUILD_ZIMAGE) $(ET_KERNEL_BUILD_SYSMAP) \
			$(ET_KERNEL_DIR)/boot/; \
	else \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION) zImage FAILED! *****\n"; \
		exit 2; \
	fi
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_KERNEL_SOFTWARE_DIR) O=$(ET_KERNEL_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		uImage \
		LOADADDR=$(ET_KERNEL_LOADADDR) \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION)
	@if [ -f $(ET_KERNEL_BUILD_UIMAGE) ]; then \
		$(RM) $(ET_KERNEL_UIMAGE); \
	        cp -av $(ET_KERNEL_BUILD_UIMAGE) $(ET_KERNEL_DIR)/boot/; \
	else \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION) uImage FAILED! *****\n"; \
		exit 2; \
	fi
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_KERNEL_SOFTWARE_DIR) O=$(ET_KERNEL_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		$(ET_KERNEL_DT).dtb \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION)
	@if [ -f $(ET_KERNEL_BUILD_DTB) ]; then \
		$(RM) $(ET_KERNEL_DTB); \
		cp -av $(ET_KERNEL_BUILD_DTB) $(ET_KERNEL_DIR)/boot/; \
	else \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION) $(ET_KERNEL_DT).dtb FAILED! *****\n"; \
		exit 2; \
	fi
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_KERNEL_SOFTWARE_DIR) O=$(ET_KERNEL_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		modules \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION)
	@$(RM) -r $(ET_KERNEL_DIR)/lib/modules
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_KERNEL_SOFTWARE_DIR) O=$(ET_KERNEL_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		modules_install \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION) \
		INSTALL_MOD_PATH=$(ET_KERNEL_DIR)
	@if [ -d $(ET_KERNEL_DIR)/lib/modules ]; then \
		find $(ET_KERNEL_DIR)/lib/modules -type l -exec rm -f {} \; ; \
	fi
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_KERNEL_SOFTWARE_DIR) O=$(ET_KERNEL_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		headers_install \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION) \
		INSTALL_HDR_PATH=$(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot/usr/include
endef

define kernel-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] kernel 'make $1' *****\n\n"
	@mkdir -p $(ET_KERNEL_DIR)/boot
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_KERNEL_SOFTWARE_DIR) O=$(ET_KERNEL_BUILD_DIR) \
		$(ET_CROSS_PARAMS) \
		$1 \
		LOADADDR=$(ET_KERNEL_LOADADDR) \
		LOCALVERSION=$(ET_KERNEL_LOCALVERSION) \
		INSTALL_MOD_PATH=$(ET_KERNEL_DIR) \
		INSTALL_HDR_PATH=$(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot/usr/include
	@case "$1" in \
	zImage) \
		if [ -f $(ET_KERNEL_BUILD_ZIMAGE) ]; then \
			$(RM) $(ET_KERNEL_DIR)/boot/zImage \
				$(ET_KERNEL_DIR)/boot/System.map; \
		        cp -av $(ET_KERNEL_BUILD_ZIMAGE) \
				$(ET_KERNEL_BUILD_SYSMAP) \
				$(ET_KERNEL_DIR)/boot/; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION) zImage FAILED! *****\n"; \
			exit 2; \
		fi; \
		;; \
	uImage) \
		if [ -f $(ET_KERNEL_BUILD_UIMAGE) ]; then \
			$(RM) $(ET_KERNEL_DIR)/boot/uImage; \
		        cp -av $(ET_KERNEL_BUILD_UIMAGE) \
				$(ET_KERNEL_DIR)/boot/; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION) uImage FAILED! *****\n"; \
			exit 2; \
		fi; \
		;; \
	$(ET_KERNEL_DT).dtb) \
		if [ -f $(ET_KERNEL_BUILD_DTB) ]; then \
			$(RM) $(ET_KERNEL_DIR)/boot/$(ET_KERNEL_DT).dtb; \
			cp -av $(ET_KERNEL_BUILD_DTB) $(ET_KERNEL_DIR)/boot/; \
		else \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_KERNEL_TREE) $(ET_KERNEL_VERSION) $(ET_KERNEL_DT).dtb FAILED! *****\n"; \
			exit 2; \
		fi; \
		;; \
	modules_install) \
		if [ -d $(ET_KERNEL_DIR)/lib/modules ]; then \
			find $(ET_KERNEL_DIR)/lib/modules -type l -exec rm -f {} \; ; \
		fi; \
		;; \
	*clean) \
		$(RM) $(ET_KERNEL_DIR)/boot/*; \
		$(RM) -r $(ET_KERNEL_DIR)/lib/modules/*; \
		;; \
	*) \
		;; \
	esac
	@if [ -n "$(shell printf "%s" $1 | grep config)" ]; then \
		if [ -n "$(shell diff -q $(ET_KERNEL_BUILD_CONFIG) $(ET_KERNEL_CONFIG) 2> /dev/null)" ]; then \
			cat $(ET_KERNEL_BUILD_CONFIG) > $(ET_KERNEL_CONFIG); \
		fi; \
	fi
endef

define kernel-config
	$(call software-check,$(ET_KERNEL_TREE))
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] make kernel-config *****\n\n"
	@mkdir -p $(ET_KERNEL_DIR)/boot
	@mkdir -p $(ET_KERNEL_DIR)/lib/modules
	@mkdir -p $(ET_KERNEL_BUILD_BOOT_DIR)
	@cat $(ET_KERNEL_CONFIG) > $(ET_KERNEL_BUILD_CONFIG)
endef

define kernel-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] make kernel-clean *****\n\n"
	$(RM) $(ET_KERNEL_DIR)/boot/*
	$(RM) -r $(ET_KERNEL_DIR)/lib/modules/*
endef

define kernel-purge
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] make kernel-purge *****\n\n"
	$(RM) -r $(ET_KERNEL_BUILD_DIR)
endef

define kernel-info
	@printf "ET_KERNEL_TREE: $(ET_KERNEL_TREE)\n"
	@printf "ET_KERNEL_VERSION: $(ET_KERNEL_VERSION)\n"
	@printf "ET_KERNEL_LOCALVERSION: $(ET_KERNEL_LOCALVERSION)\n"
	@printf "ET_KERNEL_DT: $(ET_KERNEL_DT)\n"
	@printf "ET_KERNEL_DTB: $(ET_KERNEL_DTB)\n"
	@printf "ET_KERNEL_SYSMAP: $(ET_KERNEL_SYSMAP)\n"
	@printf "ET_KERNEL_UIMAGE: $(ET_KERNEL_UIMAGE)\n"
	@printf "ET_KERNEL_ZIMAGE: $(ET_KERNEL_ZIMAGE)\n"
	@printf "ET_KERNEL_CONFIG: $(ET_KERNEL_CONFIG)\n"
	@printf "ET_KERNEL_BUILD_CONFIG: $(ET_KERNEL_BUILD_CONFIG)\n"
	@printf "ET_KERNEL_BUILD_DTB: $(ET_KERNEL_BUILD_DTB)\n"
	@printf "ET_KERNEL_BUILD_SYSMAP: $(ET_KERNEL_BUILD_SYSMAP)\n"
	@printf "ET_KERNEL_BUILD_UIMAGE: $(ET_KERNEL_BUILD_UIMAGE)\n"
	@printf "ET_KERNEL_BUILD_ZIMAGE: $(ET_KERNEL_BUILD_ZIMAGE)\n"
	@printf "ET_KERNEL_DIR: $(ET_KERNEL_DIR)\n"
	@printf "ET_KERNEL_BUILD_DIR: $(ET_KERNEL_BUILD_DIR)\n"
	@printf "ET_KERNEL_SOFTWARE_DIR: $(ET_KERNEL_SOFTWARE_DIR)\n"
	@printf "ET_KERNEL_TARGET_FINAL: $(ET_KERNEL_TARGET_FINAL)\n"
endef
