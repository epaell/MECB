                include 'mecb.inc'
                include 'tutor.inc'
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
start    move.l   #isr0,a6
         move.l   a6,VEC_IRQ0
         move.l   #isr1,a6
         move.l   a6,VEC_IRQ1
         move.l   #isr2,a6
         move.l   a6,VEC_IRQ2
         move.l   #isr3,a6
         move.l   a6,VEC_IRQ3
         move.l   #isr4,a6
         move.l   a6,VEC_IRQ4
         move.l   #isr5,a6
         move.l   a6,VEC_IRQ5
         move.l   #isr6,a6
         move.l   a6,VEC_IRQ6
         move.l   #isr7,a6
         move.l   a6,VEC_IRQ7
         move.b   #$FF,irq_num
;
; Init Timer and enable interrupt
;
         bsr      ptm_init          ; initialize the timer and enable interrupts
;
;
         and.w    #$F8FF,sr         ; enable interrupts
;         
loop    ; or.w     #$0700,sr         ; enable interrupts
         move.l   tick,d0           ; Add the tick value
         move.l   #buffer,a6
         move.b   #'$',(a6)+
         move.b   #PNT8HX,d7
         trap     #14
         move.b   #$20,(a6)+

         move.b   irq_num,d0        ; Add the last IRQ number that was serviced
         move.b   #'$',(a6)+
         move.b   #PNT2HX,d7
         trap     #14

         move.b   #$0d,(a6)+        ; Add new line
         move.b   #$0a,(a6)+
;
         move.b   #OUTPUT,d7        ; Output buffer
         move.l   #buffer,a5
         trap     #14
;
         move.l   #$10000,d7        ; wait to see if anything happens
delay    sub.l    #1,d7
         bne      delay
         bra      loop
;
         move.b   #TUTOR,d7
         trap     #14
;
;
ptm_init:
         move.l   #OUT1CR,d7        ; Write message to indicate PTM is being initialised
         move.l   #MISR_START,a5
         move.l   #MISR_END,a6
         trap     #14
         
         move.w   #TIMER_VAL,d0
         move.w   d0,PTM1_T1MSB
         move.b   #TIMER_SETH,d0    ; Preset all timers : CRX6=1 (interrupt); CRX1=1 (enable clock)
         move.b   d0,PTM1_CR2        ; Write to CR2
         move.b   #TIMER_SETL,d0
         move.b   d0,PTM1_CR13 
         move.l   #0,d0
         move.b   d0,PTM1_CR2 

         move.l   d0,tick           ; Reset the tick counter

         move.b   PTM1_SR,d0         ; Read the interrupt flag from the status register
         move.b   #$40,d0
         move.b   d0,PTM1_CR13       ; enable interrupt and start timer
         rts 
;
isr0:    move.b   #0,irq_num
         bra      timer_isr
isr1:    move.b   #1,irq_num
         bra      timer_isr
isr2:    move.b   #2,irq_num
         bra      timer_isr
isr3:    move.b   #3,irq_num
         bra      timer_isr
isr4:    move.b   #4,irq_num
         bra      timer_isr
isr5:    move.b   #5,irq_num
         bra      timer_isr
isr6:    move.b   #6,irq_num
         bra      timer_isr
isr7:    move.b   #7,irq_num
         bra      timer_isr

timer_isr:
         move.l   d1,temp        ; save d1
         move.b   PTM1_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM1_T1MSB,d1   ; clear timer interrupt flag
         move.b   PTM1_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM1_T2MSB,d1
         move.b   PTM1_SR,d1      ; Read the interrupt flag from the status register
         move.w   PTM1_T3MSB,d1

         add.l    #1,tick        ; increment the tick counter
         move.l   temp,d1       ; restore d1
         rte
;
buffer   ds.b     64
;
temp     ds.l     1
tick     ds.l     1
;
irq_num  ds.b     1

;
MISR_START dc.b   "Initializing ISR."
MISR_END
