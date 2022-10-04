# Expect: 0x7FF

.text
.globl main
main:
    addi t1, t1, 0x7FF
    andi a0, t1, 0x7FF
    jr zero
    