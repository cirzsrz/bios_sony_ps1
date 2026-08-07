# Makefile for Custom PS1 BIOS
TARGET = custom
TYPE = bin

# Toolchain (provided by the Docker container)
CC = mipsel-unknown-elf-gcc
LD = mipsel-unknown-elf-ld
OBJCOPY = mipsel-unknown-elf-objcopy

# Compiler and linker flags based on the OpenBIOS project
CFLAGS = -Wall -O2 -G0 -mips1 -mfp32 -mno-abicalls -fno-builtin -fno-stack-protector -nostdlib -nostartfiles
LDFLAGS = -T bios.ld -nostdlib

# Source files
SRCS = bios.c

# Object files
OBJS = $(SRCS:.c=.o)

all: $(TARGET).bin

$(TARGET).elf: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	truncate -s 0x80000 $@
	python3 fix_checksum.py $@

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin

.PHONY: all clean
