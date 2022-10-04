# Expect: 0x18

.text
.globl main
main:
    la   t3, var1
    la   t4, var2
    addi t0, t0, 0xC     # t0 = 0xC
    sw   t0, 0(t3)       # M(var1) = 0xC
    sw   t0, 0(t4)       # M(var2) = 0xC
    lw   t1, 0(t3)       # t1 = M(var1) = 0xC 
    lw   t2, 0(t4)       # t2 = M(var2) = 0xC
    add  t0, t1, t2      # t0 = 0x18
    addi a0, t0, 0x0     # a0 = 0x18
    jr   zero

.data
    var1: .word 0x00000000
    var2: .word 0x00000000
