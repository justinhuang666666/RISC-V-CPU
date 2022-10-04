# Expect: 0x14

.text
.globl main
main:
    lb a0, var
    jr zero
.data
    var: .word 0xBA589B14
    var2: .word 0x468024CD
