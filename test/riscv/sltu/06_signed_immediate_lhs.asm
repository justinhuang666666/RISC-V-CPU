# Expect: 0x0

.text
.globl main
main: 
    addi t1, t1, 0x000A        # 10 u, 10 s
    addi t0, t0, 0xFFFFFFFF    # 4294967295 u, -1 s
    sltu a0, t0, t1            # will break if signed compare is used
    jr zero


