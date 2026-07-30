         include "library.inc"
DCB_RX_BUFFER        equ   4
DCB_TX_BUFFER        equ   8
DCB_SIZE             equ   18
;
FN_TIME_YEARH        equ   0
FN_TIME_YEARL        equ   1
FN_TIME_MONTH        equ   2
FN_TIME_MDAY         equ   3
FN_TIME_HOUR         equ   4
FN_TIME_MIN          equ   5
FN_TIME_SEC          equ   6
;
FUJINET_RC_OK        equ   0
;
CR       EQU      $0D            ; Carriage return
LF       EQU      $0A            ; Linefeed
EOT      EQU      $00
;
TUTOR    equ      228
;
         org      $4000
;
; test fujinet_get_time
;
         move.l   #fujinet_dcb,a0   ; Point to the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)
         move.l   #txdata,DCB_TX_BUFFER(a0)
         library  FNGETDT
         cmp.b    #FUJINET_RC_OK,d0 ; Check if OK
         bne      error             ; if not, report error
         move.l   #rxdata,a0
         move.l   #txdata,a1
;
         movem.l  d0/a1,-(a7)
         move.b   FN_TIME_MDAY(a0),d0     ; Get the day of month
         library  HEX2DEC2
         move.b   #'/',(a1)+
         move.b   FN_TIME_MONTH(a0),d0    ; Get the month
         library  HEX2DEC2
         move.b   #'/',(a1)+
         move.b   FN_TIME_YEARH(a0),d0    ; Get the MSB year
         library  HEX2DEC2
         move.b   FN_TIME_YEARL(a0),d0    ; Get the LSB year
         library  HEX2DEC2
         move.b   #' ',(a1)+
         move.b   FN_TIME_HOUR(a0),d0     ; Get the hour
         library  HEX2DEC2
         move.b   #':',(a1)+
         move.b   FN_TIME_MIN(a0),d0      ; Get the minutes
         library  HEX2DEC2
         move.b   #':',(a1)+
         move.b   FN_TIME_SEC(a0),d0      ; Get the seconds
         library  HEX2DEC2
         move.b   #0,(a1)+
         movem.l  (a7)+,d0/a1
;
         exg      a0,a1
         library  PRINT
         library  PCRLF
         bra      exit
error
         move.l   #STR_ERR,a0
         jsr      print
;
exit     move.w   #TUTOR,d7
         trap     #14

         rts

;
STR_ERR  dc.b     "Failed to get time.",CR,LF,EOT
;
         align 4
;
txdata   ds.b   32
rxdata   ds.b   32
;
fujinet_dcb:
         ds.b   DCB_SIZE

         end