# Expect: 0xFFFFFFF6

.text
.globl main
main:
    addi t0, zero, -0x5
    addi t1, zero, -0x5
    mulhu a0, t0, t1
    jr zero
