# Expect: 0x19

.text
.globl main
main:
    addi t0, t0, 0x5
    addi t1, t1, 0x5
    mul a0, t0, t1
    jr zero
