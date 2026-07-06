;
; output as hex digits contents of A/B register
;
out4h    psha
         pshb
         bsr   out2h
         tba
         bsr   out2h
         pulb
         pula
         rts

;
; output two hex digits in A
;
out2h    psha
         asra
         asra
         asra
         asra
         bsr   outnyb
         pula
         bsr   outnyb
         rts

;
; output least significant nybble in A
;
outnyb   anda  #$0F
         cmpa  #$0A
         bcs   outnyb2
         adda  #$07
outnyb2  adda  #$30
         jsr   OUTCH
         rts

;
; add character to string buffer
; Entry: a - character to add
;        ptrdest = points to location where character should be stored
; Exit: ptrdest = points to location after character added
;
appendc: stx   tempx1
         ldx   ptrdest
         sta   ,x
         inx
         stx   ptrdest
         ldx   tempx1
         rts
;
; add 4 spaces
; Entry: ptrdest = points to location where spaces should be stored
; Exit: ptrdest = points to location after last space
;
blank4   bsr   blank2
         bsr   blank2
         rts
;
; add 2 spaces
; Entry: ptrdest = points to location where spaces should be stored
; Exit: ptrdest = points to location after last space
;
blank2   psha
         lda   #' '
         bsr   appendc
         bsr   appendc
         pula
         rts

;
; print string pointed to by X
;
print    psha
         stx   tempx2
print2   lda   ,x
         beq   print3
         inx
         jsr   OUTCH
         bra   print2
print3   ldx   tempx2
         pula
         rts
;
; print CR/LF
;
pcrlf    psha
         lda   #CR
         jsr   OUTCH
         lda   #LF
         jsr   OUTCH
         pula
         rts
;
; Write 2-digit decimal with trailing 0
; Entry: a - signed value to convert (-128 to 128)
;        ptrdest - buffer to place ASCII representation
; Exit:  ptrdest - points just after last digit added
;
hex2dec2:
         psha
         stx   tempx1
         ldx   ptrdest
         cmpa  #10
         bhs   hex2dec2b   ;
         lda   #'0'
         sta   ,x
         inx
hex2dec2b:
         stx   ptrdest
         ldx   tempx1
         pula
         bsr   hex2dec
         rts
;
; Entry: a - signed value to convert -128 to 127
;        ptrdest - buffer to place ASCII representation
; Exit:  ptrdest - points just after last digit added
hex2dec: psha           ; save a and b
         pshb
         stx   tempx1
         ldx   ptrdest     ; point to destination
         clr   digits      ; clear number of digits added
         tsta
         bpl   hundreds    ; if it is a positive value, continue with processing
         ldb   #'-'        ; otherwise, add a minus symbol
         stb   ,x
         inx
         nega              ; convert to positive value
hundreds:
         cmpa  #100        ; check if hundreds set
         blo   tens        ; if not, continue processing
         inc   digits      ; bump digits
         ldb   #'1'        ; add the hundreds digit
         stb   ,x
         inx
         suba  #100
tens:    clrb
tens1:   cmpa  #10         ; check if tens column set
         blo   tens2       ; if not, continue to units
         incb
         suba  #10
         bra   tens1
;
tens2:   tst   digits      ; were digits added previously
         beq   tens3
tens4:   addb  #'0'
         stb   ,x
         inx
         inc   digits
         bra   units
;
tens3:   tstb              ; don't add trailing 0's if no digits previously added
         beq   units
         bra   tens4
;
units:   adda #'0'         ; add the units digit
         sta   ,x
         inx
         stx   ptrdest     ; save final location
         ldx   tempx1
         pulb
         pula
         rts
;
dump_regx:
         stx   dumpx
         sta   dumpa
         stb   dumpb
         lda   #' '
         jsr   OUTCH
         lda   #'X'
         jsr   OUTCH
         lda   #'='
         jsr   OUTCH
         lda   dumpx
         ldb   dumpx+1
         jsr   out4h
         jsr   pcrlf
         
         ldb   dumpb
         lda   dumpa
         ldx   dumpx
         rts
;
dump_rega:
         sta   dumpa
;         lda   #' '
;         jsr   OUTCH
         lda   dumpa
         jsr   out2h
;         lda   #' '
;         jsr   OUTCH
;         jsr   pcrlf
         
         lda   dumpa
         rts
;
dump_regb:
         sta   dumpa
         stb   dumpb
         lda   #' '
         jsr   OUTCH
         lda   dumpb
         jsr   out2h
         lda   #' '
         jsr   OUTCH
         jsr   pcrlf
         
         lda   dumpa
         ldb   dumpb
         rts
;
; Debug dump variables
dumpa    rmb   1
dumpb    rmb   1
dumpx    rmb   2
;
digits:  rmb   1
ptrdest: rmb   2
tempx:   rmb   2
tempx1:  rmb   2
tempx2:  rmb   2

;
; Copy zero terminated string at x to ptrdest.
; Entry
;  x points to zero-terminated string to copy
;  ptrdest points to destination
; Return:
;  ptrdest points to byte after end of string
;
strcpy:
         psha
         stx   tempx1
         stx   tempx
strcpy2:
         ldx   tempx
         lda   ,x          ; Load character from source, increment X
         inx
         stx   tempx
         ldx   ptrdest
         sta   ,x          ; Store character in destination, increment Y
         inx
         stx   ptrdest
         tst   a
         bne   strcpy2     ; If the character was not $00, loop again
         ldx   tempx1      ; Return when the null terminator is copied
         pula
         rts
;
;
; Copy zero terminated string at x to y without copying the termination character.
; Entry
;  x points to zero-terminated string to copy
;  ptrdest points to destination
; Return:
;  ptrdest points to byte after end of string
;
strcpynt:
         psha
         stx   tempx1
         stx   tempx
strcpynt1:
         ldx   tempx
         lda   ,x          ; get a character from source, increment x
         inx
         stx   tempx
         tst   a
         beq   strcpynt2   ; if it is the EOT then return
         ldx   ptrdest
         sta   ,x          ; store the character in destination, increment pointer
         inx
         stx   ptrdest
         bra   strcpynt1   ; loop back until EOT
strcpynt2:
         ldx   tempx1
         pula
         rts               ; Return when the null terminator is reached
;
