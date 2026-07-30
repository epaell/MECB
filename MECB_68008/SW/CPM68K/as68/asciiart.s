* as68 -l -u -p -s 0: asciiart.s
* lo68 -R -o asmart.68k asciiart.o
*
* Library ROM routines
*
FFPNEG   .equ     $0003 * d7=neg(d7)
FFPADD   .equ     $0004 * d7=add(d6,d7)
FFPCMP   .equ     $0008 * cmp(d6,d7) i.e. d7-d6
FFPIFP   .equ     $000F * d7=int2float(d7)
FFPMUL   .equ     $0011 * d7=mul(d6,d7)
FFPAFP   .equ     $0006 * d7=ASCII2float(a0)
*
CR       .equ     $0d
LF       .equ     $0a
*
         .text
*
main:
* Convert string constants to float
         move.l   #ac1,a0
         move.w   #FFPAFP,d5
         trap     #8
         move.l   d7,c1       * c1 = 4.0

         move.l   #ac2,a0
         move.w   #FFPAFP,d5
         trap     #8
         move.l   d7,c2       * c2 = 0.0458

         move.l   #ac3,a0
         move.w   #FFPAFP,d5
         trap     #8
         move.l   d7,c3       * c3 = 0.08333

         move.l   #ac4,a0
         move.w   #FFPAFP,d5
         trap     #8
         move.l   d7,c4       * c4 = 2.0
         
         move.l   #-12,d1     * for y (=d1) = -12 to 12
loopy:
         move.l   d1,d7
         move.w   #FFPIFP,d5
         trap     #8
         move.l   d7,y        * y = float(y)
         move.l   #-39,d0     * for x (=d0) = -39 to 39
loopx:
         move.l   d0,d7
         move.w   #FFPIFP,d5
         trap     #8
         move.l   d7,x        * x = float(x)
* ca = x * 0.0458 (=c2)
         move.l   c2,d6
         move.w   #FFPMUL,d5
         trap     #8
         move.l   d7,ca
* a = ca
         move.l   d7,a
         
* cb = y * 0.8333 (=c3)
         move.l   c3,d6
         move.l   y,d7
         move.w   #FFPMUL,d5
         trap     #8
         move.l   d7,cb
* b = cb
         move.l   d7,b
*
         move.l   #0,d2       * for i (=d2) = 0 to 15
loopi:
         move.l   a,d6
         move.l   d6,d7
         move.w   #FFPMUL,d5
         trap     #8
         move.l   d7,asq

         move.l   b,d6
         move.l   d6,d7
         move.w   #FFPMUL,d5
         trap     #8
         move.w   #FFPNEG,d5
         trap     #8

         move.l   asq,d6
         move.w   #FFPADD,d5
         trap     #8

         move.l   ca,d6
         move.w   #FFPADD,d5
         trap     #8
         move.l   d7,t        * t = a * a - b * b + ca
* b = 2 (=c4) * a * b + cb
         move.l   c4,d6
         move.l   a,d7
         move.w   #FFPMUL,d5
         trap     #8
         move.l   b,d6
         move.w   #FFPMUL,d5
         trap     #8
         move.l   cb,d6
         move.w   #FFPADD,d5
         trap     #8          * d7 = 2 * a * b + cb
         move.l   d7,b        * b = 2 * a * b + cb
         move.l   t,d6
         move.l   d6,a        * a = t
         
         move.l   a,d7
         move.l   a,d6
         move.w   #FFPMUL,d5
         trap     #8
         move.l   d7,asq      * asq = a * a

         move.l   b,d6
         move.l   d6,d7
         move.w   #FFPMUL,d5
         trap     #8
         move.l   asq,d6
         move.w   #FFPADD,d5
         trap     #8          * d7 = a * a + b * b
         move.l   c1,d6

         move.l   d7,sum2
         move.w   #FFPCMP,d5
         trap     #8          * a * a + b * b (=d7) > 4 then goto l200
         bgt      l200
* next i
         add.w    #1,d2
         cmp.w    #16,d2
         blt      loopi
* print " "
         move.l   d0,-(a7)
         move.w   #$0020,d0
         bsr      outch
         move.l   (a7)+,d0
         bra      l210        * goto l210
l200:
         cmp.w    #9,d2
         bls      l205
         add.w    #7,d2       * if i>9 then i = i + 7
l205:
* print chr$(48+i)*
         add.w    #48,d2
         move.l   d0,-(a7)
         move.w   d2,d0
         bsr      outch
         move.l   (a7)+,d0
l210:
* next x
         add.l    #1,d0
         cmp.l    #39,d0
         blt      loopx
         bsr      pcrlf
*
* next y
         add.l    #1,d1
         cmp.l    #12,d1
         blt      loopy
*
exit:    move.w   #0,d0
         trap     #2
*
outch:
         movem.l  d0-d1,-(a7)
         move.w   d0,d1
         move.w   #2,d0
         trap     #2
         movem.l  (a7)+,d0-d1
         rts
*
pcrlf:
         move.l   d0,-(a7)
         move.w   #CR,d0
         bsr      outch
         move.W   #LF,d0
         bsr      outch
         move.l   (a7)+,d0
         rts
*
         .bss
         .even
*
* variables
*
sum2     .ds.l     1
asq      .ds.l     1
x        .ds.l     1
y        .ds.l     1
ca       .ds.l     1
cb       .ds.l     1
a        .ds.l     1
b        .ds.l     1
t        .ds.l     1
c1       .ds.l     1
c2       .ds.l     1
c3       .ds.l     1
c4       .ds.l     1
*
         .data
*
* constants
*
ac1      .dc.b     "+4.0 "
ac2      .dc.b     "+0.0458 "
ac3      .dc.b     "+0.08333 "
ac4      .dc.b     "+2.0 "
*
         .end
