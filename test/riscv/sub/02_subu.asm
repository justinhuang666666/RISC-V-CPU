# Expect: 0x860C

.text
.globl main
main:
    li t1, 0x8560
    li t2, -0xAC
    sub a0, t1, t2
    jr zero
