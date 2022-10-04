# Expect: 0xFFFFFFFB

.text
.globl main
main:   
    addi a0, zero, -5
    addi t0, zero, -5
    beq a0, t0, L3
L1: 
    addi a0, a0, 1
L2: 
    beq a0, t0, L1
L3: 
    jr zero
