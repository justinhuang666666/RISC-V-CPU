# Expect: 0x266593

.text
.globl main
main: 
    li      a0, 0x00266593        
    bne		a0, a1, L1
    jr      zero
L1:

    addi	a0, a0, 0x001
    bne		a0, a1, L2
    li      t0, 0x00266593
    add  	a0, a0, t0
    jr      zero
L2:
    li      a0, 0x00266593
    jr      zero
