# Expect: 0x468024BA

.text
.globl main
main:
    la t1, var1
    lw t0, 0(t1)
    la t2, var2
    sb t0, 0(t2)
    lw a0, 0(t2)
    jr zero

.data
    var1: .word 0x14589BBA
    var2: .word 0x468024CD
