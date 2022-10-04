# Expect: 0xFFFFFFFD

.text
.globl main
main:
    addi t1, t1, 0xF
    addi t0, t2, -0x5
    div a0, t1, t0
    jr zero

