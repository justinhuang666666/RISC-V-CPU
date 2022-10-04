# Expect: 0xF458

.text
.globl main
main:
    la t0, var1
    lhu a0, 0(t0)
    jr zero
.data
    var1: .word 0x9BBAF458
