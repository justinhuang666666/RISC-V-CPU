# Expect: 0x12

.text
.globl main
main:
    li t0, 0x12
    sll a0, t0, t1
    jr zero
