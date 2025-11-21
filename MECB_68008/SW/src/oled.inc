;
; Logical functions for oled_pixel
OLED_PSET      equ      $0                   ; Set pixel
OLED_POR       equ      $1                   ; Or pixel
OLED_PEOR      equ      $2                   ; Exclusive-or pixel
OLED_PAND      equ      $3                   ; And pixel
;
; Structure used for oled_pixel
;
OLED_X         equ      $0                   ; X
OLED_Y         equ      $1                   ; Y
OLED_C         equ      $2                   ; Colour
OLED_L         equ      $3                   ; Logical function
;
; Structure used for oled_line
;
OLED_LX1       equ      $0                   ; X
OLED_LY1       equ      $1                   ; Y
OLED_LX2       equ      $2                   ; X
OLED_LY2       equ      $3                   ; Y
OLED_LC        equ      $4                   ; Colour
OLED_LL        equ      $5                   ; Logical function
;
; Structure used for oled_char
;
OLED_TX        equ      $00
OLED_TY        equ      $01
OLED_TFC       equ      $02
OLED_TBC       equ      $03
OLED_TL        equ      $04
OLED_TF        equ       $08
;
; Structure used for oled_circle
;
OLED_CX        equ      0
OLED_CY        equ      2
OLED_CR        equ      4
OLED_CC        equ      6
OLED_CL        equ      7
