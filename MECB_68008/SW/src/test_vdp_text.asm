               include  "src/mecb.asm"
               include  "src/tutor.asm"
;
CR             equ      $0D         ; Carriage return
LF             equ      $0A         ; Linefeed

               org      $4000
;
; Name table start address = $0000
; Color table start address = $0A00
; Pattern table start address = $1000
start          move.b   #OUTPUT,d7
               move.l   #msg_clear,a5
               move.l   #msg_mode,a6
               trap     #14

               bsr      vdp_clr_vram         ; Clear VRAM
               move.b   #OUTPUT,d7
               move.l   #msg_mode,a5
               move.l   #msg_end,a6
               trap     #14
               move.b   #7,d0                ; set graphics mode 7
               bsr      vdp_gfx_mode
;
               move.w   #0,PX                ; X
               move.w   #0,PY                ; Y
ploop          move.w   PX,d0
               move.w   PY,d1
               move.w   #$FF,d2              ; colour
               move.b   #VDP_IMP,d3          ; logicial expression
               bsr      vdp_pset
               add.w    #1,PX
               add.w    #1,PY
; convert PX to text
               move.w   PX,d0
               move.l   #BUFFER,a6
               move.b   #PNT2HX,d7
               trap     #14
; print value
               move.b   #OUTPUT,d7
               move.l   #BUFFER,a5
               move.l   #BUFFER+2,a6
               trap     #14
               move.b   #OUTCH,d7
               move.b   #$20,d0
               trap     #14
; convert PY to text
               move.w   PY,d0
               move.l   #BUFFER,a6
               move.b   #PNT2HX,d7
               trap     #14
; print value
               move.b   #OUT1CR,d7
               move.l   #BUFFER,a5
               move.l   #BUFFER+2,a6
               trap     #14
               
vdp_wait       move.b   #2,d0                ; Read status register 2
               bsr      vdp_read_nstat
               btst     #0,d0                ; Check CE bit
               bne      vdp_wait             ; If command is still running then wait
               
               cmp.w    #127,PX
               bne      ploop
;
               move.b   #TUTOR,d7
               trap     #14
;
PX             ds.w     1
PY             ds.w     1
;
BUFFER         ds.b     32                   ; Buffer for holding hex values
;
; Text mode stuff
;               move.l   #vdp_text_regs,a0
;               bsr      vdp_init_regs        ; Initialise to text mode
;               move.b   #OUTPUT,d7
;               move.l   #msg_clear,a5
;               move.l   #msg_end,a6
;               trap     #14

;               bsr      vdp_clr_vram         ; Clear VRAM
;
;               move.b   #$50,d1              ; Turn on VDP Display
;               move.b   #1,d2                ; set register #1
;               bsr      vdp_write_reg
;
; Copy the font definition to VRAM
;
;               move.b   #OUTPUT,d7
;               move.l   #msg_writing,a5
;               move.l   #msg_clear,a6
;               trap     #14
;               bsr      vdp_load_font

; Set Color Table for all possible 270 (80x26) Screen locations
;               move.l   #$0A00,d0            ; Write to color table
;               bsr      vdp_vram_waddr
;               move.b   #$00,d0
;               move.l   #270,d1
;               bsr      vdp_set_vram
;
; Fill the text display with characters
;
;               move.b   #OUTPUT,d7
;               move.l   #msg_text,a5
;               move.l   #msg_writing,a6
;               trap     #14

;               move.l   #$0000,d0            ; Write to name table
;               bsr      vdp_vram_waddr
;               move.l   #0,d0
;               move.l   #1920,d1
;               bsr      vdp_inc_vram
;
;               move.b   #TUTOR,d7
;               trap     #14
;
msg_text       dc.b     'Writing text',CR,LF
msg_writing    dc.b     'Writing fonts',CR,LF
msg_clear      dc.b     'Clearing VRAM',CR,LF
msg_mode       dc.b     'Set graphics mode',CR,LF
msg_end        equ      *
;
               include        "src/vdp.asm"
               include        "src/vdp_gfx.asm"