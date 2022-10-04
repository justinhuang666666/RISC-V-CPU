# Expect: 0xFF00427A

.text
.globl main
main:
    li      t2, 0x2137

repeat:   
    add     a0, a0, t2
    li      t1, 0xFF00427A
    beq     a0, t1, L3

L1: 
    addi    a0, a0, 0xC	
    li      t0, 0xFF000000
    add     a0, a0, t0
    blez	a0, repeat

L3:
    jr      zero
