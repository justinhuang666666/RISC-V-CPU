# Expect: 0x83

.text
.globl main
main:
    la t0, var1
    lbu a0, 1(t0)
    jr zero
.data
    var1: .word 0x81828384
