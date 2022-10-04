# Expect: 0x0

.text
.globl main
main:
    addi t1, t1, 0xF
    addi t2, t2, 0x5
    rem a0, t1, t2
    jr zero
