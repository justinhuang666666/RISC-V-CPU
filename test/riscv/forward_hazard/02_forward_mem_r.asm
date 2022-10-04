# Expect: 0x6
# Test forwarding alu_out in MEM stage for R-type 

.text
.globl main
main:
    addi t0, x0, 0x6     # t0 = 0x6
    add  a0, x0, t0      # a0 = 0x6
    jr zero
