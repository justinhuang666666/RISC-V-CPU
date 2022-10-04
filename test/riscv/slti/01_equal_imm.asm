# Expect: 0x0

# Test: Ensures rd = 0 when rs = imm; imm is assumed to be sign extended.

.text
.globl main
main:
    addi t1, t1, -0x1
    slti a0, t1, -0x1
    jr zero
