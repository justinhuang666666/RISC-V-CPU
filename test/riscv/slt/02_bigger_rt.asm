# Expect: 0x1

# Test: Ensures rd = 1 when rs < rt. Only works if rs and rt are signed.

.text
.globl main
main:
    li t0, 0xFFFFD69D
    li t1, 0x0001
    slt a0, t0, t1
    jr zero
