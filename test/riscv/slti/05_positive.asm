# Expect: 0x1

.text
.globl main
main: 
    addi t1, zero, 1
    slti a0, t1, 2
    jr zero
