# Expect: 0x9BBA

.text
.globl main
main:
    la t0, var1
    lhu a0, 2(t0)
    jr zero
.data
    var1: .word 0x9BBA1458
