********************************************************************
* pia2 - Write data to Prototype PIA port B
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/12  epaell

               nam      pia2
               ttl      Write data to PIA port B

               ifp1
               use   /dd/defs/defsfile
*               use      ../defsfile
               endc

tylg           set      Prgrm+Objct   
atrv           set      ReEnt+rev
rev            set      $00
edition        set      1

               mod      eom,name,tylg,atrv,start,size

               org      0
parmptr        rmb      2
               rmb      400
size           equ      .

name           fcs      /pia2/
               fcb      edition

* Message to notify user that graphics device is being started up
text1          fcc      "Initialising PIA port B"
               fcb      C$CR,C$LF
text1len       equ      *-text1
*
* I/O mapping for PIA
PIA            equ      $EFE0             ; Protoype PIA
PIA_PRTA       equ      PIA+0             ; MC6821 PIA Port A & DDR A address
PIA_CTLA       equ      PIA+1             ; MC6821 PIA Control Register A address 
PIA_PRTB       equ      PIA+2             ; MC6821 PIA Port B & DDR B address
PIA_CTLB       equ      PIA+3             ; MC6821 PIA Control Register B address 

start          stx      <parmptr          ; save parameter pointer
               lda      #1
               leax     text1,pcr
               ldy      #text1len
               os9      I$WritLn          ; Write a message to indicate VDP is being started
*
* Setup PIA Port B for LED output
               lda      #$00              ; Select DDR Register B
               sta      PIA_CTLB          ; 
               lda      #$FF              ; Set Port B as all outputs
               sta      PIA_PRTB          ; DDR B register write
               lda      #$04              ; Select Port B Data Register
               sta      PIA_CTLB
               clrb                       ; set direction of shift towards left
               lda      #$01              ; start with LED at LSB
*
loop           sta      PIA_PRTB
               tstb                       ; check scan direction
               bne      scanr
               lsla                       ; shift current bit to the left
               cmpa     #$80              ; check if reached end
               bne      wait
               ldb      #$01              ; change direction
               bra      wait
*
scanr          lsra                       ; shift current bit to the right
               cmpa     #$01              ; check if at the edge
               bne      wait              ; if not, continue
               clrb                       ; otherwise, change direction
*
wait           ldx      #10               ; Sleep for a bit
               pshs     b
               os9      F$Sleep
               puls     b
               bra      loop              ; Loop back
*
               emod
eom            equ   *
               end
