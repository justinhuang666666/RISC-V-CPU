# Expect: 0x0

# Test: Ensures rd = 0 when rs > rt. Only works if rs and rt are signed.

.text
.globl main
main:
    li t0, 0x5000
    li t1, 0xFFFF8DFF
    slt a0, t0, t1
    jr zero
