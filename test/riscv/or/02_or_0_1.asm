# Expect: 0x15

.text
.globl main
main:
    addi t1, t1, 0x15
    or a0, t0, t1
    jr zero
