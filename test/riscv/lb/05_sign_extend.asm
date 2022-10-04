# Expect: 0xFFFFFF9B

.text
.globl main
main:
    la t0, var1
    lb a0, 2(t0)
    jr zero
.data
    var1: .word 0x149B58BA
