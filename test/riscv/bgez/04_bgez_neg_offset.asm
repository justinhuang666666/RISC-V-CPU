# Expect: 0xFFFFFFFA

.text
.globl main
main:   
    addi    a0, zero, -3
    li      t1, 0x2f61
    beq     a0, t1, L3
    
L1: 
    addi    a0, a0, -3
    bgez	a0, main

L3:
    jr      zero

