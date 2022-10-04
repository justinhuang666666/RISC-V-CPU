# Expect: 0x123

.text
.globl main
main: 
    li t1, 0x80000000
    blez t1, correct
    jr zero
correct:
    addi a0, a0, 0x123
    jr zero
