********************************************************************
* Testpia1 - Write data to IO port
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/12  epaell

               nam      Testio
               ttl      Write data to IO port

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

name           fcs      /Testio/
               fcb      edition

* Message to notify user that IO port is being started up
text1          fcc      "Initialising IO port"
               fcb      C$CR,C$LF
text1len       equ      *-text1
*

start          stx      <parmptr          * save parameter pointer
               lda      #1
               leax     text1,pcr
               ldy      #text1len
               os9      I$WritLn          * Write a message to indicate VDP is being started
*
               lda      #$01              * start with LED at LSB
               clrb                       * set direction of shift towards left
*
loop           sta      IOPORTBase
               tstb                       * check scan direction
               bne      scanr
               lsla                       * shift current bit to the left
               cmpa     #$80              * check if reached end
               bne      wait
               ldb      #$01              * change direction
               bra      wait
*
scanr          lsra                       * shift current bit to the right
               cmpa     #$01              * check if at the edge
               bne      wait              * if not, continue
               clrb                       * otherwise, change direction
*

wait           ldx      #10               * Sleep for a bit
               pshs     b
               os9      F$Sleep
               puls     b
               bra      loop              * Loop back
*
               emod
eom            equ   *
               end
