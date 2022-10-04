# Expect: 0x1F8B

.text
.globl main
main:
    li      a0, 0
    
repeat:
    li      t0, 0xFC0
    add     a0, a0, t0 
    li      t1, 0x1F8B
    beq     a0, t1, L3

L1: 
    addi    a0, a0, 0xB
    bgtz	a0, repeat

L3:
    jr      zero
