OUTPUT_ARCH(mipsel)
ENTRY(_reset)

MEMORY {
    rom (rx) : ORIGIN = 0xBFC00000, LENGTH = 0x80000
}

SECTIONS {
    .vectors : { *(.vectors) } > rom
    .text : { *(.text.start) *(.text) } > rom
    .rodata : { *(.rodata) } > rom
    .data : { *(.data) } > rom
    .bss : { *(.bss) } > rom
    /DISCARD/ : { *(.reginfo) *(.comment) *(.pdr) }
}
