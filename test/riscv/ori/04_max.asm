# Expect: 0x7FF

.text
.globl main
main:
    li t1, 0x7FF
    ori a0, t1, 0x7FF
    jr zero
