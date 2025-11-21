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
VDP_TC         equ      VDP_STATE+BYTE    ; Current Text colour (BYTE)
VDP_BD         equ      VDP_TC+BYTE       ; Current Backdrop colour (BYTE)
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
VDP_CB_SIZE    equ      10*DWORD          ; Size of the VDP control block in bytes

;
; PIXEL structure
;
VDP_PX         equ     $00               ; X (WORD)
VDP_PY         equ     VDP_PX+WORD       ; Y (WORD)
VDP_PGC        equ     VDP_PY+WORD       ; Graphic colour
VDP_PLOG       equ     VDP_PGC+BYTE      ; Logical function
VDP_PIXEL_SIZE equ     2*DWORD           ; Size of PIXEL structure

;
; LINE structure
;
VDP_LX1        equ     $00               ; X1 (WORD)
VDP_LY1        equ     VDP_LX1+WORD      ; Y1 (WORD)
VDP_LX2        equ     VDP_LY1+WORD      ; X2 (WORD)
VDP_LY2        equ     VDP_LX2+WORD      ; Y2 (WORD)
VDP_LGC        equ     VDP_LY2+WORD      ; Graphic colour
VDP_LLOG       equ     VDP_LGC+BYTE      ; Logical function
VDP_LINE_SIZE  equ     3*DWORD           ; Size of LINE structure

;
; CIRCLE structure
;
VDP_CX         equ      $00               ; X (WORD)
VDP_CY         equ      VDP_CX+WORD       ; Y (WORD)
VDP_CR         equ      VDP_CY+WORD       ; r (WORD)
VDP_CGC        equ      VDP_CR+WORD       ; Graphic colour
VDP_CLOG       equ      VDP_CGC+BYTE      ; Logical function
VDP_CIRCLE_SIZE   equ   2*DWORD           ; Size of CIRCLE structure
;

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

