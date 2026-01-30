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
int1_3:  push     bp
         mov      bp,sp                       ; BP+2=IP, BP+4=CS, BP+6=Flags
         push     ss                          
         push     es
         push     ds
         push     di
         push     si
         push     bp                          ; Note this is the wrong value
         push     sp
         push     dx
         push     cx
         push     bx
         push     ax                           

         mov      ax,cs                       ; Restore Monitor's Data segment
         mov      ds,ax                       
                     
         mov      ax,ss:[bp+4]                ; Get user CS
         mov      es,ax                       ; Used for restoring bp replaced opcode
         mov      es:[ucs],ax                    ; Save User CS            
        
         mov      ax,ss:[bp+2]                ; Save User IP
         mov      es:[uip],ax
                                
         mov      di,sp                       ; SS:SP=AX
         mov      bx,uax                      ; Update User registers, DI=pointing to AX
         mov      cx,11
nextureg:   
         mov      ax,ss:[di]                  ; Get register
         mov      [es:bx],ax                  ; Write it to user reg
         add      bx,2
         add      di,2
         loop     nextureg
         
         mov      ax,bp                       ; Save User SP
         add      ax,8                        
         mov      es:[usp],ax

         mov      ax,ss:[bp]
         mov      es:[ubp],ax                 ; Restore real BP value
         
         mov      ax,ss:[bp+6]                ; Save Flags            
         mov      es:[ufl],ax
         and      word es:[ufl],0FEFFh        ; Clear TF
         test     ax,0100h                    ; Check If Trace flag set then
         jz       contbpc                     ; No, check which bp triggered it
                     
         jmp      exitint3                    ; Exit, Display regs, Cmd prompt
            
contbpc: dec      word es:[uip]               ; No, IP-1 and save
                                 
         mov      si,str_breakp               ; Display "***** BreakPoint # *****

         mov      bx,bptab                    ; Check which breakpoint triggered
         mov      cx,8                        ; and restore opcode
intnextbp:
         mov      ax,8
         sub      al,cl

         test     byte es:[bx+3],1            ; Check enable/disable flag
         jz       int3resbp
                         
         mov      di,es:[bx]                  ; Get Breakpoint Address
         cmp      es:[uip],di
         jne      int3res
         
         add      al, '0'                     ; Add the numeric bias
         mov      [si+18],al                  ; Save number
           
int3res: mov      al,byte [bx+2]              ; Get original Opcode
         mov      es:[di],al                  ; Write it back

int3resbp:
         add      bx,4                        ; Next entry
         loop     intnextbp

         call     puts                        ; Write BP Number message                 

exitint3:
         mov      ax,cs                       ; Restore Monitor settings
         mov      ss,ax
         mov      ax, tos                     ; Top of Stack
         mov      sp,ax                       ; Restore Monitor Stack pointer
         mov      ax,ss:baseseg               ; Restore Base Pointer
         mov      es,ax
         
         jmp      dispreg                     ; Jump to Display Registers

; ------------------------------------------------------------------------------
div0:    push     si
         mov      si, str_div0
         call     puts
         pop      si
         jmp      start
;
nmi:     push     si
         mov      si, str_nmi
         call     puts
         pop      si
         jmp      start
;
overflow:
         push     si
         mov      si, str_overflow
         call     puts
         pop      si
         jmp      start
;
int_00:  mov      ax,000h
         jmp      int_unhandled
int_01:  mov      ax,001h
         jmp      int_unhandled
int_02:  mov      ax,002h
         jmp      int_unhandled
int_03:  mov      ax,003h
         jmp      int_unhandled
int_04:  mov      ax,004h
         jmp      int_unhandled
int_05:  mov      ax,005h
         jmp      int_unhandled
int_06:  mov      ax,006h
         jmp      int_unhandled
int_07:  mov      ax,007h
         jmp      int_unhandled
int_08:  mov      ax,008h
         jmp      int_unhandled
int_09:  mov      ax,009h
         jmp      int_unhandled
int_0A:  mov      ax,00Ah
         jmp      int_unhandled
int_0B:  mov      ax,00Bh
         jmp      int_unhandled
int_0C:  mov      ax,00Ch
         jmp      int_unhandled
int_0D:  mov      ax,00Dh
         jmp      int_unhandled
int_0E:  mov      ax,00Eh
         jmp      int_unhandled
int_0F:  mov      ax,00Fh
         jmp      int_unhandled
;
int_10:  mov      ax,010h
         jmp      int_unhandled
int_11:  mov      ax,011h
         jmp      int_unhandled
int_12:  mov      ax,012h
         jmp      int_unhandled
int_13:  mov      ax,013h
         jmp      int_unhandled
int_14:  mov      ax,014h
         jmp      int_unhandled
int_15:  mov      ax,015h
         jmp      int_unhandled
int_16:  mov      ax,016h
         jmp      int_unhandled
int_17:  mov      ax,017h
         jmp      int_unhandled
int_18:  mov      ax,018h
         jmp      int_unhandled
int_19:  mov      ax,019h
         jmp      int_unhandled
int_1A:  mov      ax,01Ah
         jmp      int_unhandled
int_1B:  mov      ax,01Bh
         jmp      int_unhandled
int_1C:  mov      ax,01Ch
         jmp      int_unhandled
int_1D:  mov      ax,01Dh
         jmp      int_unhandled
int_1E:  mov      ax,01Eh
         jmp      int_unhandled
int_1F:  mov      ax,01Fh
         jmp      int_unhandled
;
int_20:  mov      ax,020h
         jmp      int_unhandled
int_21:  mov      ax,021h
         jmp      int_unhandled
int_22:  mov      ax,022h
         jmp      int_unhandled
int_23:  mov      ax,023h
         jmp      int_unhandled
int_24:  mov      ax,024h
         jmp      int_unhandled
int_25:  mov      ax,025h
         jmp      int_unhandled
int_26:  mov      ax,026h
         jmp      int_unhandled
int_27:  mov      ax,027h
         jmp      int_unhandled
int_28:  mov      ax,028h
         jmp      int_unhandled
int_29:  mov      ax,029h
         jmp      int_unhandled
int_2A:  mov      ax,02Ah
         jmp      int_unhandled
int_2B:  mov      ax,02Bh
         jmp      int_unhandled
int_2C:  mov      ax,02Ch
         jmp      int_unhandled
int_2D:  mov      ax,02Dh
         jmp      int_unhandled
int_2E:  mov      ax,02Eh
         jmp      int_unhandled
int_2F:  mov      ax,02Fh
         jmp      int_unhandled
;
int_30:  mov      ax,030h
         jmp      int_unhandled
int_31:  mov      ax,031h
         jmp      int_unhandled
int_32:  mov      ax,032h
         jmp      int_unhandled
int_33:  mov      ax,033h
         jmp      int_unhandled
int_34:  mov      ax,034h
         jmp      int_unhandled
int_35:  mov      ax,035h
         jmp      int_unhandled
int_36:  mov      ax,036h
         jmp      int_unhandled
int_37:  mov      ax,037h
         jmp      int_unhandled
int_38:  mov      ax,038h
         jmp      int_unhandled
int_39:  mov      ax,039h
         jmp      int_unhandled
int_3A:  mov      ax,03Ah
         jmp      int_unhandled
int_3B:  mov      ax,03Bh
         jmp      int_unhandled
int_3C:  mov      ax,03Ch
         jmp      int_unhandled
int_3D:  mov      ax,03Dh
         jmp      int_unhandled
int_3E:  mov      ax,03Eh
         jmp      int_unhandled
int_3F:  mov      ax,03Fh
         jmp      int_unhandled
;
int_40:  mov      ax,040h
         jmp      int_unhandled
int_41:  mov      ax,041h
         jmp      int_unhandled
int_42:  mov      ax,042h
         jmp      int_unhandled
int_43:  mov      ax,043h
         jmp      int_unhandled
int_44:  mov      ax,044h
         jmp      int_unhandled
int_45:  mov      ax,045h
         jmp      int_unhandled
int_46:  mov      ax,046h
         jmp      int_unhandled
int_47:  mov      ax,047h
         jmp      int_unhandled
int_48:  mov      ax,048h
         jmp      int_unhandled
int_49:  mov      ax,049h
         jmp      int_unhandled
int_4A:  mov      ax,04Ah
         jmp      int_unhandled
int_4B:  mov      ax,04Bh
         jmp      int_unhandled
int_4C:  mov      ax,04Ch
         jmp      int_unhandled
int_4D:  mov      ax,04Dh
         jmp      int_unhandled
int_4E:  mov      ax,04Eh
         jmp      int_unhandled
int_4F:  mov      ax,04Fh
         jmp      int_unhandled
;
int_50:  mov      ax,050h
         jmp      int_unhandled
int_51:  mov      ax,051h
         jmp      int_unhandled
int_52:  mov      ax,052h
         jmp      int_unhandled
int_53:  mov      ax,053h
         jmp      int_unhandled
int_54:  mov      ax,054h
         jmp      int_unhandled
int_55:  mov      ax,055h
         jmp      int_unhandled
int_56:  mov      ax,056h
         jmp      int_unhandled
int_57:  mov      ax,057h
         jmp      int_unhandled
int_58:  mov      ax,058h
         jmp      int_unhandled
int_59:  mov      ax,059h
         jmp      int_unhandled
int_5A:  mov      ax,05Ah
         jmp      int_unhandled
int_5B:  mov      ax,05Bh
         jmp      int_unhandled
int_5C:  mov      ax,05Ch
         jmp      int_unhandled
int_5D:  mov      ax,05Dh
         jmp      int_unhandled
int_5E:  mov      ax,05Eh
         jmp      int_unhandled
int_5F:  mov      ax,05Fh
         jmp      int_unhandled
;
int_60:  mov      ax,060h
         jmp      int_unhandled
int_61:  mov      ax,061h
         jmp      int_unhandled
int_62:  mov      ax,062h
         jmp      int_unhandled
int_63:  mov      ax,063h
         jmp      int_unhandled
int_64:  mov      ax,064h
         jmp      int_unhandled
int_65:  mov      ax,065h
         jmp      int_unhandled
int_66:  mov      ax,066h
         jmp      int_unhandled
int_67:  mov      ax,067h
         jmp      int_unhandled
int_68:  mov      ax,068h
         jmp      int_unhandled
int_69:  mov      ax,069h
         jmp      int_unhandled
int_6A:  mov      ax,06Ah
         jmp      int_unhandled
int_6B:  mov      ax,06Bh
         jmp      int_unhandled
int_6C:  mov      ax,06Ch
         jmp      int_unhandled
int_6D:  mov      ax,06Dh
         jmp      int_unhandled
int_6E:  mov      ax,06Eh
         jmp      int_unhandled
int_6F:  mov      ax,06Fh
         jmp      int_unhandled
;
int_70:  mov      ax,070h
         jmp      int_unhandled
int_71:  mov      ax,071h
         jmp      int_unhandled
int_72:  mov      ax,072h
         jmp      int_unhandled
int_73:  mov      ax,073h
         jmp      int_unhandled
int_74:  mov      ax,074h
         jmp      int_unhandled
int_75:  mov      ax,075h
         jmp      int_unhandled
int_76:  mov      ax,076h
         jmp      int_unhandled
int_77:  mov      ax,077h
         jmp      int_unhandled
int_78:  mov      ax,078h
         jmp      int_unhandled
int_79:  mov      ax,079h
         jmp      int_unhandled
int_7A:  mov      ax,07Ah
         jmp      int_unhandled
int_7B:  mov      ax,07Bh
         jmp      int_unhandled
int_7C:  mov      ax,07Ch
         jmp      int_unhandled
int_7D:  mov      ax,07Dh
         jmp      int_unhandled
int_7E:  mov      ax,07Eh
         jmp      int_unhandled
int_7F:  mov      ax,07Fh
         jmp      int_unhandled
;
int_80:  mov      ax,080h
         jmp      int_unhandled
int_81:  mov      ax,081h
         jmp      int_unhandled
int_82:  mov      ax,082h
         jmp      int_unhandled
int_83:  mov      ax,083h
         jmp      int_unhandled
int_84:  mov      ax,084h
         jmp      int_unhandled
int_85:  mov      ax,085h
         jmp      int_unhandled
int_86:  mov      ax,086h
         jmp      int_unhandled
int_87:  mov      ax,087h
         jmp      int_unhandled
int_88:  mov      ax,088h
         jmp      int_unhandled
int_89:  mov      ax,089h
         jmp      int_unhandled
int_8A:  mov      ax,08Ah
         jmp      int_unhandled
int_8B:  mov      ax,08Bh
         jmp      int_unhandled
int_8C:  mov      ax,08Ch
         jmp      int_unhandled
int_8D:  mov      ax,08Dh
         jmp      int_unhandled
int_8E:  mov      ax,08Eh
         jmp      int_unhandled
int_8F:  mov      ax,08Fh
         jmp      int_unhandled
;
int_90:  mov      ax,090h
         jmp      int_unhandled
int_91:  mov      ax,091h
         jmp      int_unhandled
int_92:  mov      ax,092h
         jmp      int_unhandled
int_93:  mov      ax,093h
         jmp      int_unhandled
int_94:  mov      ax,094h
         jmp      int_unhandled
int_95:  mov      ax,095h
         jmp      int_unhandled
int_96:  mov      ax,096h
         jmp      int_unhandled
int_97:  mov      ax,097h
         jmp      int_unhandled
int_98:  mov      ax,098h
         jmp      int_unhandled
int_99:  mov      ax,099h
         jmp      int_unhandled
int_9A:  mov      ax,09Ah
         jmp      int_unhandled
int_9B:  mov      ax,09Bh
         jmp      int_unhandled
int_9C:  mov      ax,09Ch
         jmp      int_unhandled
int_9D:  mov      ax,09Dh
         jmp      int_unhandled
int_9E:  mov      ax,09Eh
         jmp      int_unhandled
int_9F:  mov      ax,09Fh
         jmp      int_unhandled
;
int_A0:  mov      ax,0A0h
         jmp      int_unhandled
int_A1:  mov      ax,0A1h
         jmp      int_unhandled
int_A2:  mov      ax,0A2h
         jmp      int_unhandled
int_A3:  mov      ax,0A3h
         jmp      int_unhandled
int_A4:  mov      ax,0A4h
         jmp      int_unhandled
int_A5:  mov      ax,0A5h
         jmp      int_unhandled
int_A6:  mov      ax,0A6h
         jmp      int_unhandled
int_A7:  mov      ax,0A7h
         jmp      int_unhandled
int_A8:  mov      ax,0A8h
         jmp      int_unhandled
int_A9:  mov      ax,0A9h
         jmp      int_unhandled
int_AA:  mov      ax,0AAh
         jmp      int_unhandled
int_AB:  mov      ax,0ABh
         jmp      int_unhandled
int_AC:  mov      ax,0ACh
         jmp      int_unhandled
int_AD:  mov      ax,0ADh
         jmp      int_unhandled
int_AE:  mov      ax,0AEh
         jmp      int_unhandled
int_AF:  mov      ax,0AFh
         jmp      int_unhandled
;
int_B0:  mov      ax,0B0h
         jmp      int_unhandled
int_B1:  mov      ax,0B1h
         jmp      int_unhandled
int_B2:  mov      ax,0B2h
         jmp      int_unhandled
int_B3:  mov      ax,0B3h
         jmp      int_unhandled
int_B4:  mov      ax,0B4h
         jmp      int_unhandled
int_B5:  mov      ax,0B5h
         jmp      int_unhandled
int_B6:  mov      ax,0B6h
         jmp      int_unhandled
int_B7:  mov      ax,0B7h
         jmp      int_unhandled
int_B8:  mov      ax,0B8h
         jmp      int_unhandled
int_B9:  mov      ax,0B9h
         jmp      int_unhandled
int_BA:  mov      ax,0BAh
         jmp      int_unhandled
int_BB:  mov      ax,0BBh
         jmp      int_unhandled
int_BC:  mov      ax,0BCh
         jmp      int_unhandled
int_BD:  mov      ax,0BDh
         jmp      int_unhandled
int_BE:  mov      ax,0BEh
         jmp      int_unhandled
int_BF:  mov      ax,0BFh
         jmp      int_unhandled
;
int_C0:  mov      ax,0C0h
         jmp      int_unhandled
int_C1:  mov      ax,0C1h
         jmp      int_unhandled
int_C2:  mov      ax,0C2h
         jmp      int_unhandled
int_C3:  mov      ax,0C3h
         jmp      int_unhandled
int_C4:  mov      ax,0C4h
         jmp      int_unhandled
int_C5:  mov      ax,0C5h
         jmp      int_unhandled
int_C6:  mov      ax,0C6h
         jmp      int_unhandled
int_C7:  mov      ax,0C7h
         jmp      int_unhandled
int_C8:  mov      ax,0C8h
         jmp      int_unhandled
int_C9:  mov      ax,0C9h
         jmp      int_unhandled
int_CA:  mov      ax,0CAh
         jmp      int_unhandled
int_CB:  mov      ax,0CBh
         jmp      int_unhandled
int_CC:  mov      ax,0CCh
         jmp      int_unhandled
int_CD:  mov      ax,0CDh
         jmp      int_unhandled
int_CE:  mov      ax,0CEh
         jmp      int_unhandled
int_CF:  mov      ax,0CFh
         jmp      int_unhandled
;
int_D0:  mov      ax,0D0h
         jmp      int_unhandled
int_D1:  mov      ax,0D1h
         jmp      int_unhandled
int_D2:  mov      ax,0D2h
         jmp      int_unhandled
int_D3:  mov      ax,0D3h
         jmp      int_unhandled
int_D4:  mov      ax,0D4h
         jmp      int_unhandled
int_D5:  mov      ax,0D5h
         jmp      int_unhandled
int_D6:  mov      ax,0D6h
         jmp      int_unhandled
int_D7:  mov      ax,0D7h
         jmp      int_unhandled
int_D8:  mov      ax,0D8h
         jmp      int_unhandled
int_D9:  mov      ax,0D9h
         jmp      int_unhandled
int_DA:  mov      ax,0DAh
         jmp      int_unhandled
int_DB:  mov      ax,0DBh
         jmp      int_unhandled
int_DC:  mov      ax,0DCh
         jmp      int_unhandled
int_DD:  mov      ax,0DDh
         jmp      int_unhandled
int_DE:  mov      ax,0DEh
         jmp      int_unhandled
int_DF:  mov      ax,0DFh
         jmp      int_unhandled
;
int_E0:  mov      ax,0E0h
         jmp      int_unhandled
int_E1:  mov      ax,0E1h
         jmp      int_unhandled
int_E2:  mov      ax,0E2h
         jmp      int_unhandled
int_E3:  mov      ax,0E3h
         jmp      int_unhandled
int_E4:  mov      ax,0E4h
         jmp      int_unhandled
int_E5:  mov      ax,0E5h
         jmp      int_unhandled
int_E6:  mov      ax,0E6h
         jmp      int_unhandled
int_E7:  mov      ax,0E7h
         jmp      int_unhandled
int_E8:  mov      ax,0E8h
         jmp      int_unhandled
int_E9:  mov      ax,0E9h
         jmp      int_unhandled
int_EA:  mov      ax,0EAh
         jmp      int_unhandled
int_EB:  mov      ax,0EBh
         jmp      int_unhandled
int_EC:  mov      ax,0ECh
         jmp      int_unhandled
int_ED:  mov      ax,0EDh
         jmp      int_unhandled
int_EE:  mov      ax,0EEh
         jmp      int_unhandled
int_EF:  mov      ax,0EFh
         jmp      int_unhandled
;
int_F0:  mov      ax,0F0h
         jmp      int_unhandled
int_F1:  mov      ax,0F1h
         jmp      int_unhandled
int_F2:  mov      ax,0F2h
         jmp      int_unhandled
int_F3:  mov      ax,0F3h
         jmp      int_unhandled
int_F4:  mov      ax,0F4h
         jmp      int_unhandled
int_F5:  mov      ax,0F5h
         jmp      int_unhandled
int_F6:  mov      ax,0F6h
         jmp      int_unhandled
int_F7:  mov      ax,0F7h
         jmp      int_unhandled
int_F8:  mov      ax,0F8h
         jmp      int_unhandled
int_F9:  mov      ax,0F9h
         jmp      int_unhandled
int_FA:  mov      ax,0FAh
         jmp      int_unhandled
int_FB:  mov      ax,0FBh
         jmp      int_unhandled
int_FC:  mov      ax,0FCh
         jmp      int_unhandled
int_FD:  mov      ax,0FDh
         jmp      int_unhandled
int_FE:  mov      ax,0FEh
         jmp      int_unhandled
int_FF:  mov      ax,0FFh
         jmp      int_unhandled
;
int_unhandled:
         push     si
         mov      si, str_unhandled
         call     puts
         pop      si
         call     puthex2
         mov      al,'h'
         call     putch
         mov      al,SPACE
         call     putch
         mov      al,'*'
         call     putch
         call     putch
         mov      al,CR
         call     putch
         mov      al,LF
         call     putch
         pop      ax
         jmp      start

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

;  UART character input handler.
getch:
         in    al,ACIA         ; Status byte       
         and   al,01h          ; Check if receive buffer full
         jz    getch           ; Loop until flag signals ready
         in    al,ACIA+1       ; Read the character
         ret

;
; Print a null-terminated string from ROM.
; Arguments: pointer to string in CS:SI
puts:
         push  ax
         push  ds
         push  si
         mov   ax, cs
         mov   ds, ax
.1:      lodsb                ; get character
         or    al, al         ; end if 0
         jz    .done
         call  putch
         jmp   .1
.done:   pop   si
         pop   ds
         pop   ax
         ret

; Vectored UART character output handler.
putch_int:
         push  ax              ; Store character
putch_int1:
         in    al,ACIA         ; Status byte       
         and   al,02h          ; Set Zero flag if still transmitting character       
         jz    putch_int1      ; Loop until flag signals ready
         pop   ax              ; Retrieve character
         out   ACIA+1,al       ; Output the character
         iret

; Vectored UART character input handler.
getch_int:
         in    al,ACIA         ; Status byte       
         and   al,01h          ; Set Zero flag if still transmitting character       
         jz    getch_int       ; Loop until flag signals ready
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
         call  putch
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
         dw    int_05, ROMCS                 ; INT 05h: reserved (bounds check on 80186)
; API vectors
         dw    putch_int, ROMCS              ; INT 06h: character output
         dw    puts_int, ROMCS               ; INT 07h: string output
         dw    getch_int, ROMCS              ; INT 08h: character input
         dw    start, ROMCS                  ; INT 09h: return control to monitor
         dw    int_0A, ROMCS                 ; INT 0Ah:
         dw    int_0B, ROMCS                 ; INT 0Bh:
         dw    int_0C, ROMCS                 ; INT 0Ch:
         dw    int_0D, ROMCS                 ; INT 0Dh:
         dw    int_0E, ROMCS                 ; INT 0Eh:
         dw    int_0F, ROMCS                 ; INT 0Fh:
         dw    int_10, ROMCS                 ; INT 10h:
         dw    int_11, ROMCS                 ; INT 11h:
         dw    int_12, ROMCS                 ; INT 12h:
         dw    int_13, ROMCS                 ; INT 13h:
         dw    int_14, ROMCS                 ; INT 14h:
         dw    int_15, ROMCS                 ; INT 15h:
         dw    int_16, ROMCS                 ; INT 16h:
         dw    int_17, ROMCS                 ; INT 17h:
         dw    int_18, ROMCS                 ; INT 18h:
         dw    int_19, ROMCS                 ; INT 19h:
         dw    int_1A, ROMCS                 ; INT 1Ah:
         dw    int_1B, ROMCS                 ; INT 1Bh:
         dw    int_1C, ROMCS                 ; INT 1Ch:
         dw    int_1D, ROMCS                 ; INT 1Dh:
         dw    int_1E, ROMCS                 ; INT 1Eh:
         dw    int_1F, ROMCS                 ; INT 1Fh:
         dw    int_20, ROMCS                 ; INT 20h:
         dw    int_21, ROMCS                 ; INT 21h:
         dw    int_22, ROMCS                 ; INT 22h:
         dw    int_23, ROMCS                 ; INT 23h:
         dw    int_24, ROMCS                 ; INT 24h:
         dw    int_25, ROMCS                 ; INT 25h:
         dw    int_26, ROMCS                 ; INT 26h:
         dw    int_27, ROMCS                 ; INT 27h:
         dw    int_28, ROMCS                 ; INT 28h:
         dw    int_29, ROMCS                 ; INT 29h:
         dw    int_2A, ROMCS                 ; INT 2Ah:
         dw    int_2B, ROMCS                 ; INT 2Bh:
         dw    int_2C, ROMCS                 ; INT 2Ch:
         dw    int_2D, ROMCS                 ; INT 2Dh:
         dw    int_2E, ROMCS                 ; INT 2Eh:
         dw    int_2F, ROMCS                 ; INT 2Fh:
         dw    int_30, ROMCS                 ; INT 30h:
         dw    int_31, ROMCS                 ; INT 31h:
         dw    int_32, ROMCS                 ; INT 32h:
         dw    int_33, ROMCS                 ; INT 33h:
         dw    int_34, ROMCS                 ; INT 34h:
         dw    int_35, ROMCS                 ; INT 35h:
         dw    int_36, ROMCS                 ; INT 36h:
         dw    int_37, ROMCS                 ; INT 37h:
         dw    int_38, ROMCS                 ; INT 38h:
         dw    int_39, ROMCS                 ; INT 39h:
         dw    int_3A, ROMCS                 ; INT 3Ah:
         dw    int_3B, ROMCS                 ; INT 3Bh:
         dw    int_3C, ROMCS                 ; INT 3Ch:
         dw    int_3D, ROMCS                 ; INT 3Dh:
         dw    int_3E, ROMCS                 ; INT 3Eh:
         dw    int_3F, ROMCS                 ; INT 3Fh:
         dw    int_40, ROMCS                 ; INT 40h:
         dw    int_41, ROMCS                 ; INT 41h:
         dw    int_42, ROMCS                 ; INT 42h:
         dw    int_43, ROMCS                 ; INT 43h:
         dw    int_44, ROMCS                 ; INT 44h:
         dw    int_45, ROMCS                 ; INT 45h:
         dw    int_46, ROMCS                 ; INT 46h:
         dw    int_47, ROMCS                 ; INT 47h:
         dw    int_48, ROMCS                 ; INT 48h:
         dw    int_49, ROMCS                 ; INT 49h:
         dw    int_4A, ROMCS                 ; INT 4Ah:
         dw    int_4B, ROMCS                 ; INT 4Bh:
         dw    int_4C, ROMCS                 ; INT 4Ch:
         dw    int_4D, ROMCS                 ; INT 4Dh:
         dw    int_4E, ROMCS                 ; INT 4Eh:
         dw    int_4F, ROMCS                 ; INT 4Fh:
         dw    int_50, ROMCS                 ; INT 50h:
         dw    int_51, ROMCS                 ; INT 51h:
         dw    int_52, ROMCS                 ; INT 52h:
         dw    int_53, ROMCS                 ; INT 53h:
         dw    int_54, ROMCS                 ; INT 54h:
         dw    int_55, ROMCS                 ; INT 55h:
         dw    int_56, ROMCS                 ; INT 56h:
         dw    int_57, ROMCS                 ; INT 57h:
         dw    int_58, ROMCS                 ; INT 58h:
         dw    int_59, ROMCS                 ; INT 59h:
         dw    int_5A, ROMCS                 ; INT 5Ah:
         dw    int_5B, ROMCS                 ; INT 5Bh:
         dw    int_5C, ROMCS                 ; INT 5Ch:
         dw    int_5D, ROMCS                 ; INT 5Dh:
         dw    int_5E, ROMCS                 ; INT 5Eh:
         dw    int_5F, ROMCS                 ; INT 5Fh:
         dw    int_60, ROMCS                 ; INT 60h:
         dw    int_61, ROMCS                 ; INT 61h:
         dw    int_62, ROMCS                 ; INT 62h:
         dw    int_63, ROMCS                 ; INT 63h:
         dw    int_64, ROMCS                 ; INT 64h:
         dw    int_65, ROMCS                 ; INT 65h:
         dw    int_66, ROMCS                 ; INT 66h:
         dw    int_67, ROMCS                 ; INT 67h:
         dw    int_68, ROMCS                 ; INT 68h:
         dw    int_69, ROMCS                 ; INT 69h:
         dw    int_6A, ROMCS                 ; INT 6Ah:
         dw    int_6B, ROMCS                 ; INT 6Bh:
         dw    int_6C, ROMCS                 ; INT 6Ch:
         dw    int_6D, ROMCS                 ; INT 6Dh:
         dw    int_6E, ROMCS                 ; INT 6Eh:
         dw    int_6F, ROMCS                 ; INT 6Fh:
         dw    int_70, ROMCS                 ; INT 70h:
         dw    int_71, ROMCS                 ; INT 71h:
         dw    int_72, ROMCS                 ; INT 72h:
         dw    int_73, ROMCS                 ; INT 73h:
         dw    int_74, ROMCS                 ; INT 74h:
         dw    int_75, ROMCS                 ; INT 75h:
         dw    int_76, ROMCS                 ; INT 76h:
         dw    int_77, ROMCS                 ; INT 77h:
         dw    int_78, ROMCS                 ; INT 78h:
         dw    int_79, ROMCS                 ; INT 79h:
         dw    int_7A, ROMCS                 ; INT 7Ah:
         dw    int_7B, ROMCS                 ; INT 7Bh:
         dw    int_7C, ROMCS                 ; INT 7Ch:
         dw    int_7D, ROMCS                 ; INT 7Dh:
         dw    int_7E, ROMCS                 ; INT 7Eh:
         dw    int_7F, ROMCS                 ; INT 7Fh:
         dw    int_80, ROMCS                 ; INT 80h:
         dw    int_81, ROMCS                 ; INT 81h:
         dw    int_82, ROMCS                 ; INT 82h:
         dw    int_83, ROMCS                 ; INT 83h:
         dw    int_84, ROMCS                 ; INT 84h:
         dw    int_85, ROMCS                 ; INT 85h:
         dw    int_86, ROMCS                 ; INT 86h:
         dw    int_87, ROMCS                 ; INT 87h:
         dw    int_88, ROMCS                 ; INT 88h:
         dw    int_89, ROMCS                 ; INT 89h:
         dw    int_8A, ROMCS                 ; INT 8Ah:
         dw    int_8B, ROMCS                 ; INT 8Bh:
         dw    int_8C, ROMCS                 ; INT 8Ch:
         dw    int_8D, ROMCS                 ; INT 8Dh:
         dw    int_8E, ROMCS                 ; INT 8Eh:
         dw    int_8F, ROMCS                 ; INT 8Fh:
         dw    int_90, ROMCS                 ; INT 90h:
         dw    int_91, ROMCS                 ; INT 91h:
         dw    int_92, ROMCS                 ; INT 92h:
         dw    int_93, ROMCS                 ; INT 93h:
         dw    int_94, ROMCS                 ; INT 94h:
         dw    int_95, ROMCS                 ; INT 95h:
         dw    int_96, ROMCS                 ; INT 96h:
         dw    int_97, ROMCS                 ; INT 97h:
         dw    int_98, ROMCS                 ; INT 98h:
         dw    int_99, ROMCS                 ; INT 99h:
         dw    int_9A, ROMCS                 ; INT 9Ah:
         dw    int_9B, ROMCS                 ; INT 9Bh:
         dw    int_9C, ROMCS                 ; INT 9Ch:
         dw    int_9D, ROMCS                 ; INT 9Dh:
         dw    int_9E, ROMCS                 ; INT 9Eh:
         dw    int_9F, ROMCS                 ; INT 9Fh:
         dw    int_A0, ROMCS                 ; INT A0h:
         dw    int_A1, ROMCS                 ; INT A1h:
         dw    int_A2, ROMCS                 ; INT A2h:
         dw    int_A3, ROMCS                 ; INT A3h:
         dw    int_A4, ROMCS                 ; INT A4h:
         dw    int_A5, ROMCS                 ; INT A5h:
         dw    int_A6, ROMCS                 ; INT A6h:
         dw    int_A7, ROMCS                 ; INT A7h:
         dw    int_A8, ROMCS                 ; INT A8h:
         dw    int_A9, ROMCS                 ; INT A9h:
         dw    int_AA, ROMCS                 ; INT AAh:
         dw    int_AB, ROMCS                 ; INT ABh:
         dw    int_AC, ROMCS                 ; INT ACh:
         dw    int_AD, ROMCS                 ; INT ADh:
         dw    int_AE, ROMCS                 ; INT AEh:
         dw    int_AF, ROMCS                 ; INT AFh:
         dw    int_B0, ROMCS                 ; INT B0h:
         dw    int_B1, ROMCS                 ; INT B1h:
         dw    int_B2, ROMCS                 ; INT B2h:
         dw    int_B3, ROMCS                 ; INT B3h:
         dw    int_B4, ROMCS                 ; INT B4h:
         dw    int_B5, ROMCS                 ; INT B5h:
         dw    int_B6, ROMCS                 ; INT B6h:
         dw    int_B7, ROMCS                 ; INT B7h:
         dw    int_B8, ROMCS                 ; INT B8h:
         dw    int_B9, ROMCS                 ; INT B9h:
         dw    int_BA, ROMCS                 ; INT BAh:
         dw    int_BB, ROMCS                 ; INT BBh:
         dw    int_BC, ROMCS                 ; INT BCh:
         dw    int_BD, ROMCS                 ; INT BDh:
         dw    int_BE, ROMCS                 ; INT BEh:
         dw    int_BF, ROMCS                 ; INT BFh:
         dw    int_C0, ROMCS                 ; INT C0h:
         dw    int_C1, ROMCS                 ; INT C1h:
         dw    int_C2, ROMCS                 ; INT C2h:
         dw    int_C3, ROMCS                 ; INT C3h:
         dw    int_C4, ROMCS                 ; INT C4h:
         dw    int_C5, ROMCS                 ; INT C5h:
         dw    int_C6, ROMCS                 ; INT C6h:
         dw    int_C7, ROMCS                 ; INT C7h:
         dw    int_C8, ROMCS                 ; INT C8h:
         dw    int_C9, ROMCS                 ; INT C9h:
         dw    int_CA, ROMCS                 ; INT CAh:
         dw    int_CB, ROMCS                 ; INT CBh:
         dw    int_CC, ROMCS                 ; INT CCh:
         dw    int_CD, ROMCS                 ; INT CDh:
         dw    int_CE, ROMCS                 ; INT CEh:
         dw    int_CF, ROMCS                 ; INT CFh:
         dw    int_D0, ROMCS                 ; INT D0h:
         dw    int_D1, ROMCS                 ; INT D1h:
         dw    int_D2, ROMCS                 ; INT D2h:
         dw    int_D3, ROMCS                 ; INT D3h:
         dw    int_D4, ROMCS                 ; INT D4h:
         dw    int_D5, ROMCS                 ; INT D5h:
         dw    int_D6, ROMCS                 ; INT D6h:
         dw    int_D7, ROMCS                 ; INT D7h:
         dw    int_D8, ROMCS                 ; INT D8h:
         dw    int_D9, ROMCS                 ; INT D9h:
         dw    int_DA, ROMCS                 ; INT DAh:
         dw    int_DB, ROMCS                 ; INT DBh:
         dw    int_DC, ROMCS                 ; INT DCh:
         dw    int_DD, ROMCS                 ; INT DDh:
         dw    int_DE, ROMCS                 ; INT DEh:
         dw    int_DF, ROMCS                 ; INT DFh:
         dw    int_E0, ROMCS                 ; INT E0h:
         dw    int_E1, ROMCS                 ; INT E1h:
         dw    int_E2, ROMCS                 ; INT E2h:
         dw    int_E3, ROMCS                 ; INT E3h:
         dw    int_E4, ROMCS                 ; INT E4h:
         dw    int_E5, ROMCS                 ; INT E5h:
         dw    int_E6, ROMCS                 ; INT E6h:
         dw    int_E7, ROMCS                 ; INT E7h:
         dw    int_E8, ROMCS                 ; INT E8h:
         dw    int_E9, ROMCS                 ; INT E9h:
         dw    int_EA, ROMCS                 ; INT EAh:
         dw    int_EB, ROMCS                 ; INT EBh:
         dw    int_EC, ROMCS                 ; INT ECh:
         dw    int_ED, ROMCS                 ; INT EDh:
         dw    int_EE, ROMCS                 ; INT EEh:
         dw    int_EF, ROMCS                 ; INT EFh:
         dw    int_F0, ROMCS                 ; INT F0h:
         dw    int_F1, ROMCS                 ; INT F1h:
         dw    int_F2, ROMCS                 ; INT F2h:
         dw    int_F3, ROMCS                 ; INT F3h:
         dw    int_F4, ROMCS                 ; INT F4h:
         dw    int_F5, ROMCS                 ; INT F5h:
         dw    int_F6, ROMCS                 ; INT F6h:
         dw    int_F7, ROMCS                 ; INT F7h:
         dw    int_F8, ROMCS                 ; INT F8h:
         dw    int_F9, ROMCS                 ; INT F9h:
         dw    int_FA, ROMCS                 ; INT FAh:
         dw    int_FB, ROMCS                 ; INT FBh:
         dw    int_FC, ROMCS                 ; INT FCh:
         dw    int_FD, ROMCS                 ; INT FDh:
         dw    int_FE, ROMCS                 ; INT FEh:
         dw    int_FF, ROMCS                 ; INT FFh:
initial_ivt_end:

str_div0:
         db    '** Divide by zero error! **', CR, LF, EOT
str_nmi:
         db    '** NMI **', CR, LF, EOT
str_overflow:
         db    '** Overflow interrupt! **', CR, LF, EOT
str_unhandled:
         db    '** Unhandled Interrupt - int ', EOT
