#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2019 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifneq ($(shell ls $(ET_BOARD_DIR)/software.conf 2> /dev/null),$(ET_BOARD_DIR)/software.conf)
$(error [ 'etinker' requires '$(ET_BOARD_DIR)/software.conf' ***)
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
				[ -d $1 ] && \
					(cd $1 && git fetch --all && git fetch --tags) || \
					git clone $$url $1; \
				(cd $1 && git checkout $$ref) || exit 2; \
				;; \
			*) \
				[ -d $2 ] && \
					(cd $2 && git fetch --all && git fetch --tags) || \
					git clone $$url $2; \
				(cd $2 && git checkout $$ref) || exit 2; \
				;; \
			esac; \
		); \
		printf "\n"; \
	fi
endef
