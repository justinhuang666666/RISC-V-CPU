# Expect: 0x83

.text
.globl main
main:
    la t0, var1
    lbu a0, 5(t0)
    jr zero
.data
    var1: .word 0x41424344
    var2: .word 0x81828384
