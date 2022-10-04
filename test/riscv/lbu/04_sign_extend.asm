# Expect: 0x9B

.text
.globl main
main:
    la t0, var1
    lbu a0, 2(t0)
    jr zero
.data
    var1: .word 0x149B58BA
