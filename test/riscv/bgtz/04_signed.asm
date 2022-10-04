# Expect: 0x123

.text
.globl main
main: 
    li t1, 0x80000000
    bgtz t1, incorrect
    addi a0, a0, 0x123
    jr zero
incorrect: 
    jr zero
