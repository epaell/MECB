; Tutor TRAP 14 Functions
PORTIN1N       equ      224
GETNUMD        equ      225
GETNUMA        equ      226
OUT1CR         equ      227   ; a5=start; a6=end
TUTOR          equ      228
RESTART        equ      229
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
INCHE          equ      247   ; d0=char; not restored: d1,a0
OUTCH          equ      248   ; d0=char; not restored: a0
FIXDCRLF       equ      249
FIXDATA        equ      250
FIXBUF         equ      251
FIXDADD        equ      252
LINKIT         equ      253
;
VEC_RESET      equ      $01*4 ; 1
VEC_BUSERR     equ      $02*4 ; 2
VEC_ADDRERR    equ      $03*4 ; 3
VEC_ILLEGAL    equ      $04*4 ; 4
VEC_DIV0       equ      $05*4 ; 5
VEC_CHK        equ      $06*4 ; 6
VEC_TRAPV      equ      $07*4 ; 7
VEC_PRIV       equ      $08*4 ; 8
VEC_TRACE      equ      $09*4 ; 9
VEC_1010       equ      $0A*4 ; 10
VEC_1111       equ      $0B*4 ; 11
VEC_FORMAT     equ      $0E*4 ; 12
VEC_BADINT     equ      $0F*4 ; 13
VEC_IRQ0       equ      $18*4 ; 14
VEC_IRQ1       equ      $19*4 ; 15
VEC_IRQ2       equ      $1A*4 ; 16
VEC_IRQ3       equ      $1B*4 ; 17
VEC_IRQ4       equ      $1C*4 ; 18
VEC_IRQ5       equ      $1D*4 ; 19
VEC_IRQ6       equ      $1E*4 ; 20
VEC_IRQ7       equ      $1F*4 ; 21
VEC_TRAP0      equ      $20*4 ; 22
VEC_TRAP1      equ      $21*4 ; 23
VEC_TRAP2      equ      $22*4 ; 24
VEC_TRAP3      equ      $23*4 ; 25     Used by CPM
VEC_TRAP4      equ      $24*4 ; 26
VEC_TRAP5      equ      $25*4 ; 27
VEC_TRAP6      equ      $26*4 ; 28
VEC_TRAP7      equ      $27*4 ; 29
VEC_TRAP8      equ      $28*4 ; 30
VEC_TRAP9      equ      $29*4 ; 31
VEC_TRAP10     equ      $2A*4 ; 32
VEC_TRAP11     equ      $2B*4 ; 33
VEC_TRAP12     equ      $2C*4 ; 34
VEC_TRAP13     equ      $2D*4 ; 35
VEC_TRAP14     equ      $2E*4 ; 36     Used by Tutor
VEC_TRAP15     equ      $2F*4 ; 37
;
