# Expect: 0x3

.text
.globl main
main:
    addi t1, t1, 0xF
    addi t2, t2, 0x5
    div a0, t1, t2
    jr zero
