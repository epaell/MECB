;
; Output the floating point value in d7 to console
;
FFPOUT   movem.l  d0-d1/d7/a0,-(a7)       ; save registers
         jsr      ffpfpa                  ; convert float to string
         move.l   a7,a0                   ; point to the ascii string
         move.l   #13,d1
FFPOUT1
         move.b   (a0)+,d0
         jsr      outch1
         dbra     d1,FFPOUT1
FFPOUTEX lea      14(a7),a7               ; restore stack
         movem.l  (a7)+,d0-d1/d7/a0       ; restore registers
         rts                              ; return to caller
