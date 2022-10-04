# Expect: 0x0

.text
.globl main
main: 
    addi t0, t0, 0x0006
    sltiu a0, t0, 0x0006
    jr zero


