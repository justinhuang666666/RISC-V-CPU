# Expect: 0x9

.text
.globl main
main:
    addi t1, t1, 0xC
    xori a0, t1, 0x5
    jr zero
