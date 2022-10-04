# Expect: 0x358B

.text
.globl main
main:
    li		a0,  0x1AC5D3C7
    li		t0,  15
    sra     a0, a0, t0
    jr      zero	
