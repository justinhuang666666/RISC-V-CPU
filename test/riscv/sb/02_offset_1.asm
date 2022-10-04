# Expect: 0xFFFFFFBA

.text
.globl main
main:
    lb t0, var
    la t1, var2
    sb t0, 1(t1)
    lb a0, 1(t1)
    jr zero

.data
    var: .word 0x14589BBA
    var2: .word 0x468024CD
