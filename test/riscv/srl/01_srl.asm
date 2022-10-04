# Expect: 0x333566E0

.text
.globl main
main:
    li  a0, 0x666ACDC1
    li  t0, 0x00000101
    srl a0, a0, t0
    jr  zero	
