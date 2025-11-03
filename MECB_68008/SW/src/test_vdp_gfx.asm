               include  "src/mecb.asm"
               include  "src/tutor.asm"
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
               move.w   #$0F800,VDP_SGT(a1)        ; Sprite Color Table = $0F800
               move.w   #$0FA00,VDP_SGT(a1)        ; Sprite Attribute Table = $0FA00
               bsr      vdp_set_mode               ; Set the graphics mode
;
               bsr      vdp_clr_vram               ; Clear VRAM
               move.b   #VDP_BL+VDP_IE0+VDP_SI,VDP_STATE(a1)
               bsr      vdp_set_mode               ; Set the graphics mode
;
               move.l   #vdp_cb,a1                 ; Set up pointer to point data
               move.w   #0,VDP_X1(a1)              ; (0,0) - (XMAX-1,YMAX-1)
               move.w   #0,VDP_Y1(a1)
               move.w   VDP_XMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_X2(a1)
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_Y2(a1)
               move.b   VDP_CMAX,d0
               sub.b    #1,d0
               move.b   d0,VDP_GC(a1)              ; CMAX
               move.b   #VDP_EOR,VDP_LOG(a1)       ; Logical function = eor
draw           bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,VDP_X1(a1)              ; inc X1
               sub.w    #1,VDP_X2(a1)              ; dec X2
               move.w   VDP_XMAX(a1),d0
               sub.w    VDP_X1(a1),d0
               bne      draw
;
               move.l   #vdp_cb,a1                 ; Set up pointer to point data
               move.w   VDP_XMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_X1(a1)              ; (XMAX-1,0) - (0,YMAX-1)
               move.w   #0,VDP_Y1(a1)
               move.w   #0,VDP_X2(a1)
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_Y2(a1)
               move.b   VDP_CMAX,d0
               sub.b    #1,d0
               move.b   d0,VDP_GC(a1)              ; CMAX
               move.b   #VDP_EOR,VDP_LOG(a1)       ; Logical function = eor
draw2          bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,VDP_Y1(a1)              ; inc Y1
               sub.w    #1,VDP_Y2(a1)              ; dec Y2
               move.w   VDP_YMAX(a1),d0
               sub.w    VDP_Y1(a1),d0
               bne      draw2
;
               move.l   #vdp_cb,a1                 ; Set up pointer to point data
               move.w   #0,VDP_X1(a1)              ; (0,0)-(XMAX-1,YMAX-1)
               move.w   #0,VDP_Y1(a1)              ; Y1
               move.w   VDP_XMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_X2(a1)              ; X2
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_Y2(a1)              ; Y2
               move.b   VDP_CMAX,d0
               sub.b    #1,d0
               move.b   d0,VDP_GC(a1)              ; CMAX
               move.b   #VDP_EOR,VDP_LOG(a1)       ; Logical function = eor
draw3          bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,VDP_X1(a1)              ; inc X1
               sub.w    #1,VDP_X2(a1)              ; dec X2
               move.w   VDP_XMAX(a1),d0
               sub.w    VDP_X1(a1),d0
               bne      draw3
;
               move.l   #vdp_cb,a1                 ; Set up pointer to point data
               move.w   VDP_XMAX(a1),d0            ; (XMAX-1,0)-(0,YMAX-1)
               sub.w    #1,d0
               move.w   d0,VDP_X1(a1)              ; X1
               move.w   #0,VDP_Y1(a1)              ; Y1
               move.w   #0,VDP_X2(a1)              ; X2
               move.w   VDP_YMAX(a1),d0
               sub.w    #1,d0
               move.w   d0,VDP_Y2(a1)              ; Y2
               move.b   VDP_CMAX,d0
               sub.b    #1,d0
               move.b   d0,VDP_GC(a1)              ; CMAX
               move.b   #VDP_EOR,VDP_LOG(a1)       ; Logical function = eor
draw4          bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,VDP_Y1(a1)              ; inc Y1
               sub.w    #1,VDP_Y2(a1)              ; dec Y2
               move.w   VDP_YMAX(a1),d0
               sub.w    VDP_Y1(a1),d0
               bne      draw4
;
exit           move.b   #TUTOR,d7
               trap     #14
;
vdp_cb         ds.b     VDP_CB_SIZE
;
rand_seed      ds.l     1
;
BUFFER         ds.b     32                   ; Buffer for holding hex values
;
msg_write      dc.b     'Writing VRAM',CR,LF
msg_read       dc.b     'Reading VRAM',CR,LF
msg_clear      dc.b     'Clearing VRAM',CR,LF
msg_mode       dc.b     'Set graphics mode',CR,LF
msg_good       dc.b     'VRAM check successful',CR,LF
msg_bad        dc.b     'VRAM check failed at 0x'
msg_end        equ      *
;
               include  "src/vdp.asm"
               include  "src/vdp_gfx.asm"
               include  "src/random.asm"
;