# Expect: 0x71

.text
.globl main
main:
    la t0, var2
    lb a0, 2(t0)
    jr zero
.data
    var: .word 0x14589BBA
    var2: .word 0x467124CD
