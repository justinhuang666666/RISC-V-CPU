# Expect: 0x9BBA

.text
.globl main
main:
    la t0, var2
    lhu a0, -2(t0)
    jr zero
.data
    var: .word 0x9BBA1458
    var2: .word 0x468024CD
