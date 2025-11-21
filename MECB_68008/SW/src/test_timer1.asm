               include  'mecb.inc'
               include  'tutor.inc'
;
CR              EQU     $0D         ; Carriage return
LF              EQU     $0A         ; Linefeed

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
         move.w   d0,PTM1_T1MSB
         move.b   #TIMER_SETH,d0    ; Preset all timers : CRX6=1 (interrupt); CRX1=1 (enable clock)
         move.b   d0,PTM1_CR2        ; Write to CR2
         move.b   #TIMER_SETL,d0
         move.b   d0,PTM1_CR13 
         move.l   #0,d0
         move.b   d0,PTM1_CR2 

         move.l   d0,tick        ; Reset the tick counter

         move.b   PTM1_SR,d0      ; Read the interrupt flag from the status register
         move.b   #$40,d0
         move.b   d0,PTM1_CR13    ; enable interrupt and start timer
         rts 
;
timer_isr:
         move.l   d1,temp
         move.b   PTM1_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM1_T1MSB,d1   ; clear timer interrupt flag
         move.b   PTM1_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM1_T2MSB,d1
         move.b   PTM1_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM1_T3MSB,d1

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