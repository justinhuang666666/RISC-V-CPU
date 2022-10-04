# Expect: 0x0

.text
.globl main
main:
    addi t1, t1, 0x7FF
    xori a0, t1, 0x7FF
    jr zero
