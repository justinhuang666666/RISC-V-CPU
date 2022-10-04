# Expect: 0x6
# Test forwarding result in WB stage for R-type 

.text
.globl main
main:
    addi t0, x0, 0x6     # t0 = 0x6
    addi t1, t2, 0x88    # t0 = 0x6
    add  a0, x0, t0      # a0 = 0x6
    jr zero
