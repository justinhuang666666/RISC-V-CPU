# Expect: 0x0

.text
.globl main
main: 
    addi t1, zero, 2
    addi t2, zero, 3
    slt a0, t2, t1
    jr zero
