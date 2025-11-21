               org      $4000
;
               include  'mecb.inc'
               include  'tutor.inc'
               include  'library_rom.inc'
               include  'oled.inc'
;
BUFFER_SIZE    equ      255
;
start          move.l   #RAM_END+1,a7              ; Set up stack
               jsr      oled_init
;
               move.b   #$00,d0                    ; d0 = fill value
               move.b   #$00,d1                    ; d1 = start row
               move.b   #$3f,d2                    ; d2 = end row
               jsr      oled_fill
               jsr      oled_on
;
               lea.l    circle_struct,a0
               move.w   #$3f,OLED_CX(a0)
               move.w   #$1f,OLED_CY(a0)
               move.w   #$10,OLED_CR(a0)
               move.b   #15,OLED_CC(a0)
               move.b   #OLED_PEOR,OLED_CL(a0)
               jsr      oled_circle
               move.w   #$0D,OLED_CR(a0)
               move.b   #7,OLED_CC(a0)
               move.b   #OLED_PEOR,OLED_CL(a0)
               jsr      oled_circle
               move.w   #$0A,OLED_CR(a0)
               move.b   #3,OLED_CC(a0)
               move.b   #OLED_PEOR,OLED_CL(a0)
               jsr      oled_circle

test_end       move.b   #TUTOR,d7
               trap     #14
;
; Structure for circle drawing
;
circle_struct  ds.w     1              ; x
               ds.w     1              ; y
               ds.w     1              ; r
               ds.b     1              ; colour
               ds.b     1              ; logical function
;
; Structure for pixel drawing
;
pixel          ds.b     1              ; x
               ds.b     1              ; y
               ds.b     1              ; colour
               ds.b     1              ; logical function
;
; Structure for character drawing
;
char           ds.b     1              ; x
               ds.b     1              ; y
               ds.b     1              ; foreground colour
               ds.b     1              ; background colour
               ds.b     1              ; logical function
               ds.b     3              ; alignment
               ds.l     1              ; font pointer
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
               end
