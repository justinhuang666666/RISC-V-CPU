# Expect: 0xFFFFFFFF

.text
.globl main
main:
    li		a0,  0xA8576AFD
    li		t0,  31
    sra     a0, a0, t0
    jr      zero	
