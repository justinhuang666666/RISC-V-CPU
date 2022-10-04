# Expect: 0x0

.text
.globl main
main:
    li t1, 0x7FFF
    sll t1, t1, 0x10
    li t2, 0x7FFF
    add t2, t2, t2
    addi t2, t2, 0x1
    add t1, t1, t2
    mul a0, t0, t1
    jr zero
