# Expect: 0x2F

.text
.globl main
main:
    addi t1, t1, 0xB
    ori a0, t1, 0x2F
    jr zero
