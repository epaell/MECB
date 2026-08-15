;
ACIA     equ     08h               ; Assume MECB ACIA mapped to $08 on I/O port
RESET    equ     03h               ; Master reset for ACIA
CONTROL  equ     051h              ; Control settings for ACIA (receive interrupt disabled) %0101 0001
;
section  .text
;
; Initialise the ACIA / UART / Serial interface
;
init_acia:
         mov   al, RESET                  ; reset ACIA
         out   ACIA, al
         mov   al, CONTROL                ; set up ACIA
         out   ACIA, al
         ret

; UART character output handler.
outch1:
         push  ax              ; Store character
.1:
         in    al,ACIA         ; Status byte       
         and   al,02h          ; Set Zero flag if still transmitting character       
         jz    .1              ; Loop until flag signals ready
         pop   ax              ; Retrieve character
         out   ACIA+1,al       ; Output the character
         ret

;
; flush ACIA output buffer
;
flush:
         push  ax
.1:
         in    al,ACIA
         and   al,02h
         jz    .1
         pop   ax
         ret

;
; Write CRLF to output
;
pcrlf:   push  ax
         mov   al,CR
         call  outch1
         mov   al,LF
         call  outch1
         pop   ax
         ret
;
;  UART character input handler.
;
inch1:
         in    al,ACIA         ; Status byte       
         and   al,01h          ; Check if receive buffer full
         jz    inch1           ; Loop until flag signals ready
         in    al,ACIA+1       ; Read the character
         ret

;
; Print a null-terminated string
; Arguments: pointer to string in DS:SI
print:
         push  ax
         push  si
.loop:   lodsb                ; get character
         or    al, al         ; end if 0
         jz    .done
         call  outch1
         jmp   .loop
.done:   pop   si
         pop   ax
         ret

;----------------------------------------------------------------------
; Output ax/al in hex
;----------------------------------------------------------------------
out4h:   xchg    al,ah                       ; Write AX in hex
         call    out2h
         xchg    al,ah
         call    out2h
         ret

out2h:   push    ax                          ; Save the working register
         shr     al,1
         shr     al,1
         shr     al,1
         shr     al,1
         call    out1h                       ; Output it
         pop     ax                          ; Get the LSD
         call    out1h                       ; Output
         ret

out1h:   push    ax                          ; Save the working register
         and     al, 0FH                     ; Mask off any unused bits
         cmp     al, 0AH                     ; Test for alpha or numeric
         jl      .out1h                      ; Take the branch if numeric
         add     al, 7                       ; Add the adjustment for hex alpha
.out1h:  add     al, '0'                     ; Add the numeric bias
         call    outch1                      ; Send to the console
         pop     ax
         ret

;
; Write 2-digit decimal with trailing 0
; d0 - contains value
; es:di - buffer destination
;
hex2dec2:
         push     ax
         cmp      al,10
         jae      .notrail                   ; >=10 so no trailing 0 required
         mov      al,'0'
         stosb                               ; otherwise add a trailing 0
.notrail:
         pop      ax
         call     chex2dec
         ret
;
; Entry: al - signed value to convert -128 to 127
;        es:di - buffer to place ASCII representation
; Exit:  es:di - points just after last digit added
chex2dec:
         push     ax
         push     bx
         mov      ah,al       ; ah = number
         mov      bh,0        ; clear number of digits added
         test     ah,ah
         jns      hundreds    ; if it is a positive value, continue with processing
         mov      al,'-'      ; add a minus symbol
         stosb
         neg      ah          ; convert to positive value
hundreds:
         cmp      ah,100      ; check if hundreds set
         jb       tens        ; if not, continue processing
         inc      bh          ; bump digits
         mov      al,'1'      ; add the hundreds digit
         stosb
         sub      ah,100
tens:    mov      bl,0        ; count of 10s
tens1:   cmp      ah,10       ; check if tens column set
         jb       tens2       ; if not, continue to units
         inc      bl
         sub      ah,10
         jmp      tens1
;
tens2:   test     bh,bh       ; were digits added previously
         jz       tens3
tens4:   mov      al,'0'
         add      al,bl
         stosb
         inc      bh
         jmp      units
;
tens3:   test     bl,bl       ; don't add trailing 0's if no digits previously added
         jz       units
         jmp      tens4
;
units:   mov      al,'0'      ; add the units digit
         add      al,ah
         stosb
         pop      bx
         pop      ax
         ret

;
; Entry: ax - signed value to convert to string
;        es:di - pointer to buffer
; Exit   es:di - points to just after last digit added

;shex2dec movem.l  d1-d4/d6-d7,-(a7)    ; save registers
;         move.l   d0,d7                ; save it here
;         bpl      hx2dc
;         neg.l    d7                   ; change to positive
;         bmi      hx2dc57              ; special case (-0)
;         move.b   #'-',(a1)+           ; add negative sign
;hx2dc    clr.w    d4                   ; for zero suppress
;         move.l   #10,d6               ; counter
;hx2dc0   move.l   #1,d2                ; value to sub
;         move.l   d6,d1                ; counter
;         sub.l    #1,d1                ; adjust - form power of ten
;         beq      hx2dc2               ; if power is zero
;hx2dc1   move.w   d2,d3                ; d3=lower word
;         mulu     #10,d3
;         swap     d2                   ; d2=upper word
;         mulu     #10,d2
;         swap     d3                   ; add upper to upper
;         add.w    d3,d2
;         swap     d2                   ; put upper in upper
;         swap     d3                   ; put lower in lower
;         move.w   d3,d2                ; d2=upper & lower
;         sub.l    #1,d1
;         BNE      hx2dc1
;hx2dc2   clr.l    d0                   ; holds sub amount
;hx2dc22  cmp.l    d2,d7
;         blt      hx2dc3               ; if no more sub possible
;         add.l    #1,d0                ; bump subs
;         sub.l    d2,d7                ; count down by powers of ten
;         jmp      hx2dc22              ; do more
;hx2dc3   tst.b    d0                   ; any value?
;         bne      hx2dc4
;         tst.w    d4                   ; zero suppress
;         beq      hx2dc5
;hx2dc4   add.b    #$30,d0              ; binary to ASCII
;         move.b   d0,(a1)+             ; put in buffer
;         move.b   d0,d4                ; mark as non-zero suppress
;hx2dc5   sub.l    #1,d6                ; next power
;         bne      hx2dc0
;         tst.w    d4                   ; see if anything printed
;         bne      hx2dc6
;hx2dc57  move.b   #'0',(a1)+           ; print at least a zero
;hx2dc6   movem.l  (a7)+,d1-d4/d6-d7    ; restore registers
;         ret                           ; end of routine

;
; Copy zero terminated string at a0 to a1.
; Entry
;  ds:si points to zero-terminated string to copy
;  es:di points to destination
; Return:
;  es:di points to byte after end of string
; Destroyed:
;  -
;
strcpy:
         push     ax
         push     si
.1:      lodsb                         ; Load byte [SI] into AL, increment SI
         stosb                         ; Store AL into [DI], increment DI
         test     al, al               ; Check if byte is 0 (null terminator)
         jnz      .1                   ; If not zero, repeat copy
         pop      si
         pop      ax
         ret

;
; Return length of null terminated string pointed to by a0.L
;
; Entry
;  es:di points to zero-terminated string
; Return:
;  ax returns string length
;  es:di points to end of string
; Destroyed:
;  None
;
strlen:
         cld                 ; Ensure direction flag increments DI forward
         xor     al, al      ; AL = 0 (the null-terminator value to scan for)
         mov     cx, 0FFFFh  ; Set CX to maximum possible 16-bit counter (65535 bytes)
         repne   scasb       ; Scan bytes until [DI] == AL or CX drops to 0
         ; Length = Max_CX (65535) - Remaining_CX - 1 (for the extra post-decrement)
         mov     ax, 0FFFFh  
         sub     ax, cx      
         dec     ax          ; Adjust count to exclude the null terminator itself
         ret
;
; Copy cx bytes starting from ds:si to es:di.
; Entry
;  ds:si points to source
;  es:di points to destination
;  cx number of bytes to transfer
; Return:
;  es:di points to byte after end of data copied
; Destroyed:
;  -
;
strncpy:
         cld                 ; Ensure direction flag increments DI forward
         push     ax
         rep      movsb
         pop      ax
         ret
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
         push     ax
.1:      lodsb                         ; Load byte [SI] into AL, increment SI
         test     al,al                ; check if byte is 0 (null terminator)
         jz       .2                   ; If zero, exit without transfering byte
         stosb                         ; Store AL into [DI], increment DI
         jmp      .1                   ; repeat copy
.2:      pop      ax
         ret
;
; dump all register values
;
dump_reg: 
         push  ax
         push  si
         mov   si,sax
         call  print
         call  out4h

         mov   si,sbx
         call  print
         mov   ax,bx
         call  out4h

         mov   si,scx
         call  print
         mov   ax,cx
         call  out4h

         mov   si,sdx
         call  print
         mov   ax,dx
         call  out4h

         mov   si,ssi
         call  print
         pop   si
         mov   ax,si
         call  out4h
         push  si

         mov   si,sdi
         call  print
         mov   ax,di
         call  out4h

         mov   si,sbp
         call  print
         mov   ax,bp
         call  out4h

         mov   si,ssp
         call  print
         mov   ax,sp
         call  out4h

         mov   si,sss
         call  print
         mov   ax,ss
         call  out4h

         mov   si,sds
         call  print
         mov   ax,ds
         call  out4h

         mov   si,scs
         call  print
         mov   ax,cs
         call  out4h

         mov   si,ses
         call  print
         mov   ax,es
         call  out4h
         
         mov   si,scc
         call  print
         lahf
         call  out2h
         call  pcrlf
         
         pop   si
         pop   ax
         ret
;
sax      db    CR,LF,"AX=",EOT
sbx      db    " BX=",EOT
scx      db    " CX=",EOT
sdx      db    " DX=",EOT
ssi      db    " SI=",EOT
sdi      db    " DI=",EOT
sbp      db    " BP=",EOT
ssp      db    " SP=",EOT
sss      db    CR,LF,"SS=",EOT
sds      db    " DS=",EOT
scs      db    " CS=",EOT
ses      db    " ES=",EOT
scc      db    " FLAGS=",EOT
