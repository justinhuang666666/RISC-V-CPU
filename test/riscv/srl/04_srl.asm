# Expect: 0x560A

.text
.globl main
main:
    li		a0,  0xAC146BCF
    li		t0,  0x00111111
    srl     a0, a0, t0
    jr      zero	
