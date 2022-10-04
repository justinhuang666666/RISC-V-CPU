# Expect: 0x4680

.text
.globl main
main:
    la t0, var2
    lh a0, 2(t0)
    jr zero
.data
    var: .word 0x14589BBA
    var2: .word 0x468024CD
