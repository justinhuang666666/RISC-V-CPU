# Expect: 0x4680BACD

.text
.globl main
main:
    lw t0, var
    la t1, var2
    sb t0, 1(t1)
    lw a0, 0(t1)
    jr zero

.data
    var: .word 0x14589BBA
    var2: .word 0x468024CD
