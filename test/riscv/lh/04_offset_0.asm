# Expect: 0x24CD

.text
.globl main
main:
    lh a0, var2
    jr zero
.data
    var: .word 0x14589BBA
    var2: .word 0x468024CD
