ET_BOARD := ek-tm4c123gxl

TARGET_NAME = tiva-$(ET_BOARD)

TARGET_ELF = $(TARGET_NAME).elf
TARGET_BIN = $(TARGET_NAME).axf
TARGET_HEX = $(TARGET_NAME).hex
TARGET_MAP = $(TARGET_NAME).map

all: $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)

ET_DIR := $(shell realpath ../../..)

include $(ET_DIR)/etinker.mk

TIVAWARE := $(ET_SOFTWARE_DIR)/tivaware

CFLAGS = -march=armv7e-m -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb
CFLAGS += -MD -std=c99 -Wall -ffunction-sections -fdata-sections -pedantic
CFLAGS += -DPART_$(shell echo $(ET_BOARD_MCU) | tr '[:lower:]' '[:upper:]') -DTARGET_IS_TM4C123_RB1
CFLAGS += -I$(TIVAWARE)
ifdef DEBUG
CFLAGS += -Og -g3 -gdwarf -DDEBUG=1
else
CFLAGS += -Os
endif

CC = $(ET_CROSS_TUPLE)-gcc
LD = $(ET_CROSS_TUPLE)-ld
GDB = $(ET_CROSS_TUPLE)-gdb
SIZE = $(ET_CROSS_TUPLE)-size
OBJCOPY = $(ET_CROSS_TUPLE)-objcopy
OBJDUMP = $(ET_CROSS_TUPLE)-objdump

MKDIR = mkdir -p

OUTPUT = build

LDFLAGS = -Wl,-T$(ET_BOARD_MCU).ld \
	  -Wl,--entry=ResetISR \
	  -Wl,--static \
	  -Wl,--gc-sections \
	  -Wl,-Map=$(OUTPUT)/$(TARGET_MAP)

LDLIBS = $(ET_SOFTWARE_DIR)/tivaware/driverlib/gcc/libdriver.a

SOURCES = $(shell find src/ -name "*.c" -print)
TIVAWARE_SOURCES := $(TIVAWARE)/utils/uartstdio.c
ifdef DEBUG
OBJECTS = $(addprefix $(OUTPUT)/,$(notdir $(SOURCES:.c=.s)))
TIVAWARE_OBJECTS = $(addprefix $(OUTPUT)/tivaware/,$(notdir $(TIVAWARE_SOURCES:.c=.s)))
else
OBJECTS = $(addprefix $(OUTPUT)/,$(notdir $(SOURCES:.c=.o)))
TIVAWARE_OBJECTS = $(addprefix $(OUTPUT)/tivaware/,$(notdir $(TIVAWARE_SOURCES:.c=.o)))
endif

$(TARGET_ELF): $(OUTPUT)/$(TARGET_ELF)
$(OUTPUT)/$(TARGET_ELF): $(TIVAWARE_OBJECTS) $(OBJECTS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS)
	@$(SIZE) $@
ifdef DEBUG
	@$(OBJDUMP) -S --disassemble $@ > $@.lst 2> $@-error.lst
endif

$(TARGET_HEX): $(OUTPUT)/$(TARGET_HEX)
$(OUTPUT)/$(TARGET_HEX): $(OUTPUT)/$(TARGET_ELF)
	$(OBJCOPY) -O ihex $< $@

$(TARGET_BIN): $(OUTPUT)/$(TARGET_BIN)
$(OUTPUT)/$(TARGET_BIN): $(OUTPUT)/$(TARGET_ELF)
	$(OBJCOPY) -O binary $< $@

ifdef DEBUG
$(OUTPUT)/%.s: src/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -S $^ -o $@

$(OUTPUT)/tivaware/%.s: $(TIVAWARE)/utils/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -S $^ -o $@
else
$(OUTPUT)/%.o: src/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -c $^ -o $@

$(OUTPUT)/tivaware/%.o: $(TIVAWARE)/utils/%.c | $(OUTPUT)
	$(CC) $(CFLAGS) -c $^ -o $@
endif

$(OUTPUT):
	@$(MKDIR) $(OUTPUT)/tivaware

clean:
	$(RM) -r $(OUTPUT) *.log

flash: $(OUTPUT)/$(TARGET_BIN)
	lm4flash $<

gdb: $(OUTPUT)/$(TARGET_ELF)
	@$(GDB) \
		-ex 'target remote | openocd -p -f board/$(ET_BOARD).cfg -c "gdb_port pipe; log_output $(ET_BOARD)-openocd.log"' \
		$<

.PHONY: all clean flash gdb $(TARGET_ELF) $(TARGET_HEX) $(TARGET_BIN)
