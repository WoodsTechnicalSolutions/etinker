ET_BOARD := ek-tm4c1294xl

TARGET_NAME = tiva-$(ET_BOARD)

TARGET_ELF = $(TARGET_NAME).elf
TARGET_BIN = $(TARGET_NAME).axf
TARGET_HEX = $(TARGET_NAME).hex
TARGET_MAP = $(TARGET_NAME).map

all: $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)

ET_DIR ?= $(shell realpath -e ../../..)

include $(ET_DIR)/etinker.mk

CC = $(ET_CROSS_TUPLE)-gcc
LD = $(ET_CROSS_TUPLE)-ld
GDB = $(ET_CROSS_TUPLE)-gdb
SIZE = $(ET_CROSS_TUPLE)-size
OBJCOPY = $(ET_CROSS_TUPLE)-objcopy
OBJDUMP = $(ET_CROSS_TUPLE)-objdump

MKDIR = mkdir -p

OUTPUT = build

TIVAWARE := tivaware-$(ET_MCU_LIBC)
TIVAWARE_DIR := $(ET_SOFTWARE_DIR)/$(TIVAWARE)

OPENOCD_GDB_CONFIG ?= openocd-gdb.cfg
OPENOCD_GDB_LOG := $(OUTPUT)/openocd-gdb.log

export GCC_EXEC_PREFIX := $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/lib/gcc

ifeq ($(ET_RELEASE),yes)
OPTIMIZE = -Os
else
OPTIMIZE = -g3 -Og
endif

CFLAGS = $(OPTIMIZE)
CFLAGS += $(ET_CFLAGS)
ifeq ($(ET_MCU_LIBC),newlib-nano)
CFLAGS += --specs=nano.specs
endif
ifeq ($(ET_MCU_LIBC),picolibc)
CFLAGS += --specs=picolibc.specs
endif
CFLAGS = -mthumb -march=armv7e-m+fp -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS += -MD -std=c99 -Wall -ffunction-sections -fdata-sections -pedantic
CFLAGS += -DPART_$(shell echo $(ET_BOARD_MCU) | tr '[:lower:]' '[:upper:]') -DTARGET_IS_TM4C123_RB1
CFLAGS += -I $(ET_TOOLCHAIN_DIR)/newlib-nano/$(ET_CROSS_TUPLE)/include
CFLAGS += -I $(TIVAWARE_DIR)

LDFLAGS  = $(OPTIMIZE)
LDFLAGS += $(ET_LDFLAGS)
ifeq ($(ET_MCU_LIBC),newlib-nano)
LDFLAGS += --specs=nano.specs
endif
ifeq ($(ET_MCU_LIBC),picolibc)
LDFLAGS += --specs=picolibc.specs
endif
LDFLAGS += -Wl,-T$(ET_BOARD_MCU).ld
LDFLAGS += -Wl,--entry=ResetISR
LDFLAGS += -Wl,--static
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(OUTPUT)/$(TARGET_MAP)
LDFLAGS += -Wl,-L $(ET_TOOLCHAIN_DIR)/$(ET_CROSS_TUPLE)/lib
LDFLAGS += -Wl,-L $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/lib
LDFLAGS += -Wl,-L $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/$(ET_CROSS_TUPLE)/lib
LDFLAGS += -Wl,-L $(ET_TOOLCHAIN_DIR)/$(ET_MCU_LIBC)/lib/gcc/$(ET_CROSS_TUPLE)/$(ET_TOOLCHAIN_GCC_VERSION)
LDFLAGS += -u _printf_float
LDFLAGS += -u _scanf_float

LDLIBS  = $(ET_LDLIBS)
LDLIBS += $(TIVAWARE_DIR)/driverlib/gcc/libdriver.a
LDLIBS += -Wl,--start-group -lm -lc -lgcc -Wl,--end-group

SOURCES = $(shell find src/ -name "*.c" -print)
TIVAWARE_SOURCES := $(TIVAWARE_DIR)/utils/uartstdio.c
ifndef RELEASE
OBJECTS = $(addprefix $(OUTPUT)/,$(notdir $(SOURCES:.c=.s)))
TIVAWARE_OBJECTS = $(addprefix $(OUTPUT)/$(TIVAWARE)/,$(notdir $(TIVAWARE_SOURCES:.c=.s)))
else
OBJECTS = $(addprefix $(OUTPUT)/,$(notdir $(SOURCES:.c=.o)))
TIVAWARE_OBJECTS = $(addprefix $(OUTPUT)/$(TIVAWARE)/,$(notdir $(TIVAWARE_SOURCES:.c=.o)))
endif

$(TARGET_ELF): $(OUTPUT)/$(TARGET_ELF)
$(OUTPUT)/$(TARGET_ELF): $(TIVAWARE_OBJECTS) $(OBJECTS)
	$(call toolchain-mcu-libc)
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)
	@$(SIZE) $@
ifndef RELEASE
	@$(OBJDUMP) -S --disassemble $@ > $@.lst 2> $@-error.lst
endif

$(TARGET_HEX): $(OUTPUT)/$(TARGET_HEX)
$(OUTPUT)/$(TARGET_HEX): $(OUTPUT)/$(TARGET_ELF)
	$(OBJCOPY) -O ihex $< $@

$(TARGET_BIN): $(OUTPUT)/$(TARGET_BIN)
$(OUTPUT)/$(TARGET_BIN): $(OUTPUT)/$(TARGET_ELF)
	$(OBJCOPY) -O binary $< $@

ifndef RELEASE
$(OUTPUT)/%.s: src/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -S $^ -o $@

$(OUTPUT)/$(TIVAWARE)/%.s: $(TIVAWARE_DIR)/utils/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -S $^ -o $@
else
$(OUTPUT)/%.o: src/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -c $^ -o $@

$(OUTPUT)/$(TIVAWARE)/%.o: $(TIVAWARE_DIR)/utils/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -c $^ -o $@
endif

$(OUTPUT):
	@$(MKDIR) $(OUTPUT)/$(TIVAWARE)

clean:
	$(RM) -r $(OUTPUT) *.log

flash: $(OUTPUT)/$(TARGET_BIN)
ifdef TARGET_SERIAL
	lm4flash -s $(TARGET_SERIAL) $<
else
	lm4flash $<
endif

program: flash

gdb: $(OUTPUT)/$(TARGET_ELF)
	@$(GDB) \
		-ex 'target remote | openocd -f board/ti_$(ET_BOARD).cfg -f $(OPENOCD_GDB_CONFIG) -c "gdb_port pipe; log_output $(OPENOCD_GDB_LOG)"' \
		$<

.PHONY: all clean flash gdb $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)
