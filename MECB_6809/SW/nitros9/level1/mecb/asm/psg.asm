********************************************************************
* psg - Play sounds on PSG
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/08/29  epaell

               nam     psg
               ttl     Play sounds on PSG

               ifp1
               use   /dd/defs/defsfile
*               use     ../defsfile
               endc

tylg           set     Prgrm+Objct   
atrv           set     ReEnt+rev
rev            set     $00
edition        set     1

               mod     eom,name,tylg,atrv,start,size

               org     0
Offset         rmb     2
Decay          rmb     1               * This location holds Frame Count until next Note plays.
SBPtr          rmb     2               * 16 bit pointer into the stable melody data.
PSGV1          rmb     1
PSGV2          rmb     1
PSGV3          rmb     1
parmptr        rmb     2
               rmb     400
size           equ     .

name           fcs     /psg/
               fcb     edition

* Include the sound definitions
               use     freq.asm
               use     sound.asm

* Message to notify user that graphics device is being started up
text1          fcc     "Initialising programmable sound generator"
               fcb     C$CR,C$LF
text1len       equ     *-text1
*
* I/O mapping for VDP
PIA            equ     $EF30           * 6821 Base address
PPRTB          equ     PIA+2           * MC6821 PIA Port B & DDR B address
PCTLB          equ     PIA+3           * MC6821 PIA Control Register B address
DELAY          equ     10              * Determines overall tempo

start          stx     <parmptr        * save parameter pointer
               lda     #1
               leax    text1,pcr
               ldy     #text1len
               os9     I$WritLn        * Write a message to indicate VDP is being started
*
* Setup PIA Port B for Sound ouput
               lda     #$22            * Select DDR Register B
               sta     PCTLB
               lda     #$FF            * Set Port B as all outputs
               sta     PPRTB           * DDR B register write
               lda     #$26            * Select Port B Data Register (rest as above) 
               sta     PCTLB
* Initialize Decay
               lda     #DELAY          * Wait a bit before starting the music
               sta     Decay,u
* Initialize PSGVolume, PSGNote & SBPtr storage to Zero
               clr     PSGV1,u
               clr     PSGV2,u
               clr     PSGV3,u
               leax    stable,pcr
               stx     SBPtr,u         * Initialise pointer to Sound table
               lbsr	  nosnd           * Turn off all sounds
*
* Function:	Play stable notes for all 3 Tone Generators of the SN76489
* Set attenuators first.
* Format = 1xx1 yyyy* x=channel* yyyy=level (1111=off* 0000=loudest)
mainLoop       lda     PSGV1,u         * Check if the Tone Generator's volume is >0
               beq     NoAtt1          * If Tone Generator's volume now 0 then note is silenced
               deca                    * Decrement the Tone Generator's volume to use
               sta     PSGV1,u	      * And save new volume
               eora    #$9F            * Convert desired volume into SN76489 Attenuation Control Byte 
*                                        So this turns 0000xxxx into 1001yyyy, where y = 15-x
*                                        (and x is the desired volume for tone 1).
               lbsr    writePSG        * Write the Attenuation Control Byte to the SN76489
NoAtt1         lda     PSGV2,u         * Check if the Tone Generator's volume is >0
               beq     NoAtt2          * If Tone Generator's volume now 0 then note is silenced
               deca                    * Decrement the Tone Generator's volume to use
               sta     PSGV2,u         * And save new volume
               eora    #$BF            * Convert desired volume into SN76489 Attenuation Control Byte 
*                                        - So this turns 0000xxxx into 1011yyyy, where y = 15-x
*                                        (and x is the desired volume for tone 2).
               lbsr    writePSG        * Write the Attenuation Control Byte to the SN76489
NoAtt2         lda     PSGV3,u         * Check if the Tone Generator's volume is >0
               beq     updtone         * If Tone Generator's volume now 0 then note is silenced
               deca                    * Decrement the Tone Generator's volume to use
               sta     PSGV3,u	      * And save new volume
               eora    #$DF            * Convert desired volume into SN76489 Attenuation Control Byte 
*                                        - So this turns 0000xxxx into 1101yyyy, where y = 15-x
*                                        (and x is the desired volume for tone 3).
               lbsr    writePSG  * Write the Attenuation Control Byte to the SN76489
*
updtone        dec     Decay,u         * Decrement our Decay Count
               lbne    wait            * If volume still decaying then wait
*
* The following handles the reading of new notes to be played for each of the 3 tone generators
* Tone generator setting is 1rr0llll 00hhhhhh where r is the tone generator* l is the lower part of frequency* and h is higher part.
               lda     #DELAY          * Reset the decay value for new notes (which determines the overall tempo).
               sta     Decay,u
newnotes       ldy     SBPtr,u
               ldb     ,y+             * Get the note for Tone Generator 1
               sty     SBPtr,u         * Save updated pointer
               cmpb    #$FE            * #$FE marks the end of the stable, so we loop back to the start
               lbeq    Reset
               cmpb    #$FF            * #$FF marks no note to play (a pause) for this channel
               beq     Nope1
               lda     #$10            * Initialise full volume (+1) for Tone generator 1
               sta     PSGV1,u
               bsr     NoteTofptr      * Convert note in b to table pointer in y
               lda     #$80            * 1xx00000, xx=00
               adda    1,y	            * set up LSB of tone generator
               lbsr    writePSG        * Write low byte of desired note frequency
               lda     0,y             * set up MSB of tone generator
               lbsr    writePSG        * Write high byte of desired note frequency
Nope1          ldy     SBPtr,u
               ldb     ,y+
               sty     SBPtr,u
               cmpb    #$FE            * #$FE marks the end of the stable, so we loop back to the start
               beq     Reset
               cmpb    #$FF            * #$FF marks no note to play (a pause), so no note gets played this time for this sound channel
               beq     Nope2
               lda     #$10            * Initialise full volume (+1)
               sta     PSGV2,u
               bsr     NoteTofptr      * Convert note in b to table pointer in y
               lda     #$A0            * 1xx00000, xx=01
               adda    1,y	            * set up LSB of tone generator
               lbsr    writePSG        * Write low byte of desired note frequency
               lda     0,y             * set up MSB of tone generator
               lbsr    writePSG        * Write high byte of desired note frequency
Nope2          ldy     SBPtr,u
               ldb     ,y+
               sty     SBPtr,u
               cmpb    #$FE            * #$FE marks the end of the stable, so we loop back to the start
               beq     Reset
               cmpb    #$FF            * #$FF marks no note to play (a pause)
               beq     wait
               lda     #$10            * Initialise full volume (+1)
               sta     PSGV3,u
               bsr     NoteTofptr      * Convert note in b to table pointer in y
               lda     #$C0            * 1xx00000, xx=10
               adda    1,y	            * set up LSB of tone generator
               lbsr    writePSG        * Write low byte of desired note frequency
               lda     0,y             * set up MSB of tone generator
               lbsr    writePSG        * Write high byte of desired note frequency
*
wait           ldx     #50             * Do a 50 mS delay
               bsr     sleep
               lbra    mainLoop
*
Reset          leax    stable,pcr
               stx     SBPtr,u         * Reset the SBPtr to the start of the stable
               lbra    newnotes        * Re-start the sound channel loop as we're starting again
*
* Convert note in b to offset in frequency table (y)
NoteTofptr     pshs    a,b,x           * save registers
               leax    ftable,pcr
               stx     Offset,u        * Save the pointer to the top of the ftable
               lslb                    * Adjust note offset for 16-bit values
               clra                    * Clear top byte
               andcc   #$FE
               addb    Offset+1,u      * Add the LSB offset
               adca    Offset,u        * Add the MSB offset
               tfr     d,y             * Y now holds the ftable pointer for the required note
               puls    a,b,x,pc        * Restore registers and return
*
* Function:	Delay X ms (Actually X * 1.004ms + 0.003ms at 1Mhz clock)
* Parameters:	X - Specifies desired delay in millseconds (note above)
* Returns:	-
* Destroys:	X, Y
delmS          ldy     #123            * 4 Cycles - Assumes 1Mhz Clock
loop2          leay    -1,y            * 5 cycles
               bne     loop2           * 3 cycles
               leax    -1,x            * 5 cycles
               bne     delmS           * 3 cycles
               rts                     * 5 cycles

sleep          ldx      #2               ; Sleep for a bit
               os9      F$Sleep
               rts

*
* Function:	Write Sound Byte (A) to SN76489 and wait for not busy
* Parameters:	A - Sound Byte to write
* Returns:	-
* Destroys:	
writePSG       pshs    a               * Save a
               sta     PPRTB
busyCheck      lda     PCTLB           * Read control Register
               anda    #$80
               beq     busyCheck       * Wait for CB1 transition (IRQB1 flag)	
               lda     PPRTB           * Reset the IRQ flag by reading the data register
               puls    a,pc            * Restore a and return
*
* Function:	Silence all SN76489 Sound Channels
* Parameters:	-
* Returns:	-
* Destroys:	A
nosnd          pshs    a              * Save a
               lda     #$9F           * Turn Off Channel 0
               bsr     writePSG
               lda     #$BF           * Turn Off Channel 1
               bsr     writePSG
               lda     #$DF           * Turn Off Channel 2
               bsr     writePSG
               lda     #$FF           * Turn Off Noise Channel
               bsr     writePSG
               puls    a,pc
*
               emod
eom            equ   *
               end
