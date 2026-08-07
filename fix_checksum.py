#!/usr/bin/env python3
import sys
import struct

def compute_checksum(data):
    data = bytearray(data)
    data[0x1E0:0x1E4] = b'\x00\x00\x00\x00'
    checksum = 0
    for i in range(0, len(data), 4):
        word = struct.unpack_from('<I', data, i)[0]
        checksum = (checksum + word) & 0xFFFFFFFF
    return checksum

def main():
    if len(sys.argv) < 2:
        print("Usage: fix_checksum.py <bios_file>")
        sys.exit(1)
    filename = sys.argv[1]
    with open(filename, 'rb') as f:
        data = f.read()
    if len(data) != 0x80000:
        print(f"Warning: size {len(data)} bytes, expected 524288")
    checksum = compute_checksum(data)
    data = bytearray(data)
    struct.pack_into('<I', data, 0x1E0, checksum)
    with open(filename, 'wb') as f:
        f.write(data)
    print(f"Checksum written: 0x{checksum:08X}")

if __name__ == '__main__':
    main()
