# Expect: 0x0

# Test: Ensures rt = 0 when $signed(rs) > $signed(imm); imm is assumed to be sign extended.

.text
.globl main
main: 
    addi t1, t1, 0x659
    slti a0, t1, -0x1
    jr zero
