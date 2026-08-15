********************************************************************
* nopsg - Turn off PSG
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/08/29  epaell

               nam     nopsg
               ttl     Turn off PSG

               ifp1
*               use   /dd/defs/defsfile
               use     ../defsfile
               endc

tylg           set     Prgrm+Objct   
atrv           set     ReEnt+rev
rev            set     $00
edition        set     1

               mod     eom,name,tylg,atrv,start,size

               org     0
parmptr        rmb     2
               rmb     400
size           equ     .

name           fcs     /nopsg/
               fcb     edition

* Message to notify user that graphics device is being started up
text1          fcc     "Resetting PSG"
               fcb     C$CR,C$LF
text1len       equ     *-text1
*
* I/O mapping for PSG
PIA            equ     $EF30           ; 6821 Base address
PPRTB          equ     PIA+2           ; MC6821 PIA Port B & DDR B address
PCTLB          equ     PIA+3           ; MC6821 PIA Control Register B address

start          stx     <parmptr        ; save parameter pointer
               lda     #1
               leax    text1,pcr
               ldy     #text1len
               os9     I$WritLn        ; Write a message to indicate VDP is being started
*
* Setup PIA Port B for Sound ouput
               lda     #$22            ; Select DDR Register B
               sta     PCTLB
               lda     #$FF            ; Set Port B as all outputs
               sta     PPRTB           ; DDR B register write
               lda     #$26            ; Select Port B Data Register
               sta     PCTLB
*
               lbsr	  noSound         ; Turn off all channels
*
               clrb                    ; clear carry
               os9     F$Exit          ; and exit
*
* Function:	Write Sound Byte (A) to SN76489 and wait for not busy
* Parameters:	A - Sound Byte to write
* Returns:	-
* Destroys:	
writePSG       pshs    a               ; Save a
               sta     PPRTB
busyCheck      lda     PCTLB           ; Read control Register
               anda    #$80
               beq     busyCheck       ; Wait for CB1 transition (IRQB1 flag)	
               lda     PPRTB           ; Reset the IRQ flag by reading the data register
               puls    a,pc            ; Restore a and return
*
* Function:	Silence all SN76489 Sound Channels
* Parameters:	-
* Returns:	-
* Destroys:	A
noSound        pshs    a               ; Save a
               lda     #0x9F           ; Turn Off Channel 0
               bsr     writePSG
               lda     #0xBF           ; Turn Off Channel 1
               bsr     writePSG
               lda     #0xDF           ; Turn Off Channel 2
               bsr     writePSG
               lda     #0xFF           ; Turn Off Noise Channel
               bsr     writePSG
               puls    a,pc
*
               emod
eom            equ   *
               end
