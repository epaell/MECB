         cpu   8086
;
%include 'src/mecb.asm'
;
;
; ASCII control characters
BS       equ   08h                  ; backspace
CR       equ   0Dh                  ; carraige return
LF       equ   0Ah                  ; form feed
ESC      equ   1Bh                  ; escape
SPACE    equ   20h                  ; space
EOT      equ   00h                  ; End of Text
;
;
TIMER_VAL   equ     0f000h          ; timer 1 count setting
TIMER_SETH  equ     01h             ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
TIMER_SETL  equ     42h             ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)

         org   100h
;
tick:    equ     0xfa00             ; Current tick count
;
section  .text
         global   start

start:
         cli
         mov   ax,cs
         mov   ds,ax                ; Set up data segment
         mov   si, str_start        ; Print string to signal start
         call  puts
;
         mov   ax,cs
         xor   di,di
         mov   es,di                ; Set up the interrupt vector [0000:03FC] to point to the PTM ISR
         mov   di,ptm_isr
         mov   word es:[03FCh],di   ; Update vector for interrupt 0ffh (hardware interrupt)
         mov   word es:[03FEh],ax
         call  ptm_init             ; Initialise the timer
         sti                        ; Allow interrupts
         mov   ax,ds:[tick]         ; get the current tick count
loop:    cmp   ax,ds:[tick]
         je    loop
         mov   ax,ds:[tick]
         call  puthex4              ; Write the current tick value
         call  pcrlf
         jmp   loop                 ; Loop and allow interrupts to occur

;
; Initialise the PTM
;
ptm_init:
         mov   ax,TIMER_VAL
         xchg  ah,al
         out   PTM1_T1MSB,al        ; Write MSB first
         xchg  ah,al
         out   PTM1_T1LSB,al
         
         mov   al,TIMER_SETH        ; Preset all timers : CRX6=1 (interrupt); CRX1=1 (enable clock)
         out   PTM1_CR2,al          ; Write to CR2
         mov   al,TIMER_SETL
         out   PTM1_CR13,al
         xor   ax,ax
         out   PTM1_CR2,al 

         mov   [tick],ax              ; Reset the tick counter
         in    al,PTM1_SR           ; Read the interrupt flag from the status register
         mov   al,40h
         out   PTM1_CR13,al         ; enable interrupt and start timer
         ret 

;
; Interrupt handler for PTM
;
ptm_isr:
         push  ax
         in    al,PTM1_SR           ; Read the interrupt flag from the status register
         in    al,PTM1_T1MSB        ; Clear the timer interrupt flag
         in    al,PTM1_T1LSB        ; Clear the timer interrupt flag
         in    al,PTM1_SR           ; Read the interrupt flag from the status register
         in    al,PTM1_T2MSB        ; Clear the timer interrupt flag
         in    al,PTM1_T2LSB        ; Clear the timer interrupt flag
         in    al,PTM1_SR           ; Read the interrupt flag from the status register
         in    al,PTM1_T3MSB        ; Clear the timer interrupt flag
         in    al,PTM1_T3LSB        ; Clear the timer interrupt flag
         inc   word ds:[tick]
         pop   ax
         iret

%include 'src/acia_io.asm'

;
str_start:
         db       CR,LF,'Testing timer interrupts',CR,LF,CR,LF,EOT

section  .data
data_group:
;
