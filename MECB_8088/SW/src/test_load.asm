         cpu   8086

;
; ASCII control characters
CR       equ   0Dh               ; carraige return
LF       equ   0Ah               ; form feed
EOT      equ   00h               ; End of Text

         org   100h
;
; INT 06h: print character in AL
%macro PUTC 0
         int   06h
%endmacro

; INT 0Ah: return control to monitor
%macro MONITOR 0
         int   09h
%endmacro

section  .text
         global   start

start:
         mov   si, str_welcome
         call  pstr
         MONITOR
;
; Print a null-terminated string from ROM.
; Arguments: pointer to string in SI (stack_group)
pstr:
pstr1:   lodsb           ; get character
         or    al, al  ; end if 0
         jz    pstr2
         PUTC
         jmp   pstr1
pstr2:   ret

section  .data
data_group:
str_welcome:
         db    CR,LF,'Hello, World!', CR, LF, 0
;
