# Expect: 0xFFE1FFE

.text
.globl main
main:
    addi t0, zero, 0x7FF
    sll t0, t0, 0x10
    add t1, zero, 0x7FF
    add t1, t1, t1
    addi t0, t0, 0x1
    add t0, t1, t0 
    addi t2, t0, 0x0
    add a0, t0, t2 
    jr zero
