vdp_load_font  move.l   #$1000,d0            ; Write the text font definition to the pattern table
               bsr      vdp_vram_waddr
               move.l   #text_font_def,a0
               move.l   #1024,d0
vdp_load_font1 move.b   (a0)+,VDP_VRAM		; Load VRAM data pointed to by A0 and increment A0
;               nop                  ; NOP x2 - add for required delay when running at 4Mhz
;               nop
               sub.l    #1,d0
               bne      vdp_load_font1
;
               move.l   #$1000+1024,d0       ; Do another 128 characters but inverted
               bsr      vdp_vram_waddr
               move.l   #text_font_def,a0
               move.l   #1024,d0
vdp_load_font2 move.b   (a0)+,d1
               not.b    d1
               move.b   d1,VDP_VRAM
;               nop
;               nop
               sub.l    #1,d0
               bne      vdp_load_font2
               rts
;
; Set text mode
;
vdp_text_mode  move.l   #vdp_text_regs,a0
               bra      vdp_init_regs
;
; VDP Register Values for bulk initialisation of VDP Registers
;
vdp_text_regs:
         dc.b       $04    ; R0 - Graphics I, Multi-Color, or Text Mode
         dc.b       $10    ; R1 - Text Mode, 8x8 Sprites, 16KB VRAM, Display Area Enabled
         dc.b       $03    ; R2 - Name table start address = $0000 (0,A16-A12,1,1)
         dc.b       $2F    ; R3 - Color table start address = $0A00 (A13-A9,1,1,1) - holds blink attribute
         dc.b       $02    ; R4 - Pattern table start address = $1000 (0,0,A16-A11)
         dc.b       $02    ; R5 - Sprite Attribute table start address = $0100
         dc.b       $00    ; R6 - Sprite Pattern table start address = $0000
         dc.b       $C1    ; R7 - Dark Green Text / Black Backdrop
;         dc.b       $F4    ; R7 - White Text / Blue Backdrop
;         dc.b       $C1    ; R7 - Dark Green Text / Black Backdrop
         dc.b       $08    ; R8 - 64K DRAM chips / Enable Sprite display
         dc.b       $00    ; R9 - Non-interlaced NTSC
         dc.b       $00    ; R10- Color Table start address (high) (0,0,0,0,0,A16-A14)
         dc.b       $00    ; R11- Sprite Attribute table start address (high)
         dc.b       $C1    ; R12- Test2 Blinking Text / Background color 
         dc.b       $88    ; R13- Blinking period register
         dc.b       $00    ; R14- VRAM Access base address register (high)
         dc.b       $00    ; R15- Status register pointer
         dc.b       $00    ; R16- Color palette address register
         dc.b       $00    ; R17- Control register pointer
         dc.b       $00    ; R18- Display adjust register (0 = centred)
         dc.b       $00    ; R19- Interrupt line register
         dc.b       $00    ; R20- Color burst register 1
         dc.b       $3F    ; R21- Color burst register 2
         dc.b       $05    ; R22- Color burst register 3
         dc.b       $00    ; R23- Display offset register 
;
         include  "src/text_font.asm"