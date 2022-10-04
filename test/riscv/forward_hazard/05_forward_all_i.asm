# Expect: 0x9
# Test precedence of mem over wb forwarding for I-type 

.text
.globl main
main:
    addi t0, x0, 0x6     # t0 = 0x6 
    addi t0, t0, 0x1     # t0 = 0x7 
    addi t0, t0, 0x2     # t0 = 0x9 
    addi a0, t0, 0x0     # a0 = 0x9
    jr zero
