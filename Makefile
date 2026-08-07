# Makefile – uses system mipsel-linux-gnu toolchain
CC = mipsel-linux-gnu-gcc
OBJCOPY = mipsel-linux-gnu-objcopy
CHECKSUM = python3 fix_checksum.py

# These are the EXACT flags from PCSX-Redux common.mk
ARCHFLAGS = -march=mips1 -mabi=32 -EL -fno-pic -mno-shared -mno-abicalls \
            -mfp32 -mno-llsc -fno-stack-protector -nostdlib -ffreestanding
CFLAGS = $(ARCHFLAGS) -Wall -O2 -G0 -fno-builtin -fno-strict-aliasing
LDFLAGS = -nostdlib -Wl,-T,bios.ld -Wl,--oformat=elf32-tradlittlemips

all: custom.bios

custom.elf: bios.c bios.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ bios.c

custom.bios: custom.elf fix_checksum.py
	$(OBJCOPY) -O binary $< $@
	truncate -s 0x80000 $@
	$(CHECKSUM) $@

clean:
	rm -f custom.elf custom.bios

.PHONY: all clean
