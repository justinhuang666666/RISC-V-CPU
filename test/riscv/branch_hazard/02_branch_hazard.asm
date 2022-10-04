# Expect: 0x2

.text
.globl main
main:
    add  a0, zero, zero
    addi t0, zero, 0x1   # t0 = 0x1 
    beq  t0, x0, L2      # No branch 
    beq  t0, t0, L3      # Branch 
    addi a0, t0, 0x1     # No exec 
L2: 
    addi t0, t0, 0x3     # t0 = 0x4 No exec 
    add  a0, t0, a0      # a0 = 0x4 No exec
L3: 
    addi t0, t0, 0x1     # t0 = 0x2
    add  a0, t0, a0      # a0 = 0x2 
    jr zero
