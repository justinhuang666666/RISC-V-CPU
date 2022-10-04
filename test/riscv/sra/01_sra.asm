# Expect: 0xFFFECABD

.text
.globl main
main:
    li		a0,  0xD957AC1F
    li		t0,  13
    sra     a0, a0, t0
    jr      zero	
