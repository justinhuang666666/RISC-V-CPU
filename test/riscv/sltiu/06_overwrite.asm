# Expect: 0x1

.text
.globl main
main: 
    lw t1, overwrite
    add a0, a0, t1
    sltiu a0, t0, -0x1
    jr zero

.data
overwrite: .word 0x6FA1F25F


