# Expect: 0x995
.text
.globl main
main: 
    addi	a0, zero, 0x195
    addi	a1, zero, 0x195  
    beq		a0, a1, L1
    addi	a0, a0, 0x027  
    addi	a0, a0, 0x234       
    jr		zero				

L1: 
    addi	a0, a0, 0x7FF
    addi	a0, a0, 0x1
    jr		zero
