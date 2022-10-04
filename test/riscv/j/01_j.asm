# Expect: 0xFFFFF91F

.text
.globl main
main: 
    li   a0, 0xFFFFF910   
    j	 L1
    jr   zero

L1: 
    addi a0, a0, 0x0000F
    jr   zero
