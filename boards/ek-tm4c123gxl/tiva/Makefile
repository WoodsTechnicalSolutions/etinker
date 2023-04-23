ET_BOARD := ek-tm4c123gxl

TARGET_NAME = tiva-$(ET_BOARD)

TARGET_ELF = $(TARGET_NAME).elf
TARGET_BIN = $(TARGET_NAME).axf
TARGET_HEX = $(TARGET_NAME).hex
TARGET_MAP = $(TARGET_NAME).map

TARGET_DIR := $(shell realpath -e $(CURDIR))

all: depends $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)

ET_DIR ?= $(shell realpath -e ../../..)

include $(ET_DIR)/etinker.mk

TIVAWARE := tivaware-$(ET_MCU_LIBC)
TIVAWARE_DIR := $(ET_SOFTWARE_DIR)/$(TIVAWARE)

ifeq ($(ET_RELEASE),yes)
TARGET_BUILD := release
else
TARGET_BUILD := debug
endif

CC = $(ET_CROSS_TUPLE)-gcc
LD = $(ET_CROSS_TUPLE)-ld
SIZE = $(ET_CROSS_TUPLE)-size
OBJCOPY = $(ET_CROSS_TUPLE)-objcopy
OBJDUMP = $(ET_CROSS_TUPLE)-objdump

MKDIR = mkdir -p

BUILD_DIR := $(TARGET_BUILD)

ifeq ($(ET_RELEASE),yes)
OPTIMIZE = -Os
else
OPTIMIZE = -g3 -Og
endif

CFLAGS  = $(OPTIMIZE)
CFLAGS += $(ET_CFLAGS)
CFLAGS += --sysroot=$(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
CFLAGS += -isysroot $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
CFLAGS += -mthumb -march=armv7e-m+fp -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS += -MD -std=c99 -Wall -ffunction-sections -fdata-sections -pedantic
CFLAGS += -DPART_$(shell echo $(ET_BOARD_MCU) | tr '[:lower:]' '[:upper:]') -DTARGET_IS_TM4C123_RB1
CFLAGS += -I $(TIVAWARE_DIR)
ifeq ($(ET_MCU_LIBC),picolibc)
CFLAGS += -I $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/include
endif

LDFLAGS  = $(OPTIMIZE)
LDFLAGS += $(ET_LDFLAGS)
LDFLAGS += --sysroot=$(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)
LDFLAGS += -Wl,-T$(ET_BOARD_MCU).ld
LDFLAGS += -Wl,--entry=ResetISR
LDFLAGS += -Wl,--static
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,--no-dynamic-linker
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/$(TARGET_MAP)
LDFLAGS += -u _printf_float
LDFLAGS += -u _scanf_float

LDLIBS  = $(ET_LDLIBS)
LDLIBS += $(TIVAWARE_DIR)/driverlib/gcc/libdriver.a
LDLIBS += -Wl,--start-group -lm -lc -lgcc -Wl,--end-group

SOURCES = $(shell find src/ -name "*.c" -print)
TIVAWARE_SOURCES := $(TIVAWARE_DIR)/utils/uartstdio.c
ifndef RELEASE
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.s)))
TIVAWARE_OBJECTS = $(addprefix $(BUILD_DIR)/$(TIVAWARE)/,$(notdir $(TIVAWARE_SOURCES:.c=.s)))
else
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))
TIVAWARE_OBJECTS = $(addprefix $(BUILD_DIR)/$(TIVAWARE)/,$(notdir $(TIVAWARE_SOURCES:.c=.o)))
endif

depends:
	$(call toolchain-mcu-libc)

$(TARGET_ELF): $(BUILD_DIR)/$(TARGET_ELF)
$(BUILD_DIR)/$(TARGET_ELF): $(TIVAWARE_OBJECTS) $(OBJECTS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)
	@$(SIZE) $@
ifndef RELEASE
	@$(OBJDUMP) -S --disassemble $@ > $@.lst 2> $@-error.lst
endif

$(TARGET_HEX): $(BUILD_DIR)/$(TARGET_HEX)
$(BUILD_DIR)/$(TARGET_HEX): $(BUILD_DIR)/$(TARGET_ELF)
	$(OBJCOPY) -O ihex $< $@

$(TARGET_BIN): $(BUILD_DIR)/$(TARGET_BIN)
$(BUILD_DIR)/$(TARGET_BIN): $(BUILD_DIR)/$(TARGET_ELF)
	$(OBJCOPY) -O binary $< $@

ifndef RELEASE
$(BUILD_DIR)/%.s: src/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -S $^ -o $@

$(BUILD_DIR)/$(TIVAWARE)/%.s: $(TIVAWARE_DIR)/utils/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -S $^ -o $@
else
$(BUILD_DIR)/%.o: src/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $^ -o $@

$(BUILD_DIR)/$(TIVAWARE)/%.o: $(TIVAWARE_DIR)/utils/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $^ -o $@
endif

$(BUILD_DIR):
	@$(MKDIR) $(BUILD_DIR)/$(TIVAWARE)

clean:
	$(RM) -r $(BUILD_DIR) *.log

flash: $(BUILD_DIR)/$(TARGET_BIN)
ifdef TARGET_SERIAL
	lm4flash -s $(TARGET_SERIAL) $<
else
	lm4flash $<
endif

program: flash

openocd:
	$(call openocd, server)

gdb: $(BUILD_DIR)/$(TARGET_ELF)
	$(call openocd, $@, $<)

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

.PHONY: all clean depends flash gdb openocd $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)
