#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2021 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifneq ($(ET_BOARD_VENDOR),$(ET_HOST_OS_ID))
ifneq ($(shell ls $(ET_BOARD_DIR)/software.conf 2> /dev/null),$(ET_BOARD_DIR)/software.conf)
$(error [ 'etinker' requires '$(ET_BOARD_DIR)/software.conf' ***)
endif
endif

# check for existence of a source tree
define software-check
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] USING $(ET_SOFTWARE_DIR)/$1 for $2 *****\n\n"
	@if ! [ -d $(ET_SOFTWARE_DIR)/$1 ] || [ "$(ET_SOFTWARE_SYNC)" = "yes" ]; then \
		mkdir -p $(ET_SOFTWARE_DIR); \
		(cd $(ET_SOFTWARE_DIR) && \
			url="`grep $2-url $(ET_BOARD_DIR)/software.conf | cut -d ':' -f 2-3 | tr -d \\\\n`" && \
			ref="`grep $2-ref $(ET_BOARD_DIR)/software.conf | cut -d ':' -f 2-3 | tr -d \\\\n`" && \
			case $2 in \
			toolchain | bootloader | kernel | rootfs) \
				if [ -d $1 ]; then \
					(cd $1 && git restore . && git clean -df && git fetch --all && git fetch --tags); \
				else \
					git clone $$url $1; \
				fi; \
				if ! [ -d $1 ]; then \
					printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] ERROR MISSING $(ET_SOFTWARE_DIR)/$1 DIRECTORY *****\n\n"; \
					exit 2; \
				fi; \
				(cd $1 && git checkout $$ref); \
				if [ -d $(ET_PATCH_DIR)/$2 ]; then \
					(cd $1 && patch -p1 -i $(ET_PATCH_DIR)/$2/*.patch 2> /dev/null); \
				fi; \
				;; \
			*) \
				if [ -d $2 ]; then \
					(cd $2 && git restore . && git clean -df && git fetch --all && git fetch --tags); \
				else \
					git clone $$url $2; \
				fi; \
				if ! [ -d $2 ]; then \
					printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] ERROR MISSING $(ET_SOFTWARE_DIR)/$2 DIRECTORY *****\n\n"; \
					exit 2; \
				fi; \
				(cd $2 && git checkout $$ref); \
				if [ -d $(ET_PATCH_DIR)/$2 ]; then \
					(cd $2 && patch -p1 -i $(ET_PATCH_DIR)/$2/*.patch 2> /dev/null); \
				fi; \
				;; \
			esac; \
		); \
		printf "\n"; \
	fi
endef
