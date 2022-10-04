# Expect: 0x0

# Test: Ensures rd = 0 when rt < rs; rt and rs are loaded from memory and must be signed.

.text
.globl main
main:
    lw t0, rt
    lw t1, rs
    slt a0, t1, t0
    jr zero
    
.data
rt: .word 0xFEEE8888
rs: .word 0x7694AFEE
