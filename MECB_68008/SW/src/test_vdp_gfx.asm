               include  "mecb.inc"
               include  "tutor.inc"
               include  "library_rom.inc"
               include  "vdp.inc"
;
CR             equ      $0D         ; ASCII code for Carriage return
LF             equ      $0A         ; ASCII code for Linefeed
;
               org      $4000
;
start          move.b   #OUTPUT,d7
               move.l   #msg_clear,a5
               move.l   #msg_mode,a6
               trap     #14

               move.l   #vdp_cb,a1                 ; Set up pointer to point data
               move.b   #VDP_MODE_GFX5,VDP_MODE(a1)
               move.b   #VDP_IE0+VDP_SI,VDP_STATE(a1)
               move.w   #$00000,VDP_PNT(a1)        ; Pattern Name Table = $00000
               move.w   #$0F000,VDP_SGT(a1)        ; Sprite Generator Table = $0F000
               move.w   #$0F800,VDP_SCT(a1)        ; Sprite Color Table = $0F800
               move.w   #$0FA00,VDP_SAT(a1)        ; Sprite Attribute Table = $0FA00
               jsr      vdp_set_mode               ; Set the graphics mode
;
               jsr      vdp_clr_vram               ; Clear VRAM
               move.b   #VDP_BL+VDP_IE0+VDP_SI,VDP_STATE(a1)
               jsr      vdp_set_mode               ; Set the graphics mode
               bsr      test_circle
;               bsr      test_pset
;               bsr      test_line
;
exit           move.b   #TUTOR,d7
               trap     #14
;
test_pset      move.l   #pixel_struct,a2          ; Set up pointer to circle structure
               move.w   #255,VDP_PX(a2)
               move.w   #95,VDP_PY(a2)
               move.b   VDP_CMAX(a1),d0            ; Set colour to CMAX-1
               sub.b    #1,d0
               move.b   d0,VDP_PGC(a2)
               move.b   #VDP_EOR,VDP_PLOG(a2)      ; Logical function = eor
               jsr      vdp_pset
               rts
;
test_circle    move.l   #circle_struct,a2          ; Set up pointer to circle structure
               move.w   #255,VDP_CX(a2)
               move.w   #95,VDP_CY(a2)
               move.w   #80,VDP_CR(a2)
               move.b   VDP_CMAX(a1),d0            ; Set colour to CMAX-1
               sub.b    #1,d0
               move.b   d0,VDP_CGC(a2)
               move.b   #VDP_EOR,VDP_CLOG(a2)      ; Logical function = eor
               jsr      vdp_circle
               rts
;
test_line      move.l   #line_struct,a2            ; Set up pointer to line structure
               move.w   #0,VDP_LX1(a2)             ; (0,0) - (XMAX-1,YMAX-1)
               move.w   #0,VDP_LY1(a2)
               move.w   VDP_XMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_LX2(a2)
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_LY2(a2)
               move.b   VDP_CMAX(a1),d0
               sub.b    #1,d0
               move.b   d0,VDP_LGC(a2)             ; CMAX
               move.b   #VDP_EOR,VDP_LLOG(a2)      ; Logical function = eor
draw           jsr      vdp_line
               jsr      vdp_wait
               add.w    #1,VDP_LX1(a2)             ; inc X1
               sub.w    #1,VDP_LX2(a2)             ; dec X2
               move.w   VDP_XMAX(a1),d0
               sub.w    VDP_LX1(a2),d0
               bne      draw
;
               move.l   #line_struct,a2            ; Set up pointer to line structure
               move.w   VDP_XMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_LX1(a2)             ; (XMAX-1,0) - (0,YMAX-1)
               move.w   #0,VDP_LY1(a2)
               move.w   #0,VDP_LX2(a2)
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_LY2(a2)
               move.b   VDP_CMAX(a1),d0
               sub.b    #1,d0
               move.b   d0,VDP_LGC(a2)             ; CMAX
               move.b   #VDP_EOR,VDP_LLOG(a2)      ; Logical function = eor
draw2          jsr      vdp_line
               jsr      vdp_wait
               add.w    #1,VDP_LY1(a2)             ; inc Y1
               sub.w    #1,VDP_LY2(a2)             ; dec Y2
               move.w   VDP_YMAX(a1),d0
               sub.w    VDP_LY1(a2),d0
               bne      draw2
;
               move.l   #line_struct,a2            ; Set up pointer to line structure
               move.w   #0,VDP_LX1(a2)             ; (0,0)-(XMAX-1,YMAX-1)
               move.w   #0,VDP_LY1(a2)             ; Y1
               move.w   VDP_XMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_LX2(a2)             ; X2
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_LY2(a2)             ; Y2
               move.b   VDP_CMAX(a1),d0
               sub.b    #1,d0
               move.b   d0,VDP_LGC(a2)             ; CMAX
               move.b   #VDP_EOR,VDP_LLOG(a2)      ; Logical function = eor
draw3          jsr      vdp_line
               jsr      vdp_wait
               add.w    #1,VDP_LX1(a2)             ; inc X1
               sub.w    #1,VDP_LX2(a2)             ; dec X2
               move.w   VDP_XMAX(a1),d0
               sub.w    VDP_LX1(a2),d0
               bne      draw3
;
               move.l   #line_struct,a2            ; Set up pointer to line structure
               move.w   VDP_XMAX(a1),d0            ; (XMAX-1,0)-(0,YMAX-1)
               sub.w    #1,d0
               move.w   d0,VDP_LX1(a2)             ; X1
               move.w   #0,VDP_LY1(a2)             ; Y1
               move.w   #0,VDP_LX2(a2)             ; X2
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_LY2(a2)             ; Y2
               move.b   VDP_CMAX(a1),d0
               sub.b    #1,d0
               move.b   d0,VDP_LGC(a2)             ; CMAX
               move.b   #VDP_EOR,VDP_LLOG(a2)      ; Logical function = eor
draw4          jsr      vdp_line
               jsr      vdp_wait
               add.w    #1,VDP_LY1(a2)             ; inc Y1
               sub.w    #1,VDP_LY2(a2)             ; dec Y2
               move.w   VDP_YMAX(a1),d0
               sub.w    VDP_LY1(a2),d0
               bne      draw4
               rts
;

vdp_cb         ds.b     VDP_CB_SIZE
line_struct    ds.b     VDP_LINE_SIZE
circle_struct  ds.b     VDP_CIRCLE_SIZE
pixel_struct   ds.b     VDP_PIXEL_SIZE
;
rand_seed      ds.l     1
;
msg_write      dc.b     'Writing VRAM',CR,LF
msg_read       dc.b     'Reading VRAM',CR,LF
msg_clear      dc.b     'Clearing VRAM',CR,LF
msg_mode       dc.b     'Set graphics mode',CR,LF
msg_end        equ      *
;
