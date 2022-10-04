# Expect: 0x7FF

.text
.globl main
main:
    addi t2, t2, 0x7FF
    addi t1, t1, 0x7FF 
    and a0, t1, t2
    jr zero
