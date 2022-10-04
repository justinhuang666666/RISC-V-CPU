# Expect: 0x1

.text
.globl main
main: 
    addi t1, t1, 0x000F
    addi t0, t0, 0x0009
    sltu a0, t0, t1
    jr zero
