# Expect: 0x9175FAC1

.text
.globl main
main:
    li  a0,  0x9175FAC1
    li  t0,  0x00000100
    srl a0, a0, t0
    jr  zero	
