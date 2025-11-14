         align    2
* DISPLAY CHARACTER IN D0

CHAROUT  MOVEM.L   A0/D7,-(A7)
         MOVE.B   #248,D7
         TRAP     #14
         MOVEM.L   (A7)+,A0/D7
         RTS

CHARIN   MOVEM.L   A0/D7,-(A7)
         MOVE.B   #247,D7
         TRAP     #14
         BSR      CHAROUT
         CMP.B    #$0D,D0
         BNE      CHARIN2
         MOVE.B   #$0A,D0
         BSR      CHAROUT
         MOVE.B   #$0D,D0
CHARIN2  MOVEM.L   (A7)+,A0/D7
         RTS

* HALT - RETURN TO TUTOR

HALT      MOVE.W    #228,D7
          TRAP      #14
          NOP

