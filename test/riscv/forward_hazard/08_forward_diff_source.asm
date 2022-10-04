# Expect: 0x3
# Extensive test 

.text
.globl main
main:
    addi t0, t0, 0x1     # t0 = 0x1 
    addi t1, t0, 0x1     # t1 = 0x2
    add  t2, t0, t1      # t2 = 0x3 
    addi a0, t2, 0x0     # a0 = 0x3
    jr zero
