# Expect: 0x8AD

.text
.globl main
main:
    li		a0,  0x115AFC10
    li		t0,  17826065
    sra     a0, a0, t0
    jr      zero	
