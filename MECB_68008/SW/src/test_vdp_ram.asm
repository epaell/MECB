               include  "mecb.inc"
               include  "tutor.inc"
               include  "library_rom.inc"
               include  "vdp.inc"
;
CR             equ      $0d
LF             equ      $0a
;
               org      $4000
;
start          move.b   #OUTPUT,d7
               move.l   #msg_clear,a5
               move.l   #msg_mode,a6
               trap     #14

               move.l   #vdp_cb,a1                 ; Set up pointer to point data
               move.b   #VDP_MODE_GFX5,VDP_MODE(a1)
               move.b   #VDP_IE0+VDP_SI+VDP_BL,VDP_STATE(a1)
               move.w   #$00000,VDP_PNT(a1)        ; Pattern Name Table = $00000
               move.w   #$0F000,VDP_SGT(a1)        ; Sprite Generator Table = $0F000
               move.w   #$0F800,VDP_SGT(a1)        ; Sprite Color Table = $0F800
               move.w   #$0FA00,VDP_SGT(a1)        ; Sprite Attribute Table = $0FA00
               jsr      vdp_set_mode               ; Set the graphics mode
;
; Fill VRAM with random values
;
               move.b   #OUTPUT,d7
               move.l   #msg_write,a5
               move.l   #msg_read,a6
               trap     #14

               move.l   #rand_seed,a0        ; Reset the random seed
               move.l   #$12345678,(a0)
               move.l   #$00000000,d0
               jsr      vdp_vram_waddr       ; Set the initial write address to the beginning of memory
               move.l   #$00000000,d3        ; Initialise counter
fill           jsr      random
               move.b   d0,VDP_VRAM          ; Write a random byte to VRAM
               add.l    #1,d3                ; Increment counter
               cmp.l    #$20000,d3           ; Check if all memory has been checked
               bne      fill                 ; If not, continue
;
               move.b   #OUTPUT,d7
               move.l   #msg_read,a5
               move.l   #msg_good,a6
               trap     #14

               move.l   #rand_seed,a0        ; Reset the random seed
               move.l   #$12345678,(a0)      ; Reset the random seed
               move.l   #$00000000,d0
               jsr      vdp_vram_raddr       ; Set up the VRAM read address to the beginning of memory
               move.l   #$00000000,d3        ; Initialise counter
check          jsr      random
               move.b   VDP_VRAM,d1
               cmp.b    d0,d1
               bne      bad
               add.l    #1,d3
               cmp.l    #$20000,d3
               bne      check
               move.b   #OUTPUT,d7
               move.l   #msg_good,a5
               move.l   #msg_bad,a6
               trap     #14
               bra      exit
;
bad            move.b   d1,d0
               move.l   #BUFFER,a6           ; Write out the byte
               move.b   #PNT2HX,d7
               trap     #14
               move.b   #OUT1CR,d7           ; Write to terminal
               move.l   #BUFFER,a5
               trap     #14

               move.b   #OUTPUT,d7           ; VRAM check failed
               move.l   #msg_bad,a5
               move.l   #msg_end,a6
               trap     #14
               move.l   d3,d0                ; Convert address to ASCII
               move.l   #BUFFER,a6
               move.b   #PNT8HX,d7
               trap     #14
               move.b   #OUT1CR,d7           ; Write to terminal
               move.l   #BUFFER,a5
               trap     #14
;
exit           move.b   #TUTOR,d7
               trap     #14
;
;
vdp_cb         ds.b     VDP_CB_SIZE
;
rand_seed      ds.l     1
;
BUFFER         ds.b     32                   ; Buffer for holding hex values
;
msg_mode       dc.b     'Setting graphics mode',CR,LF
msg_clear      dc.b     'Clearing VRAM',CR,LF
msg_write      dc.b     'Writing VRAM',CR,LF
msg_read       dc.b     'Reading VRAM',CR,LF
msg_good       dc.b     'VRAM check successful',CR,LF
msg_bad        dc.b     'VRAM check failed at 0x'
msg_end        equ      *
;
