# Expect: 0xFFE

.text
.globl main
main:
    addi t0, t0, 0x7FF  # t0 = 0x7FFF
    addi a0, t0, 0x7FF  # t0 = 0xFFFE
    jr zero
