typedef unsigned int uint32_t;
typedef unsigned char uint8_t;

#define OUT_ADDR ((uint8_t *)0x20)

void main() {
    uint32_t fact = 1, i = 0;

    for (i = 1; i != 10; i++) {
        fact *= i;
        *(volatile uint32_t *)OUT_ADDR = fact;
    }
}
