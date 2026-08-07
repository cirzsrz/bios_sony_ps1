#include <stdint.h>

#define GPU_GP0         (*(volatile uint32_t*)0x1F801810)
#define GPU_GP1         (*(volatile uint32_t*)0x1F801814)

static inline void gpu_send_cmd(uint32_t cmd) {
    while (GPU_GP0 & 0x80000000);
    GPU_GP0 = cmd;
}

static inline void gpu_send_ctrl(uint32_t cmd) {
    while (GPU_GP1 & 0x80000000);
    GPU_GP1 = cmd;
}

void fill_rect(int x, int y, int w, int h, uint16_t colour) {
    gpu_send_cmd(0xE1000000 | ((x + w - 1) << 0) | ((y + h - 1) << 16));
    gpu_send_cmd(0xE2000000 | (x << 0) | (y << 16));
    gpu_send_cmd(0x20);
    gpu_send_cmd((x << 16) | y);
    gpu_send_cmd((w << 16) | h);
    gpu_send_cmd(colour);
}

void draw_pixel(int x, int y, uint16_t colour) {
    fill_rect(x, y, 1, 1, colour);
}

static const uint8_t font[8][8] = {
    {0x81,0x81,0x81,0xFF,0x81,0x81,0x81,0x00},
    {0xFE,0x80,0x80,0xF8,0x80,0x80,0xFE,0x00},
    {0x80,0x80,0x80,0x80,0x80,0x80,0xFE,0x00},
    {0x7E,0x81,0x81,0x81,0x81,0x81,0x7E,0x00},
    {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00},
    {0x81,0x81,0x81,0x99,0xA5,0xC3,0x81,0x00},
    {0xFC,0x82,0x82,0xFC,0x82,0x82,0x82,0x00},
    {0xF8,0x84,0x82,0x82,0x82,0x84,0xF8,0x00}
};

int char_index(char c) {
    switch(c) {
        case 'H': return 0; case 'E': return 1; case 'L': return 2;
        case 'O': return 3; case ' ': return 4; case 'W': return 5;
        case 'R': return 6; case 'D': return 7; default: return 4;
    }
}

void draw_char(int x, int y, char c, uint16_t colour) {
    int idx = char_index(c);
    for (int row = 0; row < 8; row++) {
        uint8_t bits = font[idx][row];
        for (int col = 0; col < 8; col++) {
            if (bits & (1 << (7 - col)))
                draw_pixel(x + col, y + row, colour);
        }
    }
}

void draw_string(int x, int y, const char *str, uint16_t colour) {
    while (*str) {
        draw_char(x, y, *str, colour);
        x += 8;
        str++;
    }
}

void delay(int count) {
    for (volatile int i = 0; i < count; i++);
}

void _start() __attribute__((section(".text.start")));
void _start() {
    __asm__ volatile (
        "li $t0, 0x0000FFFF\n"
        "mtc0 $t0, $12\n"
        "li $sp, 0x80010000\n"
    );

    gpu_send_ctrl(0x00000000);
    gpu_send_ctrl(0x00000008);
    gpu_send_ctrl(0x00000044);
    gpu_send_ctrl(0x00000010);

    fill_rect(0, 0, 320, 240, 0x0000);
    fill_rect(100, 80, 120, 80, 0x7C00);
    draw_string(80, 110, "HELLO WORLD", 0xFFFF);

    while (1) {
        delay(1000000);
    }
}

void _reset() __attribute__((section(".vectors")));
void _reset() {
    __asm__ volatile ("j _start\n nop");
}
