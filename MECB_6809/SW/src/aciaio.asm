
;
; output as hex digits contents of D register
;
out4h    pshs  d
         bsr   out2h
         exg   b,a
         bsr   out2h
         puls  pc,d

;
; output two hex digits in A
;
out2h    pshs  a
         asra
         asra
         asra
         asra
         bsr   outnyb
         puls  a
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
         outch
         rts

;
; print string pointed to by X
;
print    pshs  a,x
print2   lda   ,x+
         beq   print3
         outch
         bra   print2
print3   puls  a,x,pc

;
; Write 2-digit decimal with trailing 0
;
hex2dec2:
         pshs  a
         cmpa  #10
         bhs   hex2dec2b   ;
         lda   #'0'
         sta   ,y+
hex2dec2b:
         puls  a
         bsr   hex2dec
         rts
;
; Entry: a - signed value to convert -128 to 127
;        y - buffer to place ASCII representation
; Exit:  y - points just after last digit added
hex2dec: pshs  d           ; save a and b
         clr   digits      ; clear number of digits added
         tsta
         bpl   hundreds    ; if it is a positive value, continue with processing
         ldb   #'-'        ; otherwise, add a minus symbol
         stb   ,y+
         nega              ; convert to positive value
hundreds:
         cmpa  #100        ; check if hundreds set
         blo   tens        ; if not, continue processing
         inc   digits      ; bump digits
         ldb   #'1'        ; add the hundreds digit
         stb   ,y+
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
         stb   ,y+
         inc   digits
         bra   units
;
tens3:   tstb              ; don't add trailing 0's if no digits previously added
         beq   units
         bra   tens4
;
units:   adda #'0'         ; add the units digit
         sta   ,y+
         puls  d,pc
;
digits:  rmb   1

;
; Copy zero terminated string at x to y.
; Entry
;  x points to zero-terminated string to copy
;  y points to destination
; Return:
;  y points to byte after end of string
; Destroyed:
;  x
;
strcpy:
         pshs  a,x
strcpy2:
         lda   ,x+         ; Load character from source, increment X
         sta   ,y+         ; Store character in destination, increment Y
         bne   strcpy2     ; If the character was not $00, loop again
         puls  a,x,pc        ; Return when the null terminator is copied
;
;
; Copy zero terminated string at x to y without copying the termination character.
; Entry
;  x points to zero-terminated string to copy
;  y points to destination
; Return:
;  y points to byte after end of string
; Destroyed:
;  x, a
;
strcpynt:
         pshs  a,x
strcpynt1:
         lda   ,x+         ; get a character from source, increment x
         beq   strcpynt2   ; if it is the EOT then return
         sta   ,y+         ; store the character in destination, increment y
         bra   strcpynt1   ; loop back until EOT
strcpynt2:
         puls  a,x,pc        ; Return when the null terminator is reached
;
