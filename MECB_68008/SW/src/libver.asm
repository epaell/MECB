LIB_MAJOR_VER  equ      0
LIB_MINOR_VER  equ      1

;
; returns the library version
;  d0.l = major version in upper word, minor version in lower word
;
GETLVER:
               move.l   #LIB_MAJOR_VER<<16+LIB_MINOR_VER,d0
               rts

;
; Prints the current library version
;
OUTLVER:
               movem.l  d0/d7/a0/a6,-(a7) ; save registers
               move.l   #str_version,a0   ; print the initial string
               jsr      print
               move.l   #LIB_MAJOR_VER,d0 ; add the major version
               jsr      outdec
               move.b   #'.',d0           ; add a divider
               jsr      outch1
               move.l   #LIB_MINOR_VER,d0 ; add the minor version
               jsr      outdec
               jsr      pcrlf
               movem.l  (a7)+,d0/d7/a0/a6 ; restore registers
               rts
;
str_version    dc.b     "Digicool MECB 68008 Library v",EOT
