# Expect: 0xF0000000

.text
.globl main
main: 
    lw      a0, var1   
    bgez	a0, L1
    jr		zero	

L1: 
    la      t0, var2
    lw      t0, 0(t0)
    add    a0, a0, t0
    bgez	a0, L2
    jr		zero	

L2: 
    lw      a0, var3
    bgez	a0, main
    jr		zero	

.data
var1: .word 0x00000000
var2: .word 0x000F
var3: .word 0xF0000000
