# Expect: 0xBFC0000C

.text
.globl main
main:
    addi t0, zero, 0x1     # t0 = 0x1 
    jal  t1, L2         # Jump, t1 = 0xBFC00008
    addi t0, t0, 0x2     # No exec 
L2:
    add  t2, t0, t1      # t2 = 0x9 
    addi a0, t2, 0x3     # a0 = 0xC
    jr zero
