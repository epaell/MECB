               align    2              ; Make sure everything is aligned to long boundary
               include  'vdp.inc'
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
;
; Function:    Draw a circle at x,y with radius r given logical function and colour
; Parameters:  a2 - points to a circle structure
; Returns:     -
; Destroys:    -
; Intermediate variables:
; 0(a7) - PIXEL structure
; d1 = tx
; d2 = ty
; d3 = tswitch
;
vdp_circle     movem.l  d0-d3/a0-a2,-(a7)          ; save registers
               lea.l    -VDP_PIXEL_SIZE(a7),a7     ; Make space for pixel structure
               move.l   a2,a1                      ; a1 points to the circle data structure
               move.l   a7,a2                      ; a2 points to the pixel data structure
               
               move.b   VDP_CGC(a1),VDP_PGC(a2)    ; set up colour for pixels
               move.b   VDP_CLOG(a1),VDP_PLOG(a2)  ; set up logic function for drawing
               move.w   #0,d1                      ; tx = 0
               move.w   VDP_CR(a1),d2              ; ty = r
               move.w   #3,d0
               sub.w    VDP_CR(a1),d0
               sub.w    VDP_CR(a1),d0
               move.w   d0,d3                      ; tswitch = 3 - 2 * r
               move.w   VDP_CX(a1),d0              ; tvx = tx - ty
               sub.w    d2,d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0              ; d4 = cy - tx
               sub.w    d1,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(cx-ty, cy-tx)
               
vdp_circle1    move.w   d1,d0
               cmp.w    d2,d0                      ; cmp ty,tx
               bgt      vdp_circle7
               move.w   VDP_CX(a1),d0              ; if tx <= ty
               add.w    d1,d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0
               sub.w    d2,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(tx + cx, -ty + cy)
               
               move.w   d1,d0
               cmp.w    d2,d0
               beq      vdp_circle2
               move.w   d2,d0                      ; if tx != ty
               add.w    VDP_CX(a1),d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0
               sub.w    d1,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(ty + cx, -tx + cy)
               
vdp_circle2    tst.w    d1
               beq      vdp_circle3
               move.w   d2,d0                      ; if tx != 0
               add.w    VDP_CX(a1),d0
               move.w   d0,VDP_PX(a2)
               move.w   d1,d0
               add.w    VDP_CY(a1),d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(ty + cx,  tx + cy)
               
               tst.w    d2
               beq      vdp_circle3
               move.w   VDP_CX(a1),d0              ; if ty != 0
               sub.w    d1,d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0
               add.w    d2,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(-tx + cx,  ty + cy)
               
               move.w   VDP_CX(a1),d0
               sub.w    d2,d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0
               sub.w    d1,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(-ty + cx, -tx + cy)
               
               move.w   d1,d0
               cmp.w    d2,d0
               beq      vdp_circle3

               move.w   VDP_CX(a1),d0              ; if tx != ty
               sub.w    d2,d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0
               add.w    d1,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(-ty + cx,  tx + cy)

               move.w   VDP_CX(a1),d0
               sub.w    d1,d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0
               sub.w    d2,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(-tx + cx, -ty + cy)
               
vdp_circle3    tst.w    d2
               beq      vdp_circle4
               move.w   d2,d0
               cmp.w    d1,d0
               beq      vdp_circle4
               
               move.w   VDP_CX(a1),d0              ; if ty != 0 and tx != ty
               add.w    d1,d0
               move.w   d0,VDP_PX(a2)
               move.w   VDP_CY(a1),d0
               add.w    d2,d0
               move.w   d0,VDP_PY(a2)
               bsr      vdp_pset                   ; plot(tx + cc,  ty + cy)
               
vdp_circle4    tst.w    d3
               bge      vdp_circle5
               move.w   d1,d0                      ; if tswitch < 0:
               asl.w    #2,d0
               add.w    #6,d0
               add.w    d3,d0
               move.w   d0,d3                      ; tswitch += (4 * tx) + 6
               bra      vdp_circle6
vdp_circle5    move.w   d1,d0                      ; else:
               sub.w    d2,d0
               asl.w    #2,d0
               add.w    #10,d0
               add.w    d3,d0
               move.w   d0,d3                      ; tswitch += (4 * (tx - ty)) + 10
               sub.w    #1,d2                      ; ty -= 1
vdp_circle6    add.w    #1,d1                      ; tx += 1
               bra      vdp_circle1
vdp_circle7    lea.l    VDP_PIXEL_SIZE(a7),a7      ; Deallocate space for pixel
               movem.l  (a7)+,d0-d3/a0-a2          ; Restore registers
               rts

;
; Draw line
; Parameters: a2 points to LINE structure
; Destroys: -
;
vdp_line       movem.l  d1-d5,-(a7)          ; save d1-d5
               move.w   VDP_LX1(a2),d1       ; set DX
               move.w   d1,d3                ; make a copy
               move.b   #36,d2
               bsr      vdp_write_reg        ; write lower byte of DX
               lsr.w    #8,d1                ; get DX8
               move.b   #37,d2
               bsr      vdp_write_reg        ; write upper byte of DX
               move.w   VDP_LY1(a2),d1       ; get DY
               move.w   d1,d4                ; make a copy
               move.b   #38,d2
               bsr      vdp_write_reg        ; write lower byte of DY
               lsr.w    #8,d1                ; get DY9 and DY8
               move.b   #39,d2
               bsr      vdp_write_reg        ; write upper byte of DY
;
               move.b   #0,d5                ; Set up ARG
               move.w   VDP_LX2(a2),d1       ; d1 = X2
               move.w   VDP_LY2(a2),d2       ; d2 = Y2
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
               
               move.b   VDP_LGC(a2),d1       ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg        ; write to colour register
               move.b   d5,d1
               move.b   #45,d2               ; write ARG MXD=0 (video RAM)
               bsr      vdp_write_reg
               move.b   VDP_LLOG(a2),d1      ; get logical function
               or.b     #VDP_CMD_LINE,d1
               move.b   #46,d2
               bsr      vdp_write_reg        ; execute PSET command
               movem.l  (a7)+,d1-d5
               rts
;
; Set point
; Parameters: a2 points to a PIXEL structure:
; Destroys: -
;
vdp_pset       movem.l  d1/d2,-(a7)
               move.w   VDP_PX(a2),d1     ; set DX
               move.b   #36,d2
               bsr      vdp_write_reg     ; write lower byte of DX
               lsr.w    #8,d1             ; get DX8
               move.b   #37,d2
               bsr      vdp_write_reg     ; write upper byte of DX
               move.w   VDP_PY(a2),d1     ; set DY
               move.b   #38,d2
               bsr      vdp_write_reg     ; write lower byte of DY
               lsr.w    #8,d1             ; get DY9 and DY8
               move.b   #39,d2
               bsr      vdp_write_reg     ; write upper byte of DY
               move.b   VDP_PGC(a2),d1    ; get colour
               move.b   #44,d2
               bsr      vdp_write_reg     ; write to colour register
               move.b   #0,d1
               move.b   #45,d2
               bsr      vdp_write_reg     ; write MXD=0 (video RAM)
               move.b   VDP_PLOG(a2),d1   ; get logical function
               or.b     #VDP_CMD_PSET,d1
               move.b   #46,d2
               bsr      vdp_write_reg     ; extecute PSET command
               movem.l  (a7)+,d1/d2
               rts
; Draw point
; Parameters: a2 points to a PIXEL structure
; Destroys: d1,d2
;
vdp_point      movem.l  d1/d2,-(a7)
               move.w   VDP_PX(a2),d1     ; set SX
               move.b   #32,d2
               bsr      vdp_write_reg     ; write lower byte of SX
               lsr.w    #8,d1             ; get SX8
               move.b   #33,d2
               bsr      vdp_write_reg     ; write upper byte of SX
               move.w   VDP_PY(a2),d1     ; set SY
               move.b   #34,d2
               bsr      vdp_write_reg     ; write lower byte of SY
               lsr.w    #8,d1             ; get SY9 and SY8
               move.b   #35,d2
               bsr      vdp_write_reg     ; write upper byte of SY
               move.b   #0,d1
               move.b   #45,d2
               bsr      vdp_write_reg     ; write MXD=0 (video RAM)
               move.b   VDP_PGC(a2),d1    ; get colour
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
