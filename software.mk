#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

# check for existence of a source tree
define software-check
	@if ! [ -d $(ET_SOFTWARE_DIR)/$1 ]; then \
		printf "\n"; \
		printf "*****  MISSING $(ET_SOFTWARE_DIR)/$1 DIRECTORY  *****\n"; \
		printf "===>  PLEASE ADD $(ET_SOFTWARE_DIR)/$1 SOFTWARE  <===\n"; \
		printf "\n"; \
		exit 2; \
	fi
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] USING $(ET_SOFTWARE_DIR)/$1 *****\n\n"
endef
