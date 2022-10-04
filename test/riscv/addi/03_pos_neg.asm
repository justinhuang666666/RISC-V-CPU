# Expect: 0xFFFFFFB8

.text
.globl main
main:
    addi t0, t0, -0x6A
    addi a0, t0, 0x22
    jr zero
