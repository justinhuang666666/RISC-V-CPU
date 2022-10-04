# Expect: 0x80000000

.text
.globl main
main:
    li  t0, 0x1F
    li  t1, 0x1F
    sll a0, t0, t1
    jr  zero
