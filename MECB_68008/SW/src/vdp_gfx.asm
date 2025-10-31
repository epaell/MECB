;
; Logical expressions
;
VDP_IMP        equ      $00
VDP_AND        equ      $01
VDP_OR         equ      $02
VDP_EOR        equ      $03
VDP_NOT        equ      $04
VDP_TIMP       equ      $08
VDP_TAND       equ      $09
VDP_TOR        equ      $0A
VDP_TEOR       equ      $0B
VDP_TNOT       equ      $0C
;
; Graphic commands
;
VDP_CMD_HMMC   equ      $F0
VDP_CMD_YMMM   equ      $E0
VDP_CMD_HMMM   equ      $D0
VDP_CMD_HMMV   equ      $C0
VDP_CMD_LMMC   equ      $B0
VDP_CMD_LMCM   equ      $A0
VDP_CMD_LMMM   equ      $90
VDP_CMD_LMMV   equ      $80
VDP_CMD_LINE   equ      $70
VDP_CMD_SRCH   equ      $60
VDP_CMD_PSET   equ      $50
VDP_CMD_POINT  equ      $40
;
; Draw line
; Parameters: a1 points to data structure:
;             0(a1)   X1       ds.w     1
;             2(a1)   Y1       ds.w     1
;             4(a1)   X2       ds.w     1
;             6(a1)   Y2       ds.w     1
;             8(a1)   C        ds.b     1
;             9(a1)   LOGICAL  ds.b     1
; Destroys: d1,d2,d3,d4,d5
;
vdp_line       move.w   0(a1),d1          ; set DX
               move.w   d1,d3             ; make a copy
               move.b   #36,d2
               bsr      vdp_write_reg     ; write lower byte of DX
               lsr.w    #8,d1             ; get DX8
               move.b   #37,d2
               bsr      vdp_write_reg     ; write upper byte of DX
               move.w   2(a1),d1          ; get DY
               move.w   d1,d4             ; make a copy
               move.b   #38,d2
               bsr      vdp_write_reg     ; write lower byte of DY
               lsr.w    #8,d1             ; get DY9 and DY8
               move.b   #39,d2
               bsr      vdp_write_reg     ; write upper byte of DY
;
               move.b   #0,d5             ; Set up ARG
               move.w   4(a1),d1          ; d1 = X2
               move.w   6(a1),d2          ; d2 = Y2
               cmp.w    d1,d3             ; cmp X2,X1
               blo      vdp_line1         ; X1<X2
               sub.w    d1,d3             ; X1>=X2, d3=|DX|=X1-X2
               bset     #2,d5             ; set DIX i.e. X2 is to the left
               bra      vdp_line2
vdp_line1      exg      d1,d3             ; X1<X2
               sub.w    d1,d3             ; d3=|DX|=X2-X1
;
vdp_line2      cmp.w    d2,d4
               blo      vdp_line3         ; Y1<Y2
               sub.w    d2,d4             ; Y1>=Y2, d4=|DY|=Y1-Y2
               bset     #3,d5             ; set DIY i.e. Y2 is on top of Y1
               bra      vdp_line4
vdp_line3      exg      d2,d4             ; Y1<Y2
               sub.w    d2,d4             ; d4=|DY|=Y2-Y1
;
vdp_line4      cmp      d3,d4
               blo      vdp_line5
               bset     #0,d5             ; Long side is Y-axis (or DX=DY)
               exg      d4,d3             ; d3 has long side; d4 has short side
vdp_line5      move.w   d3,d1
               move.b   #40,d2
               bsr      vdp_write_reg     ; write Maj (LSB)
               lsr.w    #8,d1             ; get DX8
               move.b   #41,d2
               bsr      vdp_write_reg     ; write Maj (MSB)
               move.w   d4,d1
               move.b   #42,d2
               bsr      vdp_write_reg     ; write Min (LSB)
               lsr.w    #8,d1             ; get DX8
               move.b   #43,d2
               bsr      vdp_write_reg     ; write Min (MSB)
               
               move.b   8(a1),d1          ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg     ; write to colour register
               move.b   d5,d1
               move.b   #45,d2            ; write ARG MXD=0 (video RAM)
               bsr      vdp_write_reg
               move.b   9(a1),d1          ; get logical function
               or.b     #VDP_CMD_LINE,d1
               move.b   #46,d2
               bsr      vdp_write_reg     ; extecute PSET command
               rts
;
; Set point
; Parameters: a1 points to data structure:
;             0(a1)   PX       ds.w     1
;             2(a1)   PY       ds.w     1
;             4(a1)   C        ds.b     1
;             5(a1)   LOGICAL  ds.b     1
; Destroys: d1,d2
;
vdp_pset       move.w   0(a1),d1          ; set DX
               move.b   #36,d2
               bsr      vdp_write_reg     ; write lower byte of DX
               lsr.w    #8,d1             ; get DX8
               move.b   #37,d2
               bsr      vdp_write_reg     ; write upper byte of DX
               move.w   2(a1),d1          ; set DY
               move.b   #38,d2
               bsr      vdp_write_reg     ; write lower byte of DY
               lsr.w    #8,d1             ; get DY9 and DY8
               move.b   #39,d2
               bsr      vdp_write_reg     ; write upper byte of DY
               move.b   4(a1),d1          ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg     ; write to colour register
               move.b   #0,d1
               move.b   #45,d2
               bsr      vdp_write_reg     ; write MXD=0 (video RAM)
               move.b   5(a1),d1          ; get logical function
               or.b     #VDP_CMD_PSET,d1
               move.b   #46,d2
               bsr      vdp_write_reg     ; extecute PSET command
               rts
; Draw point
; Parameters: a1 points to data structure:
;             0(a1)   PX       ds.w     1
;             2(a1)   PY       ds.w     1
;             4(a1)   C        ds.b     1
; Destroys: d1,d2
;
vdp_point      move.w   0(a1),d1          ; set SX
               move.b   #32,d2
               bsr      vdp_write_reg     ; write lower byte of SX
               lsr.w    #8,d1             ; get SX8
               move.b   #33,d2
               bsr      vdp_write_reg     ; write upper byte of SX
               move.w   2(a1),d1          ; set SY
               move.b   #34,d2
               bsr      vdp_write_reg     ; write lower byte of SY
               lsr.w    #8,d1             ; get SY9 and SY8
               move.b   #35,d2
               bsr      vdp_write_reg     ; write upper byte of SY
               move.b   #0,d1
               move.b   #45,d2
               bsr      vdp_write_reg     ; write MXD=0 (video RAM)
               move.b   4(a1),d1          ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg     ; write to colour register
               move.b   #VDP_CMD_POINT,d1
               move.b   #46,d2
               bsr      vdp_write_reg     ; extecute PSET command
               rts
;
; Set graphics mode
; Parameters: d0 - mode (4-7)
;
vdp_gfx_mode   cmp.b    #4,d0
               bne      vdp_gfx_mode1
               move.l   #vdp_gfx4_regs,a0
               bra      vdp_init_regs
vdp_gfx_mode1  cmp.b    #5,d0
               bne      vdp_gfx_mode2
               move.l   #vdp_gfx5_regs,a0
               bra      vdp_init_regs
vdp_gfx_mode2  cmp.b    #6,d0
               bne      vdp_gfx_mode3
               move.l   #vdp_gfx6_regs,a0
               bra      vdp_init_regs
vdp_gfx_mode3  cmp.b    #7,d0
               bne      vdp_gfx_mode4
               move.l   #vdp_gfx7_regs,a0
               bra      vdp_init_regs
vdp_gfx_mode4  rts
;
; Graphics mode 4 (256x212, 16 out of 512 colours)
;
vdp_gfx4_regs:
         dc.b       $06    ; R0 - Graphics I, Multi-Color, or Text Mode
         dc.b       $40    ; R1 - Text Mode, 8x8 Sprites, 16KB VRAM, Display Area Enabled
         dc.b       $1F    ; R2 - Name table start address = $0000 A16=0
         dc.b       $2F    ; R3 - Color table start address = $0A00
         dc.b       $02    ; R4 - Pattern table start address = $1000
         dc.b       $FF    ; R5 - Sprite Attribute table start address = $0100 = FA00 (A14-A10,1,1,1)
         dc.b       $3E    ; R6 - Sprite Pattern table start address = $0000 = F000 (0,0,A16-A11)
         dc.b       $00    ; R7 - White Text / Black Backdrop
         dc.b       $0A    ; R8 - 64K DRAM chips / Enable Sprite display
         dc.b       $84    ; R9 - Non-interlaced NTSC LN=1 for 212 dots high
         dc.b       $00    ; R10- Color Table start address (high)
         dc.b       $01    ; R11- Sprite Attribute table start address (high) (0,0,0,0,0,0,A16-A15)
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
; Graphics mode 5 (512x212, 4 out of 512 colours)
;
vdp_gfx5_regs:
         dc.b       $08    ; R0 - Graphics I, Multi-Color, or Text Mode
         dc.b       $40    ; R1 - Text Mode, 8x8 Sprites, 16KB VRAM, Display Area Enabled
         dc.b       $1F    ; R2 - Name table start address = $0000 A16=0
         dc.b       $2F    ; R3 - Color table start address = $0A00
         dc.b       $02    ; R4 - Pattern table start address = $1000
         dc.b       $FF    ; R5 - Sprite Attribute table start address = $0100 (A14-A10,1,1,1)
         dc.b       $3E    ; R6 - Sprite Pattern table start address = $0000 (0,0,A16-A11)
         dc.b       $00    ; R7 - White Text / Black Backdrop
         dc.b       $0A    ; R8 - 64K DRAM chips / Enable Sprite display
         dc.b       $84    ; R9 - Non-interlaced NTSC LN=1 for 212 dots high
         dc.b       $00    ; R10- Color Table start address (high)
         dc.b       $01    ; R11- Sprite Attribute table start address (high) (0,0,0,0,0,0,A16-A15)
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
; Graphics mode 6 (512x212, 16 out of 512 colours)
;
vdp_gfx6_regs:
         dc.b       $0A    ; R0 - Graphics I, Multi-Color, or Text Mode
         dc.b       $40    ; R1 - Text Mode, 8x8 Sprites, 16KB VRAM, Display Area Enabled
         dc.b       $1F    ; R2 - Name table start address = $0000 A16=0
         dc.b       $2F    ; R3 - Color table start address = $0A00
         dc.b       $02    ; R4 - Pattern table start address = $1000
         dc.b       $FF    ; R5 - Sprite Attribute table start address = $0100 (A14-A10,1,1,1)
         dc.b       $3E    ; R6 - Sprite Pattern table start address = $0000 (0,0,A16-A11)
         dc.b       $00    ; R7 - White Text / Black Backdrop
         dc.b       $0A    ; R8 - 64K DRAM chips / Enable Sprite display
         dc.b       $84    ; R9 - Non-interlaced NTSC LN=1 for 212 dots high
         dc.b       $00    ; R10- Color Table start address (high)
         dc.b       $01    ; R11- Sprite Attribute table start address (high) (0,0,0,0,0,0,A16-A15)
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
; Graphics mode 7 (256x212, 256 colours)
;
vdp_gfx7_regs:
         dc.b       $0E    ; R0 - Graphics I, Multi-Color, or Text Mode
         dc.b       $40    ; R1 - Text Mode, 8x8 Sprites, 16KB VRAM, Display Area Enabled
         dc.b       $1F    ; R2 - Name table start address = $0000 A16=0
         dc.b       $2F    ; R3 - Color table start address = $0A00
         dc.b       $02    ; R4 - Pattern table start address = $1000
         dc.b       $FF    ; R5 - Sprite Attribute table start address = $FA00 (A14-A10,1,1,1) A15-A11,A9=1
         dc.b       $3E    ; R6 - Sprite Pattern table start address = $F000 (0,0,A16-A11) A15-A12=1
         dc.b       $00; $0E    ; R7 - White Text / Black Backdrop
         dc.b       $0A    ; R8 - 64K DRAM chips / Enable Sprite display
         dc.b       $80    ; R9 - Non-interlaced NTSC LN=1 for 212 dots high
         dc.b       $00    ; R10- Color Table start address (high)
         dc.b       $01    ; R11- Sprite Attribute table start address (high) (0,0,0,0,0,0,A16-A15)
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
