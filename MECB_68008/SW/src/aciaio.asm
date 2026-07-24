
;
; output 8 hex digits in d0
;
out8h    swap  d0
         bsr   out4h          ; Write out upper word
         swap  d0
         bsr   out4h          ; Write out lower word
         rts

;
; output 6 hex digits in d0
;
out6h    swap  d0
         bsr   out2h          ; write out lower byte of upper word
         swap  d0
         bsr   out4h          ; Write out lower word
         rts

;
;
; output 4 hex digits in d0.w
;
out4h    move.l   d0,-(a7)
         lsr.w    #8,d0       ; Write upper 8 bits
         bsr      out2h
         move.l   (a7)+,d0
         bsr      out2h       ; Write lower 8 bits
         rts

;
; output two hex digits in d0.b
;
out2h    move.l   d0,-(a7)
         lsr.b    #4,d0
         bsr      out1h
         move.l   (a7)+,d0
         bsr      out1h
         rts

;
; output least significant nybble in d0.b
;
out1h    move.l   d0,-(a7)
         and.b    #$0F,d0
         cmp.b    #$0A,d0
         bcs      outnyb2
         add.b    #$07,d0
outnyb2  add.b    #$30,d0
         bsr      outch1
         move.l   (a7)+,d0
         rts

;
; print string pointed to by a0
;
print    movem.l  d0/a0,-(a7)
print2   move.b   (a0)+,d0
         beq      print3
         bsr      outch1
         bra      print2
print3   movem.l  (a7)+,d0/a0
         rts

;
; output character in d0
;
outch1   btst.b   #1,ACIA1_STATUS      ; Read the ACIA status
         beq      outch1               ; Wait until ready
         move.b   d0,ACIA1_DATA        ; Send a character
         rts

;
;
;
pcrlf    move.l   d0,-(a7)
         move.b   #CR,d0
         bsr      outch1
         move.b   #LF,d0
         bsr      outch1
         move.l   (a7)+,d0
         rts
;
; Write 2-digit decimal with trailing 0
; d0 - contains value
; a1 - buffer destination
;
hex2dec2:
         move.l   d0,-(a7)
         cmp.b    #10,d0
         bhs      hex2dec2b   ;
         move.b   #'0',(a1)+
hex2dec2b:
         bsr      chex2dec
         move.l   (a7)+,d0
         rts
;
; Entry: d0 - signed value to convert -128 to 127
;        a1 - buffer to place ASCII representation
; Exit:  a1 - points just after last digit added
chex2dec: movem.l  d0-d2,-(a7)
         move.l   #0,d2       ; clear number of digits added
         tst.b    d0
         bpl      hundreds    ; if it is a positive value, continue with processing
         move.b   #'-',(a1)+  ; otherwise, add a minus symbol
         neg.b    d0          ; convert to positive value
hundreds:
         cmp.b    #100,d0     ; check if hundreds set
         blo      tens        ; if not, continue processing
         add.b    #1,d2       ; bump digits
         move.b   #'1',(a1)+  ; add the hundreds digit
         sub.b    #100,d0
tens:    move.b   #0,d1
tens1:   cmp.b    #10,d0      ; check if tens column set
         blo      tens2       ; if not, continue to units
         add.b    #1,d1
         sub.b    #10,d0
         bra      tens1
;
tens2:   tst.b    d2          ; were digits added previously
         beq      tens3
tens4:   add.b    #'0',d1
         move.b   d1,(a1)+
         add.b    #1,d2
         bra      units
;
tens3:   tst.b    d1          ; don't add trailing 0's if no digits previously added
         beq      units
         bra      tens4
;
units:   add.b    #'0',d0     ; add the units digit
         move.b   d0,(a1)+
         movem.l  (a7)+,d0-d2
         rts

;
; Copy zero terminated string at a0 to a1.
; Entry
;  a0 points to zero-terminated string to copy
;  a1 points to destination
; Return:
;  a1 points to byte after end of string
; Destroyed:
;  a0
;
strcpy:
         movem.l  d0/a0,-(a7)
strcpy2:
         move.b   (a0)+,d0          ; Load character from source, increment X
         move.b   d0,(a1)+          ; Store character in destination, increment Y
         bne      strcpy2           ; If the character was not $00, loop again
         movem.l  (a7)+,d0/a0
         rts

;
; Copy d0 bytes starting from a0 to a1.
; Entry
;  a0.l points to source
;  a1.l points to destination
;  d0.l number of bytes to transfer
; Return:
;  a1 points to byte after end of data copied
; Destroyed:
;  -
;
strncpy:
         movem.l  d0/a0,-(a7)
strncpy2:
         tst.l    d0                ; check if anything to transfer
         beq      strncpyexit
         move.b   (a0)+,(a1)+       ; Load character from source, increment X
         sub.l    #1,d0             ; decrement counter
         bra      strncpy2          ; loop until done
strncpyexit:
         movem.l  (a7)+,d0/a0
         rts
;
;
; Copy zero terminated string at a0 to a1 without copying the termination character.
; Entry
;  a0 points to zero-terminated string to copy
;  a1 points to destination
; Return:
;  a1 points to byte after end of string
; Destroyed:
;  -
;
strcpynt:
         movem.l  d0/a0,-(a7)
strcpynt1:
         move.b   (a0)+,d0          ; get a character from source, increment x
         beq      strcpynt2         ; if it is the EOT then return
         move.b   d0,(a1)+          ; store the character in destination, increment y
         bra      strcpynt1         ; loop back until EOT
strcpynt2:
         movem.l  (a7)+,d0/a0       ; Return when the null terminator is reached
         rts
;
