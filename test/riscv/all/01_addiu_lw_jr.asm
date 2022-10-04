# Expect: 0x41424344

.text
.globl main
main:
    la   t5, var1
    lw   t0, 0(t5)           # t0   = 0x20A121A4
    addi t0, t0, -1          # t0   = 0x20A121A3
    addi t1, t0, -1          # t1   = 0x20A121A2
    sw   t1, 0(t5)           # var1 = 0x20A121A2
    la   t6, var2
    lw   t2, 0(t6)           # t2   = 0xFFFFFFFF
    lw   t3, 0(t5)           # t3   = 0x20A121A2
    add  t3, t3, t2          # t3   = 0x20A121A1
    addi t3, t3, 1           # t3   = 0x20A121A2
    add  a0, t3, t3          # t0   = 0x41424344
    jr   zero

.data
var1: .word 0x20A121A4
var2: .word 0xFFFFFFFF
