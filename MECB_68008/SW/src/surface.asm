               org      $4000
;
               include  'mecb.inc'
               include  'tutor.inc'
               include  'library_rom.inc'       ; Make use of library routines
               include  'oled.inc'              ; OLED specific definitions
;
start          move.l   #RAM_END+1,a7           ; Set up stack
               jsr      oled_init
;
               jsr      oled_on
;
               move.b   #$00,d0                 ; d0 = fill value
               move.b   #$00,d1                 ; d1 = start row
               move.b   #$3f,d2                 ; d2 = end row
               jsr      oled_fill
;
               bsr      init_constants
               bsr      init_variables
;
               move.l   xm,d7                   ; for x = -xm to xm
               jsr      FFPNEG
               move.l   d7,x
surface        move.l   zm,d7                   ; for y = -zm to zm step 32
               jsr      FFPNEG
               move.l   d7,y
surface0       move.l   x,d7
               move.l   d7,d6
               jsr      FFPMUL                  ; d7 = x * x
               move.l   d7,d2                   ; d2 = x * x
               move.l   y,d7
               move.l   d7,d6
               jsr      FFPMUL                  ; d7 = y * y
               move.l   d2,d6
               jsr      FFPADD                  ; d7 = x * x + y * y
               jsr      FFPSQRT                 ; d7 = sqrt(x * x + y * y)
               move.l   ri,d6
               jsr      FFPMUL                  ; d7 = ri * sqrt(x * x + y * y)
               move.l   d7,kr                   ; kr = ri * sqr(x * x + y * y)
               move.l   d7,d6
               jsr      FFPSIN                  ; d7 = sin(kr)
               jsr      FFPDIV                  ; d7 = sin(kr)/kr
               move.l   ym,d6
               jsr      FFPMUL                  ; d7 = ym * sin(kr)/kr
               move.l   ct,d6
               jsr      FFPMUL                  ; d7 = ct * ym * sin(kr)/kr
               move.l   d7,d2                   ; d2 = ct * ym * sin(kr) / kr
               move.l   y,d6
               move.l   st,d7
               jsr      FFPMUL                  ; d7 = y * st
               move.l   d2,d6
               jsr      FFPADD                  ; d7 = y * st + ct * ym * sin(kr) / kr
               move.l   d7,sy                   ; sy = y * st + ct * ym * sin(kr) / kr
               move.l   zm,d7                   ; if y == -zm
               JSR      FFPNEG                  ; d7 = -zm
               move.l   y,d6
               JSR      FFPCMP                  ; 
               bne      surface1
               move.l   sy,miny                 ;     miny=sy; maxy=sy
               move.l   sy,maxy
surface1       move.l   maxy,d6
               move.l   sy,d7
               jsr      FFPCMP
               ble      surface2                ; if sy>maxy
               move.l   sy,maxy                 ; maxy = sy
               bsr      do_plot
surface2       move.l   miny,d6
               move.l   sy,d7
               jsr      FFPCMP
               ble      surface3                ; if sy<miny
               move.l   sy,miny                 ; miny = sy
               bsr      do_plot
surface3       move.l   y,d6                    ; y += 32
               move.l   ffp32,d7
               jsr      FFPADD
               move.l   d7,y
               move.l   zm,d6
               jsr      FFPCMP
               blt      surface0                ; if y<zm next y
               move.l   x,d6                    ; x += 1
               move.l   ffp1,d7
               jsr      FFPADD
               move.l   d7,x
               move.l   xm,d6
               jsr      FFPCMP
               blt      surface                 ; next x
;
test_end       move.b   #TUTOR,d7
               trap     #14
;
; RESULT DISPLAY SUBROUTINE
;   INPUT IS FLOAT IN D7
result         movem.l  d7/a0-a1,-(a7)
               jsr      FFPFPA
               move.l   #'LT: ',-(a7)          ; MOVE RESULT HEADER
               MOVE.L   #'RESU',-(a7)          ; ONTO STACK
               lea      (a7),a0                ; POINT TO MESSAGE
               lea      14+8(a7),a1            ; POINT TO END OF MESSAGE
               bsr.s    put                    ; ISSUE TO CONSOLE
               lea      14+8(a7),a7            ; GET RID OF CONVERSION AND HEADING
               bsr.s    msg                    ; PUT BLANK LINE OUT
               dc.b     '        '
               movem.l  (a7)+,d7/a0-a1
               rts                             ; RETURN TO CALLER

* DISPLAY CHARACTER IN D0

charout        MOVEM.L  A0/D7,-(A7)
               MOVE.B   #OUTCH,D7
               TRAP     #14
               MOVEM.L  (A7)+,A0/D7
               RTS

*   *
*   * MSG SUBROUTINE
*   *  INPUT: (SP) POINT TO EIGHT BYTE TEXT FOLLOWING BSR/JSR
*   *
msg            MOVEM.L  D0/A0/A1,-(SP)        ; SAVE REGS
               MOVE.L   3*4(SP),A0            ; LOAD RETURN POINTER
               LEA      7(A0),A1              ; POINT TO BUFFER END
               BSR.S    put                   ; ISSUE I/O CALL
               MOVEM.L  (SP)+,D0/A0/A1        ; RELOAD REGISTERS
               ADD.L    #8,(SP)               ; ADJUST RETURN ADDRESS
               RTS                            ; RETURN TO CALLER

*   *
*   * PUT SUBROUTINE
*   *  INPUT: A0->TEXT START, A1->TEXT END
*   *

put            MOVEM.L  D0/A0,-(SP)           ; SAVE REGS
put1           MOVE.B   (A0)+,D0
               BSR      charout
               CMP.L    A1,A0
               BLS      put1
               MOVE.B   #13,D0                ; CARRIAGE RETURN
               BSR      charout
               MOVE.B   #10,D0                ; LINE FEED
               BSR      charout
               MOVEM.L  (SP)+,D0/A0           ; RELOAD REGISTERS
               RTS                            ; RETURN TO CALLER
;
; plot pixel
;
do_plot        movem.l  d6-d7/a0,-(a7)
;
               move.l   xoff,d6
               move.l   x,d7
               jsr      FFPADD                     ; d7 = x + xoff
               move.l   ffp2,d6
               jsr      FFPMUL                     ; d7 = 2 * (x + xoff)
               move.l   d7,px                      ; px = 2 * (x + xoff)
               move.l   xw,d6
               jsr      FFPMUL                     ; d7 = px * xw
               move.l   ffp1280,d6
               jsr      FFPDIV                     ; d7 = px * xw / 1280
               jsr      FFPFPI                     ; d7 = int(px * xw / 1280)
               move.l   d7,ipx                     ; ipx = int(px*xw/1280)
;
               move.l   yoff,d7
               move.l   sy,d6
               jsr      FFPSUB                     ; d7 = yoff-sy
               move.l   ffp2,d6
               jsr      FFPMUL                     ; d7 = 2 * (yoff-sy)
               move.l   d7,py                      ; py = 2 * (yoff-sy)
               move.l   yw,d6
               jsr      FFPMUL                     ; d7 = py * yw
               move.l   ffp960,d6
               jsr      FFPDIV                     ; d7 = py * yw / 960
               jsr      FFPFPI                     ; d7 = int(py * yw / 960)
               move.l   d7,ipy                     ; ipy = int(py * yw / 960)
               move.l   #pixel,a0
               move.b   d7,OLED_Y(a0)              ; store x
               move.l   ipx,d6
               move.b   d6,OLED_X(a0)              ; store y
               move.b   #$0f,OLED_C(a0)            ; full brightness
               move.b   #OLED_PSET,OLED_L(a0)      ; set pixel
               jsr      oled_pixel                 ; draw the pixel
               movem.l  (a7)+,d6-d7/a0
               rts
               
;
; convert strings to FFP constants
;
init_constants move.l   d7,-(a7)
               lea.l    n0p05,a0
               jsr      FFPAFP
               move.l   d7,ffp0p05
;
               lea.l    n1,a0
               jsr      FFPAFP
               move.l   d7,ffp1
;
               lea.l    n2,a0
               jsr      FFPAFP
               move.l   d7,ffp2
;
               lea.l    npi,a0
               jsr      FFPAFP
               move.l   d7,ffppi
;
               lea.l    n32,a0
               jsr      FFPAFP
               move.l   d7,ffp32
;
               lea.l    n34,a0
               jsr      FFPAFP
               move.l   d7,ffp34
;
               lea.l    n64,a0
               jsr      FFPAFP
               move.l   d7,ffp64
;
               lea.l    n128,a0
               jsr      FFPAFP
               move.l   d7,ffp128
;
               lea.l    n180,a0
               jsr      FFPAFP
               move.l   d7,ffp180
;
               lea.l    n240,a0
               jsr      FFPAFP
               move.l   d7,ffp240
;
               lea.l    n290,a0
               jsr      FFPAFP
               move.l   d7,ffp290
;
               lea.l    n320,a0
               jsr      FFPAFP
               move.l   d7,ffp320
;
               lea.l    n400,a0
               jsr      FFPAFP
               move.l   d7,ffp400
;
               lea.l    n960,a0
               jsr      FFPAFP
               move.l   d7,ffp960
;
               lea.l    n1280,a0
               jsr      FFPAFP
               move.l   d7,ffp1280
;
               move.l   (a7)+,d7
               rts
;
; init variables
;
init_variables move.l   ffp128,xw   ; xw = 128.0
               move.l   ffp64,yw    ; yw = 64.0
               move.l   ffp320,xoff ; xoff = 320.0
               move.l   ffp240,yoff ; yoff = 240.0
               move.l   ffppi,pie   ; pie = 3.1415926
               move.l   ffp0p05,ri  ; ri = 0.05
               move.l   ffp320,xm   ; xm = 320.0
               move.l   ffp400,zm   ; zm = 400.0
               move.l   ffp290,ym   ; ym = 290.0
               move.l   ffp34,tilt  ; tilt = 34.0
               move.l   pie,d7
               move.l   ffp180,d6
               jsr      FFPDIV
               move.l   tilt,d6
               jsr      FFPMUL
               jsr      FFPSINCS
               move.l   d6,st       ; st = sin((pie/180.0)*tilt)
               move.l   d7,ct       ; ct = cos((pie/180.0)*tilt)
               rts
               
;
; FFP variables
;
xw             ds.l     1
yw             ds.l     1
xoff           ds.l     1
yoff           ds.l     1
pie            ds.l     1
ri             ds.l     1
xm             ds.l     1
zm             ds.l     1
ym             ds.l     1
tilt           ds.l     1
st             ds.l     1
ct             ds.l     1
x              ds.l     1
y              ds.l     1
kr             ds.l     1
sy             ds.l     1
miny           ds.l     1
maxy           ds.l     1
py             ds.l     1
px             ds.l     1
ipy            ds.l     1
ipx            ds.l     1
ix             ds.l     1
iy             ds.l     1
;
; FFP contants
;
ffp0p05        ds.l     1
ffp1           ds.l     1
ffp2           ds.l     1
ffppi          ds.l     1
ffp32          ds.l     1
ffp34          ds.l     1
ffp64          ds.l     1
ffp128         ds.l     1
ffp180         ds.l     1
ffp240         ds.l     1
ffp290         ds.l     1
ffp320         ds.l     1
ffp400         ds.l     1
ffp960         ds.l     1
ffp1280        ds.l     1

;
; Structure for pixel drawing
;
pixel          ds.b     1              ; x
               ds.b     1              ; y
               ds.b     1              ; colour
               ds.b     1              ; logical function
;
; Structure for line drawing
;
line           ds.b     1              ; x1
               ds.b     1              ; y1
               ds.b     1              ; x2
               ds.b     1              ; y2
               ds.b     1              ; colour
               ds.b     1              ; logical function
;
;constants
n0p05          dc.b     '0.05 '
n1             dc.b     '1.0 '
n2             dc.b     '2.0 '
npi            dc.b     '3.1415926 '
n32            dc.b     '32.0 '
n34            dc.b     '34.0 '
n64            dc.b     '64.0 '
n128           dc.b     '128.0 '
n180           dc.b     '180.0 '
n240           dc.b     '240.0 '
n290           dc.b     '290.0 '
n320           dc.b     '320.0 '
n400           dc.b     '400.0 '
n960           dc.b     '960.0 '
n1280          dc.b     '1280.0 '

               end
