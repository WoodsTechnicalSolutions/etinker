#
# This is a GNU Make include for 'etinker'.
#
# Copyright (C) 2018-2026, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

# check for existence of a source tree
define software-check
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] USING $(ET_SOFTWARE_DIR)/$1 for $2 *****\n\n"
	@if ! [ -d $(ET_SOFTWARE_DIR)/$1 ] || [ "fetch" = "$3" ]; then \
		mkdir -p $(ET_SOFTWARE_DIR); \
		(cd $(ET_SOFTWARE_DIR) && \
			export et_url="$(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) $2-url)"; \
			export et_ref="$(shell $(ET_SCRIPTS_DIR)/software $(ET_BOARD) $2-ref)"; \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] et_url=$$et_url *****\n"; \
			printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] et_ref=$$et_ref *****\n\n"; \
			case $2 in \
			toolchain | bootloader* | kernel* | rootfs) \
				if [ -d $1 ]; then \
					(cd $1 && git restore . && git clean -df && git fetch --all && git fetch --tags); \
				else \
					git clone $$et_url $1; \
				fi; \
				if ! [ -d $1 ]; then \
					printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] ERROR MISSING $(ET_SOFTWARE_DIR)/$1 DIRECTORY *****\n\n"; \
					exit 2; \
				fi; \
				(cd $1 && git checkout $$et_ref && (git status | grep -oq HEAD) || git pull) || exit 2; \
				if [ -d $(ET_PATCH_DIR)/$(notdir $1) ]; then \
					(cd $1 && \
						git branch -D patched -f $(ET_NOERR); \
						git switch -c patched; \
						for f in $(shell ls $(ET_PATCH_DIR)/$(notdir $1)/*.patch $(ET_NOERR)); do \
							patch --no-backup-if-mismatch -p1 -i $$f; \
						done && \
						git add . && \
						git commit -a -m "etinker: patches applied @ $$et_ref") || exit 2; \
				fi; \
				;; \
			*) \
				if [ -d $2 ]; then \
					(cd $2 && git restore . && git clean -df && git fetch --all && git fetch --tags); \
				else \
					git clone $$et_url $2; \
				fi; \
				if ! [ -d $2 ]; then \
					printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] ERROR MISSING $(ET_SOFTWARE_DIR)/$2 DIRECTORY *****\n\n"; \
					exit 2; \
				fi; \
				(cd $2 && git checkout $$et_ref && (git status | grep -oq HEAD) || git pull) || exit 2; \
				if [ -d $(ET_PATCH_DIR)/$(notdir $2) ]; then \
					(cd $2 && \
						git branch -D patched -f $(ET_NOERR); \
						git switch -c patched; \
						for f in $(shell ls $(ET_PATCH_DIR)/$(notdir $2)/*.patch $(ET_NOERR)); do \
							patch --no-backup-if-mismatch -p1 -i $$f; \
						done && \
						git add . && \
						git commit -a -m "etinker: patches applied @ $$et_ref") || exit 2; \
				fi; \
				;; \
			esac; \
		) || exit 2; \
		printf "\n"; \
	fi
endef
