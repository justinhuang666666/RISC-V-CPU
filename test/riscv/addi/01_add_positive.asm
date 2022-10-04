# Expect: 0xC

.text
.globl main
main:
    addi t0, zero, 0x8    # t0 = 0x8
    addi t0, t0,   0x3     # t0 = 0xB
    addi t0, t0,   0x1     # t0 = 0xC
    addi a0, t0,   0x0     # a0 = 0xC
    jr zero
