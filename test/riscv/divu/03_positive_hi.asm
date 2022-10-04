# Expect: 0x0

.text
.globl main
main:
    addi t0, t0, 0xF
    addi t1, t1, 0x5
    remu a0, t0, t1
    jr zero
