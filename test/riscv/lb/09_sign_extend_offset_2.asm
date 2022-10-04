# Expect: 0xFFFFFF82

.text
.globl main
main:
    la t0, var1
    lb a0, 2(t0)
    jr zero
.data
    var1: .word 0x81828384
