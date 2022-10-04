# Expect: 0xFFFFFDA0

.text
.globl main
main:
    addi t0, t0, -0x21F
    addi a0, t0, -0x41  
    jr zero
