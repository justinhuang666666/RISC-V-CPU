# Expect: 0xFFFF0304
# Tags: DESTROY_BYTE_ENABLE_TEST

# Experimental test which defines DESTROY_BYTE_ENABLE_TEST to cause
# memory to be set to 0xFF after a read if the byte-enable flag
# for that byte is set.

.text
.globl main
main:
    la t0, var2

    addi t0, t0, 1
    lh t1, -3(t0)

    lw a0, var1
    jr zero

.data
    var1: .word 0x01020304
    var2: .word 0x01020304
