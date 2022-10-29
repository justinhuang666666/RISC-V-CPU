# Expect: 0x19

.text
.globl main
main:
    addi t0, t0, 0xC     # t0 = 0xC
    la   t1, var1
    sw   t0, 0(t1)     # M(0x4) = 0xC
    addi t0, t0, 0x1     # t0 = 0xD
    lw   t1, 0(t1)     # t1 = M(0x4) = 0xC 
    add  t0, t0, t1      # t0 = 0x19
    addi a0, t0, 0x0     # a0 = 0x19 
    jr zero

.data
    var1: .word 0x00000004
