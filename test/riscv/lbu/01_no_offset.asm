# Expect: 0xBA

.text
.globl main
main:
    lbu a0, var
    jr zero
.data
    var: .word 0x14589BBA
    var2: .word 0x468024CD
