            include  "mecb.inc"
            include  "tutor.inc"
;
MSCNT10MHZ  equ   545      ; number of loops to delay 1 mS with 10 MHz 68008 CPU
;
            org      USERPROG_ORG
;
main:
            move.l   #RAM_END+1,a7           ; Set up stack
            move.l   #ststart,a0
            bsr      print
;
            move.l   #0,d0
loop0       move.l   #999,d1                 ; 1000 x 1ms = 1s
            bsr      out8h
loop        bsr      delay1ms
            dbra     d1,loop
            add.l    #1,d0
            bsr      pcrlf
            bra      loop0
;
; Delay about 1mS
;
delay1ms:
            move.l   d0,-(a7)
            move.w   #MSCNT10MHZ,d0
delay1ms2:
            dbra     d0,delay1ms2
            move.l   (a7)+,d0
            rts
;
            include  "aciaio.asm"
;
ststart:    dc.b   CR,LF
            dc.b   'Delay test'
            dc.b   CR,LF,EOT
