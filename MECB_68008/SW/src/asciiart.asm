         include  "mecb.inc"
         include  "tutor.inc"
         include  "library.inc"
         include  "libfujinet.inc"
;
         org      USERPROG_ORG
;
         move.l   #RAM_END+1,a7
         move.l   #title,a0
         bsr      prline
         
         ; Convert string constants to float
         move.l   #ac1,a0
         library  FFPAFP
         move.l   d7,c1       ; c1 = 4.0

         move.l   #ac2,a0
         library  FFPAFP
         move.l   d7,c2       ; c2 = 0.0458

         move.l   #ac3,a0
         library  FFPAFP
         move.l   d7,c3       ; c3 = 0.08333

         move.l   #ac4,a0
         library  FFPAFP
         move.l   d7,c4       ; c4 = 2.0
         
         move.l   #-12,d1     ; for y (=d1) = -12 to 12
loopy:
         move.l   d1,d7
         library  FFPIFP
         move.l   d7,y        ; y = float(y)         
         move.l   #-39,d0     ; for x (=d0) = -39 to 39
         move.l   #line,a4    ; start at beginning of line
loopx:
         move.l   d0,d7
         library  FFPIFP
         move.l   d7,x        ; x = float(x)
         
; ca = x * 0.0458 (=c2)
         move.l   c2,d6
         library  FFPMUL
         move.l   d7,ca
; a = ca
         move.l   d7,a
         
; cb = y * 0.8333 (=c3)
         move.l   c3,d6
         move.l   y,d7
         library  FFPMUL
         move.l   d7,cb
; b = cb
         move.l   d7,b
;
         move.l   #0,d2       ; for i (=d2) = 0 to 15
loopi:
         move.l   a,d6
         move.l   d6,d7
         library  FFPMUL      ; d7 = a * a
         move.l   d7,asq      ; a2 = a * a

         move.l   b,d6
         move.l   d6,d7
         library  FFPMUL      ; d7 = b * b
         library  FFPNEG      ; d7 = - b * b

         move.l   asq,d6      ; d6 = a * a
         library  FFPADD      ; d7 = a * a - b * b

         move.l   ca,d6
         library  FFPADD      ; d7 = a * a - b * b + ca
         move.l   d7,t        ; t = a * a - b * b + ca
; b = 2 (=c4) * a * b + cb
         move.l   c4,d6
         move.l   a,d7
         library  FFPMUL      ; d7 = 2 * a
         move.l   b,d6
         library  FFPMUL      ; d7 = 2 * a * b
         move.l   cb,d6
         library  FFPADD      ; d7 = 2 * a * b + cb
         move.l   d7,b        ; b = 2 * a * b + cb
         move.l   t,d6
         move.l   d6,a        ; a = t
         
         move.l   a,d7
         move.l   a,d6
         library  FFPMUL      ; d7 = a * a
         move.l   d7,asq      ; a2 = a * a

         move.l   b,d6
         move.l   d6,d7
         library  FFPMUL      ; d7 = b * b
         move.l   asq,d6      ; d6 = a * a
         library  FFPADD      ; d7 = a * a + b * b
         move.l   c1,d6

         move.l   d7,sum2
;         library  FFPOUT
;         library  PCRLF
         library  FFPCMP      ; a * a + b * b (=d7) > 4 then goto l200
         bgt      l200

; next i
         add.b    #1,d2
         cmp.b    #16,d2
         blt      loopi
; print " "
         move.l   d0,-(a7)
         move.b   #' ',d0
         move.b   d0,(a4)+
         library  OUTCH1
         move.l   (a7)+,d0
         bra      l210        ; goto l210
l200:
         cmp.b    #9,d2
         bls      l205
         add.b    #7,d2       ; if i>9 then i = i + 7
l205:
         ; print chr$(48+i);
         add.b    #48,d2
         move.l   d0,-(a7)
         move.b   d2,d0
         move.b   d0,(a4)+
         library  OUTCH1
         move.l   (a7)+,d0
         
l210:    ; next x
         add.l    #1,d0
         cmp.l    #39,d0
         blt      loopx
         library  PCRLF
         move.b   #CR,(a4)+
         move.b   #LF,(a4)+
         move.b   #EOT,(a4)+
         
         movem.l  d0-d2,-(a7)             ; print the line
         move.l   #line,a0
         library  STRLEN
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.l   #0,DCB_RX_BUFFER(a0)        ; Set up receive and transmit buffers
         move.l   #line,DCB_TX_BUFFER(a0)
         move.b   #2,d1                   ; Printer device
         library  FNWRPRN                 ; Open network channel
         movem.l  (a7)+,d0-d2
         
         
;         bra      halt
         ; next y
         add.l    #1,d1
         cmp.l    #12,d1
         ble      loopy
;
halt     move.w   #TUTOR,d7
         trap     #14
;
prline   movem.l  d0-d2/a0-a1,-(a7)             ; print the line
         move.l   a0,a1
         library  STRLEN
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.l   #0,DCB_RX_BUFFER(a0)        ; Set up receive and transmit buffers
         move.l   a1,DCB_TX_BUFFER(a0)
         move.b   #2,d1                   ; Printer device
         library  FNWRPRN                 ; Open network channel
         movem.l  (a7)+,d0-d2/a0-a1
         rts

; constants
ac1      dc.b     '+4.0 '
ac2      dc.b     '+0.0458 '
ac3      dc.b     '+0.08333 '
ac4      dc.b     '+2.0 '
; variables
sum2     ds.l     1
asq      ds.l     1
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
line     ds.b     128
;
title    dc.b     $1B,'4                                 ASCII ART',$1B,'5',CR,LF,LF,EOT
;
         align    4
fujinet_dcb:
         ds.b     DCB_SIZE

;
         end