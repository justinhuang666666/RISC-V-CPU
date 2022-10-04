# Expect: 0x3

.text
.globl main
main:
    addi t0, t0, 0xF
    addi t1, t1, 0x5
    divu a0, t0, t1
    jr zero
