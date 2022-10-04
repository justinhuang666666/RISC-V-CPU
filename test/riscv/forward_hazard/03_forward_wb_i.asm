# Expect: 0x8
# Test forwarding result in WB stage for I-type 

.text
.globl main
main:
    addi t0, x0, 0x6     # t0 = 0x6
    addi t1, t2, 0x88    # t0 = 0x6
    addi a0, t0, 0x2     # a0 = 0x8
    jr zero
