# Expect: 0xFFFFFFAF

.text
.globl main
main:
    addi t1, t1, -0x6 
    addi t2, t2, -0x4B
    add a0, t1, t2
    jr zero
    
