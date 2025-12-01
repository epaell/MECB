;
; Initialize PIA1 for use with PSG
;
psg_init       move.b   #$22,PIA1CTLB     ; Setup PIA Port B for Sound ouput, select DDR Register B
                                          ; CB2 goes low following data write, returned high by IRQB1 set by low to high transition on CB1
               move.b   #$ff,PIA1DDRB     ; Set Port B as all outputs, DDR B register write
               move.b   #$26,PIA1CTLB     ; Select Port B Data Register (rest as above) 
               bsr      psg_stop
               rts
;
;
; Function:	Silence all SN76489 Sound Channels
; Parameters:	-
; Returns:	-
; Destroys:	A
psg_stop       movem.l  d0-d1,-(a7) ; Save registers
               move.b   #$00,d0     ; Turn off channel 0
               move.b   #$00,d1
               bsr      psg_volume
               add.b    #1,d0       ; Turn off channel 1
               bsr      psg_volume
               add.b    #1,d0       ; Turn off channel 2
               bsr      psg_volume
               add.b    #1,d0       ; Turn off channel 3
               bsr      psg_volume
               movem.l  (a7)+,d0-d1 ; Restore registers
               rts
;
; Function : Set channel volume for PSG
; Parameters:  d0 - channel (0-3, 3=noise)
;              d1 - level (0-15, 0=off)
psg_volume     movem.l  d0/d1,-(a7)    ; save registers
               lsl.b    #5,d0          ; move channel number to bits 5 and 6
               and.b    #$60,d0
               and.b    #$0f,d1
               eor.b    #$9f,d1        ; set bits for attenuator control
               add.b    d1,d0          ; add the attenuation level
               bsr      psg_write      ; write to the PSG
               movem.l  (a7)+,d0/d1    ; restore registers
               rts                     ; return
;
; Function : Set channel tone for PSG
; Parameters:  d0 - channel (0-2)
;              d1 - tone (0-1023)
psg_tone       movem.l  d0/d2,-(a7)    ; save registers
               lsl.b    #5,d0          ; move channel number to bits 5 and 6
               or.b     #$80,d0        ; set bits for frequency control
               move.w   d1,d2
               and.b    #$0F,d2        ; Mask off lowest four bits
               add.b    d2,d0          ; Add to the control byte
               bsr      psg_write      ; write to the PSG
               move.w   d1,d0
               lsr.w    #4,d0          ; Move most significant six bits 
               and.b    #$3f,d0        ; get the frequency LSB
               bsr      psg_write      ; write to the PSG
               movem.l  (a7)+,d0/d2    ; restore registers
               rts                     ; return
;
; Function:	Write Sound Byte (d0) to SN76489 and wait for not busy
; Parameters:  d0 - Sound Byte to write
; Returns:     -
; Destroys:    -
psg_write      move.b   d0,PIA1REGB
psg_write1     btst.b   #7,PIA1CTLB    ; Read control Register
               beq      psg_write1     ; Wait for CB1 transition (IRQB1 flag)
               tst.b    PIA1REGB       ; Reset the IRQ flag by reading the data register
               rts
