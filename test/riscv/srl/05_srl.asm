# Expect: 0x6A3D

.text
.globl main
main:
    li		a0,  0xD47A11F1
    li		t0,  0x00011111
    srl     a0, a0, t0
    jr      zero	
