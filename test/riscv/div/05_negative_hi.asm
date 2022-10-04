# Expect: 0x0

.text
.globl main
main:
    addi t1, t1, -0xF
    addi t0, t2, -0x5
    rem a0, t1, t0
    jr zero
