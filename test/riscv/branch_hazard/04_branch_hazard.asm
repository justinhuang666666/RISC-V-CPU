# Expect: 0xC

.text
.globl main
main:
    addi t0, t0, 0x1     # t0 = 0x1 
    addi t1, x0, 0xC     # t1 = 0xC
    beq  t1, t0, L2      # No branch until t1 = t0
    j main
L2:                   
    addi a0, t0, 0x0     # a0 = 0xC
    jr zero
