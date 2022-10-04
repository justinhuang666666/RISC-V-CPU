# Expect: 0x0

.text
.globl main
main:
    addi t1, t1, -2048
    andi a0, t1, 0X0
    jr zero
    