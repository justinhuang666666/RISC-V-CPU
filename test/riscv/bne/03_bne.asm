# Expect: 0xFFFF9174

.text
.globl main

main:
    li      a1, 0x8164DAC2
    bne     a0, a1, L1
    li      a0, 0x8164DAC2
    bne     a0, a1, L1
    jr		zero

L1:
    li      t0, 0xFFFF9174
    add 	a0, a0, t0	
    jr		zero		
