# Expect: 0xA

.text
.globl main
main: 
    addi t1, t1, 0x000F
    addi t0, t0, 0x0009
    sltu a0, t1, t0
    addi a0, a0, 0x000A
    jr zero


