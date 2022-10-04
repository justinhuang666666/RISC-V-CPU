# Expect: 0x468

.text
.globl main
main: 
    addi	a0, zero, 0x234   
    addi	a1, zero, 0x234
    beq		a0, a1, L1
    addi	a0, a0, 0x238
    addi	a0, a0, 0x237
    jr		zero

L1: 
    addi	a0, a0, 0x234
    jr		zero
