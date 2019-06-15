#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2019 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

# check for existence of a source tree
define software-check
	@if ! [ -d $(ET_SOFTWARE_DIR)/$1 ]; then \
		printf "\n"; \
		mkdir -p $(ET_SOFTWARE_DIR); \
		(cd $(ET_SOFTWARE_DIR) && \
			url="`grep $2-url $(ET_DIR)/boards/$(ET_BOARD_TYPE)/software.conf | cut -d ':' -f 2-3 | tr -d \\\\n`" && \
			ref="`grep $2-ref $(ET_DIR)/boards/$(ET_BOARD_TYPE)/software.conf | cut -d ':' -f 2-3 | tr -d \\\\n`" && \
			case $2 in \
			toolchain | bootloader | kernel | rootfs) \
				git clone $$url $1; \
				(cd $1 && git checkout $$ref); \
				;; \
			*) \
				git clone $$url $2; \
				(cd $2 && git checkout $$ref); \
				;; \
			esac; \
		); \
		printf "\n"; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] USING $(ET_SOFTWARE_DIR)/$1 for $2 *****\n\n"
endef
