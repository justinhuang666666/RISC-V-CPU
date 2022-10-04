# Expect: 0x0

.text
.globl main
main:
    addi t0, t0, 0x5
    addi t1, t1, 0x5
    mulhu a0, t0, t1
    jr zero
