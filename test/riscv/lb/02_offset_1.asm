# Expect: 0x7F

.text
.globl main
main:
    li t1, 0x17FFD
    la t0, var1
    sw t1, 0(t0)
    lb a0, 1(t0)
    jr zero

.data
    var1: .word 0x11111111
