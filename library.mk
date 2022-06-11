#
# This is a GNU Make include for 'etinker'.
#
# Uses similar build concepts as found in 'libgpiod' here:
# - https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
#
# Copyright (C) 2021-2022 Derald D. Woods
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ifndef ET_DIR
$(error [ 'etinker' library build requires ET_DIR definition ] ***)
endif

ifndef ET_TOOLCHAIN_TYPE
$(error [ 'etinker' library build requires ET_TOOLCHAIN_TYPE definition ] ***)
endif

export ET_LIBRARY_NAME := etinker

# excerpts from libtool 2.4.6 manual:
#
#  --> current[:revision[:age]] <--
#
#   So, libtool library versions are described by three integers:
#   current  - The most recent interface number that this library implements.
#   revision - The implementation number of the current interface.
#   age      - The difference between the newest and oldest interfaces that
#              this library implements. In other words, the library
#              implements all the interface numbers in the range from number
#              (current - age) to current.
#
#   Here are a set of rules to help you update your library version information:
#   1. Start with version information of ‘0:0:0’ for each libtool library.
#   2. Update the version information only immediately before a public release
#      of your software. More frequent updates are unnecessary, and only
#      guarantee that the current interface number gets larger faster.
#   3. If the library source code has changed at all since the last update, then
#      increment revision (‘c:r:a’ becomes ‘c:r + 1:a’).
#   4. If any interfaces have been added, removed, or changed since the last
#      update, increment current, and set revision to 0.
#   5. If any interfaces have been added since the last public release, then
#      increment age.
#   6. If any interfaces have been removed or changed since the last public
#      release, then set age to 0.
#   Never try to set the interface numbers so that they correspond to the
#   release number of your package.

export ET_LIBRARY_CURRENT := 0
export ET_LIBRARY_REVISION := 0
export ET_LIBRARY_AGE := 0
export ET_LIBRARY_VERSION := $(ET_LIBRARY_CURRENT).$(ET_LIBRARY_REVISION).$(ET_LIBRARY_AGE)

export ET_LIBRARY_BUILD_DIR := $(ET_DIR)/library/build/$(ET_TOOLCHAIN_TYPE)
export ET_LIBRARY_BUILD_ARCHIVE := $(ET_LIBRARY_BUILD_DIR)/lib$(ET_LIBRARY_NAME).a
export ET_LIBRARY_BUILD_SO := $(ET_LIBRARY_BUILD_DIR)/lib$(ET_LIBRARY_NAME).so.$(ET_LIBRARY_VERSION)
export ET_LIBRARY_DIR := $(ET_DIR)/library/$(ET_BOARD)/$(ET_TOOLCHAIN_TYPE)
export ET_LIBRARY_ARCHIVE := $(ET_LIBRARY_DIR)/usr/lib/lib$(ET_LIBRARY_NAME).a
ifdef ET_MCU_LIBC
export ET_LIBRARY_TARGET_FINAL := $(ET_LIBRARY_ARCHIVE)
else
export ET_LIBRARY_SO := $(ET_LIBRARY_DIR)/usr/lib/lib$(ET_LIBRARY_NAME).so.$(ET_LIBRARY_VERSION)
export ET_LIBRARY_TEST := $(ET_LIBRARY_DIR)/usr/bin/$(ET_LIBRARY_NAME)
export ET_LIBRARY_TARGET_FINAL := $(ET_LIBRARY_TEST)
endif

sources := $(wildcard $(ET_DIR)/lib/*.c)
SOURCES := $(filter-out $(wildcard $(ET_DIR)/lib/test*.c),$(sources))
OBJECTS := $(SOURCES:$(ET_DIR)/lib/%.c=$(ET_LIBRARY_BUILD_DIR)/%.o)
DEPENDS := $(OBJECTS:.o=.d)

CC := $(ET_CROSS_COMPILE)gcc
AR := $(ET_CROSS_COMPILE)gcc-ar
NM := $(ET_CROSS_COMPILE)gcc-nm
ifeq ($(shell which $(ET_CROSS_COMPILE)size 2> /dev/null),)
SIZE := size
OBJCOPY := objcopy
OBJDUMP := objdump
else
SIZE := $(ET_CROSS_COMPILE)size
OBJCOPY := $(ET_CROSS_COMPILE)objcopy
OBJDUMP := $(ET_CROSS_COMPILE)objdump
endif

CFLAGS = -Wall -Wextra
CFLAGS_TEST = -Wall -Wextra
ifdef ET_LIBRARY_SO
CFLAGS += -fPIC
endif
ifeq ($(ET_RELEASE),no)
CFLAGS += -g -DDEBUG -O0
CFLAGS_TEST += -g -DDEBUG -O0
else
CFLAGS += -Os
CFLAGS_TEST += -Os
endif
CFLAGS += -fvisibility=hidden
CFLAGS += -I $(ET_DIR)/include
CFLAGS_TEST += -I $(ET_LIBRARY_DIR)/usr/include
CFLAGS += -I $(ET_TOOLCHAIN_DIR)/include
CFLAGS_TEST += -I $(ET_TOOLCHAIN_DIR)/include
ifdef ET_MCU_LIBC
CFLAGS += -isysroot $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
CFLAGS_TEST += -isysroot $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
CFLAGS += -DETINKER_MCU_LIBC=\"$(ET_MCU_LIBC)\"
else
CFLAGS += -isysroot $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot
CFLAGS_TEST += -isysroot $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/sysroot
endif
CFLAGS += -DETINKER_LIBRARY_VERSION=\"$(ET_LIBRARY_VERSION)\"

ifdef ET_LIBRARY_SO
LDFLAGS = -shared -Wl,-soname,lib$(ET_LIBRARY_NAME).so
LDFLAGS_TEST = -static -L $(ET_LIBRARY_DIR)/usr/lib -l$(ET_LIBRARY_NAME)
endif

define library-info
	@printf "========================================================================\n"
	@printf "ET_LIBRARY_NAME: lib$(ET_LIBRARY_NAME)\n"
	@printf "ET_LIBRARY_VERSION: $(ET_LIBRARY_VERSION)\n"
	@printf "ET_LIBRARY_BUILD_DIR: $(ET_LIBRARY_BUILD_DIR)\n"
	@printf "ET_LIBRARY_BUILD_ARCHIVE: $(ET_LIBRARY_BUILD_ARCHIVE)\n"
	@printf "ET_LIBRARY_BUILD_SO: $(ET_LIBRARY_BUILD_SO)\n"
	@printf "ET_LIBRARY_DIR: $(ET_LIBRARY_DIR)\n"
	@printf "ET_LIBRARY_ARCHIVE: $(ET_LIBRARY_ARCHIVE)\n"
	@if [ -n "$(ET_LIBRARY_SO)" ]; then \
		printf "ET_LIBRARY_SO: $(ET_LIBRARY_SO)\n"; \
	fi
	@printf "ET_LIBRARY_TEST: $(ET_LIBRARY_TEST)\n"
	@printf "ET_LIBRARY_TARGET_FINAL: $(ET_LIBRARY_TARGET_FINAL)\n"
	@printf "ET_LIBRARY ENVIRONMENT:\n"
	@printf " ├── AR: $(AR)\n"
	@printf " ├── CC: $(CC)\n"
	@printf " ├── NM: $(NM)\n"
	@printf " ├── OBJCOPY: $(OBJCOPY)\n"
	@printf " ├── OBJDUMP: $(OBJDUMP)\n"
	@printf " ├── CFLAGS: $(CFLAGS)\n"
	@printf " ├── CFLAGS_TEST: $(CFLAGS_TEST)\n"
	@printf " ├── LDFLAGS: $(LDFLAGS)\n"
	@printf " ├── LDFLAGS_TEST: $(LDFLAGS_TEST)\n"
	@printf " ├── OBJECTS: $(OBJECTS)\n"
	@printf " ├── SOURCES: $(SOURCES)\n"
	@printf " └── DEPENDS: $(DEPENDS)\n"
endef

define library-sync
	@$(ET_DIR)/scripts/sync library $1
endef

define library-update
	@$(ET_MAKE) -C $(ET_DIR) library-clean
	@$(ET_MAKE) -C $(ET_DIR) library
endef

define library-all
	@$(ET_MAKE) -C $(ET_DIR) library
endef

.PHONY: library
library: $(ET_LIBRARY_TARGET_FINAL)

$(ET_LIBRARY_ARCHIVE): $(ET_LIBRARY_BUILD_ARCHIVE)
ifdef ET_MCU_LIBC
$(ET_LIBRARY_TARGET_FINAL): $(ET_LIBRARY_BUILD_ARCHIVE)
else
$(ET_LIBRARY_SO): $(ET_LIBRARY_BUILD_SO)
$(ET_LIBRARY_TARGET_FINAL): $(ET_LIBRARY_BUILD_SO)
endif

$(ET_LIBRARY_BUILD_ARCHIVE): $(OBJECTS) $(DEPENDS)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building static library *****\n\n"
	@mkdir -p $(ET_LIBRARY_DIR)/usr/include
	@mkdir -p $(ET_LIBRARY_DIR)/usr/lib
	@mkdir -p $(ET_LIBRARY_DIR)/usr/bin
	$(AR) cr -o $@ $(OBJECTS)
	@$(NM) -g $@ && echo
	@$(SIZE) $@ && echo
	cp -a $(ET_DIR)/include/* $(ET_LIBRARY_DIR)/usr/include/
	cp -a $@ $(ET_LIBRARY_DIR)/usr/lib/

ifdef ET_LIBRARY_SO
$(ET_LIBRARY_BUILD_SO): $(ET_LIBRARY_BUILD_ARCHIVE)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building shared library *****\n\n"
	$(CC) $(LDFLAGS) -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive
	cp -a $@ $(ET_LIBRARY_DIR)/usr/lib/
	(cd $(ET_LIBRARY_DIR)/usr/lib && \
		$(RM) lib$(ET_LIBRARY_NAME).so && \
		ln -s lib$(ET_LIBRARY_NAME).so.$(ET_LIBRARY_VERSION) lib$(ET_LIBRARY_NAME).so)

$(ET_LIBRARY_TEST): $(ET_LIBRARY_SO)
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] Building test binary *****\n\n"
	@mkdir -p $(@D)
	@mkdir -p $(ET_LIBRARY_DIR)/usr/include
	@cp -a $(ET_DIR)/include/* $(ET_LIBRARY_DIR)/usr/include/
	$(CC) $(CFLAGS_TEST) $(ET_DIR)/lib/test.c -o $@ $(LDFLAGS_TEST)
endif

$(ET_LIBRARY_BUILD_DIR)/%.o: $(ET_DIR)/lib/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $< -c -o $@

$(ET_LIBRARY_BUILD_DIR)/%.d: $(ET_DIR)/lib/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -M $< > $@

.PHONY: library-clean
library-clean:
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call library-clean *****\n\n"
	$(RM) $(OBJECTS) $(ET_LIBRARY_BUILD_ARCHIVE) $(ET_LIBRARY_BUILD_SO)
	$(RM) $(ET_LIBRARY_SO) $(ET_LIBRARY_TEST) $(ET_LIBRARY_TARGET_FINAL)
	$(RM) -r $(ET_LIBRARY_DIR)

.PHONY: library-purge
library-purge: library-clean
	@printf "\n***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] call library-purge *****\n\n"
	$(RM) -r $(ET_LIBRARY_BUILD_DIR)

.PHONY: library-version
library-version:
	@printf "ET_lIBRARY_VERSION: $(ET_LIBRARY_VERSION)\n"

.PHONY: library-info
library-info:
	$(call $@)

library-sync-%:
	$(call library-sync,$(*F))

.PHONY: library-update
library-update:
	$(call $@)

.PHONY: library-all
library-all:
	$(call $@)
