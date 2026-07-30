RAM_BASE       equ      $000000            ; RAM start
RAM_END        equ      $07FFFF            ; RAM end
ROM_BASE       equ      $200000            ; ROM start
ROM_END        equ      $27FFFF            ; ROM end
EX_ROM1_BASE    equ     $100000            ; Expansion ROM 1 start
EX_ROM1_END     equ     $17FFFF            ; Expansion ROM 1 end
EX_ROM2_BASE    equ     $180000            ; Expansion ROM 2 start
EX_ROM2_END     equ     $1FFFFF            ; Expansion ROM 2 end
;
IO_BASE        equ      $3C0000              ; I/O Base address
IO1_BASE       equ      IO_BASE              ; First Motorola I/O Card
IO2_BASE       equ      IO_BASE+$20          ; Second Motorol I/O Card
;
; DEFINITIONS FOR FIRST MOTOROLA I/O CARD
;
;
; Motorola 6850 ACIA
;
ACIA1          equ      IO1_BASE+$08 ; Location of ACIA
ACIA1_STATUS   equ      ACIA1        ; Status
ACIA1_CONTROL  equ      ACIA1        ; Control
ACIA1_DATA     equ      ACIA1+1      ; Data
;
; Motorola 6840 PTM (Programmable Timer Module)
;
PTM1            equ     IO1_BASE
PTM1_CR13       equ     PTM1         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM1_SR         equ     PTM1+1
PTM1_CR2        equ     PTM1+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM1_T1MSB      equ     PTM1+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM1_T1LSB      equ     PTM1+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM1_T2MSB      equ     PTM1+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM1_T2LSB      equ     PTM1+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM1_T3MSB      equ     PTM1+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM1_T3LSB      equ     PTM1+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PIA1BASE        equ     IO1_BASE+$10    ; PIA Base address (ELENC updated for MECB)
PIA1REGA        equ     PIA1BASE       ; data reg A
PIA1DDRA        equ     PIA1BASE       ; data dir reg A
PIA1CTLA        equ     PIA1BASE+1     ; control reg A
PIA1REGB        equ     PIA1BASE+2     ; data reg B
PIA1DDRB        equ     PIA1BASE+2     ; data dir reg B
PIA1CTLB        equ     PIA1BASE+3     ; control reg B
;
; DEFINITIONS FOR SECOND MOTOROLA I/O CARD
;
; Motorola 6850 ACIA
;
ACIA2          equ      IO2_BASE+$08 ; Location of ACIA
ACIA2_STATUS   equ      ACIA2        ; Status
ACIA2_CONTROL  equ      ACIA2        ; Control
ACIA2_DATA     equ      ACIA2+1      ; Data
;
PTM2            equ     IO2_BASE
PTM2_CR13       equ     PTM2         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM2_SR         equ     PTM2+1
PTM2_CR2        equ     PTM2+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM2_T1MSB      equ     PTM2+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM2_T1LSB      equ     PTM2+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM2_T2MSB      equ     PTM2+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM2_T2LSB      equ     PTM2+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM2_T3MSB      equ     PTM2+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM2_T3LSB      equ     PTM2+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PIA2BASE        equ     IO2_BASE+$10    ; PIA Base address (ELENC updated for MECB)
PIA2REGA        equ     PIA2BASE        ; data reg A
PIA2DDRA        equ     PIA2BASE        ; data dir reg A
PIA2CTLA        equ     PIA2BASE+1      ; control reg A
PIA2REGB        equ     PIA2BASE+2      ; data reg B
PIA2DDRB        equ     PIA2BASE+2      ; data dir reg B
PIA2CTLB        equ     PIA2BASE+3      ; control reg B
;
; I/O mapping for VDP
;
VDP            equ      IO_BASE+$80     ; TMS9918A Video Display Processor
VDP_VRAM       equ      VDP+0           ; used for VRAM reads/writes
VDP_REG        equ      VDP+1           ; control registers/address latch
;
; I/O mapping for OLED
;
OLED           equ      IO_BASE+$88     ; OLED Panel base address
OLED_CMD       equ      OLED            ; OLED Command address
OLED_DTA       equ      OLED+1          ; OLED Data address
