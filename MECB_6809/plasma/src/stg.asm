PIA         EQU     0xE010      ; MC6821 PIA base address
PIA_PRTB    EQU     PIA+2       ; MC6821 PIA Port B & DDR B address
PIA_CTLB    EQU     PIA+3       ; MC6821 PIA Control Register B address 


stg_init
; Setup PIA Port B for Sound ouput
            PSHS    A
            LDA     #$22        ; Select DDR Register B
            STA     PIA_CTLB    ; CB2 goes low following data write, returned high by IRQB1 set by low to high transition on CB1
            LDA     #$FF        ; Set Port B as all outputs
            STA     PIA_PRTB    ; DDR B register write
            LDA     #$26        ; Select Port B Data Register (rest as above) 
            STA     PIA_CTLB
;
            BSR     stg_stop	; Silence the SN76489
            PULS    A
            RTS
;
; Function:     Silence all SN76489 Sound Channels
; Parameters:   -
; Returns:      -
; Destroys:     A
stg_stop	
            LDA     #$0F        ; Turn Off Channel 0
            BSR     stg_atten0
            LDA     #$0F        ; Turn Off Channel 1
            BSR     stg_atten1
            LDA     #$0F        ; Turn Off Channel 2
            BSR     stg_atten2
            LDA     #$0F        ; Turn Off Noise Channel
            BSR     stg_atten3
            RTS
;
; Function:     Set sound channel attenuation for channel 0
; Parameters:   A - attenuation level (0-15)
; Returns:      -
; Destroys:     A
stg_atten0  ANDA    #$0F            ; Attenuation forms the 4 LSB bits
            ORA     #$90            ; A= 1 0 0 1 A0 A1 A2 A3
            BRA     stg_write
;
; Function:     Set sound channel attenuation for channel 1
; Parameters:   A - attenuation level (0-15)
; Returns:      -
; Destroys:     A
stg_atten1  ANDA    #$0F            ; Attenuation forms the 4 LSB bits
            ORA     #$B0            ; A= 1 0 1 1 A0 A1 A2 A3
            BRA     stg_write
;
; Function:     Set sound channel attenuation for channel 2
; Parameters:   A - attenuation level (0-15)
; Returns:      -
; Destroys:     A
stg_atten2  ANDA    #$0F            ; Attenuation forms the 4 LSB bits
            ORA     #$D0            ; A= 1 1 0 1 A0 A1 A2 A3
            BRA     stg_write
;
; Function:     Set sound channel attenuation for channel 3
; Parameters:   A - attenuation level (0-15)
; Returns:      -
; Destroys:     A
stg_atten3  ANDA    #$0F            ; Attenuation forms the 4 LSB bits
            ORA     #$F0            ; A= 1 1 1 1 A0 A1 A2 A3
            BRA     stg_write
;
; Function:     Write Sound Byte (A) to SN76489 and wait for not busy
; Parameters:   A - Sound Byte to write
; Returns:      -
; Destroys:     A

stg_write   STA     PIA_PRTB
busyCheck   LDA     PIA_CTLB        ; Read control Register
            BPL     busyCheck       ; Wait for CB1 transition (IRQB1 flag)	
            LDA     PIA_PRTB        ; Reset the IRQ flag by reading the data register
            RTS
;
; Function:     Set sound channel frequency 0
; Parameters:   X - frequency (0-1023)
; Returns:      -
; Destroys:     A, B
stg_freq0   TFR     X,D             ; A = 0  0  0  0  0  0 f0 f1 , B = f2 f3 f4 f5 f6 f7 f8 f9
            ANDB    #$0F            ; B = 0  0  0  0 f6 f7 f8 f9
            ORB     #$80            ; B = 1  0  0  0 f6 f7 f8 f9
            EXG     a,b
            BSR     stg_write
            TFR     X,D
            lsra
            rorb                    ; A = 0  0  0  0  0  0  0  f0 , B = f1 f2 f3 f4 f5 f6 f7 f8
            lsra
            rorb                    ; B = f0 f1 f2 f3 f4 f5 f6 f7
            LSRB                    ; B = 0  f0 f1 f2 f3 f4 f5 f6
            LSRB                    ; B = 0  0  f0 f1 f2 f3 f4 f5
            EXG     A,B             ; A = 0  0  f0 f1 f2 f3 f4 f5
            ANDA    #$3F
            BRA     stg_write       ; Write to STG

;
; Function:     Set sound channel frequency 1
; Parameters:   X - frequency (0-1023)
; Returns:      -
; Destroys:     A, B
stg_freq1   TFR     X,D             ; A = 0  0  0  0  0  0 f0 f1 , B = f2 f3 f4 f5 f6 f7 f8 f9
            ANDB    #$0F            ; B = 0  0  0  0 f6 f7 f8 f9
            ORB     #$A0            ; B = 1  0  1  0 f6 f7 f8 f9
            EXG     a,b
            BSR     stg_write
            TFR     X,D
            lsra
            rorb                    ; A = 0  0  0  0  0  0  0  f0 , B = f1 f2 f3 f4 f5 f6 f7 f8
            lsra
            rorb                    ; B = f0 f1 f2 f3 f4 f5 f6 f7
            LSRB                    ; B = 0  f0 f1 f2 f3 f4 f5 f6
            LSRB                    ; B = 0  0  f0 f1 f2 f3 f4 f5
            EXG     A,B             ; A = 0  0  f0 f1 f2 f3 f4 f5
            ANDA    #$3F
            BRA     stg_write       ; Write to STG

;
; Function:     Set sound channel frequency 2
; Parameters:   X - frequency (0-1023)
; Returns:      -
; Destroys:     A, B
stg_freq2   TFR     X,D             ; A = 0  0  0  0  0  0 f0 f1 , B = f2 f3 f4 f5 f6 f7 f8 f9
            ANDB    #$0F            ; B = 0  0  0  0 f6 f7 f8 f9
            ORB     #$C0            ; B = 1  1  0  0 f6 f7 f8 f9
            EXG     a,b
            LBSR     stg_write
            TFR     X,D
            lsra
            rorb                    ; A = 0  0  0  0  0  0  0  f0 , B = f1 f2 f3 f4 f5 f6 f7 f8
            lsra
            rorb                    ; B = f0 f1 f2 f3 f4 f5 f6 f7
            LSRB                    ; B = 0  f0 f1 f2 f3 f4 f5 f6
            LSRB                    ; B = 0  0  f0 f1 f2 f3 f4 f5
            EXG     A,B             ; A = 0  0  f0 f1 f2 f3 f4 f5
            ANDA    #$3F
            LBRA    stg_write       ; Write to STG
