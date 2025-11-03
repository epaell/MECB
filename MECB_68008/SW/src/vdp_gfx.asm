;
; VDP modes
;
VDP_MODE_TEXT1 equ      $00   ; Text mode 1 - 40x24; 2 colour; 4k/screen
VDP_MODE_TEXT2 equ      $01   ; Text mode 2 - 80x24; 2/4 colour; 8k/screen
VDP_MODE_MC    equ      $02   ; Multicolor mode - 64x48, 16 colours; 4k/screen
VDP_MODE_GFX1  equ      $03   ; Graphic 1 mode - 8x8; 256 patterns; 32x24; 16 colours; 4k/screen
VDP_MODE_GFX2  equ      $04   ; Graphic 2 mode - 8x8; 756 patterns; 32x24; 16 colours; 16k/screen
VDP_MODE_GFX3  equ      $05   ; Graphic 3 mode - 8x8; 756 patterns; 32x24; 16 colours; 16k/screen
VDP_MODE_GFX4  equ      $06   ; Graphic 4 mode - 256x192; 16 colour; 32k/screen
VDP_MODE_GFX5  equ      $07   ; Graphic 5 mode - 512x192; 4 colour; 32k/screen
VDP_MODE_GFX6  equ      $08   ; Graphic 6 mode - 512x192; 16 colour; 128k/screen
VDP_MODE_GFX7  equ      $09   ; Graphic 7 mode - 256x192; 256 colour; 128k/screen
;
; VDP_STATE
;
VDP_BL         equ      $40   ; Enable display
VDP_IE0        equ      $20   ; Enable horizontal interrupt
VDP_SI         equ      $02   ; 16x16 sprites
VDP_MA         equ      $01   ; Sprites x2 expansion
;
BYTE           equ      $01               ; Size of byte
WORD           equ      $02               ; Size of word
DWORD          equ      $04               ; Size of double word
;
; VDP control block
;
;
; Higher level VDP function will have a1 point to this structure
; for recording the current state and for drawing functions.
;
VDP_MODE       equ      $00               ; Current VDP mode (BYTE)
VDP_STATE      equ      VDP_MODE+BYTE     ; Display state (BYTE)
VDP_TC         equ      VDP_STATE+WORD    ; Current Text colour (BYTE)
VDP_BD         equ      VDP_TC+WORD       ; Current Backdrop colour (BYTE)
VDP_TCB        equ      VDP_BD+BYTE       ; Text colour for blinking (BYTE)
VDP_BCB        equ      VDP_TCB+BYTE      ; Background colour for blinking (BYTE)
VDP_BON        equ      VDP_BCB+BYTE      ; Blink on period (BYTE)
VDP_BOFF       equ      VDP_BON+BYTE      ; Blink off period (BYTE)
VDP_PMAX       equ      VDP_BOFF+BYTE     ; Maximum Pages (WORD)
VDP_XMAX       equ      VDP_PMAX+WORD     ; Maximum X value (WORD)
VDP_YMAX       equ      VDP_XMAX+WORD     ; Maximum Y value (WORD)
VDP_CMAX       equ      VDP_YMAX+WORD     ; Maximum Colours (WORD)
VDP_PNT        equ      VDP_CMAX+DWORD    ; Pattern Name Table location in VRAM (DWORD)
VDP_PGT        equ      VDP_PNT+DWORD     ; Pattern Generator Table location in VRAM (DWORD)
VDP_CT         equ      VDP_PGT+DWORD     ; Colour Table location in VRAM (DWORD)
VDP_SGT        equ      VDP_CT+DWORD      ; Sprite Generator Table location in VRAM (DWORD)
VDP_SCT        equ      VDP_SGT+DWORD     ; Sprite Color Table location in VRAM (DWORD)
VDP_SAT        equ      VDP_SCT+DWORD     ; Sprite Attribute Table location in VRAM (DWORD)
;
; For pixel and line drawing
VDP_X1         equ      VDP_SCT+DWORD     ; X1 (WORD)
VDP_Y1         equ      VDP_X1+WORD       ; Y1 (WORD)
VDP_X2         equ      VDP_Y1+WORD       ; X2 (WORD)
VDP_Y2         equ      VDP_X2+WORD       ; Y2 (WORD)
VDP_GC         equ      VDP_Y2+WORD       ; Graphic colour
VDP_LOG        equ      VDP_GC+BYTE       ; Logical function
VDP_UNUSED2    equ      VDP_LOG+BYTE      ; Unused (for alignment) (BYTE)
;
VDP_CB_SIZE    equ      VDP_UNUSED2-VDP_MODE  ; Size of the VDP control block in bytes
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
; VDP set mode
;
; Parameters: a1 points to vdp control block
; VDP_STATE and VDP_MODE should be set to control behaviour
;
vdp_sm_table   dc.w     vdp_set_modet1-vdp_sm_table
               dc.w     vdp_set_modet2-vdp_sm_table
               dc.w     vdp_set_modemc-vdp_sm_table
               dc.w     vdp_set_modeg1-vdp_sm_table
               dc.w     vdp_set_modeg2-vdp_sm_table
               dc.w     vdp_set_modeg3-vdp_sm_table
               dc.w     vdp_set_modeg4-vdp_sm_table
               dc.w     vdp_set_modeg5-vdp_sm_table
               dc.w     vdp_set_modeg6-vdp_sm_table
               dc.w     vdp_set_modeg7-vdp_sm_table
               

vdp_set_mode   movem.l  d0-d2/a0,-(a7)       ; Save d1, d2 and a0
               move.l   #0,d1
               cmp.b    #VDP_MODE_GFX7,VDP_MODE(a1)
               bls      vdp_set_mode1        ; A valid mode - process it
               bra      vdp_set_mode2        ; Invalid mode, return
;
vdp_set_mode1  moveq    #0,d1
               move.b   VDP_MODE(a1),d1   ; Get word offset into jump table for this mode
               lsl.l    #1,d1
               move.w   vdp_sm_table(pc,d1.w),d1
               jmp      vdp_sm_table(pc,d1.w)   ; Jump to handler
;
vdp_set_modet1                               ; Text mode 1
               move.b   #$00,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               bset     #4,d1                ; Bit 4 is set in text mode
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #40,VDP_XMAX(a1)     ; 40 columns
               move.w   #24,VDP_YMAX(a1)     ; 24 rows
               move.w   #2,VDP_CMAX(a1)      ; 2 colours
               move.b   #32,VDP_PMAX(a1)     ; 32 pages
               bra      vdp_set_mode2

vdp_set_modet2                               ; Text mode 2
               move.b   #$04,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               bset     #4,d1                ; Bit 4 is set in text mode
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #80,VDP_XMAX(a1)     ; 80 columns
               move.w   #24,VDP_YMAX(a1)     ; 24 rows
               move.w   #2,VDP_CMAX(a1)      ; 2 colours
               move.b   #16,VDP_PMAX(a1)     ; 16 pages               
               bra      vdp_set_mode2

vdp_set_modemc                               ; Multicolour mode
               move.b   #$00,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               bset     #3,d1                ; bit 3 set for multicolour mode
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #64,VDP_XMAX(a1)     ; 64 columns
               move.w   #48,VDP_YMAX(a1)     ; 48 rows
               move.w   #16,VDP_CMAX(a1)     ; 16 colours
               bra      vdp_set_mode2

vdp_set_modeg1                               ; Graphic mode 1
               move.b   #$00,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #32,VDP_XMAX(a1)     ; 32 columns
               move.w   #24,VDP_YMAX(a1)     ; 24 rows
               move.w   #16,VDP_CMAX(a1)     ; 16 colours
               bra      vdp_set_mode2

vdp_set_modeg2                               ; Graphic mode 2
               move.b   #$02,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #32,VDP_XMAX(a1)     ; 32 columns
               move.w   #24,VDP_YMAX(a1)     ; 24 rows
               move.w   #16,VDP_CMAX(a1)     ; 16 colours
               move.b   #8,VDP_PMAX(a1)      ; 8 pages
               bra      vdp_set_mode2

vdp_set_modeg3                               ; Graphic mode 3
               move.b   #$04,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #32,VDP_XMAX(a1)     ; 32 columns
               move.w   #24,VDP_YMAX(a1)     ; 24 rows
               move.w   #16,VDP_CMAX(a1)     ; 16 colours
               move.b   #8,VDP_PMAX(a1)      ; 8 pages
               bra      vdp_set_mode2

vdp_set_modeg4                               ; Graphic mode 4
               move.b   #$06,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #256,VDP_XMAX(a1)    ; 256 columns
               move.w   #192,VDP_YMAX(a1)    ; 192 rows
               move.w   #16,VDP_CMAX(a1)     ; 16 colours
               bra      vdp_set_modeg5a

vdp_set_modeg5                               ; Graphic mode 5
               move.b   #$08,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #512,VDP_XMAX(a1)    ; 512 columns
               move.w   #192,VDP_YMAX(a1)    ; 192 rows
               move.w   #4,VDP_CMAX(a1)      ; 4 colours
vdp_set_modeg5a
               move.b   #$0A,d1              ; 
               move.b   #$08,d2
               bsr      vdp_write_reg
               move.b   #$80,d1
               move.b   #$09,d2
               bsr      vdp_write_reg
               move.b   #4,VDP_PMAX(a1)      ; 2 pages
               move.l   VDP_PNT,d1           ; Set Pattern Name Table location
               lsl.l    #1,d1                ; Move A15 into upper word
               swap     d1                   ; Only need A15 and A16 (now in bit 0/1)
               and.b    #$03,d1              ; Mask off all but A15/A16
               lsl.b    #5,d1                ; Shift to bit 5
               or.b     #$1F,d1              ; Set lower bits
               move.b   #$02,d2              ; Set register 2
               bsr      vdp_write_reg        ; Set the pattern name table address

vdp_set_modeg6                               ; Graphic mode 6
               move.b   #$0A,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #512,VDP_XMAX(a1)    ; 512 columns
               move.w   #192,VDP_YMAX(a1)    ; 192 rows
               move.w   #16,VDP_CMAX(a1)     ; 16 colours
               bra      vdp_set_modeg7a

vdp_set_modeg7                               ; Graphic mode 7
               move.b   #$0E,d1
               move.b   #$00,d2              ; Set register 0
               bsr      vdp_write_reg
               move.b   VDP_STATE(a1),d1     ; Get the state
               move.b   #$01,d2              ; Set register 1
               bsr      vdp_write_reg
               move.w   #256,VDP_XMAX(a1)    ; 256 columns
               move.w   #192,VDP_YMAX(a1)    ; 192 rows
               move.w   #256,VDP_CMAX(a1)    ; 256 colours
vdp_set_modeg7a
               move.b   #$0A,d1              ; 
               move.b   #$08,d2
               bsr      vdp_write_reg
               move.b   #$80,d1
               move.b   #$09,d2
               bsr      vdp_write_reg
               move.b   #2,VDP_PMAX(a1)      ; 2 pages
               move.l   VDP_PNT,d1           ; Set Pattern Name Table location
               swap     d1                   ; Only need A16 (not in bit 0)
               and.b    #$01,d1              ; Mask off all but A16 (now bit 0)
               lsl.b    #5,d1                ; Shift to bit 5
               or.b     #$1F,d1              ; Set lower bits
               move.b   #$02,d2              ; Set register 2
               bsr      vdp_write_reg        ; Set the pattern name table address
;
vdp_set_mode2  
               movem.l  (a7)+,d0-d2/a0       ; Restore a0, d1 and s2
               rts
;
; Draw line
; Parameters: a1 points to vdp contol block
; Destroys: d1,d2,d3,d4,d5
;
vdp_line       movem.l  d1-d5,-(a7)          ; save d1-d5
               move.w   VDP_X1(a1),d1        ; set DX
               move.w   d1,d3                ; make a copy
               move.b   #36,d2
               bsr      vdp_write_reg        ; write lower byte of DX
               lsr.w    #8,d1                ; get DX8
               move.b   #37,d2
               bsr      vdp_write_reg        ; write upper byte of DX
               move.w   VDP_Y1(a1),d1        ; get DY
               move.w   d1,d4                ; make a copy
               move.b   #38,d2
               bsr      vdp_write_reg        ; write lower byte of DY
               lsr.w    #8,d1                ; get DY9 and DY8
               move.b   #39,d2
               bsr      vdp_write_reg        ; write upper byte of DY
;
               move.b   #0,d5                ; Set up ARG
               move.w   VDP_X2(a1),d1        ; d1 = X2
               move.w   VDP_Y2(a1),d2        ; d2 = Y2
               cmp.w    d1,d3                ; cmp X2,X1
               blo      vdp_line1            ; X1<X2
               sub.w    d1,d3                ; X1>=X2, d3=|DX|=X1-X2
               bset     #2,d5                ; set DIX i.e. X2 is to the left
               bra      vdp_line2
vdp_line1      exg      d1,d3                ; X1<X2
               sub.w    d1,d3                ; d3=|DX|=X2-X1
;
vdp_line2      cmp.w    d2,d4
               blo      vdp_line3            ; Y1<Y2
               sub.w    d2,d4                ; Y1>=Y2, d4=|DY|=Y1-Y2
               bset     #3,d5                ; set DIY i.e. Y2 is on top of Y1
               bra      vdp_line4
vdp_line3      exg      d2,d4                ; Y1<Y2
               sub.w    d2,d4                ; d4=|DY|=Y2-Y1
;
vdp_line4      cmp      d3,d4
               blo      vdp_line5
               bset     #0,d5                ; Long side is Y-axis (or DX=DY)
               exg      d4,d3                ; d3 has long side; d4 has short side
vdp_line5      move.w   d3,d1
               move.b   #40,d2
               bsr      vdp_write_reg        ; write Maj (LSB)
               lsr.w    #8,d1                ; get DX8
               move.b   #41,d2
               bsr      vdp_write_reg        ; write Maj (MSB)
               move.w   d4,d1
               move.b   #42,d2
               bsr      vdp_write_reg        ; write Min (LSB)
               lsr.w    #8,d1                ; get DX8
               move.b   #43,d2
               bsr      vdp_write_reg        ; write Min (MSB)
               
               move.b   VDP_GC(a1),d1        ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg        ; write to colour register
               move.b   d5,d1
               move.b   #45,d2               ; write ARG MXD=0 (video RAM)
               bsr      vdp_write_reg
               move.b   VDP_LOG(a1),d1       ; get logical function
               or.b     #VDP_CMD_LINE,d1
               move.b   #46,d2
               bsr      vdp_write_reg        ; extecute PSET command
               movem.l  (a7)+,d1-d5
               rts
;
; Set point
; Parameters: a1 points to VDP control block:
; Destroys: -
;
vdp_pset       movem.l  d1/d2,-(a7)
               move.w   VDP_X1(a1),d1          ; set DX
               move.b   #36,d2
               bsr      vdp_write_reg     ; write lower byte of DX
               lsr.w    #8,d1             ; get DX8
               move.b   #37,d2
               bsr      vdp_write_reg     ; write upper byte of DX
               move.w   VDP_Y1(a1),d1          ; set DY
               move.b   #38,d2
               bsr      vdp_write_reg     ; write lower byte of DY
               lsr.w    #8,d1             ; get DY9 and DY8
               move.b   #39,d2
               bsr      vdp_write_reg     ; write upper byte of DY
               move.b   VDP_GC(a1),d1          ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg     ; write to colour register
               move.b   #0,d1
               move.b   #45,d2
               bsr      vdp_write_reg     ; write MXD=0 (video RAM)
               move.b   VDP_LOG(a1),d1          ; get logical function
               or.b     #VDP_CMD_PSET,d1
               move.b   #46,d2
               bsr      vdp_write_reg     ; extecute PSET command
               movem.l  (a7)+,d1/d2
               rts
; Draw point
; Parameters: a1 points to VDP control block
; Destroys: d1,d2
;
vdp_point      movem.l  d1/d2,-(a7)
               move.w   VDP_X1(a1),d1          ; set SX
               move.b   #32,d2
               bsr      vdp_write_reg     ; write lower byte of SX
               lsr.w    #8,d1             ; get SX8
               move.b   #33,d2
               bsr      vdp_write_reg     ; write upper byte of SX
               move.w   VDP_Y1(a1),d1          ; set SY
               move.b   #34,d2
               bsr      vdp_write_reg     ; write lower byte of SY
               lsr.w    #8,d1             ; get SY9 and SY8
               move.b   #35,d2
               bsr      vdp_write_reg     ; write upper byte of SY
               move.b   #0,d1
               move.b   #45,d2
               bsr      vdp_write_reg     ; write MXD=0 (video RAM)
               move.b   VDP_GC(a1),d1          ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg     ; write to colour register
               move.b   #VDP_CMD_POINT,d1
               move.b   #46,d2
               bsr      vdp_write_reg     ; extecute PSET command
               movem.l  (a7)+,d1/d2
               rts
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
