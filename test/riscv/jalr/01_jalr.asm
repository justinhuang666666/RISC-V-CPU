# Expect: 0x00082C89

.text
.globl main
main: 
    la      t2, var1
    lw      a1, 0(t2)
    li      a0, 0x15AD
    add     a0, a0, a1
    li		t1, 0xbfc0001c
    jalr	t1
    jr		zero

L1: 
    addi    a0, a0, 0x000F
    li      a1, 0x6400
    add     a0, a0, a1
    jr      ra


.data
var1: .word 0x000816DC
