# Makefile - based on OpenBIOS build system
TARGET = custom
CC = mipsel-unknown-elf-gcc
LD = mipsel-unknown-elf-ld
OBJCOPY = mipsel-unknown-elf-objcopy

CFLAGS = -O2 -G0 -mips1 -mfp32 -mno-abicalls -fno-builtin -fno-stack-protector \
         -nostdlib -nostartfiles -Wall -Werror
LDFLAGS = -T bios.ld -nostdlib

all: $(TARGET).bios

$(TARGET).elf: bios.c bios.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ bios.c

$(TARGET).bios: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	truncate -s 0x80000 $@
	python3 fix_checksum.py $@

clean:
	rm -f $(TARGET).elf $(TARGET).bios

.PHONY: all clean
