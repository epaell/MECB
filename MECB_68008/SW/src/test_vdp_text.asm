               include  "mecb.inc"
               include  "tutor.inc"
               include  "library_rom.inc"
;
CR             equ      $0D         ; Carriage return
LF             equ      $0A         ; Linefeed

               org      $4000
;
; Name table start address = $0000
; Color table start address = $0A00
; Pattern table start address = $1000
start          ;
               move.b   #OUTPUT,d7
               move.l   #msg_clear,a5
               move.l   #msg_mode,a6
               trap     #14

               jsr      vdp_clr_vram         ; Clear VRAM
;
               move.b   #1,d0                ; set text mode 1 (40 char wide)
               jsr      vdp_text_mode

               move.b   #$50,d1              ; Turn on VDP Display
               move.b   #1,d2                ; set register #1
               jsr      vdp_write_reg
;
; Copy the font definition to VRAM
;
               move.b   #OUTPUT,d7
               move.l   #msg_writing,a5
               move.l   #msg_clear,a6
               trap     #14
;
               move.l   #$0800,d0            ; Destination in VRAM for the patterns
               jsr      vdp_load_font

; Set Color Table (blink attribute) for all possible 135 (40x26) Screen locations
               move.l   #$0A00,d0            ; Write to color table
               jsr      vdp_vram_waddr
               move.b   #$00,d0
               move.l   #135,d1
               jsr      vdp_set_vram
;
; Fill the text display with characters
;
               move.b   #OUTPUT,d7
               move.l   #msg_text,a5
               move.l   #msg_writing,a6
               trap     #14

               move.l   #$0000,d0            ; Write to name table
               jsr      vdp_vram_waddr
               move.l   #0,d0
               move.l   #40*24,d1
               jsr      vdp_inc_vram
;
               move.b   #TUTOR,d7
               trap     #14
;
msg_text       dc.b     'Writing text',CR,LF
msg_writing    dc.b     'Writing fonts',CR,LF
msg_clear      dc.b     'Clearing VRAM',CR,LF
msg_mode       dc.b     'Set text mode',CR,LF
msg_end        equ      *
