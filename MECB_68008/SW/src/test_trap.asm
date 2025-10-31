; Tutor TRAP 14 Functions
PORTIN1N equ      224
GETNUMD  equ      225
GETNUMA  equ      226
OUT1CR   equ      227
TUTOR    equ      228
START    equ      229
PNT8HX   equ      230
PNT6HX   equ      231
PNT4HX   equ      232
PNT2HX   equ      233
PUTHEX   equ      234
GETHEX   equ      235
HEX2DEC  equ      236
PRCRLF   equ      237
TAPEIN   equ      238
TAPEOUT  equ      239
PORTIN20 equ      240
PORTIN1  equ      241
OUTPUT21 equ      242
OUTPUT   equ      243
CHRPRINT equ      244
INCHE    equ      247
OUTCH    equ      248
FIXDCRLF equ      249
FIXDATA  equ      250
FIXBUF   equ      251
FIXDADD  equ      252
LINKIT   equ      253
;
         org      $4000
;
         move.b   #OUTPUT,d7
         move.l   #MESG_START,a5
         move.l   #MESG_END,a6
         trap     #14
         move.b   #TUTOR,d7
         trap     #14
;
MESG_START dc.b   "Hello, World!"
MESG_END
