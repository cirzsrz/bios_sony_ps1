CC = mipsel-unknown-elf-gcc
LD = mipsel-unknown-elf-ld
OBJCOPY = mipsel-unknown-elf-objcopy
CHECKSUM = python3 fix_checksum.py

CFLAGS = -Wall -O2 -G0 -mips1 -mfp32 -mno-abicalls \
         -fno-builtin -fno-stack-protector -nostdlib -nostartfiles
LDFLAGS = -T bios.ld -nostdlib

all: custom.bios

custom.elf: bios.c bios.ld
	$(CC) $(CFLAGS) -Wl,-T,bios.ld -Wl,-nostdlib -o $@ bios.c

custom.bios: custom.elf fix_checksum.py
	$(OBJCOPY) -O binary $< $@
	truncate -s 0x80000 $@
	$(CHECKSUM) $@

clean:
	rm -f custom.elf custom.bios

.PHONY: all clean
