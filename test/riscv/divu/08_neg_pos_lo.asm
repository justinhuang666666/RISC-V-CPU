# Expect: 0xFFFFFFFF
    
.text
.globl main
main:    
    addi t0, t0, -0x1
    addi t1, t1, 0x1
    divu a0, t0, t1
    jr zero
