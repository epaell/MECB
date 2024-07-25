;************ Memory ************
RAMSTART        equ     0x0000
RAMEND          equ     0xDFFF

USERPROG_ORG    equ     0x0100      ; entry point for user programs

CPU_CLK         equ     3           ; CPU clock in MHz (1, 2 or 3)

vdp_wait        MACRO
                IF      CPU_CLK>2
                nop
                ENDIF
                IF      CPU_CLK>1
                nop
                ENDIF
                ENDM

