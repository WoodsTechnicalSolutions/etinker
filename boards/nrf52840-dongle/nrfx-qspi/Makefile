ET_BOARD := nrf52840-dongle

TARGET_NAME := nrfx-qspi-$(ET_BOARD)

TARGET_ELF = $(TARGET_NAME).elf
TARGET_HEX = $(TARGET_NAME).hex
TARGET_BIN = $(TARGET_NAME).bin
TARGET_MAP = $(TARGET_NAME).map

TARGET_DIR := $(shell realpath -e $(CURDIR))

all: $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)

ET_DIR ?= $(shell realpath ../../..)

include $(ET_DIR)/etinker.mk

NRFX_DIR := $(ET_SOFTWARE_DIR)/nrfx
CMSIS_DIR := $(ET_SOFTWARE_DIR)/cmsis

ifeq ($(ET_RELEASE),yes)
TARGET_BUILD := release
else
TARGET_BUILD := debug
endif

BUILD_DIR := $(TARGET_BUILD)

OPENOCD_CONFIG ?= openocd.cfg
OPENOCD_GDB_LOG := $(BUILD_DIR)/openocd-gdb.log
OPENOCD_PROGRAM_LOG := $(BUILD_DIR)/openocd-program.log

CC = $(ET_CROSS_TUPLE)-gcc
LD = $(ET_CROSS_TUPLE)-ld
GDB = $(ET_CROSS_TUPLE)-gdb
SIZE = $(ET_CROSS_TUPLE)-size
OBJCOPY = $(ET_CROSS_TUPLE)-objcopy
OBJDUMP = $(ET_CROSS_TUPLE)-objdump

MKDIR = mkdir -p

ifeq ($(ET_RELEASE),yes)
OPTIMIZE = -Os
else
OPTIMIZE = -g3 -Og
endif

CFLAGS = $(OPTIMIZE)
CFLAGS += $(ET_CFLAGS)
CFLAGS += -std=c11 -Wall -Werror
CFLAGS += -MD
CFLAGS += -D$(ET_BOARD_MCU_DEFINE)
CFLAGS += -DCONFIG_GPIO_AS_PINRESET
CFLAGS += -D__HEAP_SIZE=8192
CFLAGS += -D__STACK_SIZE=8192
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
CFLAGS += -I config
CFLAGS += -I $(NRFX_DIR)
CFLAGS += -I $(NRFX_DIR)/hal
CFLAGS += -I $(NRFX_DIR)/mdk
CFLAGS += -I $(NRFX_DIR)/drivers
CFLAGS += -I $(NRFX_DIR)/drivers/include
CFLAGS += -I $(CMSIS_DIR)/CMSIS/Core/Include

LDFLAGS = $(OPTIMIZE)
LDFLAGS += $(ET_LDFLAGS)
LDFLAGS += -D$(ET_BOARD_MCU_DEFINE)
LDFLAGS += -mthumb
LDFLAGS += -mabi=aapcs
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard
LDFLAGS += -mfpu=fpv4-sp-d16
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/$(TARGET_MAP)
LDFLAGS += -Wl,-L $(NRFX_DIR)/mdk
LDFLAGS += -Wl,-T $(NRFX_DIR)/mdk/$(ET_BOARD_MCU)_xxaa.ld

LDLIBS  = -Wl,--start-group -lm -lc -lgcc -lnosys -Wl,--end-group
LDLIBS += $(ET_LDLIBS)

SOURCES = $(shell find src/ -name "*.c" -print 2> /dev/null)
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_gpiote.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_pwm.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_qspi.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_saadc.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_systick.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_twi_twim.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_twim.c
SOURCES += $(NRFX_DIR)/drivers/src/nrfx_uarte.c
SOURCES += $(NRFX_DIR)/drivers/src/prs/nrfx_prs.c
SOURCES += $(NRFX_DIR)/mdk/system_$(ET_BOARD_MCU).c

OBJECTS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.c=.o))

HEADERS = Makefile
HEADERS += $(shell find config/ -name "*.h" -print 2> /dev/null)
HEADERS += $(shell find src/ -maxdepth 1 -name "*.h" -print 2> /dev/null)

$(TARGET_ELF): $(BUILD_DIR)/$(TARGET_ELF)

$(BUILD_DIR)/$(TARGET_ELF): $(NRFX_DIR)/mdk/gcc_startup_$(ET_BOARD_MCU).S
$(BUILD_DIR)/$(TARGET_ELF): $(OBJECTS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)
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

$(BUILD_DIR):
	$(call software-check,nrfx,nrfx)
	$(call software-check,cmsis,cmsis)
	@$(MKDIR) $(BUILD_DIR)/asm

program: $(BUILD_DIR)/$(TARGET_BIN)
	@if [ -n "`which openocd 2> /dev/null | tr -d \\n`" ]; then \
		openocd -f $(OPENOCD_CONFIG) -c "log_output $(OPENOCD_PROGRAM_LOG); program $< verify reset exit" ; \
		cat $(OPENOCD_PROGRAM_LOG); \
	fi

flash: program

gdb: $(BUILD_DIR)/$(TARGET_ELF)
	@if [ -n "`which openocd 2> /dev/null | tr -d \\n`" ]; then \
		$(GDB) \
		-ex 'target remote | openocd -p -f $(OPENOCD_CONFIG) -c "gdb_port pipe; log_output $(OPENOCD_GDB_LOG)"' \
		$<; \
	fi

reset:
	@if [ -n "`which openocd 2> /dev/null | tr -d \\n`" ]; then \
		openocd -f $(OPENOCD_CONFIG) -c "init; reset run; shutdown" ; \
	fi

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
		$(TARGET_DIR)/config/nrfx_config.h &)

distclean: clean
	$(RM) -r *.log
	$(RM) -r debug
	$(RM) -r release

clean:
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
	@printf "GDB: $(GDB)\n"
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

.PHONY: all clean distclean flash gdb program $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)
