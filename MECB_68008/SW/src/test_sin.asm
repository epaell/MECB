            include  'mecb.inc'
            include  'tutor.inc'
            include  'library_rom.inc
***************************************************
* THIS IS A DEMO OF THE 68343 FAST FLOATING POINT *
***************************************************
            org      $1000
          
ffp_demo    lea.l    stack,a7              ;LOAD STACK
            lea.l    buffer,a2
            lea.l    ASCII0,a0             ;CONVERT 0 TO FLOAT
            bsr      FFPAFP
            move.l   d7,(a2)              ; (a2) = 0.0
            lea.l    ASCIIN,a0
            bsr      FFPAFP
            move.l   d7,4(a2)             ; 4(a2) = 0.06
            move.l   #100,d0
sine_loop   move.l   (a2),d7              ; get current angle
            bsr      input                ; write the input
            bsr      input                ; write the input
            jsr      FFPSIN               ; perform sine
            bsr      output               ; write the output

            move.l   (a2),d6
            move.l   4(a2),d7
            jsr      FFPADD               ; increment the angle
            move.l   d7,(a2)              ; save it fot next loop
            sub.l    #1,d0
            bne      sine_loop

            bra      HALT

;
; output float value in d7
;
output      movem.l  d7/a2,-(a7) 
            jsr      FFPFPA
            move.l   #'UT: ',-(a7)         ;MOVE RESULT HEADER
            move.l   #'OUTP',-(a7)         ;ONTO STACK
            lea      (SP),A0               ;POINT TO MESSAGE
            lea      14+8(a7),A1           ;POINT TO END OF MESSAGE
            bsr      PUT                   ;ISSUE TO CONSOLE
            lea      14+8(a7),a7           ;GET RID OF CONVERSION AND HEADING
            movem.l  (a7)+,d7/a2
            rts                             ;RETURN TO CALLER
;
; input float value in d7
;
input       movem.l  d7/a2,-(a7) 
            jsr      FFPFPA
            move.l   #'T:  ',-(a7)         ;MOVE RESULT HEADER
            move.l   #'INPU',-(a7)         ;ONTO STACK
            lea      (a7),A0               ;POINT TO MESSAGE
            lea      14+8(a7),A1           ;POINT TO END OF MESSAGE
            bsr      PUT                   ;ISSUE TO CONSOLE
            lea      14+8(a7),a7           ;GET RID OF CONVERSION AND HEADING
            movem.l  (a7)+,d7/a2
            rts                             ;RETURN TO CALLER

*   *
*   * PUT SUBROUTINE
*   *  INPUT: A0->TEXT START, A1->TEXT END
*   *

PUT       movem.l    D0/D7/A0/A5/A6,-(a7)           ;SAVE REGS
          move.l     a0,a5
          move.l     a1,a6
          move.l     #OUT1CR,d7
          trap       #14
          movem.l    (a7)+,D0/D7/A0/A5/A6           ;RELOAD REGISTERS
          rts                             ;RETURN TO CALLER

* CONSTANTS
ASCIIPI   DC.B      '+3.1415926535897 '
ASCIIN    DC.B      '+0.06 '
ASCII0    DC.B      '+0.0 '

          align 2
buffer    ds.l       10

* PROGRAM STACK
          ds.w     100,0                 ;STACK AREA
stack     EQU       *

* DISPLAY CHARACTER IN D0

CHAROUT  MOVEM.L   A0/D7,-(A7)
         MOVE.B   #OUTCH,D7
         TRAP     #14
         MOVEM.L   (A7)+,A0/D7
         RTS

* HALT - RETURN TO TUTOR

HALT      MOVE.W    #228,D7
          TRAP      #14
          NOP
