# Expect: 0x0

# Test: Ensures rd = 0 when rt = rs. Only works if rs and rt are signed.

.text
.globl main
main:
    li t0, 0x8000
    li t1, 0x8000
    slt a0, t0, t1
    jr zero
