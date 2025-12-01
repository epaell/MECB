               include  'oled.inc'
;
oled_init      movem.l  d0-d1/a0,-(a7)       ; save registers
               lea.l    OLED_INIT_CMDS(pc),a0   ; point to initialisation command table
oled_init1     move.b   (a0)+,d0             ; get a command
               beq      oled_init2
               move.b   d0,OLED_CMD          ; Send to OLED
               move.b   (a0)+,d0             ; get a parameter
               move.b   d0,OLED_CMD          ; Send to OLED
               bra      oled_init1           ; loop if more commands to send
;
oled_init2     movem.l  (a7)+,d0-d1/a0       ; restore registers
               rts
;
oled_on        move.b   #$AF,OLED_CMD        ; Turn on the display
               rts
;
oled_off       move.b   #$AE,OLED_CMD        ; Turn on the display
               rts
;
; Support Subroutines
; -------------------
;
; Function:	Set the Display buffer Column Start and End addresses (128x64 res)
; Parameters:  d0 - Start column (0 - 127)
;              d1 - End column  (0 - 127)
; Returns:     -
; Destroys:    -
oled_set_col   move.l   d0,-(a7)          ; Save d0
               move.b   #$15,OLED_CMD     ; Set column address command
               lsr.b    #1,d0             ; column/2 (2 pixels per byte)
               move.b   d0,OLED_CMD       ; write start column
               move.b   d1,d0
               lsr.b    #1,d0             ; column/2 (2 pixels per byte)
               move.b   d0,OLED_CMD       ; write end column
               move.l   (a7)+,d0          ; Restore d0
               rts
;
; Function:	Set the Display buffer Row Start and End addresses (128x64 res)
; Parameters:  d0 - Start row (0 - 63)
;              d1 - End row (0 - 63) 
; Returns:     -
; Destroys:    -
oled_set_row   move.b   #$75,OLED_CMD     ; Set row address command
               move.b   d0,OLED_CMD       ; row start
               move.b   d1,OLED_CMD       ; row end
               rts
;
; Draw line from (lx1, ly1) to (lx2, ly2)
; Parameters:  a0 - points to structure containing:
;              OLED_LX1(a0) - x1 coord (0 - 127)
;              OLED_LY1(a0) - y1 coord (0 - 63)
;              OLED_LX2(a0) - x2 coord (0 - 127)
;              OLED_LY2(a0) - y2 coord (0 - 63)
;              OLED_LC(a0) - colour (0 - 15)
oled_sline      rts

;
; Subroutines
; -----------
;
; Draw line from (lx1, ly1) to (lx2, ly2)
; Parameters:  a0 - points to structure containing:
;              OLED_LX1(a0) - x1 coord (0 - 127)
;              OLED_LY1(a0) - y1 coord (0 - 63)
;              OLED_LX2(a0) - x2 coord (0 - 127)
;              OLED_LY2(a0) - y2 coord (0 - 63)
;              OLED_LC(a0) - colour (0 - 15)
;              OLED_LL(a0) - logical function (OLED_PSET, OLED_POR, OLED_PEOR, OLED_PAND)
; 
; Intermediate variables:
; d1 - dx
; d2 - dy
; d3 - error
; d4 - steep
; 0(a7) - lx1
; 1(a7) - ly1
; 2(a7) - lx2
; 3(a7) - ly2
; 4(a7) - lx
; 5(a7) - ly
; 6(a7) - stepy
; 7(a7) - x
; 8(a7) - y
; 9(a7) - c
; 10(a7) - l
TX1            equ      0
TY1            equ      1
TX2            equ      2
TY2            equ      3
TLX            equ      4
TLY            equ      5
TSTEPY         equ      6
TVX            equ      7
TVY            equ      8
TC             equ      9
TL             equ      10
;
oled_line      movem.l  d0-d5/a0,-(a7)       ; Save registers
               lea.l    -12(a7),a7           ; Make space for intermediate variables
               move.b   OLED_LX1(a0),TX1(a7) ; Copy across line parameters, lx1=x1
               move.b   OLED_LY1(a0),TY1(a7) ; ly1 = y1
               move.b   OLED_LX2(a0),TX2(a7) ; lx2 = x2
               move.b   OLED_LY2(a0),TY2(a7) ; ly2 = y2
               move.b   OLED_LC(a0),TC(a7)   ; Copy pixel drawing attributes c=lc
               move.b   OLED_LL(a0),TL(a7)   ; l = tl
               move.b   TX2(a7),d1
               sub.b    TX1(a7),d1           ; d1 = dx = abs(x2-x1)
               bcc      line2
               neg.b    d1                   ; if d1<0 d1=-d1
line2          move.b   TY2(a7),d2
               sub.b    TY1(a7),d2           ; d2 = dy = abs(y2-y1)
               bcc      line2a
               neg.b    d2                   ; if d2<0 d2=-d2
line2a         move.b   #0,d4                ; clear steep flag
               cmp.b    d1,d2                ; compare d2/dy with d1/dx
               bls      line3
               add.b    #1,d4                ; set steep flag
               move.b   OLED_LX1(a0),TY1(a7) ; swap x1,x2 with y1,y2
               move.b   OLED_LY1(a0),TX1(a7)
               move.b   OLED_LX2(a0),TY2(a7)
               move.b   OLED_LY2(a0),TX2(a7)
line3          move.b   TX1(a7),d0           ; if (x1>x2)
               cmp.b    TX2(a7),d0
               bgt      line_rev             ; reversed
;
               lea.l    TVX(a7),a0           ; set up pointer to pixel parameters
               move.b   TX2(a7),d1           ; dx = x2 - x1
               sub.b    TX1(a7),d1
               move.b   d1,d3
               lsr.b    #1,d3                ; error = (dx >> 1)
               move.b   TY2(a7),d2           ; dy = abs(y2-y1)
               sub.b    TY1(a7),d2
               bcc      line4
               neg.b    d2                   ; if dy<0 dy=-dy
line4          move.b   #0,TSTEPY(a7)        ; stepy = 0
               move.b   TY1(a7),d0           ; ly = y1
               move.b   d0,TLY(a7)
               cmp.b    TY2(a7),d0
               blt      line5
               move.b   #$ff,TSTEPY(a7)      ; if y1 >= y2 stepy = -1
               bra      line6
;
line5          move.b   #1,TSTEPY(a7)        ; else stepy = 1
line6          move.b   TX1(a7),TLX(a7)
;
line6a         tst.b    d4                   ; check steep flag
               beq      line7
               move.b   TLY(a7),TVX(a7)
               move.b   TLX(a7),TVY(a7)
               bra      line8                ; plot(ly, lx)
line7          move.b   TLX(a7),TVX(a7)      ; else plot(lx, ly)
               move.b   TLY(a7),TVY(a7)
line8          bsr      oled_pixel
               sub.b    d2,d3                ; error -= dy
               bge      line9
               move.b   TSTEPY(a7),d0
               add.b    d0,TLY(a7)           ; if error < 0 ly += ystep
               add.b    d1,d3                ; error += dx
line9          move.b   TLX(a7),d0
               cmp.b    TX2(a7),d0
               beq      ldone
               add.b    #1,TLX(a7)           ; lx += 1
               bra      line6a
ldone          lea.l    12(a7),a7            ; deallocate stack work area
               movem.l  (a7)+,d0-d5/a0       ; restore registers
               rts
;
line_rev       move.b   TX1(a7),d0           ; Reverse, x1, x2 = x2, x1
               move.b   TX2(a7),TX1(a7)
               move.b   d0,TX2(a7)
               move.b   TY1(a7),d0           ; y1, y2 = y2, y1
               move.b   TY2(a7),TY1(a7)
               move.b   d0,TY2(a7)
;
               move.b   TX2(a7),d1           ; dx = x2 - x1
               sub.b    TX1(a7),d1
               move.b   d1,d3
               lsr.b    #1,d3                ; error = (dx >> 1)
               lea.l    TVX(a7),a0           ; set up pointer to pixel parameters
               move.b   TY2(a7),d2
               sub.b    TY1(a7),d2           ; dy = abs(y2-y1)
               bcc      liner4
               neg.b    d2                   ; if dy<0 dy=-dy
liner4         move.b   #0,TSTEPY(a7)        ; stepy = 0
               move.b   TY2(a7),d0
               move.b   d0,TLY(a7)           ; ly = y2
               cmp.b    TY1(a7),d0
               blt      liner5
               move.b   #1,TSTEPY(a7)        ; if y1 < y2 stepy = 1
               bra      liner6
;
liner5         move.b   #$ff,TSTEPY(a7)      ; else stepy = -1
liner6         move.b   TX2(a7),TLX(a7)      ; lx = x2
liner6a        tst.b    d4                   ; if steep
               beq      liner7
               move.b   TLY(a7),TVX(a7)
               move.b   TLX(a7),TVY(a7)
               bra      liner8               ; plot(ly, lx)
liner7         move.b   TLX(a7),TVX(a7)      ; else plot(lx, ly)
               move.b   TLY(a7),TVY(a7)
liner8         bsr      oled_pixel
               sub.b    d2,d3                ; error -= dy
               bgt      liner9
               move.b   TSTEPY(a7),d0
               sub.b    d0,TLY(a7)           ; ly += stepy
               add.b    d1,d3                ; error += dx
liner9         move.b   TLX(a7),d0
               cmp.b    TX1(a7),d0
               beq      liner_done
               sub.b    #1,TLX(a7)           ; lx -= 1
               bra      liner6a
liner_done     lea.l    12(a7),a7            ; deallocate stack work area
               movem.l  (a7)+,d0-d5/a0       ; restore registers
               rts

;
; Function:    Set the Pixel at X,Y colour C
; Parameters:  d0 - X coord (0 - 127)
;              d1 - Y coord (0 - 63)
;              d2 - colour = 0 - 15
; Returns:     -
; Destroys:    -
oled_spixel    movem.l  d0-d3,-(a7)
               move.b   #$75,OLED_CMD        ; Set Row Address Command
               move.b   d1,OLED_CMD          ; Start row (top)
               move.b   d1,OLED_CMD          ; End row (bottom) = Start row
;
               move.b   #$15,OLED_CMD        ; Set Column Address Command
               move.b   d0,d3                ; D3=x
               lsr.b    #1,d0                ; Div A by 2 (2 pixels per byte)
               move.b   d0,OLED_CMD          ; Start column (left)
               move.b   d0,OLED_CMD          ; End column address (right) = Start column
;
               move.b   OLED_DTA,d0          ; Dummy Read
               move.b   OLED_DTA,d0          ; Read pixel data
               btst     #0,d3                ; Test if we're updating odd column?
               beq      oled_spixel1         ;
               and.b    #$F0,d0              ; Mask out odd column
               or.b     d2,d0                ; Set for odd column pixel
               bra      oled_spixel2            ;
oled_spixel1   and.b    #$0F,d0              ; Mask out even column
               lsl.b    #4,d2                ; Move colour to upper nybble
               or.b     d2,d0                ; Set for even column pixel
oled_spixel2   move.b   d0,OLED_DTA
               movem.l  (a7)+,d0-d3
               rts

;
; Function:    Set the Pixel at x,y with given logical function and colour
; Parameters:  a0 - points to structure containing:
;              OLED_X(a0) - x coord (0 - 127)
;              OLED_Y(a0) - y coord (0 - 63)
;              OLED_C(a0) - colour (0 - 15)
;              OLED_L(a0) - logical function (OLED_PSET, OLED_POR, OLED_PEOR, OLED_PAND)
; Returns:     -
; Destroys:    -
oled_pixel     movem.l  d0-d2,-(a7)
               move.b   #$75,OLED_CMD        ; Set Row Address Command
               move.b   OLED_Y(a0),OLED_CMD  ; Start row (top)
               move.b   OLED_Y(a0),OLED_CMD  ; End row (bottom) = Start row

               move.b   #$15,OLED_CMD        ; Set Column Address Command
               move.b   OLED_X(a0),d0
               lsr.b    #1,d0                ; Div A by 2 (2 pixels per byte)
               move.b   d0,OLED_CMD          ; Start column (left)
               move.b   d0,OLED_CMD          ; End column address (right) = Start column

               move.b   OLED_DTA,d0          ; Dummy Read
               move.b   OLED_DTA,d0          ; Read pixel data
               move.b   d0,d1                ; keep copy of [even|odd] pixel in d1
               btst.b   #0,OLED_X(a0)        ; Test if we're updating odd column?
               beq      oled_pixel1          ;
               and.b    #$0f,d0              ; Get the current pixel value
               and.b    #$f0,d1              ; Keep "other" pixel in d2 (needs to remain intact within the byte)
               bra      oled_pixel2          ;
oled_pixel1    lsr.b    #4,d0                ; Current pixel value in lower nybble of d0
               and.b    #$0f,d1              ; Keep "other" pixel in d2
oled_pixel2    cmp.b    #OLED_PSET,OLED_L(a0) 
               bne      oled_pixel3
               move.b   OLED_C(a0),d0        ; For PSET, pixel = colour
               bra      oled_pixel6
oled_pixel3    cmp.b    #OLED_POR,OLED_L(a0) 
               bne      oled_pixel4
               or.b     OLED_C(a0),d0        ; For POR, pixel = pixel | colour
               bra      oled_pixel6
oled_pixel4    cmp.b    #OLED_PEOR,OLED_L(a0) 
               bne      oled_pixel5
               move.b   OLED_C(a0),d2
               eor.b    d2,d0                ; For PEOR, pixel = pixel ^ colour
               bra      oled_pixel6
oled_pixel5    and.b    OLED_C(a0),d0
oled_pixel6    btst     #0,OLED_X(a0)        ; For PAND, pixel = pixel & colour
               bne      oled_pixel7
               lsl.b    #4,d0                ; If it was even, shift it back in place
oled_pixel7    add.b    d1,d0                ; combine with "other" pixel
               move.b   d0,OLED_DTA
               movem.l  (a7)+,d0-d2
               rts

;
; Function:    Fill OLED display VRAM with byte, from a specified start row
; Parameters:  d0 - Byte to fill OLED buffer with
;              d1 - Start row
;              d2 - End row
; Returns:     -
; Destroys:    -
oled_fill      movem.l  d0-d3,-(a7)    ; Save registers
               move.b   d0,d3          ; d3 = fill
;
               move.b   d1,d0          ; start row
               move.b   d2,d1          ; end row
               bsr      oled_set_row   ; set the row range
               sub.b    d0,d1          ; number of rows to fill
               add.b    #1,d1
               and.l    #$ff,d1        ; mask off high order bits
               lsl.l    #6,d1          ; Multiple by 64 bytes per row
               move.l   d1,d2          ; Count of bytes to fill in d2
;
               move.b   #0,d0          ; start column = 0
               move.b   #$7f,d1        ; end column = 127
               bsr      oled_set_col   ; set the column range
;
oled_fill1     move.b   d3,OLED_DTA    ; Write fill byte to curent buffer location
               sub.w    #1,d2          ; Dec byte counter
               bne      oled_fill1     ; Done?
               movem.l  (a7)+,d0-d3    ; Restore registers
               rts
;
; Function:    Fill OLED display VRAM data pointed to by a0
; Parameters:  -
; Returns:     -
; Destroys:    -
oled_move      movem.l  d0-d1/a0,-(a7)    ; Save registers
               move.b   #0,d0             ; start row
               move.b   #$3f,d1           ; end row
               bsr      oled_set_row      ; set the row range
               move.b   #0,d0             ; start column = 0
               move.b   #$7f,d1           ; end column = 127
               bsr      oled_set_col      ; set the column range
               move.w   #64*64,d0         ; number of bytes to transfer 128 x 64 / 2 (pixels per byte)
;
oled_move1     move.b   (a0)+,OLED_DTA    ; Move byte to current VRAM location
               sub.w    #1,d0             ; Dec byte counter
               bne      oled_move1        ; Done?
               movem.l  (a7)+,d0-d1/a0    ; Restore registers

;
; Draw circle (not implemented yet)
;
oled_scircle   rts
;
;
; Function:    Draw a circle at x,y with radius r given logical function and colour
; Parameters:  a0 - points to a circle structure containing:
;              OLED_CY(a0) - x coord (0 - 127)
;              OLED_CY(a0) - y coord (0 - 63)
;              OLED_CR(a0) - r radius (0 - ?)
;              OLED_CC(a0) - colour (0 - 15)
;              OLED_CL(a0) - logical function (OLED_PSET, OLED_POR, OLED_PEOR, OLED_PAND)
; Returns:     -
; Destroys:    -
; Intermediate variables:
; 0(a7) - TX
; 2(a7) - TY
; 4(a7) - TSWITCH
; 10(a7) - VX   for pixel drawing
; 11(a7) - VY
; 12(a7) - VC
; 13(a7) - VL
;
TCX            equ      0
TCY            equ      2
TCSWITCH       equ      4
TCVX           equ      10
TCVY           equ      11
TCVC           equ      12
TCVL           equ      13
;
oled_circle    movem.l  d0/a0-a1,-(a7)          ; save registers
               lea.l    -16(a7),a7              ; Make space for intermediate variables
               move.l   a0,a1                   ; a1 points to the circle data structure
               lea.l    TCVX(a7),a0             ; a0 points to the pixel data structure
               
               move.b   OLED_CC(a1),TCVC(a7)    ; set up colour for pixels
               move.b   OLED_CL(a1),TCVL(a7)    ; set up logic function for drawing
               move.w   #0,TCX(a7)              ; tx = 0
               move.w   OLED_CR(a1),TCY(a7)     ; ty = r
               move.w   #3,d0
               sub.w    OLED_CR(a1),d0
               sub.w    OLED_CR(a1),d0
               move.w   d0,TCSWITCH(a7)         ; tswitch = 3 - 2 * r
               move.w   OLED_CX(a1),d0          ; tvx = tx - ty
               sub.w    TCY(a7),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0          ; d4 = cy - tx
               sub.w    TCX(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(cx-ty, cy-tx)
               
oled_circle1   move.w   TCX(a7),d0
               cmp.w    TCY(a7),d0              ; cmp ty,tx
               bgt      oled_circle7
               move.w   OLED_CX(a1),d0          ; if tx <= ty
               add.w    TCX(a7),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0
               sub.w    TCY(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(tx + cx, -ty + cy)
               
               move.w   TCX(a7),d0
               cmp.w    TCY(a7),d0
               beq      oled_circle2
               move.w   TCY(a7),d0               ; if tx != ty
               add.w    OLED_CX(a1),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0
               sub.w    TCX(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(ty + cx, -tx + cy)
               
oled_circle2   tst.w    TCX(a7)
               beq      oled_circle3
               move.w   TCY(a7),d0              ; if tx != 0
               add.w    OLED_CX(a1),d0
               move.b   d0,TCVX(a7)
               move.w   TCX(a7),d0
               add.w    OLED_CY(a1),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(ty + cx,  tx + cy)
               
               tst.w    TCY(a7)
               beq      oled_circle3
               move.w   OLED_CX(a1),d0          ; if ty != 0
               sub.w    TCX(a7),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0
               add.w    TCY(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(-tx + cx,  ty + cy)
               
               move.w   OLED_CX(a1),d0
               sub.w    TCY(a7),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0
               sub.w    TCX(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(-ty + cx, -tx + cy)
               
               move.w   TCX(a7),d0
               cmp.w    TCY(a7),d0
               beq      oled_circle3

               move.w   OLED_CX(a1),d0          ; if tx != ty
               sub.w    TCY(a7),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0
               add.w    TCX(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(-ty + cx,  tx + cy)

               move.w   OLED_CX(a1),d0
               sub.w    TCX(a7),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0
               sub.w    TCY(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(-tx + cx, -ty + cy)
               
oled_circle3   tst.w    TCY(a7)
               beq      oled_circle4
               move.w   TCY(a7),d0
               cmp.w    TCX(a7),d0
               beq      oled_circle4
               
               move.w   OLED_CX(a1),d0          ; if ty != 0 and tx != ty
               add.w    TCX(a7),d0
               move.b   d0,TCVX(a7)
               move.w   OLED_CY(a1),d0
               add.w    TCY(a7),d0
               move.b   d0,TCVY(a7)
               jsr      oled_pixel              ; plot(tx + cc,  ty + cy)
               
oled_circle4   tst.w    TCSWITCH(a7)
               bge      oled_circle5
               move.w   TCX(a7),d0              ; if tswitch < 0:
               asl.w    #2,d0
               add.w    #6,d0
               add.w    TCSWITCH(a7),d0
               move.w   d0,TCSWITCH(a7)         ; tswitch += (4 * tx) + 6
               bra      oled_circle6
oled_circle5   move.w   TCX(a7),d0              ; else:
               sub.w    TCY(a7),d0
               asl.w    #2,d0
               add.w    #10,d0
               add.w    TCSWITCH(a7),d0
               move.w   d0,TCSWITCH(a7)         ; tswitch += (4 * (tx - ty)) + 10
               sub.w    #1,TCY(a7)              ; ty -= 1
oled_circle6   add.w    #1,TCX(a7)              ; tx += 1
               bra      oled_circle1
oled_circle7   lea.l    16(a7),a7               ; Deallocate space for intermediate variables
               movem.l  (a7)+,d0/a0-a1
               rts
;
; oled_char - write character (faster, not implemented yet)
;
oled_schar     rts
;
; oled_char - write character
; Parameters:  d0 - the ASCII character to write
;              a0 - points to structure containing:
;              OLED_TX(a0) - x1 coord (0 - 127)
;              OLED_TY(a0) - y1 coord (0 - 63)
;              OLED_TFC(a0) - foreground colour (0 - 15)
;              OLED_TBC(a0) - background colour (0 - 15)
;              OLED_TL(a0) - logical function (OLED_PSET, OLED_POR, OLED_PEOR, OLED_PAND)
;              OLED_TF(a0) - pointer to font to use
OLED_CHAR_X    equ         $00
OLED_CHAR_Y    equ         $01
OLED_CHAR_C    equ         $02
OLED_CHAR_L    equ         $03
;
oled_char      movem.l     a0-a2/d0-d2,-(a7)             ; Save registers
               lea.l       -4(a7),a7                     ; Make space for work variables
               move.b      OLED_TX(a0),OLED_CHAR_X(a7)   ; Copy start x
               move.b      OLED_TY(a0),OLED_CHAR_Y(a7)   ; Copy start y
               move.b      OLED_TL(a0),OLED_CHAR_L(a7)   ; Copy logical function
               lea.l       OLED_CHAR_X(a7),a2            ; a2 holds pixel structure location
               and.l       #$ff,d0
               lsl.l       #3,d0                         ; 8 bytes per character definition in font
               move.l      OLED_TF(a0),a1                ; Pointer to the font definition
               add.l       d0,a1                         ; Offset to the character
               move.b      #8,d0                         ; number of font bytes to read
oled_char_byte move.b      #6,d1                         ; number of bits to write
               move.b      (a1)+,d2                      ; read a byte
oled_char_bit  asl.b       #1,d2                         ; get a bit
               bcc         oled_char_off
               move.b      OLED_TFC(a0),OLED_CHAR_C(a7)  ; If on pixel then set the foreground colour
               bra         oled_char_draw
oled_char_off  move.b      OLED_TBC(a0),OLED_CHAR_C(a7)  ; If off pixel then set background colour
oled_char_draw exg.l       a0,a2
               bsr         oled_pixel
               exg.l       a0,a2
               add.b       #1,OLED_CHAR_X(a7)            ; next pixel across
               sub.b       #1,d1                         ; more bits to write
               bne         oled_char_bit
               sub.b       #1,d0                         ; move to next byte
               beq         oled_char_done
               sub.b       #6,OLED_CHAR_X(a7)            ; reset x position
               add.b       #1,OLED_CHAR_Y(a7)            ; move to next row
               bra         oled_char_byte
oled_char_done add.b       #6,OLED_TX(a0)                ; update the x position
               lea.l       4(a7),a7                      ; deallocate temporary space
               movem.l     (a7)+,a0-a2/d0-d2             ; restore registers
               rts
;
; oled_sstr - write a string (faster, not implemented yet)
;
oled_sstr      rts
;
; oled_str - write a string
; Parameters:  a1 - the ASCII character to write (NULL terminated)
;              a0 - points to structure containing:
;              OLED_TX(a0) - x1 coord (0 - 127)
;              OLED_TY(a0) - y1 coord (0 - 63)
;              OLED_TFC(a0) - foreground colour (0 - 15)
;              OLED_TBC(a0) - background colour (0 - 15)
;              OLED_TL(a0) - logical function (OLED_PSET, OLED_POR, OLED_PEOR, OLED_PAND)
;              OLED_TF(a0) - pointer to font to use
oled_str       movem.l     d0/a1,-(a7)
oled_str_loop  move.b      (a1)+,d0
               beq         oled_str_done
               cmp.b       #$0d,d0                       ; Carriage return?
               bne         oled_str_nocr
               move.b      #0,OLED_TX(a0)                ; Carriage return, move to beginning of line
               bra         oled_str_loop
oled_str_nocr  cmp.b       #$0a,d0                       ; Line feed?
               beq         oled_str_lf
oled_str_nolf  bsr         oled_char
               cmp.b       #$7f-5,OLED_TX(a0)
               blt         oled_str_xok
               move.b      #0,OLED_TX(a0)                ; move to start of next line
oled_str_lf    add.b       #8,OLED_TY(a0)
oled_str_xok   cmp.b       #$3f-7,OLED_TY(a0)            ; check if no space for writing line
               blt         oled_str_loop
               move.b      #0,OLED_TY(a0)                ; move to top of page
               bra         oled_str_loop
oled_str_done  movem.l     (a7)+,d0/a1
               rts
;
;
; Data Structures
; ---------------
OLED_INIT_CMDS dc.b  $B3,$70              ; Set Clk Divider / Osc Frequency
               dc.b  $A0,$51              ; Set appropriate Display re-map
               dc.b  $D5,$62              ; Enable second pre-charge
               dc.b  $81,$FF              ; Set contrast (0 - $FF)
               dc.b  $B1,$74              ; Set phase length - Phase 1 = 4 DCLK / Phase 2 = 7 DCLK
               dc.b  $B6,$0F              ; Set second pre-charge period
               dc.b  $BC,$07              ; Set pre-charge voltage - 0.613 x Vcc
               dc.b  $BE,$07              ; Set VCOMH - 0.86 x Vcc
               dc.b  $00,$00              ; End of table
               dc.b  $00,$00              ; Long word align

;
; Commands
;
; $15 <col_start> <col_end>   - Set column address 
; $75 <row_start> <row_end>   - Set row address
; $81 <contrast>              - Set contrast
; $84-$86                     - NOP
; $A0                         - Set Re-map
; $A1 <start_row>             - Set Display start line
; $A2 <offset>                - Set display offset
; $A4                         - Set normal display mode ON
; $A5                         - Set Entire Display ON
; $A6                         - Set display OFF
; $A7                         - Invert display
; $A8 <ratio>                 - Set multiplex ratio
; $AB <vdd>                   - Function selection A
; $AE                         - Set display on
; $AF                         - Set display off
; $B1 <phase>                 - Set phase length
; $B2                         - NOP
; $B3 <ratio>                 - Set front clock divier / oscillator frequency
; $B5 <data>                  - Set GPIO
; $B6 <period>                - Set second pre-charge period
; $B8 <GS1-GS15>              - Set grey scale setting
; $B9                         - Select linear Gray scale table
; $BB                         - NOP
; $BC <voltage>               - Set pre-charge voltage
; $BE <level>                 - Set Vcomh voltage
; $D5 <value>                 - Function selection B
; $FD <value>                 - Set command lock
; $26                         - horizontal scroll setup
; $27                         - horizontal scroll setup
; $2E                         - Deactivate scroll
; $2F                         - Activate scroll