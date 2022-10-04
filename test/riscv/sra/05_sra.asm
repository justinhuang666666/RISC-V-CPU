# Expect: 0x61856AFC

.text
.globl main
main:
    li		a0,  0x61856AFC
    li		t0,  0x0
    sra     a0, a0, t0
    jr      zero	
