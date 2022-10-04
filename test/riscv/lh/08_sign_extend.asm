# Expect: 0xFFFF9BBA

.text
.globl main
main:
    la t0, var1
    lh a0, 0(t0)
    jr zero
.data
    var1: .word 0xF4589BBA
