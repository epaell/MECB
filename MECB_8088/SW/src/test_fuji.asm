            cpu   8086
;
%include    'src/mecb.inc'
;
; int 09h: return control to monitor
%macro monitor 0
            call  flush
            int   09h
%endmacro
;
            org   100h
;
section     .text
;
start:
            cli
            cld
            mov   ax,ds
            mov   [cs:saveds],ax
            mov   ax,cs
            mov   ds,ax                ; Set up data segment
            mov   ax,es
            mov   [cs:savees],ax
            mov   ax,cs
            mov   es,ax
            
            mov   si,str_start         ; Print string to signal start
            call  print
            mov   di,tbuffer
            mov   si,str1
            call  strcpy
            dec   di                   ; back off destination pointer to overwrite EOT
            mov   al,-99
            call  chex2dec             ; add -99 to buffer
            mov   al,','
            stosb
            mov   al,45                ; add 45 to buffer
            call  chex2dec
            mov   al,','
            stosb
            mov   al,5                 ; add 5 to buffer
            call  chex2dec
            mov   al,','
            stosb
            mov   al,0                 ; add 0 to buffer
            call  chex2dec
            mov   al,0                 ; add an EOT to terminate string
            stosb
            call  pcrlf
            mov   si,tbuffer
            call  print
            call  pcrlf
            call  pcrlf
            mov   ax,[cs:savees]
            mov   es,ax
            mov   ax,[ds:saveds]
            mov   ds,ax
;            call  flush
            jmp   0f000h:0c00ch
;

;
%include 'src/acia_io.asm'
;
section .data

str_start:
            db       CR,LF,'Testing library functions',CR,LF,EOT
str1:
            db       CR,LF,'Test out:',CR,LF,EOT

section .bss
saveds      resw  1              ; space to save segment registers
savees      resw  1
tbuffer     resb  64             ; Text buffer for output
;
fujinet_dcb:
            resb  18
;
txdata      resb  512             ; transmit buffer
rxdata      resb  512             ; receive buffer
;
