# Expect: 0x4680

.text
.globl main
main:
    lhu a0, var2
    jr zero
.data
    var: .word 0x14589BBA
    var2: .word 0x24CD4680
