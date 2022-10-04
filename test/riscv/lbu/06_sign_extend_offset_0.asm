# Expect: 0x84

.text
.globl main
main:
    la t0, var1
    lbu a0, 0(t0)
    jr zero
.data
    var1: .word 0x81828384
