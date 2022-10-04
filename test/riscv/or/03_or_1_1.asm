# Expect: 0x1D

.text
.globl main
main:
    addi t1, t1, 0x15
    addi t2, t2, 0x1D
    or a0, t1, t2
    jr zero
