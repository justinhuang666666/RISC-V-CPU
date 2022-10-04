# Expect: 0xD
# Test precedence of mem over wb forwarding for R-type

.text
.globl main
main:
    addi t0, x0, 0x6     # t0 = 0x6 
    add  t0, t0, t0      # t0 = 0xC
    addi t0, t0, 0x1     # t0 = 0xD
    add  a0, x0, t0      # a0 = 0xD
    jr zero
