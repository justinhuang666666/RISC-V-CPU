# Expect: 0xFFFFFFFF

.text
.globl main
main:
    la		a0, 0xF0000000
    la		t0, -0x0FFFFFFF
    sub    a0, a0, t0
    jr      zero
