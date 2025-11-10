               org      $4000
;
               include  'mecb.asm'
               include  'tutor.asm'
;
start          move.l   #RAM_END+1,a7           ; Set up stack
               bsr      oled_init
;
               bsr      oled_on
;
               move.b   #$00,d0                 ; d0 = fill value
               move.b   #$00,d1                 ; d1 = start row
               move.b   #$3f,d2                 ; d2 = end row
               bsr      oled_fill
;
               move.b   #2,d0
loop0          move.l   #line,a0                ; point to pixel data structure
               move.b   #$00,OLED_LX1(a0)       ; x
               move.b   #$00,OLED_LY1(a0)       ; y
               move.b   #$7f,OLED_LX2(a0)       ; x
               move.b   #$3f,OLED_LY2(a0)       ; y
               move.b   #$0F,OLED_LC(a0)        ; colour
               move.b   #OLED_PEOR,OLED_LL(a0)  ; Logical function
;
loop1          bsr      oled_line
               add.b    #$01,OLED_LX1(a0)
               sub.b    #$01,OLED_LX2(a0)
               bne      loop1
;
loop2          bsr      oled_line
               add.b    #$01,OLED_LY1(a0)
               sub.b    #$01,OLED_LY2(a0)
               bne      loop2
;
               sub.b    #1,d0
               bne      loop0
;
test_end       move.b   #TUTOR,d7
               trap     #14
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
               include  'oled.asm'
;
               end
