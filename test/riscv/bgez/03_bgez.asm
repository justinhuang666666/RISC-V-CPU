# Expect: 0xFE

.text
.globl main
main: 
    lw      a0, var1   
    bgez	a0, L1
    jr		zero	

L1: 
    la      a0, -0x1
    bgez	a0, L2
    addi   a0, a0, 0x00FF
    jr		zero	

L2: 
    lw      a0, var3
    bgez	a0, main
    jr		zero	

.data
var1: .word 0x009785FC
var3: .word 0xF0000000
