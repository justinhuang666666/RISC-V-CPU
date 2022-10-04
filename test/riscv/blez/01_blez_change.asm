# Expect: 0x334AF70

.text
.globl main
main: 
    lw      a0, var1   
    blez	a0, L1
    jr		zero	

L1: 
    lw      a0, var3
    blez	a0, L2
    jr		zero	

L2: 
    lw      a0, var2
    blez	a0, main
    jr		zero	

.data
var1: .word 0x00000000
var2: .word 0x0334AF70
var3: .word 0xF0000000
