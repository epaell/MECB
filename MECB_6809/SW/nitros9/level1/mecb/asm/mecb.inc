;************ Memory ************
CPU_CLK         equ     3           ; CPU clock in MHz (1, 2, 3 or 4)

vdp_wait        macro
                ifgt      CPU_CLK-3
                nop
                endif
                ifgt      CPU_CLK-2
                nop
                endif
                ifgt      CPU_CLK-1
                nop
                endif
                endm

