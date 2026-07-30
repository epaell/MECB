
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
; Entry: d0.l - signed value to string
;        a1.l - pointer to buffer
; Exit   a1.l - points to just after last digit added

shex2dec movem.l  d1-d4/d6-d7,-(a7)    ; save registers
         move.l   d0,d7                ; save it here
         bpl      hx2dc
         neg.l    d7                   ; change to positive
         bmi      hx2dc57              ; special case (-0)
         move.b   #'-',(a1)+           ; add negative sign
hx2dc    clr.w    d4                   ; for zero suppress
         move.l   #10,d6               ; counter
hx2dc0   move.l   #1,d2                ; value to sub
         move.l   d6,d1                ; counter
         sub.l    #1,d1                ; adjust - form power of ten
         beq      hx2dc2               ; if power is zero
hx2dc1   move.w   d2,d3                ; d3=lower word
         mulu     #10,d3
         swap     d2                   ; d2=upper word
         mulu     #10,d2
         swap     d3                   ; add upper to upper
         add.w    d3,d2
         swap     d2                   ; put upper in upper
         swap     d3                   ; put lower in lower
         move.w   d3,d2                ; d2=upper & lower
         sub.l    #1,d1
         BNE      hx2dc1
hx2dc2   clr.l    d0                   ; holds sub amount
hx2dc22  cmp.l    d2,d7
         blt      hx2dc3               ; if no more sub possible
         add.l    #1,d0                ; bump subs
         sub.l    d2,d7                ; count down by powers of ten
         bra      hx2dc22              ; do more
hx2dc3   tst.b    d0                   ; any value?
         bne      hx2dc4
         tst.w    d4                   ; zero suppress
         beq      hx2dc5
hx2dc4   add.b    #$30,d0              ; binary to ASCII
         move.b   d0,(a1)+             ; put in buffer
         move.b   d0,d4                ; mark as non-zero suppress
hx2dc5   sub.l    #1,d6                ; next power
         bne      hx2dc0
         tst.w    d4                   ; see if anything printed
         bne      hx2dc6
hx2dc57  move.b   #'0',(a1)+           ; print at least a zero
hx2dc6   movem.l  (a7)+,d1-d4/d6-d7    ; restore registers
         rts                           ; end of routine

;--------------------------------------------------------
; outdec - output binary value in d0 converted to decimal
;
; d0.l = binary value
;
outdec   movem.l  a0-a1,-(a7)          ; save registers
         sub.l    #16,a7               ; make space on stack for string
         move.l   a7,a1
         bsr      shex2dec
         move.b   #EOT,(a1)+           ; add the terminator character
         move.l   a7,a0                ; print the final result
         bsr      print
         add.l    #16,a7               ; restore stack
         movem.l  (a7)+,a0-a1          ; restore registers
         rts                           ; end of routine

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
; Return length of null terminated string pointed to by a0.L
;
; Entry
;  a0 points to zero-terminated string
; Return:
;  d0.l points to byte after end of string
; Destroyed:
;  None
;
strlen:
         movem.l  a0,-(a7)
         move.l   #0,d0
strlen2:
         tst.b    (a0)+             ; check for NULL
         beq      strlen3
         add.l    #1,d0
         bra      strlen2
strlen3
         movem.l  (a7)+,a0
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
