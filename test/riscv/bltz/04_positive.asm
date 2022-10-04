# Expect: 0x123

.text
.globl main
main: 
    addi t1, zero, 1
    bltz t1, incorrect
    addi a0, a0, 0x123
    jr zero

incorrect:
    jr zero
