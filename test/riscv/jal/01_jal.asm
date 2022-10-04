# Expect: 0x2F03

.text
.globl main
main: 
    lw      a0, var1 
    addi    a0, a0, 0x7A3
    jal     L1
    jr      zero

L1: 
    addi   a0, a0, 0x00F
    addi   a0, a0, 0x400
    jr      ra
    
.data
var1: .word 0x00002351
