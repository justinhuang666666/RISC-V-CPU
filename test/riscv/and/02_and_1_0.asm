# Expect: 0x0

.text
.globl main
main:
    addi t2, t2, 0x7
    and a0, t1, t2   
    jr zero 
