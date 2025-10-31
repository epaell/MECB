               include  "src/mecb.asm"
               include  "src/tutor.asm"
;
               org      $4000
;
start          move.b   #OUTPUT,d7
               move.l   #msg_clear,a5
               move.l   #msg_mode,a6
               trap     #14

               move.b   #7,d0
               bsr      vdp_gfx_mode         ; Set the graphics mode
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
               bsr      vdp_vram_waddr       ; Set the initial write address to the beginning of memory
               move.l   #$00000000,d3        ; Initialise counter
fill           bsr      random
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
               bsr      vdp_vram_raddr       ; Set up the VRAM read address to the beginning of memory
               move.l   #$00000000,d3        ; Initialise counter
check          bsr      random
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
rand_seed      ds.l     1
;
BUFFER         ds.b     32                   ; Buffer for holding hex values
;
msg_write      dc.b     'Writing VRAM',CR,LF
msg_read       dc.b     'Reading VRAM',CR,LF
msg_good       dc.b     'VRAM check successful',CR,LF
msg_bad        dc.b     'VRAM check failed at 0x'
msg_end        equ      *
;
               include  "src/vdp.asm"
               include  "src/vdp_gfx.asm"
               include  "src/random.asm"
;