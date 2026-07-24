         cpu      68008
;
         include  "mecb.inc"
         include  "tutor.inc"
         include  "library_rom.inc"
         
         org      $4000
;
         bra      start
; constants
ac1      dc.b     '+4.0 '
ac2      dc.b     '+0.0458 '
ac3      dc.b     '+0.08333 '
ac4      dc.b     '+2.0 '

start:
         move.l   #RAM_END+1,a7
         ; Convert string constants to float
         move.l   #ac1,a0
         jsr      ffpafp
         move.l   d7,c1       ; c1 = 4.0

         move.l   #ac2,a0
         jsr      ffpafp
         move.l   d7,c2       ; c2 = 0.0458

         move.l   #ac3,a0
         jsr      ffpafp
         move.l   d7,c3       ; c3 = 0.08333

         move.l   #ac4,a0
         jsr      ffpafp
         move.l   d7,c4       ; c4 = 2.0
         
         move.l   #-12,d1     ; for y (=d1) = -12 to 12
loopy:
         move.l   d1,d7
         jsr      ffpifp
         move.l   d7,y        ; y = float(y)         
         move.l   #-39,d0     ; for x (=d0) = -39 to 39
loopx:
         move.l   d0,d7
         jsr      ffpifp
         move.l   d7,x        ; x = float(x)
         
         ; ca = x * 0.0458 (=c2)
         move.l   c2,d6
         jsr      ffpmul
         move.l   d7,ca
         ; a = ca
         move.l   d7,a
         
         ; cb = y * 0.8333 (=c3)
         move.l   c3,d6
         move.l   y,d7
         jsr      ffpmul
         move.l   d7,cb
         ; b = cb
         move.l   d7,b
;
         move.l   #0,d2       ; for i (=d2) = 0 to 15
loopi:
;         move.l   d0,-(a7)    ; print "i=",i
;         move.b   #'i',d0
;         jsr      outch1
;         move.b   #'=',d0
;         jsr      outch1
;         move.l   d2,d0
;         jsr      out2h
;         move.b   #' ',d0
;         jsr      outch1
;         move.l   (a7)+,d0
         
         move.l   a,d6
         move.l   d6,d7
         jsr      ffpmul      ; d7 = a * a
         move.l   d7,a2       ; a2 = a * a

         move.l   b,d6
         move.l   d6,d7
         jsr      ffpmul      ; d7 = b * b
         jsr      ffpneg      ; d7 = - b * b

         move.l   a2,d6       ; d6 = a * a
         jsr      ffpadd      ; d7 = a * a - b * b

         move.l   ca,d6
         jsr      ffpadd      ; d7 = a * a - b * b + ca
         move.l   d7,t        ; t = a * a - b * b + ca
         ; b = 2 (=c4) * a * b + cb
         move.l   c4,d6
         move.l   a,d7
         jsr      ffpmul      ; d7 = 2 * a
         move.l   b,d6
         jsr      ffpmul      ; d7 = 2 * a * b
         move.l   cb,d6
         jsr      ffpadd      ; d7 = 2 * a * b + cb
         move.l   d7,b        ; b = 2 * a * b + cb
         move.l   t,d6
         move.l   d6,a        ; a = t
         
         move.l   a,d7
         move.l   a,d6
         jsr      ffpmul      ; d7 = a * a
         move.l   d7,a2       ; a2 = a * a

         move.l   b,d6
         move.l   d6,d7
         jsr      ffpmul      ; d7 = b * b
         move.l   a2,d6       ; d6 = a * a
         jsr      ffpadd      ; d7 = a * a + b * b
         move.l   c1,d6

         move.l   d7,sum2
         jsr      ffpcmp      ; a * a + b * b (=d7) > 4 then goto l200
         bgt      l200

         ; next i
         add.b    #1,d2
         cmp.b    #16,d2
         blt      loopi
         ; print " "
         move.l   d0,-(a7)
         move.b   #' ',d0
         jsr      outch1
         move.l   (a7)+,d0
         bra      l210        ; goto l210
l200:
;         movem.l  d0/d7,-(a7)
;         move.l   d0,-(a7)
;         move.b   #'x',d0
;         jsr      outch1
;         move.b   #'=',d0
;         jsr      outch1
;         move.l   (a7)+,d0
;         jsr      out4h
;         move.b   #' ',d0
;         jsr      outch1
;         move.l   sum2,d7
;         move.b   #'s',d0
;         jsr      outch1
;         move.b   #'u',d0
;         jsr      outch1
;         move.b   #'m',d0
;         jsr      outch1
;         move.b   #'=',d0
;         jsr      outch1
;         jsr      write_fp
;         move.b   #' ',d0
;         jsr      outch1
;         move.b   #'I',d0
;         jsr      outch1
;         move.b   #'=',d0
;         jsr      outch1
;         move.l   d2,d0
;         jsr      out2h
;         jsr      pcrlf
;         movem.l  (a7)+,d0/d7
         
         cmp.b    #9,d2
         bls      l205
         add.b    #7,d2       ; if i>9 then i = i + 7
l205:
         ; print chr$(48+i);
         add.b    #48,d2
         move.l   d0,-(a7)
         move.b   d2,d0
         jsr      outch1
         move.l   (a7)+,d0
         
l210:    ; next x
         add.l    #1,d0
         cmp.l    #39,d0
         blt      loopx
         jsr      pcrlf
;         bra      halt
         ; next y
         add.l    #1,d1
         cmp.l    #12,d1
         blt      loopy
;
halt     move.w   #TUTOR,d7
         trap     #14
;
;
; RESULT DISPLAY SUBROUTINE
;   INPUT IS FLOAT IN D7
write_fp       movem.l  d0/d7/a0-a1,-(a7)
               jsr      ffpfpa
               move.l   a7,a0                   ; point to the ascii string
               move.l   #14,d0
               move.l   #buffer,a1
               jsr      strncpy
               move.b   #EOT,(a1)+
               move.l   #buffer,a0
               jsr      print
               lea      14(a7),a7               ; GET RID OF CONVERSION AND HEADING
               movem.l  (a7)+,d0/d7/a0-a1
               rts                              ; RETURN TO CALLER
;
buffer   ds.b     50
;
sum2     ds.l     1
a2       ds.l     1
x        ds.l     1
y        ds.l     1
ca       ds.l     1
cb       ds.l     1
a        ds.l     1
b        ds.l     1
t        ds.l     1
c1       ds.l     1
c2       ds.l     1
c3       ds.l     1
c4       ds.l     1
;
