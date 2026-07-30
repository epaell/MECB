            include  "mecb.inc"
            include  "tutor.inc"
            include  "library.inc"
;
            org      USERPROG_ORG
;
main:       library  OUTLVER
            move.l   #val,a0
            library  FFPAFP
            library  ffpout
;            jsr      ffpoutn
            library  PCRLF
            move.w   #TUTOR,d7
            trap     #14
;
; Output the floating point value in d7 to console
;
ffpoutn     movem.l  d0-d1/d7/a0,-(a7)       ; save registers
            library  FFPFPA                  ; convert float to string
            move.l   a7,a0                   ; point to the ascii string
            move.l   #13,d1
ffpout1
            move.b   (a0)+,d0
            library  OUTCH1
            dbra     d1,ffpout1
ffpoutex    lea      14(a7),a7               ; restore stack
            movem.l  (a7)+,d0-d1/d7/a0       ; restore registers
            rts                              ; return to caller

val         dc.b     '+.14746357E+01 '
;
            end
