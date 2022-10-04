# Expect: 0x3

.text
.globl main
main:
    addi t1, zero, -0xF
    addi t2, zero, -0x05
    div a0, t1, t2
    jr zero
