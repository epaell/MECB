;
; Macro for debugging - simply outputs a test string
;
DUMP     macro level,dstr
         if DEBUG>=level
         stx   dumpx
         ldx   #str
         jsr   print
         jsr   pcrlf
         ldx   dumpx
         bra   next
str      fcb   dstr,EOT
next:
         endif
         endm

;
; Macro for debugging register B contents
;
RDUMPB   macro level,dstr
         if DEBUG>=level
         stx   dumpx
         ldx   #str
         jsr   print
         ldx   dumpx
         jsr   dump_regb
         bra   next
str      fcb   dstr,EOT
next:
         endif
         endm

;
; Macro for debugging register A contents
;
RDUMPA   macro level,dstr
         if DEBUG>=level
         stx   dumpx
         ldx   #str
         jsr   print
         ldx   dumpx
         jsr   dump_rega
         bra   next
str      fcb   dstr,EOT
next:
         endif
         endm

;
; Macro for debugging - output a character
;
DOUTCH2  macro level,c
         if DEBUG>=level
         psha
         lda   #c
         jsr   OUTCH
         pula
         endif
         endm

