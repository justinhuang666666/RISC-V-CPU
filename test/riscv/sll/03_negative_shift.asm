# Expect: 0xFFFFAC00

.text
.globl main
main:
    li  t0, -0x15
    li  t1, 0xA
    sll a0, t0, t1
    jr  zero
