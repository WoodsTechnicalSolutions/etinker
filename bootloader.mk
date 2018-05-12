#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_BOARD_BOOTLOADER_TREE
$(error [ 'etinker' bootloader build requires ET_BOARD_BOOTLOADER_TREE ] ***)
endif

# embedded bootloader, for application processors, is Das U-Boot
export ET_BOOTLOADER_TREE := $(ET_BOARD_BOOTLOADER_TREE)
export ET_BOOTLOADER_SOFTWARE_DIR := $(ET_SOFTWARE_DIR)/$(ET_BOARD_BOOTLOADER_TREE)
export ET_BOOTLOADER_DEFCONFIG := $(ET_BOARD_BOOTLOADER_DEFCONFIG)
# [start] bootloader version magic
ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && git describe --long --dirty 2>/dev/null | tr -d v)
ifeq ($(shell echo $(ET_BOOTLOADER_VERSION) | cut -d '-' -f 2),0)
ET_BOOTLOADER_VERSION := $(shell cd $(ET_BOOTLOADER_SOFTWARE_DIR) 2>/dev/null && git describe --dirty 2>/dev/null | tr -d v)
endif
export ET_BOOTLOADER_VERSION
# [end] bootloader version magic
export ET_BOOTLOADER_BUILD_DIR := $(ET_DIR)/bootloader/build/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_BUILD_CONFIG := $(ET_BOOTLOADER_BUILD_DIR)/.config
export ET_BOOTLOADER_BUILD_SYSMAP := $(ET_BOOTLOADER_BUILD_DIR)/System.map
export ET_BOOTLOADER_BUILD_SPL := $(ET_BOOTLOADER_BUILD_DIR)/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_BUILD_IMAGE := $(ET_BOOTLOADER_BUILD_DIR)/u-boot.img
export ET_BOOTLOADER_CONFIGURED := $(ET_BOOTLOADER_BUILD_DIR)/configured
export ET_BOOTLOADER_DIR := $(ET_DIR)/bootloader/$(ET_BOARD)/$(ET_CROSS_TUPLE)
export ET_BOOTLOADER_CONFIG := $(ET_CONFIG_DIR)/$(ET_BOOTLOADER_TREE)/config
export ET_BOOTLOADER_SYSMAP := $(ET_BOOTLOADER_DIR)/System.map
export ET_BOOTLOADER_SPL := $(ET_BOOTLOADER_DIR)/boot/$(ET_BOARD_BOOTLOADER_SPL_BINARY)
export ET_BOOTLOADER_IMAGE := $(ET_BOOTLOADER_DIR)/boot/u-boot.img
export ET_BOOTLOADER_TARGET_FINAL += $(ET_BOOTLOADER_IMAGE)

define bootloader-targets
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] $(ET_BOOTLOADER_TREE) $(ET_BOOTLOADER_VERSION) *****\n\n"
	$(call bootloader-build)
	@if [ -n "$(shell diff -q $(ET_BOOTLOADER_BUILD_CONFIG) $(ET_BOOTLOADER_CONFIG) 2> /dev/null)" ]; then \
		cat $(ET_BOOTLOADER_BUILD_CONFIG) > $(ET_BOOTLOADER_CONFIG); \
	fi
endef

define bootloader-build
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-build 'make $1' *****\n\n"
	@mkdir -p $(ET_BOOTLOADER_DIR)/boot
	$(MAKE) --no-print-directory -j $(ET_CPUS) -C $(ET_BOOTLOADER_SOFTWARE_DIR) O=$(ET_BOOTLOADER_BUILD_DIR) \
		$(ET_CROSS_PARAMS) $1
	@if [ -n "$1" ]; then \
		if [ -n "$(shell printf "%s" $1 | grep config)" ]; then \
			if [ -n "$(shell diff -q $(ET_BOOTLOADER_BUILD_CONFIG) $(ET_BOOTLOADER_CONFIG) 2> /dev/null)" ] || \
			   [ -n "$(shell printf "%s" $1 | grep defconfig)" ]; then \
				cat $(ET_BOOTLOADER_BUILD_CONFIG) > $(ET_BOOTLOADER_CONFIG); \
			fi; \
		fi; \
	else \
		if ! [ -f $(ET_BOOTLOADER_BUILD_SPL) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] make bootloader $(ET_BOOTLOADER_BUILD_SPL) build FAILED! *****\n\n"; \
			exit 2; \
		fi; \
		if ! [ -f $(ET_BOOTLOADER_BUILD_IMAGE) ]; then \
			printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] make bootloader $(ET_BOOTLOADER_BUILD_IMAGE) build FAILED! *****\n\n"; \
			exit 2; \
		fi; \
		$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*; \
		$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*; \
		cp -av $(ET_BOOTLOADER_BUILD_SPL) $(ET_BOOTLOADER_DIR)/boot/; \
		cp -av $(ET_BOOTLOADER_BUILD_IMAGE) $(ET_BOOTLOADER_DIR)/boot/; \
	fi
endef

define bootloader-config
	$(call software-check,$(ET_BOOTLOADER_TREE))
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-config *****\n\n"
	@mkdir -p $(ET_BOOTLOADER_DIR)/boot
	@mkdir -p $(ET_BOOTLOADER_BUILD_DIR)
	@if ! [ -f $(ET_BOOTLOADER_CONFIG) ]; then \
		printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-config build FAILED! *****\n\n"; \
		exit 2; \
	fi
	@cat $(ET_BOOTLOADER_CONFIG) > $(ET_BOOTLOADER_BUILD_CONFIG)
endef

define bootloader-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-clean *****\n\n"
	$(RM) $(ET_BOOTLOADER_DIR)/boot/boot*
	$(RM) $(ET_BOOTLOADER_DIR)/boot/u-boot*
endef

define bootloader-purge
	$(call bootloader-clean)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call bootloader-purge *****\n\n"
	$(RM) -r $(ET_BOOTLOADER_BUILD_DIR)
endef

define bootloader-info
	@printf "ET_BOOTLOADER_TREE: $(ET_BOOTLOADER_TREE)\n"
	@printf "ET_BOOTLOADER_VERSION: $(ET_BOOTLOADER_VERSION)\n"
	@printf "ET_BOOTLOADER_SYSMAP: $(ET_BOOTLOADER_SYSMAP)\n"
	@printf "ET_BOOTLOADER_SPL: $(ET_BOOTLOADER_SPL)\n"
	@printf "ET_BOOTLOADER_IMAGE: $(ET_BOOTLOADER_IMAGE)\n"
	@printf "ET_BOOTLOADER_CONFIG: $(ET_BOOTLOADER_CONFIG)\n"
	@printf "ET_BOOTLOADER_BUILD_CONFIG: $(ET_BOOTLOADER_BUILD_CONFIG)\n"
	@printf "ET_BOOTLOADER_BUILD_SYSMAP: $(ET_BOOTLOADER_BUILD_SYSMAP)\n"
	@printf "ET_BOOTLOADER_BUILD_SPL: $(ET_BOOTLOADER_BUILD_SPL)\n"
	@printf "ET_BOOTLOADER_BUILD_IMAGE: $(ET_BOOTLOADER_BUILD_IMAGE)\n"
	@printf "ET_BOOTLOADER_DIR: $(ET_BOOTLOADER_DIR)\n"
	@printf "ET_BOOTLOADER_BUILD_DIR: $(ET_BOOTLOADER_BUILD_DIR)\n"
	@printf "ET_BOOTLOADER_SOFTWARE_DIR: $(ET_BOOTLOADER_SOFTWARE_DIR)\n"
	@printf "ET_BOOTLOADER_TARGET_FINAL: $(ET_BOOTLOADER_TARGET_FINAL)\n"
endef
