********************************************************************
* Testpia1 - Write data to Prototype PIA port A
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/12  epaell

               nam      Testpia1
               ttl      Write data to PIA port A

               ifp1
*         use   /dd/defs/defsfile
               use      ../defsfile
               endc

tylg           set      Prgrm+Objct   
atrv           set      ReEnt+rev
rev            set      $00
edition        set      1

               mod      eom,name,tylg,atrv,start,size

               org      0
Temp           RMB      1                 ; This location for temporary byte storage.
filepath       rmb      1
parmptr        rmb      2
bufptr         rmb      2
buffer         rmb      40
               rmb      400
size           equ      .

name           fcs      /Testpia1/
               fcb      edition

; Message to notify user that graphics device is being started up
text1          fcc      "Initialising PIA port A"
               fcb      C$CR,C$LF
text1len       equ      *-text1
;
; I/O mapping for VDP
PIA            equ      0xEFE0            ; Protoype PIA
PIA_PRTA       equ      PIA+0             ; MC6821 PIA Port A & DDR A address
PIA_CTLA       equ      PIA+1             ; MC6821 PIA Control Register A address 
PIA_PRTB       equ      PIA+2             ; MC6821 PIA Port B & DDR B address
PIA_CTLB       equ      PIA+3             ; MC6821 PIA Control Register B address 

start          stx      <parmptr          ; save parameter pointer
               lda      #1
               leax     text1,pcr
               ldy      #text1len
               os9      I$WritLn          ; Write a message to indicate VDP is being started
;
; Setup PIA Port A for LED output
               lda      #$00              ; Select DDR Register A
               sta      PIA_CTLA          ; 
               lda      #$FF              ; Set Port A as all outputs
               sta      PIA_PRTA          ; DDR A register write
               lda      #$04              ; Select Port A Data Register
               sta      PIA_CTLA
; Initialize Counter
               clra                       ; Clear the counter
mainLoop       sta      PIA_PRTA
               inca
;
               ldx      #10               ; Sleep for a bit
               os9      F$Sleep
               bra      mainLoop          ; Loop back
;
               emod
eom            equ   *
               end
