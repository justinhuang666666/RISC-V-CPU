# Expect: 0x48BA

.text
.globl main
main:
    li		a0,  0x9175FAC1
    li		t0,  0x00011111
    srl     a0, a0, t0
    jr      zero	
