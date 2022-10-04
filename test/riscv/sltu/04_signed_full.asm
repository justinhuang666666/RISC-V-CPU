# Expect: 0x0

.text
.globl main
main:
    la t2, large
    lw t1, 0(t2)

    la t2, small
    lw t0, 0(t2)

    sltu a0, t1, t0
    jr zero

.data
large: .word 0xFFFFFFFF
small: .word 0x0000000F
