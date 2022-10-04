# Expect: 0xA

.text
.globl main
main:
    addi t1, t1, 0x5
    add t0, t1, t2
    add a0, t1, t0
    add t2, t1, t0
    jr zero
