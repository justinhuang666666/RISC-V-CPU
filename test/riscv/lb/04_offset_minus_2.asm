# Expect: 0xFFFFFF9B

.text
.globl main
main:
    la t0, var2
    lb a0, -2(t0)
    jr zero
.data
    var: .word 0x149B58BA
    var2: .word 0x468024CD
