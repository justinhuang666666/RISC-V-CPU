# Expect: 0x80000000

.text
.globl main
main:
    li  t0, 0x15
    li  t1, 0x7F1F
    sll a0, t0, t1
    jr  zero
