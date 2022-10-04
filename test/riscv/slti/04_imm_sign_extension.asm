# Expect: 0x0

# Test: Ensures immediate is sign extended; rd = 0 only if immediate is sign extended.

.text
.globl main
main:
    lw t0, var
    slti a0, t0, -0x1
    jr zero

.data
var: .word 0x00000FFF
