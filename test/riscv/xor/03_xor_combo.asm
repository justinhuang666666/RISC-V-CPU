# Expect: 0x34

.text
.globl main
main:
    addi t1, t1, 0x2D
    addi t0, t0, 0x19
    xor a0, t0, t1
    jr zero
