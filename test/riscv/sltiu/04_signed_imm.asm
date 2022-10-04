# Expect: 0x1

.text
.globl main
main: 
    lw t0, var1
    sltiu a0, t0, -0x1 # immediate is sign extended, thus larger
    jr zero

.data
var1: .word 0x0001FFFF


