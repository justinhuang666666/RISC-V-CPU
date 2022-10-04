# Expect: 0x12D2

.text
.globl main
main:   
    addi    a0, a0, 0x559
    li		 t1, 0x12D2
    beq      a0, t1, L2
    
L1: 
    li      t0, 0x000A
    add     a0, a0, t0
    li      t0, 0x0816	
    add     a0, a0, t0
    li       a1, 0x5137
    bne	     a0, a1, main
    
L2:
    jr       zero
