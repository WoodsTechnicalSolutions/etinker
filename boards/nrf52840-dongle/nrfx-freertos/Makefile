#
# This is the GNU Makefile for an 'etinker' nrfx project.
#
# Copyright (C) 2020-2025, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#

ET_BOARD := nrf52840-dongle

TARGET_NAME := nrfx-$(ET_BOARD)

TARGET_ELF = $(TARGET_NAME).elf
TARGET_HEX = $(TARGET_NAME).hex
TARGET_BIN = $(TARGET_NAME).bin
TARGET_MAP = $(TARGET_NAME).map

TARGET_DIR := $(shell realpath -e $(CURDIR))
TARGET_CONFIG_DIR := $(shell realpath -e $(CURDIR)/../config)
TARGET_COMMON_DIR := $(shell realpath -e $(CURDIR)/../common)

ET_DIR ?= $(shell realpath -e ../../..)

all: depends $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)

include $(ET_DIR)/etinker.mk

NRFX_DIR ?= $(ET_SOFTWARE_DIR)/nrfx
CMSIS_DIR ?= $(ET_SOFTWARE_DIR)/cmsis
FREERTOS_DIR ?= $(ET_SOFTWARE_DIR)/freertos-kernel

ifeq ($(ET_RELEASE),yes)
TARGET_BUILD := release
else
TARGET_BUILD := debug
endif

BUILD_DIR := $(TARGET_BUILD)

CC = $(ET_CROSS_TUPLE)-gcc
LD = $(ET_CROSS_TUPLE)-ld
SIZE = $(ET_CROSS_TUPLE)-size
OBJCOPY = $(ET_CROSS_TUPLE)-objcopy
OBJDUMP = $(ET_CROSS_TUPLE)-objdump

MKDIR = mkdir -p

ifeq ($(ET_RELEASE),yes)
OPTIMIZE = -Os
else
OPTIMIZE = -g3 -O0
endif

CFLAGS  = $(OPTIMIZE)
CFLAGS += $(ET_CFLAGS)
CFLAGS += -Wno-unused-variable
CFLAGS += --sysroot=$(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
CFLAGS += -isysroot $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
CFLAGS += -std=c11 -Wall -Werror
CFLAGS += -MD
CFLAGS += -D$(ET_BOARD_MCU_DEFINE)
CFLAGS += -DCONFIG_GPIO_AS_PINRESET
CFLAGS += -D__HEAP_SIZE=16384
CFLAGS += -D__STACK_SIZE=16384
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections
CFLAGS += -fno-builtin
CFLAGS += -fno-strict-aliasing
CFLAGS += -fshort-enums
CFLAGS += -mthumb
CFLAGS += -mabi=aapcs
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mfloat-abi=hard
CFLAGS += -mfpu=fpv4-sp-d16
CFLAGS += -I src
CFLAGS += -I $(TARGET_CONFIG_DIR)
CFLAGS += -I $(NRFX_DIR)
CFLAGS += -I $(NRFX_DIR)/soc
CFLAGS += -I $(NRFX_DIR)/hal
CFLAGS += -I $(NRFX_DIR)/mdk
CFLAGS += -I $(NRFX_DIR)/drivers
CFLAGS += -I $(NRFX_DIR)/drivers/include
CFLAGS += -I $(NRFX_DIR)/helpers
CFLAGS += -I $(NRFX_DIR)/templates
CFLAGS += -I $(CMSIS_DIR)/CMSIS/Core/Include
CFLAGS += -I $(FREERTOS_DIR)/include
CFLAGS += -I $(FREERTOS_DIR)/portable/GCC/ARM_CM4F
ifeq ($(ET_MCU_LIBC),picolibc)
CFLAGS += -I $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/include
endif
ifeq ($(ET_MCU_LIBC),newlib-nano)
CFLAGS += -I $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)/include
endif

LDFLAGS  = $(OPTIMIZE)
LDFLAGS += $(ET_LDFLAGS)
LDFLAGS += --sysroot=$(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
LDFLAGS += -D$(ET_BOARD_MCU_DEFINE)
LDFLAGS += -mthumb
LDFLAGS += -mabi=aapcs
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard
LDFLAGS += -mfpu=fpv4-sp-d16
LDFLAGS += -u _printf_float
LDFLAGS += -u _scanf_float
#LDFLAGS += -Wl,--print-gc-sections
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -L $(NRFX_DIR)/mdk
LDFLAGS += -T $(NRFX_DIR)/mdk/$(ET_BOARD_MCU)_xxaa.ld
LDFLAGS += -Wl,-Map,$(BUILD_DIR)/$(TARGET_MAP)

LDLIBS = \
	-Wl,--start-group \
	 	-lc -lm \
	       	$(ET_LDLIBS) \
	-Wl,--end-group

SOURCES  = $(shell find src/ -name "*.c" -print $(ET_NOERR))
SOURCES += $(shell find $(TARGET_COMMON_DIR)/ -name "*.c" -print $(ET_NOERR))
SOURCES += $(FREERTOS_DIR)/croutine.c
SOURCES += $(FREERTOS_DIR)/event_groups.c
SOURCES += $(FREERTOS_DIR)/portable/GCC/ARM_CM4F/port.c
SOURCES += $(FREERTOS_DIR)/portable/MemMang/heap_1.c
SOURCES += $(FREERTOS_DIR)/list.c
SOURCES += $(FREERTOS_DIR)/queue.c
SOURCES += $(FREERTOS_DIR)/stream_buffer.c
SOURCES += $(FREERTOS_DIR)/tasks.c
SOURCES += $(FREERTOS_DIR)/timers.c
SOURCES += $(NRFX_DIR)/soc/nrfx_atomic.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_gpiote.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_pwm.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_saadc.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_spim.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_twi_twim.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_twim.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_uarte.c
SOURCES += $(NRFX_DIR)/drivers/src/prs/nrfx_prs.c
SOURCES += $(NRFX_DIR)/helpers/nrfx_flag32_allocator.c
SOURCES += $(NRFX_DIR)/mdk/system_$(ET_BOARD_MCU).c

source1 = $(subst $(TARGET_COMMON_DIR),common,$(SOURCES))
source2 = $(subst $(NRFX_DIR),nrfx,$(source1))
source3 = $(subst $(FREERTOS_DIR),freertos,$(source2))

OBJECTS = $(addprefix $(BUILD_DIR)/,$(source3:.c=.o))

HEADERS = Makefile
HEADERS += $(shell find src/ -maxdepth 1 -name "*.h" -print $(ET_NOERR))
HEADERS += $(shell find $(TARGET_CONFIG_DIR)/ -name "*.h" -print $(ET_NOERR))
HEADERS += $(shell find $(TARGET_COMMON_DIR)/ -name "*.h" -print $(ET_NOERR))
HEADERS += $(shell find $(NRFX_DIR)/ -name "*.h" -print $(ET_NOERR))
HEADERS += $(shell find $(FREERTOS_DIR)/include -name "*.h" -print $(ET_NOERR))
HEADERS += $(shell find $(FREERTOS_DIR)/portable/GCC/ARM_CM4F -name "*.h" -print $(ET_NOERR))

depends:
	$(call toolchain-mcu-libc)

$(TARGET_ELF): $(BUILD_DIR)/$(TARGET_ELF)

$(BUILD_DIR)/$(TARGET_ELF): $(NRFX_DIR)/mdk/gcc_startup_$(ET_BOARD_MCU).S
$(BUILD_DIR)/$(TARGET_ELF): $(OBJECTS)
	$(CC) -o $@ $(LDFLAGS) $^ $(LDLIBS)
	@$(SIZE) $@
ifeq ($(TARGET_BUILD),debug)
	@$(OBJDUMP) -S --disassemble $@ > $(BUILD_DIR)/asm/$(TARGET_ELF).lst 2> $(BUILD_DIR)/asm/$(TARGET_ELF).lst-error
endif

$(TARGET_HEX): $(BUILD_DIR)/$(TARGET_HEX)
$(BUILD_DIR)/$(TARGET_HEX): $(BUILD_DIR)/$(TARGET_ELF)
	$(OBJCOPY) -O ihex $< $@

$(TARGET_BIN): $(BUILD_DIR)/$(TARGET_BIN)
$(BUILD_DIR)/$(TARGET_BIN): $(BUILD_DIR)/$(TARGET_ELF)
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/%.o: %.c $(HEADERS) | $(BUILD_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) -o $@ -c $<
ifeq ($(TARGET_BUILD),debug)
	@$(OBJDUMP) -S --disassemble $@ > $@.lst 2> $@.lst-error
endif

$(BUILD_DIR)/common/%.o: $(TARGET_COMMON_DIR)/%.c $(HEADERS) | $(BUILD_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) -o $@ -c $<
ifeq ($(TARGET_BUILD),debug)
	@$(OBJDUMP) -S --disassemble $@ > $@.lst 2> $@.lst-error
endif

$(BUILD_DIR)/nrfx/%.o: $(NRFX_DIR)/%.c $(HEADERS) | $(BUILD_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) -o $@ -c $<
ifeq ($(TARGET_BUILD),debug)
	@$(OBJDUMP) -S --disassemble $@ > $@.lst 2> $@.lst-error
endif

$(BUILD_DIR)/freertos/%.o: $(FREERTOS_DIR)/%.c $(HEADERS) | $(BUILD_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) -o $@ -c $<
ifeq ($(TARGET_BUILD),debug)
	@$(OBJDUMP) -S --disassemble $@ > $@.lst 2> $@.lst-error
endif

$(BUILD_DIR):
	$(call software-check,nrfx,nrfx)
	$(call software-check,cmsis,cmsis)
	$(call software-check,freertos-kernel,freertos-kernel)
	@$(MKDIR) $(BUILD_DIR)/asm

openocd:
	$(call openocd, server)

program: $(BUILD_DIR)/$(TARGET_ELF)
	$(call openocd, $@, $<)

flash: program

gdb: $(BUILD_DIR)/$(TARGET_ELF)
	$(call openocd, $@, $<)

reset:
	$(call openocd, $@)

# https://sourceforge.net/projects/cmsisconfig
nrfx-config:
	@if ! [ -f $(ET_SOFTWARE_DIR)/CMSIS_Configuration_Wizard.jar ]; then \
		wget -O $(ET_SOFTWARE_DIR)/CMSIS_Configuration_Wizard_v0.0.7.zip \
			https://sourceforge.net/projects/cmsisconfig/files/CMSIS%20Configuration%20Wizard%20v0.0.7/CMSIS_Configuration_Wizard_v0.0.7.zip; \
		if [ -f $(ET_SOFTWARE_DIR)/CMSIS_Configuration_Wizard_v0.0.7.zip ]; then \
			unzip $(ET_SOFTWARE_DIR)/CMSIS_Configuration_Wizard_v0.0.7.zip CMSIS_Configuration_Wizard.jar -d $(ET_SOFTWARE_DIR)/ ; \
		else \
			exit 2; \
		fi; \
	fi
	@if ! [ -f $(ET_SOFTWARE_DIR)/CMSIS_Configuration_Wizard.jar ]; then \
		exit 2; \
	fi
	@(java -jar \
		$(ET_SOFTWARE_DIR)/CMSIS_Configuration_Wizard.jar \
		$(TARGET_CONFIG_DIR)/nrfx_config.h &)

distclean: clean
	$(RM) -r debug
	$(RM) -r release

clean:
	$(RM) -r *.log
	$(RM) -r $(BUILD_DIR)

info:
	$(call toolchain-info)
	@printf "========================================================================\n"
	@printf "ET_BOARD_MCU: $(ET_BOARD_MCU)\n"
	@printf "ET_BOARD_MCU_EXT: $(ET_BOARD_MCU_EXT)\n"
	@printf "ET_BOARD_MCU_DEFINE: $(ET_BOARD_MCU_DEFINE)\n"
	@printf "========================================================================\n"
	@printf "TARGET_NAME: $(TARGET_NAME)\n"
	@printf "TARGET_ELF: $(TARGET_ELF)\n"
	@printf "TARGET_HEX: $(TARGET_HEX)\n"
	@printf "TARGET_BIN: $(TARGET_BIN)\n"
	@printf "TARGET_MAP: $(TARGET_MAP)\n"
	@printf "TARGET_BUILD: $(TARGET_BUILD)\n"
	@printf "CC: $(CC)\n"
	@printf "LD: $(LD)\n"
	@printf "SIZE: $(SIZE)\n"
	@printf "OBJCOPY: $(OBJCOPY)\n"
	@printf "OBJDUMP: $(OBJDUMP)\n"
	@printf "CFLAGS: $(CFLAGS)\n"
	@printf "LDLIBS: $(LDLIBS)\n"
	@printf "LDFLAGS: $(LDFLAGS)\n"
	@printf "SOURCES: $(SOURCES)\n"
	@printf "HEADERS: $(HEADERS)\n"
	@printf "OBJECTS: $(OBJECTS)\n"
	@printf "PATH: $(PATH)\n"

.PHONY: all clean depends distclean flash gdb openocd program $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)
