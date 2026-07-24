LIB_MAJOR_VER  equ      1
LIB_MINOR_VER  equ      1

;
; returns the library version
;  d0.l = major version in upper word, minor version in lower word
;
get_libversion:
               move.l   #LIB_MAJOR_VER<<16+LIB_MINOR_VER,d0
               rts

;
; Prints the current library version
;
print_libversion:
               movem.l  d0/d7/a0/a6,-(a7) ; save registers
               move.l   #str_version,a0   ; print the initial string
               jsr      print
               sub.l    #-256,a7          ; make temporary buffer for version string
               move.l   #LIB_MAJOR_VER,d0 ; add the major version
               move.l   a7,a6
               move.l   #HEX2DEC,d7
               trap     #14
               move.b   #'.',(a6)+        ; add a divider
               move.l   #LIB_MINOR_VER,d0 ; add the minor version
               move.l   a7,a6
               move.l   #HEX2DEC,d7
               trap     #14
               move.l   #EOT,(a6)+        ; add the EOT
               move.l   a7,a0
               jsr      print             ; print it
               jsr      pcrlf
               add.l    #256,a7           ; remove the temporary buffer
               movem.l  (a7)+,d0/d7/a0/a6 ; restore registers
               rts

str_version    dc.b     "Digicool MECB 68008 Library v",EOT
