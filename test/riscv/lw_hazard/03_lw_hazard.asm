# Expect: 0x19

.text
.globl main
main:
    la   t3, var1
    addi t0, t0, 0xC     # t0 = 0xC
    sw   t0, 0(t3)       # M(var1) = 0xC
    addi t1, t0, 0x1     # t1 = 0xD
    lw   t1, 0(t3)       # t1 = M(var1) = 0xC 
    addi t2, t1, 0x1     # t2 = 0xD 
    add  a1, t1, t2      # a1 = 0x19
    addi a0, a1, 0x0     # a0 = 0x19
    jr   zero

.data
    var1: .word 0x00000000
