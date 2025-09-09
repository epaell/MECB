;************ Memory ************
RAMSTART        equ     0x0000
RAMEND          equ     0xEEFF
;
USERPROG_ORG    equ     0x0100      ; entry point for user programs
;
CPU_CLK         equ     4           ; CPU clock in MHz (1, 2 or 3)
;
vdp_wait        MACRO
                IF      CPU_CLK>3
                nop
                nop
                nop
                nop
                ENDIF
                IF      CPU_CLK>2
                nop
                nop
                ENDIF
                IF      CPU_CLK>1
                nop
                ENDIF
                ENDM
;
IO_BASE         equ     0xEF00
;
; Motorola 6850 ACIA
;
ACIA            EQU     IO_BASE+$08 ; Location of ACIA
ACIA_STATUS     EQU     ACIA        ; Status
ACIA_CONTROL    EQU     ACIA        ; Control
ACIA_DATA       EQU     ACIA+1      ; Data
;
; Motorola 6840 PTM (Programmable Timer Module)
;
PTM             EQU     IO_BASE
PTM_CR13        EQU     PTM         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM_SR          EQU     PTM+1
PTM_CR2         EQU     PTM+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM_T1MSB       EQU     PTM+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T1LSB       EQU     PTM+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T2MSB       EQU     PTM+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T2LSB       EQU     PTM+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T3MSB       EQU     PTM+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T3LSB       EQU     PTM+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PIABASE         equ     IO_BASE+$10     ; PIA Base address (ELENC updated for MECB)
PIAREGA         equ     PIABASE         ; data reg A
PIADDRA         equ     PIABASE         ; data dir reg A
PIACTLA         equ     PIABASE+1       ; control reg A
PIAREGB         equ     PIABASE+2       ; data reg B
PIADDRB         equ     PIABASE+2       ; data dir reg B
PIACTLB         equ     PIABASE+3       ; control reg B
;
; I/O mapping for VDP
;
VDP             equ     IO_BASE+$80     ; TMS9918A Video Display Processor
VDP_VRAM        equ     VDP+0           ; used for VRAM reads/writes
VDP_REG         equ     VDP+1           ; control registers/address latch
;
; I/O mapping for OLED
;
OLED            equ     IO_BASE+$88     ; OLED Panel base address
OLED_CMD        equ     OLED            ; OLED Command address
OLED_DTA        equ     OLED+1          ; OLED Data address
;
CR              EQU     $0D         ; Carriage return
LF              EQU     $0A         ; Linefeed
EOT             EQU     $04         ; End of text