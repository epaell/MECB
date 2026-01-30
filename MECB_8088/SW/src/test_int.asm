         cpu   8086
;
         org   100h
;
ACIA        equ     08h               ; Assume MECB ACIA mapped to $08 on I/O port
RESET       equ     03h               ; Master reset for ACIA
CONTROL     equ     0D1h              ; Control settings for ACIA (receive interrupt enabled) %1101 0001
;
section  .text
         global   start

start:
         cli
;
; Initialise the ACIA / UART / Serial interface
;
init_acia:
         mov   al, RESET            ; reset ACIA
         out   ACIA, al
         mov   al, CONTROL          ; set up ACIA
         out   ACIA, al
;
         mov   ax,cs                ; interrupt handler is in code segment
         xor   di,di
         mov   es,di
         mov   di,acia_int
         mov   word es:[03FCh],di   ; Update vector for interrupt 0ffh (hardware interrupt)
         mov   es:[03FEh],ax
         
         sti
loop:    jmp   loop                 ; Loop and allow interrupts to occur
;
; Interrupt handler for ACIA receive
;
acia_int:
         push  ax
         in    al,ACIA+1            ; Read the character
         xchg  al,ah
outch_int1:
         in    al,ACIA              ; Status byte       
         and   al,02h               ; Check if still transmitting character       
         jz    outch_int1           ; Loop until flag signals ready
         mov   al,'i'
         out   ACIA+1,al            ; Output the character
         pop   ax
         iret
         
section  .data
data_group:
;
