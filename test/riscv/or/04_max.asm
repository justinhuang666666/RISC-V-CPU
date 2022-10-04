# Expect: 0x7FFF

.text
.globl main
main:
    li t1, 0x7FFF
    li t2, 0x7FFF
    or a0, t1, t2
    jr zero
