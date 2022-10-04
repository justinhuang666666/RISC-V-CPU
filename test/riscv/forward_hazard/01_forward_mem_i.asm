# Expect: 0x8
# Test forwarding alu_out in MEM stage for I-type 

.text
.globl main
main:
    addi t0, x0, 0x6     # t0 = 0x6
    addi a0, t0, 0x2     # a0 = 0x8
    jr zero
