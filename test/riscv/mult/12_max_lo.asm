# Expect: 0x1

.text
.globl main
main:
    li t0, 0x7FFF
    sll t0, t0, 0x10
    li t1, 0x7FFF
    add t1, t1, t1
    addi t0, t0, 0x1
    add t0, t1, t0 
    addi t2, t0, 0x0
    mul a0, t0, t2
    jr zero
