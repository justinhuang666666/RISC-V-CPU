# Expect: 0x0

.text
.globl main
main:
    li t1, 0x7FFF
    mulh a0, t0, t1
    jr zero
