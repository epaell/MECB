; Tutor TRAP 14 Functions
PORTIN1N       equ      224
GETNUMD        equ      225
GETNUMA        equ      226
OUT1CR         equ      227   ; a5=start; a6=end
TUTOR          equ      228
START          equ      229
PNT8HX         equ      230   ; d0=number; a6=buffer; not restored: d0,d1,d2
PNT6HX         equ      231   ; d0=number; a6=buffer; not restored: d0,d1,d2
PNT4HX         equ      232   ; d0=number; a6=buffer; not restored: d0,d1,d2
PNT2HX         equ      233   ; d0=number; a6=buffer; not restored: d0,d2
PUTHEX         equ      234   ; d0=number; a6=buffer; not restored: d0
GETHEX         equ      235
HEX2DEC        equ      236   ; d0=number; a6=buffer; not restored: d0
PRCRLF         equ      237
TAPEIN         equ      238
TAPEOUT        equ      239
PORTIN20       equ      240
PORTIN1        equ      241
OUTPUT21       equ      242
OUTPUT         equ      243   ; a5=start; a6=end
CHRPRINT       equ      244
INCHE          equ      247
OUTCH          equ      248   ; d0=char; not restored: a0
FIXDCRLF       equ      249
FIXDATA        equ      250
FIXBUF         equ      251
FIXDADD        equ      252
LINKIT         equ      253
;
VEC_IRQ0       equ      $18*4
VEC_IRQ1       equ      $19*4
VEC_IRQ2       equ      $1A*4
VEC_IRQ3       equ      $1B*4
VEC_IRQ4       equ      $1C*4
VEC_IRQ5       equ      $1D*4
VEC_IRQ6       equ      $1E*4
VEC_IRQ7       equ      $1F*4
;
