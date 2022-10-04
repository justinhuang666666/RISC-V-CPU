# Expect: 0x123

.text
.globl main
main:
    li a0, 0
    li t1, 0x80000000
    bgez t1, incorrect
    addi a0, zero, 0x123
    jr zero
incorrect: 
    jr zero
