IO_BASE         equ     $3C0000
;
; Motorola 6850 ACIA
;
ACIA            equ     IO_BASE+$08 ; Location of ACIA
ACIA_STATUS     equ     ACIA        ; Status
ACIA_CONTROL    equ     ACIA        ; Control
ACIA_DATA       equ     ACIA+1      ; Data
;
; Motorola 6840 PTM (Programmable Timer Module)
;
PTM             equ     IO_BASE
PTM_CR13        equ     PTM         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM_SR          equ     PTM+1
PTM_CR2         equ     PTM+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM_T1MSB       equ     PTM+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T1LSB       equ     PTM+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T2MSB       equ     PTM+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T2LSB       equ     PTM+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM_T3MSB       equ     PTM+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM_T3LSB       equ     PTM+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PIABASE         equ     IO_BASE+$10     ; PIA Base address (ELENC updated for MECB)
PIAREGA         equ     PIABASE         ; data reg A
PIADDRA         equ     PIABASE         ; data dir reg A
PIACTLA         equ     PIABASE+1       ; control reg A
PIAREGB         equ     PIABASE+2       ; data reg B
PIADDRB         equ     PIABASE+2       ; data dir reg B
PIACTLB         equ     PIABASE+3       ; control reg B
;
CR              EQU     $0D         ; Carriage return
LF              EQU     $0A         ; Linefeed

; Tutor TRAP 14 Functions
PORTIN1N equ      224
GETNUMD  equ      225
GETNUMA  equ      226
OUT1CR   equ      227
TUTOR    equ      228
START    equ      229
PNT8HX   equ      230
PNT6HX   equ      231
PNT4HX   equ      232
PNT2HX   equ      233
PUTHEX   equ      234
GETHEX   equ      235
HEX2DEC  equ      236
PRCRLF   equ      237
TAPEIN   equ      238
TAPEOUT  equ      239
PORTIN20 equ      240
PORTIN1  equ      241
OUTPUT21 equ      242
OUTPUT   equ      243
CHRPRINT equ      244
INCHE    equ      247
OUTCH    equ      248
FIXDCRLF equ      249
FIXDATA  equ      250
FIXBUF   equ      251
FIXDADD  equ      252
LINKIT   equ      253
;
VEC_IRQ0 equ      $18*4
VEC_IRQ1 equ      $19*4
VEC_IRQ2 equ      $1A*4
VEC_IRQ3 equ      $1B*4
VEC_IRQ4 equ      $1C*4
VEC_IRQ5 equ      $1D*4
VEC_IRQ6 equ      $1E*4
VEC_IRQ7 equ      $1F*4
;
         org      $4000
;
TIMER_VAL      equ      $f000      ; timer 1 count setting
TIMER_SETH     equ      $01        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
TIMER_SETL     equ      $42        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)

;
start    move.l   #timer_isr,a0    ; For now, point all vectors to ISR
         move.l   a0,VEC_IRQ0
         move.l   a0,VEC_IRQ1
         move.l   a0,VEC_IRQ2
         move.l   a0,VEC_IRQ3
         move.l   a0,VEC_IRQ4
         move.l   a0,VEC_IRQ5
         move.l   a0,VEC_IRQ6
         move.l   a0,VEC_IRQ7
;
; Init Timer and enable interrupt
;
         bsr      ptm_init         ; initialize the timer and enable interrupts
;
         move.w   #$2000,sr        ; enable interrupts
;
         move.l   #$F00000,d0      ; wait to see if anything happens
loop     sub.l    #1,d0
         bne      loop
;
         move.b   #OUTPUT,d7
         move.l   #MISR_START,a5
         move.l   #MISR_END,a6
         trap     #14
         move.b   #TUTOR,d7
         trap     #14
;
;
ptm_init:
         move.w   #TIMER_VAL,d0
         move.w   d0,PTM_T1MSB
         move.b   #TIMER_SETH,d0    ; Preset all timers : CRX6=1 (interrupt); CRX1=1 (enable clock)
         move.b   d0,PTM_CR2        ; Write to CR2
         move.b   #TIMER_SETL,d0
         move.b   d0,PTM_CR13 
         move.l   #0,d0
         move.b   d0,PTM_CR2 

         move.l   d0,tick        ; Reset the tick counter

         move.b   PTM_SR,d0      ; Read the interrupt flag from the status register
         move.b   #$40,d0
         move.b   d0,PTM_CR13    ; enable interrupt and start timer
         rts 
;
timer_isr:
         move.l   d1,temp
         move.b   PTM_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM_T1MSB,d1   ; clear timer interrupt flag
         move.b   PTM_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM_T2MSB,d1
         move.b   PTM_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM_T3MSB,d1

         move.l   tick,d1        ; increment the tick counter
         add.l    #1,d1
         move.l   d1,tick
         move.l   temp,d1
         rte
;
temp     ds.l      1
;
tick     ds.l      1

;
MISR_START dc.b   "Initializing ISR."
MISR_END
