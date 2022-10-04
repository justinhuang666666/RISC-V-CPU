# Expect: 0x0

.text
.globl main
main:
    mulhu a0, t0, t1
    jr zero
