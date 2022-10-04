# Expect: 0x1

# Test: Ensures rt = 1 when $signed(rs) < $signed(imm); imm is assumed to be sign extended.

.text
.global main
main: 
    addi t1, t1, -0x1
    slti a0, t1, 0x000F
    jr zero
