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

               move.b   #6,d0
               bsr      vdp_gfx_mode               ; Set the graphics mode
;
               bsr      vdp_clr_vram               ; Clear VRAM
;
               move.l   #X1,a1                     ; Set up pointer to point data
               move.w   #0,0(a1)                   ; X1
               move.w   #0,2(a1)                   ; Y1
               move.w   #511,4(a1)                 ; X2
               move.w   #211,6(a1)                 ; Y2
               move.b   #15,8(a1)                  ; C
               move.b   #VDP_EOR,9(a1)             ; Logical function = eor
draw           bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,0(a1)                   ; inc X1
               sub.w    #1,4(a1)                   ; dec X2
               cmp.w    #512,0(a1)
               bne      draw
;
               move.l   #X1,a1                     ; Set up pointer to point data
               move.w   #511,0(a1)                 ; X1
               move.w   #0,2(a1)                   ; Y1
               move.w   #0,4(a1)                   ; X2
               move.w   #211,6(a1)                 ; Y2
               move.b   #15,8(a1)                  ; C
               move.b   #VDP_EOR,9(a1)             ; Logical function = eor
draw2          bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,2(a1)                   ; inc Y2
               sub.w    #1,6(a1)                   ; dec Y1
               cmp.w    #212,2(a1)
               bne      draw2
;
               move.l   #X1,a1                     ; Set up pointer to point data
               move.w   #0,0(a1)                   ; X1
               move.w   #0,2(a1)                   ; Y1
               move.w   #511,4(a1)                 ; X2
               move.w   #211,6(a1)                 ; Y2
               move.b   #15,8(a1)                  ; C
               move.b   #VDP_EOR,9(a1)             ; Logical function = eor
draw3          bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,0(a1)                   ; inc X1
               sub.w    #1,4(a1)                   ; dec X2
               cmp.w    #512,0(a1)
               bne      draw3
;
               move.l   #X1,a1                     ; Set up pointer to point data
               move.w   #511,0(a1)                 ; X1
               move.w   #0,2(a1)                   ; Y1
               move.w   #0,4(a1)                   ; X2
               move.w   #211,6(a1)                 ; Y2
               move.b   #15,8(a1)                  ; C
               move.b   #VDP_EOR,9(a1)             ; Logical function = eor
draw4          bsr      vdp_line
               bsr      vdp_wait
               add.w    #1,2(a1)                   ; inc Y2
               sub.w    #1,6(a1)                   ; dec Y1
               cmp.w    #212,2(a1)
               bne      draw4
;
exit           move.b   #TUTOR,d7
               trap     #14
;
X1             ds.w     1
Y1             ds.w     1
X2             ds.w     1
Y2             ds.w     1
C              ds.b     1
LOGICAL        ds.b     1
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