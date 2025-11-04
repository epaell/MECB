               include 'mecb.asm'
               include 'tutor.asm'
;
               org      $4000
;
start          move.l   #RAM_END+1,a7        ; Set up stack
               bsr      intro
;
exit           move.b   #TUTOR,d7
               trap     #14
;
; Intro
;
intro          movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
;
               move.b   #OUT1CR,d7           ; Sector erase
               move.l   #MSG_INTRO,a5
               move.l   #MSG_INTROE,a6
               trap     #14
;
intro_exit     movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
MSG_INTRO      dc.b     'Program to test FLASH ROM subtroutines'
MSG_INTROE     equ      *
