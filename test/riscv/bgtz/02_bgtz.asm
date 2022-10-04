# Expect: 0x3817FF05

.text
.globl main
main: 
    lw      a0, var1   
    bgtz	a0, L1
    lw	    a0, var3
    bgtz   	a0, L2
    lw      a0, var5 
    bgtz	a0, L2
    jr		zero	

L1: 
    lw      a0, var2
    bgtz	a0, L2
    lw	    a0, var3
    bgtz   	a0, L2
    lw      a0, var4
    jr		zero	
    

L2: 
    lw      a0, var4
    jr		zero	

.data
var1: .word -0x00089724
var2: .word 0xEF000000
var3: .word 0x00000000
var4: .word 0x3817FF05
var5: .word 0x0817FF05
