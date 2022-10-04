# Expect: 0x12

.text
.globl main
main:
    addi t1, t1, 0x12
    xor a0, t0, t1
    jr zero
