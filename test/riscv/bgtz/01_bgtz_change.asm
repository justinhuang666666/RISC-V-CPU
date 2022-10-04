# Expect: 0x35829502

.text
.globl main
main: 
    lw      a0, var1   
    bgtz	a0, L1
    jr		zero	

L1: 
    lw      a0, var2
    bgtz	a0, L2
    lw	    a0, var3
    bgtz   	a0, L2
    lw      a0, var4
    jr		zero	
    

L2: 
    lw      a0, var3
    bgtz	a0, main
    jr		zero	

.data
var1: .word 0x00003452
var2: .word 0x00000000
var3: .word 0xF0000000
var4: .word 0x35829502
