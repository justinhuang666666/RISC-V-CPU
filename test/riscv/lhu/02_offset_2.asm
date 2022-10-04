# Expect: 0x24CD

.text
.globl main
main:
    la t0, var2
    lhu a0, 2(t0)
    jr zero
.data
    var: .word 0x14589BBA
    var2: .word 0x24CD4680
