# Expect: 0xFFFF9559

.text
.globl main
main:
    li      t2, 0xFFFF9559

repeat:
    add     a0, a0, t2
    bltz    a0, L3
    
L1: 
    addi    a0, a0, 0xA	
    li      t0, 0xF0000000
    add     a0, a0, t0
    bltz	a0, main

L3:
    jr      zero
