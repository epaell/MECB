         cpu   8086

%include 'src/mecb.inc'
;
; ASCII control characters
CR       equ   0Dh               ; carraige return
LF       equ   0Ah               ; form feed
EOT      equ   00h               ; End of Text
;
         org   100h

section  .text

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
         
         mov   si,str_welcome
         call  print
         mov   ax,[cs:savees]
         mov   es,ax
         mov   ax,[ds:saveds]
         mov   ds,ax
         call  flush
         jmp   0f000h:0c00ch

;
; Print a null-terminated string
; Arguments: pointer to string in DS:SI
print:
         push  ax
         push  si
.1:      lodsb                ; get character
         or    al,al          ; end if 0
         jz    .2
         call  outch1
         jmp   .1
.2:      pop   si
         pop   ax
         ret

;
; flush ACIA output buffer
;
flush:
         push  ax
.1:
         in    al,ACIA1_STATUS
         and   al,02h
         jz    .1
         pop   ax
         ret

; UART character output handler.
outch1:
         push  ax              ; Store character
.1:
         in    al,ACIA1_STATUS ; Status byte       
         and   al,02h          ; Set Zero flag if still transmitting character       
         jz    .1              ; Loop until flag signals ready
         pop   ax              ; Retrieve character
         out   ACIA1_DATA,al   ; Output the character
         ret


section  .data

str_welcome:
         db    CR,LF,'Hello, World!',CR,LF,CR,LF,EOT
;
section .bss
saveds  resw  1              ; space to save segment registers
savees  resw  1
