# Expect: 0x17FFD

.text
.globl main
main:
    li t0, 0x17FFD
    la t1, var1
    sw t0, 0(t1)
    lw a0, 0(t1)
    jr zero

.data
    var1: .word 0x00000000
