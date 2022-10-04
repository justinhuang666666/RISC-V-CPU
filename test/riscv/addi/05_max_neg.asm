# Expect: 0xFFFFF000

.text
.globl main
main:
    addi t0, t0, 0xFFFFF800
    addi a0, t0, 0xFFFFF800
    jr zero
