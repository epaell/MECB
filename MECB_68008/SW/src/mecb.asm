RAM_BASE       equ      $000000            ; RAM start
RAM_END        equ      $07FFFF            ; RAM end
ROM_BASE       equ      $200000            ; ROM start
ROM_END        equ      $27FFFF            ; ROM end
EX_ROM_BASE    equ      $100000            ; Expansion ROM start
EX_ROM_END     equ      $1FFFFF            ; Expansion ROM end
;
IO_BASE        equ      $3C0000
;
; Motorola 6850 ACIA
;
ACIA           equ      IO_BASE+$08 ; Location of ACIA
ACIA_STATUS    equ      ACIA        ; Status
ACIA_CONTROL   equ      ACIA        ; Control
ACIA_DATA      equ      ACIA+1      ; Data
;
; Motorola 6840 PTM (Programmable Timer Module)
;
PTM            equ      IO_BASE
PTM_CR13       equ      PTM         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM_SR         equ      PTM+1
PTM_CR2        equ      PTM+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM_T1MSB      equ      PTM+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T1LSB      equ      PTM+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T2MSB      equ      PTM+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T2LSB      equ      PTM+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T3MSB      equ      PTM+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T3LSB      equ      PTM+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PIABASE        equ      IO_BASE+$10     ; PIA Base address (ELENC updated for MECB)
PIAREGA        equ      PIABASE         ; data reg A
PIADDRA        equ      PIABASE         ; data dir reg A
PIACTLA        equ      PIABASE+1       ; control reg A
PIAREGB        equ      PIABASE+2       ; data reg B
PIADDRB        equ      PIABASE+2       ; data dir reg B
PIACTLB        equ      PIABASE+3       ; control reg B
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
