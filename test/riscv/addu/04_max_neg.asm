# Expect: 0xFFFFFFFF

.text
.globl main
main:
    addi t0, zero, 0xFFFFF800
    sll  t0, t0, 0x14
    li   t1, 0x7FFFFFFF
    add  a0, t0, t1
    jr   zero
