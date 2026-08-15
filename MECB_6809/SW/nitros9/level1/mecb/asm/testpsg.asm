********************************************************************
* Testvdp - Write date to VDP screen
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/08/29  epaell

               nam     Testpsg
               ttl     Play sounds on PSG

               ifp1
*         use   /dd/defs/defsfile
               use     ../defsfile
               endc

tylg           set     Prgrm+Objct   
atrv           set     ReEnt+rev
rev            set     $00
edition        set     1

               mod     eom,name,tylg,atrv,start,size

               org     0
Offset         rmb     2
DecayCount     rmb     1               ; This location holds Frame Count until next Note plays.
SoundBytePtr   rmb     2               ; 16 bit pointer into the SoundByteTable melody data.
PSGVolume1     rmb     1
PSGVolume2     rmb     1
PSGVolume3     rmb     1
parmptr        rmb     2
buffer         rmb     40
               rmb     400
size           equ     .

name           fcs     /Testpsg/
               fcb     edition

; Include the sound definitions
               use     FrequencyTable.asm
               use     SoundByteTable.asm

; Message to notify user that graphics device is being started up
text1          fcc     "Initialising programmable sound generator"
               fcb     C$CR,C$LF
text1len       equ     *-text1
;
; I/O mapping for PSG
PIA            equ     $EF30           ; 6821 Base address
PIA_PRTB       equ     PIA+2           ; MC6821 PIA Port B & DDR B address
PIA_CTLB       equ     PIA+3           ; MC6821 PIA Control Register B address
DELAY          equ     10              ; Determines overall tempo

start          stx     <parmptr        ; save parameter pointer
               lda     #1
               leax    text1,pcr
               ldy     #text1len
               os9     I$WritLn        ; Write a message to indicate VDP is being started
;
; Setup PIA Port B for Sound ouput
               lda     #$22            ; Select DDR Register B
               sta     PIA_CTLB        ; CB2 goes low following data write, returned high by IRQB1 set by low to high transition on CB1
               lda     #$FF            ; Set Port B as all outputs
               sta     PIA_PRTB        ; DDR B register write
               lda     #$26            ; Select Port B Data Register (rest as above) 
               sta     PIA_CTLB
; Initialize DecayCount
               lda     #DELAY          ; Wait a bit before starting the music
               sta     DecayCount,u
; Initialize PSGVolume, PSGNote & SoundBytePtr storage to Zero
               clr     PSGVolume1,u
               clr     PSGVolume2,u
               clr     PSGVolume3,u
               leax    SoundByteTable,pcr
               stx     SoundBytePtr,u  ; Initialise pointer to Sound table
               lbsr	  silenceSound    ; Turn off all channels
;
; Function:	Play SoundByteTable notes for all 3 Tone Generators of the SN76489
; Set attenuators first.
; Format = 1xx1 yyyy; x=channel; yyyy=level (1111=off; 0000=loudest)
mainLoop       lda     PSGVolume1,u    ; Check if the Tone Generator's volume is >0
               beq     NoNotePlayed1   ; If Tone Generator's volume now 0 then note is silenced
               deca                    ; Decrement the Tone Generator's volume to use
               sta     PSGVolume1,u	   ; And save new volume
               eora    #$9F            ; Convert desired volume into SN76489 Attenuation Control Byte 
                                       ; - So this turns 0000xxxx into 1001yyyy, where y = 15-x
                                       ; (and x is the desired volume for tone 1).
               lbsr    writeSoundByte  ; Write the Attenuation Control Byte to the SN76489
NoNotePlayed1  lda     PSGVolume2,u    ; Check if the Tone Generator's volume is >0
               beq     NoNotePlayed2   ; If Tone Generator's volume now 0 then note is silenced
               deca                    ; Decrement the Tone Generator's volume to use
               sta     PSGVolume2,u	   ; And save new volume
               eora    #$BF            ; Convert desired volume into SN76489 Attenuation Control Byte 
                                       ; - So this turns 0000xxxx into 1011yyyy, where y = 15-x
                                       ; (and x is the desired volume for tone 2).
               lbsr    writeSoundByte  ; Write the Attenuation Control Byte to the SN76489
NoNotePlayed2  lda     PSGVolume3,u    ; Check if the Tone Generator's volume is >0
               beq     UpdateTones     ; If Tone Generator's volume now 0 then note is silenced
               deca                    ; Decrement the Tone Generator's volume to use
               sta     PSGVolume3,u	   ; And save new volume
               eora    #$DF            ; Convert desired volume into SN76489 Attenuation Control Byte 
                                       ; - So this turns 0000xxxx into 1101yyyy, where y = 15-x
                                       ; (and x is the desired volume for tone 3).
               lbsr    writeSoundByte  ; Write the Attenuation Control Byte to the SN76489
;
UpdateTones    dec     DecayCount,u    ; Decrement our Decay Count
               lbne    wait            ; If volume still decaying then wait
;
; The following handles the reading of new notes to be played for each of the 3 tone generators
; Tone generator setting is 1rr0llll 00hhhhhh where r is the tone generator; l is the lower part of frequency; and h is higher part.
               lda     #DELAY          ; Reset the decay value for new notes (which determines the overall tempo).
               sta     DecayCount,u
ReadNewNotes   ldy     SoundBytePtr,u
               ldb     ,y+             ; Get the note for Tone Generator 1
               sty     SoundBytePtr,u  ; Save updated pointer
               cmpb    #$FE            ; #$FE marks the end of the SoundBytetable, so we loop back to the start
               lbeq    ReturnToStart
               cmpb    #$FF            ; #$FF marks no note to play (a pause) for this channel
               beq     PlayNoNote1
               lda     #$10            ; Initialise full volume (+1) for Tone generator 1
               sta     PSGVolume1,u
               bsr     NoteToFreqPtr   ; Convert note in b to table pointer in y
               lda     #$80            ; 1xx00000, xx=00
               adda    1,y	            ; set up LSB of tone generator
               lbsr    writeSoundByte  ; Write low byte of desired note frequency (1xx0ffff format for the first byte)
               lda     0,y             ; set up MSB of tone generator
               lbsr    writeSoundByte  ; Write high byte of desired note frequency
PlayNoNote1    ldy     SoundBytePtr,u
               ldb     ,y+
               sty     SoundBytePtr,u
               cmpb    #$FE            ; #$FE marks the end of the SoundBytetable, so we loop back to the start
               beq     ReturnToStart
               cmpb    #$FF            ; #$FF marks no note to play (a pause), so no note gets played this time for this sound channel
               beq     PlayNoNote2
               lda     #$10            ; Initialise full volume (+1) into channel variable for the sound channel's volume
               sta     PSGVolume2,u
               bsr     NoteToFreqPtr   ; Convert note in b to table pointer in y
               lda     #$A0            ; 1xx00000, xx=01
               adda    1,y	            ; set up LSB of tone generator
               lbsr    writeSoundByte  ; Write low byte of desired note frequency (1xx0ffff format for the first byte)
               lda     0,y             ; set up MSB of tone generator
               lbsr    writeSoundByte  ; Write high byte of desired note frequency
PlayNoNote2    ldy     SoundBytePtr,u
               ldb     ,y+
               sty     SoundBytePtr,u
               cmpb    #$FE            ; #$FE marks the end of the SoundBytetable, so we loop back to the start
               beq     ReturnToStart
               cmpb    #$FF            ; #$FF marks no note to play (a pause), so no note gets played this time for this sound channel
               beq     wait
               lda     #$10            ; Initialise full volume (+1) into channel variable for the sound channel's volume
               sta     PSGVolume3,u
               bsr     NoteToFreqPtr   ; Convert note in b to table pointer in y
               lda     #$C0            ; 1xx00000, xx=10
               adda    1,y	            ; set up LSB of tone generator
               lbsr    writeSoundByte  ; Write low byte of desired note frequency (1xx0ffff format for the first byte)
               lda     0,y             ; set up MSB of tone generator
               lbsr    writeSoundByte  ; Write high byte of desired note frequency
;
wait           ldx     #50             ; Do a 50 mS delay
               bsr     delayMS
               lbra    mainLoop
                
;
ReturnToStart  leax    SoundByteTable,pcr
               stx     SoundBytePtr,u  ; Reset the SoundBytePtr to the start of the SoundByteTable
               lbra    ReadNewNotes    ; Re-start the sound channel loop as we're starting again

;
;               clrb                       ; else clear carry
;               os9      F$Exit            ; and exit
;
;
; Convert note in b to offset in frequency table (y)
NoteToFreqPtr  pshs    a,b,x           ; save registers
               leax    FrequencyTable,pcr
               stx     Offset,u        ; Save the pointer to the top of the frequency table
               lslb                    ; Adjust note offset for 16-bit values
               clra                    ; Clear top byte
               andcc   #$FE
               addb    Offset+1,u      ; Add the LSB offset
               adca    Offset,u        ; Add the MSB offset
               tfr     d,y             ; Y now holds the FrequencyTable pointer for the required note
               puls    a,b,x,pc        ; Restore registers and return
;

; Function:	Delay X ms (Actually X * 1.004ms + 0.003ms at 1Mhz clock)
; Parameters:	X - Specifies desired delay in millseconds (note above)
; Returns:	-
; Destroys:	X, Y
delayMS        bra     DelayMSLoop     ; 3 cycles

; Function:	Delay 1ms (Approximately. Actually 1.004ms at 1Mhz clock)
; Parameters:	-
; Returns:	-
; Destroys:	X, Y
delay1MS       ldx     #1              ; 3 Cycles
DelayMSLoop    ldy     #123            ; 4 Cycles - Assumes 1Mhz Clock
Delay1MSLoop   leay    -1,y            ; 5 cycles
               bne    Delay1MSLoop     ; 3 cycles
               leax    -1,x            ; 5 cycles
               bne     DelayMSLoop     ; 3 cycles
               rts                     ; 5 cycles

;

; Function:	Write Sound Byte (A) to SN76489 and wait for not busy
; Parameters:	A - Sound Byte to write
; Returns:	-
; Destroys:	
writeSoundByte pshs    a               ; Save a
               sta     PIA_PRTB
busyCheck      lda     PIA_CTLB        ; Read control Register
               anda    #$80
               beq     busyCheck       ; Wait for CB1 transition (IRQB1 flag)	
               lda     PIA_PRTB        ; Reset the IRQ flag by reading the data register
               puls    a,pc            ; Restore a and return
;
	
; Function:	Silence all SN76489 Sound Channels
; Parameters:	-
; Returns:	-
; Destroys:	A
silenceSound   pshs    a               ; Save a
               lda     #0x9F           ; Turn Off Channel 0
               bsr     writeSoundByte
               lda     #0xBF           ; Turn Off Channel 1
               bsr     writeSoundByte
               lda     #0xDF           ; Turn Off Channel 2
               bsr     writeSoundByte
               lda     #0xFF           ; Turn Off Noise Channel
               bsr     writeSoundByte
               puls    a,pc

;
               emod
eom            equ   *
               end
