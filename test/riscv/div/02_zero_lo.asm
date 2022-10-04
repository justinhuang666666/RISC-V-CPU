# Expect: 0x0

.text
.globl main
main:
    addi t1, t1, 0x4
    div a0, zero, t1
    jr zero
