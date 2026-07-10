; 6840 PTR Interrupt demo for Assis09 rom
; demo to generate cyclic interrupt from 6840 and bump a counter in memory
; after initialisation a separate function display the memory content value increasing
               INCLUDE  "mecb.inc"
               INCLUDE  "ASSISTMacros.inc"
;
timer_val      equ      $9c3f       ; timer 1 count setting (50 Hz)
timer_set      equ      $0142       ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)

               org      USERPROG_ORG  
;
               leax     isr,pcr     ; Load new IRQ handler address
               vctrsw   _IRQ

               jsr      ptm_init    ; Initialise the PTM
               andcc    #$ef        ; Enable interrupts

loop           lda      tick1       ; get the LSW of the tick count
               cmpa     otick1
               beq      loop        ; wait until second count changes
               sta      otick1      ; update mS value
;
               lda      #CR
               jsr      outc
               lda      #LF
               jsr      outc
               lda      #'$'
               jsr      outc
               lda      tick3
               ldb      tick2
               jsr      out4h
               lda      tick1
               jsr      out2h
               bra      loop
;
ptm_init       ldd      #timer_set  ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
               sta      PTM_CR2     ; Write to CR1
               stb      PTM_CR13 
               ldd      #timer_val
               std      PTM_T1MSB
;
               clr      tick0       ; Reset the tick counter
               clr      tick1
               clr      tick2
               clr      tick3
               clr      otick1
;
               rts 
                
isr            lda      PTM_SR      ; Read the interrupt flag from the status register
               anda     #$81        ; Check if interrupt was from timer
               cmpa     #$81
               bne      isrret
               ldd      PTM_T1MSB   ; clear timer interrupt flag
;
               inc      tick0
               lda      tick0
               cmpa     #50         ; count 50 20 mS clicks for a second
               beq      isrsec      ; if a second reached - handle it
               bra      isrret      ; return
;
isrsec         clr      tick0       ; reset the mS counter
               lda      tick1       ; increment the second counter
               adda     #$01
               sta      tick1
               lda      tick2
               adca     #$00
               sta      tick2
               lda      tick3
               adca     #$00
               sta      tick3
isrret         rti

; output as hex digits contents of D register
out4h          pshs     d
               bsr      out2h
               exg      b,a
               bsr      out2h
               puls     pc,d

out2h          pshs     a
               asra
               asra
               asra
               asra
               bsr      outnyb
               puls     a

outnyb         anda     #$0F
               cmpa     #$0A
               bcs      outnyb2
               adda     #$07
outnyb2        adda     #$30
;
outc           pshs     cc                ; preserve irq mask which is set by assist09
               outch
               puls     cc
               rts
;
timer1         rmb      2
timer2         rmb      2
timer3         rmb      2
;
otick1         rmb      1
tick0          rmb      1
tick1          rmb      1
tick2          rmb      1
tick3          rmb      1

