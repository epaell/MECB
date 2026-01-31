;
ACIA     equ     08h               ; Assume MECB ACIA mapped to $08 on I/O port
RESET    equ     03h               ; Master reset for ACIA
CONTROL  equ     051h              ; Control settings for ACIA (receive interrupt disabled) %0101 0001
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
putch:
         push  ax              ; Store character
putch1:
         in    al,ACIA         ; Status byte       
         and   al,02h          ; Set Zero flag if still transmitting character       
         jz    putch1          ; Loop until flag signals ready
         pop   ax              ; Retrieve character
         out   ACIA+1,al       ; Output the character
         ret
;
; Write CRLF to output
;
pcrlf:   push  ax
         mov   al,CR
         call  putch
         mov   al,LF
         call  putch
         pop   ax
         ret
;
;  UART character input handler.
;
getch:
         in    al,ACIA         ; Status byte       
         and   al,01h          ; Check if receive buffer full
         jz    getch           ; Loop until flag signals ready
         in    al,ACIA+1       ; Read the character
         ret

;
; Print a null-terminated string from ROM.
; Arguments: pointer to string in DS:SI
puts:
         push  ax
         push  si
.1:      lodsb                ; get character
         or    al, al         ; end if 0
         jz    .done
         call  putch
         jmp   .1
.done:   pop   si
         pop   ax
         ret

;----------------------------------------------------------------------
; Display AX/AL in HEX
;----------------------------------------------------------------------
puthex4: xchg    al,ah                       ; Write AX in hex
         call    puthex2
         xchg    al,ah
         call    puthex2
         ret

puthex2: push    ax                          ; Save the working register
         shr     al,1
         shr     al,1
         shr     al,1
         shr     al,1
         call    puthex1                     ; Output it
         pop     ax                          ; Get the LSD
         call    puthex1                     ; Output
         ret

puthex1: push    ax                          ; Save the working register
         and     al, 0FH                     ; Mask off any unused bits
         cmp     al, 0AH                     ; Test for alpha or numeric
         jl      numeric                     ; Take the branch if numeric
         add     al, 7                       ; Add the adjustment for hex alpha
numeric: add     al, '0'                     ; Add the numeric bias
         call    putch                       ; Send to the console
         pop     ax
         ret

