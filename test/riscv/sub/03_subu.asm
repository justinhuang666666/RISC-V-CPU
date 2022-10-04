# Expect: 0xA0000000

.text
.globl main
main:
    la		a0, 0xAFFFFFFF
    la		t0, 0x0FFFFFFF
    sub    a0, a0, t0
    jr zero

    