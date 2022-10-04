# Expect: 0x0

.text
.globl main
main:
    addi t1, t1, 0x4
    rem a0, t0, t1
    jr zero
