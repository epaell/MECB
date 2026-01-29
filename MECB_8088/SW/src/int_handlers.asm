;======================================================================
; Monitor Interrupt Handlers
;======================================================================  
;----------------------------------------------------------------------
; Breakpoint/Trace Interrupt Handler
; Restore All instructions
; Display Breakpoint Number
; Update & Display Registers
; Return to monitor                
;----------------------------------------------------------------------
int1_3:  push    bp
         mov     bp,sp                       ; BP+2=IP, BP+4=CS, BP+6=Flags
         push    ss                          
         push    es
         push    ds
         push    di
         push    si
         push    bp                          ; Note this is the wrong value
         push    sp
         push    dx
         push    cx
         push    bx
         push    ax                           

         mov     ax,cs                       ; Restore Monitor's Data segment
         mov     ds,ax                       
                     
         mov     ax,ss:[bp+4]                ; Get user CS
         mov     es,ax                       ; Used for restoring bp replaced opcode
         mov     es:[ucs],ax                    ; Save User CS            
        
         mov     ax,ss:[bp+2]                ; Save User IP
         mov     es:[uip],ax
                                
         mov     di,sp                       ; SS:SP=AX
         mov     bx,uax                      ; Update User registers, DI=pointing to AX
         mov     cx,11
nextureg:   
         mov     ax,ss:[di]                  ; Get register
         mov     [es:bx],ax                  ; Write it to user reg
         add     bx,2
         add     di,2
         loop    nextureg
         
         mov     ax,bp                       ; Save User SP
         add     ax,8                        
         mov     es:[usp],ax

         mov     ax,ss:[bp]
         mov     es:[ubp],ax                 ; Restore real BP value
         
         mov     ax,ss:[bp+6]                ; Save Flags            
         mov     es:[ufl],ax
         and     word es:[ufl],0FEFFh        ; Clear TF
         test    ax,0100h                    ; Check If Trace flag set then
         jz      contbpc                     ; No, check which bp triggered it
                     
         jmp     exitint3                    ; Exit, Display regs, Cmd prompt
            
contbpc: dec     word es:[uip]               ; No, IP-1 and save
                                 
         mov     si,str_breakp               ; Display "***** BreakPoint # *****

         mov     bx,bptab                    ; Check which breakpoint triggered
         mov     cx,8                        ; and restore opcode
intnextbp:
         mov     ax,8
         sub     al,cl

         test    byte es:[bx+3],1            ; Check enable/disable flag
         jz      int3resbp
                         
         mov     di,es:[bx]                  ; Get Breakpoint Address
         cmp     es:[uip],di
         jne     int3res
         
         add     al, '0'                     ; Add the numeric bias
         mov     [si+18],al                  ; Save number
           
int3res: mov     al,byte [bx+2]              ; Get original Opcode
         mov     es:[di],al                  ; Write it back

int3resbp:
         add     bx,4                        ; Next entry
         loop    intnextbp

         PUTS                                ; Write BP Number message                 

exitint3:
         mov     ax,cs                       ; Restore Monitor settings
         mov     ss,ax
         mov     ax, tos                     ; Top of Stack
         mov     sp,ax                       ; Restore Monitor Stack pointer
         mov     ax,ss:baseseg               ; Restore Base Pointer
         mov     es,ax
         
         jmp     dispreg                     ; Jump to Display Registers

; ------------------------------------------------------------------------------
div0:    push    si
         mov     si, str_div0
         PUTS
         pop     si
         jmp     int1_3
;
nmi:     push    si
         mov     si, str_nmi
         PUTS
         pop     si
         jmp     int1_3
;
overflow:
         push  si
         mov   si, str_overflow
         PUTS
         pop   si
         jmp   int1_3
;
int_unhandled:
         push  si
         mov   si, str_unhandled
         PUTS
         pop   si
         jmp   int1_3

; Vectored UART character output handler.
outch_int:
         push  ax              ; Store character
outch_int1:
         in    al,ACIA         ; Status byte       
         and   al,02h          ; Set Zero flag if still transmitting character       
         jz    outch_int1      ; Loop until flag signals ready
         pop   ax              ; Retrieve character
         out   ACIA+1,al       ; Output the character
         iret

; Vectored UART character input handler.
inch_int:
         in    al,ACIA         ; Status byte       
         and   al,01h          ; Set Zero flag if still transmitting character       
         jz    inch_int        ; Loop until flag signals ready
         in    al,ACIA+1       ; Read the character
         iret


;
; Print a null-terminated string from ROM.
; Arguments: pointer to string in CS:SI
puts_int:
         push  ax
         push  ds
         push  si
         mov   ax, cs
         mov   ds, ax
.1:      lodsb                ; get character
         or    al, al         ; end if 0
         jz    .done
         PUTC
         jmp   .1
.done:   pop   si
         pop   ds
         pop   ax
         iret


;
; ------------------------------------------------------------------------------
; Include a handler for every possible interrupt type
;
initial_ivt:
; Processor reserved vectors
         dw    div0, ROMCS                   ; INT 00h: divide error
         dw    int1_3, ROMCS                 ; INT 01h: single step
         dw    nmi, ROMCS                    ; INT 02h: NMI
         dw    int1_3, ROMCS                 ; INT 03h: breakpoint
         dw    overflow, ROMCS               ; INT 04h: overflow
         dw    int_unhandled, ROMCS          ; INT 05h: reserved (bounds check on 80186)
; API vectors
         dw    outch_int, ROMCS              ; INT 06h: character output
         dw    puts_int, ROMCS               ; INT 07h: string output
         dw    inch_int, ROMCS               ; INT 08h: character input
         dw    start, ROMCS                  ; INT 09h: return control to monitor
         dw    int_unhandled, ROMCS          ; INT 0Ah:
         dw    int_unhandled, ROMCS          ; INT 0Bh:
         dw    int_unhandled, ROMCS          ; INT 0Ch:
         dw    int_unhandled, ROMCS          ; INT 0Dh:
         dw    int_unhandled, ROMCS          ; INT 0Eh:
         dw    int_unhandled, ROMCS          ; INT 0Fh:
;
         dw    int_unhandled, ROMCS          ; INT 10h:
         dw    int_unhandled, ROMCS          ; INT 11h:
         dw    int_unhandled, ROMCS          ; INT 12h:
         dw    int_unhandled, ROMCS          ; INT 13h:
         dw    int_unhandled, ROMCS          ; INT 14h:
         dw    int_unhandled, ROMCS          ; INT 15h:
         dw    int_unhandled, ROMCS          ; INT 16h:
         dw    int_unhandled, ROMCS          ; INT 17h:
         dw    int_unhandled, ROMCS          ; INT 18h:
         dw    int_unhandled, ROMCS          ; INT 19h:
         dw    int_unhandled, ROMCS          ; INT 1Ah:
         dw    int_unhandled, ROMCS          ; INT 1Bh:
         dw    int_unhandled, ROMCS          ; INT 1Ch:
         dw    int_unhandled, ROMCS          ; INT 1Dh:
         dw    int_unhandled, ROMCS          ; INT 1Eh:
         dw    int_unhandled, ROMCS          ; INT 1Fh:
;
         dw    int_unhandled, ROMCS          ; INT 20h:
         dw    int_unhandled, ROMCS          ; INT 21h:
         dw    int_unhandled, ROMCS          ; INT 22h:
         dw    int_unhandled, ROMCS          ; INT 23h:
         dw    int_unhandled, ROMCS          ; INT 24h:
         dw    int_unhandled, ROMCS          ; INT 25h:
         dw    int_unhandled, ROMCS          ; INT 26h:
         dw    int_unhandled, ROMCS          ; INT 27h:
         dw    int_unhandled, ROMCS          ; INT 28h:
         dw    int_unhandled, ROMCS          ; INT 29h:
         dw    int_unhandled, ROMCS          ; INT 2Ah:
         dw    int_unhandled, ROMCS          ; INT 2Bh:
         dw    int_unhandled, ROMCS          ; INT 2Ch:
         dw    int_unhandled, ROMCS          ; INT 2Dh:
         dw    int_unhandled, ROMCS          ; INT 2Eh:
         dw    int_unhandled, ROMCS          ; INT 2Fh:
;
         dw    int_unhandled, ROMCS          ; INT 30h:
         dw    int_unhandled, ROMCS          ; INT 31h:
         dw    int_unhandled, ROMCS          ; INT 32h:
         dw    int_unhandled, ROMCS          ; INT 33h:
         dw    int_unhandled, ROMCS          ; INT 34h:
         dw    int_unhandled, ROMCS          ; INT 35h:
         dw    int_unhandled, ROMCS          ; INT 36h:
         dw    int_unhandled, ROMCS          ; INT 37h:
         dw    int_unhandled, ROMCS          ; INT 38h:
         dw    int_unhandled, ROMCS          ; INT 39h:
         dw    int_unhandled, ROMCS          ; INT 3Ah:
         dw    int_unhandled, ROMCS          ; INT 3Bh:
         dw    int_unhandled, ROMCS          ; INT 3Ch:
         dw    int_unhandled, ROMCS          ; INT 3Dh:
         dw    int_unhandled, ROMCS          ; INT 3Eh:
         dw    int_unhandled, ROMCS          ; INT 3Fh:
;
         dw    int_unhandled, ROMCS          ; INT 40h:
         dw    int_unhandled, ROMCS          ; INT 41h:
         dw    int_unhandled, ROMCS          ; INT 42h:
         dw    int_unhandled, ROMCS          ; INT 43h:
         dw    int_unhandled, ROMCS          ; INT 44h:
         dw    int_unhandled, ROMCS          ; INT 45h:
         dw    int_unhandled, ROMCS          ; INT 46h:
         dw    int_unhandled, ROMCS          ; INT 47h:
         dw    int_unhandled, ROMCS          ; INT 48h:
         dw    int_unhandled, ROMCS          ; INT 49h:
         dw    int_unhandled, ROMCS          ; INT 4Ah:
         dw    int_unhandled, ROMCS          ; INT 4Bh:
         dw    int_unhandled, ROMCS          ; INT 4Ch:
         dw    int_unhandled, ROMCS          ; INT 4Dh:
         dw    int_unhandled, ROMCS          ; INT 4Eh:
         dw    int_unhandled, ROMCS          ; INT 4Fh:
;
         dw    int_unhandled, ROMCS          ; INT 50h:
         dw    int_unhandled, ROMCS          ; INT 51h:
         dw    int_unhandled, ROMCS          ; INT 52h:
         dw    int_unhandled, ROMCS          ; INT 53h:
         dw    int_unhandled, ROMCS          ; INT 54h:
         dw    int_unhandled, ROMCS          ; INT 55h:
         dw    int_unhandled, ROMCS          ; INT 56h:
         dw    int_unhandled, ROMCS          ; INT 57h:
         dw    int_unhandled, ROMCS          ; INT 58h:
         dw    int_unhandled, ROMCS          ; INT 59h:
         dw    int_unhandled, ROMCS          ; INT 5Ah:
         dw    int_unhandled, ROMCS          ; INT 5Bh:
         dw    int_unhandled, ROMCS          ; INT 5Ch:
         dw    int_unhandled, ROMCS          ; INT 5Dh:
         dw    int_unhandled, ROMCS          ; INT 5Eh:
         dw    int_unhandled, ROMCS          ; INT 5Fh:
;
         dw    int_unhandled, ROMCS          ; INT 60h:
         dw    int_unhandled, ROMCS          ; INT 61h:
         dw    int_unhandled, ROMCS          ; INT 62h:
         dw    int_unhandled, ROMCS          ; INT 63h:
         dw    int_unhandled, ROMCS          ; INT 64h:
         dw    int_unhandled, ROMCS          ; INT 65h:
         dw    int_unhandled, ROMCS          ; INT 66h:
         dw    int_unhandled, ROMCS          ; INT 67h:
         dw    int_unhandled, ROMCS          ; INT 68h:
         dw    int_unhandled, ROMCS          ; INT 69h:
         dw    int_unhandled, ROMCS          ; INT 6Ah:
         dw    int_unhandled, ROMCS          ; INT 6Bh:
         dw    int_unhandled, ROMCS          ; INT 6Ch:
         dw    int_unhandled, ROMCS          ; INT 6Dh:
         dw    int_unhandled, ROMCS          ; INT 6Eh:
         dw    int_unhandled, ROMCS          ; INT 6Fh:
;
         dw    int_unhandled, ROMCS          ; INT 70h:
         dw    int_unhandled, ROMCS          ; INT 71h:
         dw    int_unhandled, ROMCS          ; INT 72h:
         dw    int_unhandled, ROMCS          ; INT 73h:
         dw    int_unhandled, ROMCS          ; INT 74h:
         dw    int_unhandled, ROMCS          ; INT 75h:
         dw    int_unhandled, ROMCS          ; INT 76h:
         dw    int_unhandled, ROMCS          ; INT 77h:
         dw    int_unhandled, ROMCS          ; INT 78h:
         dw    int_unhandled, ROMCS          ; INT 79h:
         dw    int_unhandled, ROMCS          ; INT 7Ah:
         dw    int_unhandled, ROMCS          ; INT 7Bh:
         dw    int_unhandled, ROMCS          ; INT 7Ch:
         dw    int_unhandled, ROMCS          ; INT 7Dh:
         dw    int_unhandled, ROMCS          ; INT 7Eh:
         dw    int_unhandled, ROMCS          ; INT 7Fh:
;
         dw    int_unhandled, ROMCS          ; INT 80h:
         dw    int_unhandled, ROMCS          ; INT 81h:
         dw    int_unhandled, ROMCS          ; INT 82h:
         dw    int_unhandled, ROMCS          ; INT 83h:
         dw    int_unhandled, ROMCS          ; INT 84h:
         dw    int_unhandled, ROMCS          ; INT 85h:
         dw    int_unhandled, ROMCS          ; INT 86h:
         dw    int_unhandled, ROMCS          ; INT 87h:
         dw    int_unhandled, ROMCS          ; INT 88h:
         dw    int_unhandled, ROMCS          ; INT 89h:
         dw    int_unhandled, ROMCS          ; INT 8Ah:
         dw    int_unhandled, ROMCS          ; INT 8Bh:
         dw    int_unhandled, ROMCS          ; INT 8Ch:
         dw    int_unhandled, ROMCS          ; INT 8Dh:
         dw    int_unhandled, ROMCS          ; INT 8Eh:
         dw    int_unhandled, ROMCS          ; INT 8Fh:
;
         dw    int_unhandled, ROMCS          ; INT 90h:
         dw    int_unhandled, ROMCS          ; INT 91h:
         dw    int_unhandled, ROMCS          ; INT 92h:
         dw    int_unhandled, ROMCS          ; INT 93h:
         dw    int_unhandled, ROMCS          ; INT 94h:
         dw    int_unhandled, ROMCS          ; INT 95h:
         dw    int_unhandled, ROMCS          ; INT 96h:
         dw    int_unhandled, ROMCS          ; INT 97h:
         dw    int_unhandled, ROMCS          ; INT 98h:
         dw    int_unhandled, ROMCS          ; INT 99h:
         dw    int_unhandled, ROMCS          ; INT 9Ah:
         dw    int_unhandled, ROMCS          ; INT 9Bh:
         dw    int_unhandled, ROMCS          ; INT 9Ch:
         dw    int_unhandled, ROMCS          ; INT 9Dh:
         dw    int_unhandled, ROMCS          ; INT 9Eh:
         dw    int_unhandled, ROMCS          ; INT 9Fh:
;
         dw    int_unhandled, ROMCS          ; INT A0h:
         dw    int_unhandled, ROMCS          ; INT A1h:
         dw    int_unhandled, ROMCS          ; INT A2h:
         dw    int_unhandled, ROMCS          ; INT A3h:
         dw    int_unhandled, ROMCS          ; INT A4h:
         dw    int_unhandled, ROMCS          ; INT A5h:
         dw    int_unhandled, ROMCS          ; INT A6h:
         dw    int_unhandled, ROMCS          ; INT A7h:
         dw    int_unhandled, ROMCS          ; INT A8h:
         dw    int_unhandled, ROMCS          ; INT A9h:
         dw    int_unhandled, ROMCS          ; INT AAh:
         dw    int_unhandled, ROMCS          ; INT ABh:
         dw    int_unhandled, ROMCS          ; INT ACh:
         dw    int_unhandled, ROMCS          ; INT ADh:
         dw    int_unhandled, ROMCS          ; INT AEh:
         dw    int_unhandled, ROMCS          ; INT AFh:
;
         dw    int_unhandled, ROMCS          ; INT B0h:
         dw    int_unhandled, ROMCS          ; INT B1h:
         dw    int_unhandled, ROMCS          ; INT B2h:
         dw    int_unhandled, ROMCS          ; INT B3h:
         dw    int_unhandled, ROMCS          ; INT B4h:
         dw    int_unhandled, ROMCS          ; INT B5h:
         dw    int_unhandled, ROMCS          ; INT B6h:
         dw    int_unhandled, ROMCS          ; INT B7h:
         dw    int_unhandled, ROMCS          ; INT B8h:
         dw    int_unhandled, ROMCS          ; INT B9h:
         dw    int_unhandled, ROMCS          ; INT BAh:
         dw    int_unhandled, ROMCS          ; INT BBh:
         dw    int_unhandled, ROMCS          ; INT BCh:
         dw    int_unhandled, ROMCS          ; INT BDh:
         dw    int_unhandled, ROMCS          ; INT BEh:
         dw    int_unhandled, ROMCS          ; INT BFh:
;
         dw    int_unhandled, ROMCS          ; INT C0h:
         dw    int_unhandled, ROMCS          ; INT C1h:
         dw    int_unhandled, ROMCS          ; INT C2h:
         dw    int_unhandled, ROMCS          ; INT C3h:
         dw    int_unhandled, ROMCS          ; INT C4h:
         dw    int_unhandled, ROMCS          ; INT C5h:
         dw    int_unhandled, ROMCS          ; INT C6h:
         dw    int_unhandled, ROMCS          ; INT C7h:
         dw    int_unhandled, ROMCS          ; INT C8h:
         dw    int_unhandled, ROMCS          ; INT C9h:
         dw    int_unhandled, ROMCS          ; INT CAh:
         dw    int_unhandled, ROMCS          ; INT CBh:
         dw    int_unhandled, ROMCS          ; INT CCh:
         dw    int_unhandled, ROMCS          ; INT CDh:
         dw    int_unhandled, ROMCS          ; INT CEh:
         dw    int_unhandled, ROMCS          ; INT CFh:
;
         dw    int_unhandled, ROMCS          ; INT D0h:
         dw    int_unhandled, ROMCS          ; INT D1h:
         dw    int_unhandled, ROMCS          ; INT D2h:
         dw    int_unhandled, ROMCS          ; INT D3h:
         dw    int_unhandled, ROMCS          ; INT D4h:
         dw    int_unhandled, ROMCS          ; INT D5h:
         dw    int_unhandled, ROMCS          ; INT D6h:
         dw    int_unhandled, ROMCS          ; INT D7h:
         dw    int_unhandled, ROMCS          ; INT D8h:
         dw    int_unhandled, ROMCS          ; INT D9h:
         dw    int_unhandled, ROMCS          ; INT DAh:
         dw    int_unhandled, ROMCS          ; INT DBh:
         dw    int_unhandled, ROMCS          ; INT DCh:
         dw    int_unhandled, ROMCS          ; INT DDh:
         dw    int_unhandled, ROMCS          ; INT DEh:
         dw    int_unhandled, ROMCS          ; INT DFh:
;
         dw    int_unhandled, ROMCS          ; INT E0h:
         dw    int_unhandled, ROMCS          ; INT E1h:
         dw    int_unhandled, ROMCS          ; INT E2h:
         dw    int_unhandled, ROMCS          ; INT E3h:
         dw    int_unhandled, ROMCS          ; INT E4h:
         dw    int_unhandled, ROMCS          ; INT E5h:
         dw    int_unhandled, ROMCS          ; INT E6h:
         dw    int_unhandled, ROMCS          ; INT E7h:
         dw    int_unhandled, ROMCS          ; INT E8h:
         dw    int_unhandled, ROMCS          ; INT E9h:
         dw    int_unhandled, ROMCS          ; INT EAh:
         dw    int_unhandled, ROMCS          ; INT EBh:
         dw    int_unhandled, ROMCS          ; INT ECh:
         dw    int_unhandled, ROMCS          ; INT EDh:
         dw    int_unhandled, ROMCS          ; INT EEh:
         dw    int_unhandled, ROMCS          ; INT EFh:
;
         dw    int_unhandled, ROMCS          ; INT F0h:
         dw    int_unhandled, ROMCS          ; INT F1h:
         dw    int_unhandled, ROMCS          ; INT F2h:
         dw    int_unhandled, ROMCS          ; INT F3h:
         dw    int_unhandled, ROMCS          ; INT F4h:
         dw    int_unhandled, ROMCS          ; INT F5h:
         dw    int_unhandled, ROMCS          ; INT F6h:
         dw    int_unhandled, ROMCS          ; INT F7h:
         dw    int_unhandled, ROMCS          ; INT F8h:
         dw    int_unhandled, ROMCS          ; INT F9h:
         dw    int_unhandled, ROMCS          ; INT FAh:
         dw    int_unhandled, ROMCS          ; INT FBh:
         dw    int_unhandled, ROMCS          ; INT FCh:
         dw    int_unhandled, ROMCS          ; INT FDh:
         dw    int_unhandled, ROMCS          ; INT FEh:
         dw    int_unhandled, ROMCS          ; INT FFh:
initial_ivt_end:

str_div0:
         db    ' DIV ERR', EOT
str_nmi:
         db    '     NMI', EOT
str_overflow:
         db    'OVERFLOW', EOT
str_unhandled:
         db    ' UNEXINT', EOT
