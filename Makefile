# Makefile.docker - uses the Docker image's toolchain correctly
CC = mipsel-unknown-elf-gcc
LD = mipsel-unknown-elf-ld
OBJCOPY = mipsel-unknown-elf-objcopy
CHECKSUM = python3 fix_checksum.py

CFLAGS = -O2 -G0 -mips1 -mfp32 -mno-abicalls -fno-builtin \
         -fno-stack-protector -nostdlib -nostartfiles -Wall
LDFLAGS = -T bios.ld -nostdlib

all: custom.bios

custom.elf: bios.c bios.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ bios.c

custom.bios: custom.elf
	$(OBJCOPY) -O binary $< $@
	truncate -s 0x80000 $@
	$(CHECKSUM) $@

clean:
	rm -f custom.elf custom.bios

.PHONY: all clean
