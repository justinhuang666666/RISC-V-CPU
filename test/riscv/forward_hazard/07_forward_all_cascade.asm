# Expect: 0x17
# Extensive test 

.text
.globl main
main:
    addi t0, x0, 0x1     # t0 = 0x1 
    addi t1, t0, 0x2     # t1 = 0x3
    addi t2, t1, 0x3     # t2 = 0x6
    addi a1, t2, 0x4     # a1 = 0xA
    addi a2, t2, 0x5     # a2 = 0xB
    addi a3, a1, 0x6     # a3 = 0x10
    addi a4, a3, 0x7     # a4 = 0x17
    addi a0, a4, 0x0     # a0 = 0x17
    jr zero
