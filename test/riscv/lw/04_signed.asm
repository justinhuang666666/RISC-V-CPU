# Expect: 0xF8414243

.text
.globl main
main:
    lw a0, var1
    jr zero
.data
    var1: .word 0xF8414243
