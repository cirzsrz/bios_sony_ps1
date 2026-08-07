CC = mipsel-linux-gnu-gcc
LD = mipsel-linux-gnu-ld
OBJCOPY = mipsel-linux-gnu-objcopy
CHECKSUM = python3 fix_checksum.py

CFLAGS = -nostdlib -nostartfiles -Wall -O2 -G0 -mips1 -mfp32 \
         -mno-abicalls -fno-builtin -fno-stack-protector

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
