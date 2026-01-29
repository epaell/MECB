           cpu      8086

ROMSIZE     equ     04000h
ROMCS       equ     0F000h
INIT_SS     equ     07000h
INIT_SP     equ     0FFF0h
STACK_SIZE  equ     0100h
;
ACIA        equ     08h               ; Assume MECB ACIA mapped to $08 on I/O port
RESET       equ     03h               ; Master reset for ACIA
CONTROL     equ     0D1h              ; Control settings for ACIA (receive interrupt enabled)
;
; ASCII control characters
BS          equ     08h               ; backspace
CR          equ     0Dh               ; carraige return
LF          equ     0Ah               ; form feed
ESC         equ     1Bh               ; escape
SPACE       equ     20h               ; space
EOT         equ     00h               ; End of Text
CAN         equ     '@'               ; Cancel
;
BASE_SEG    equ     0380h  
;----------------------------------------------------------------------
; Used for Load Hex file command
;----------------------------------------------------------------------
EOF_REC     EQU     01                ; End of file record
DATA_REC    EQU     00                ; Load data record
EAD_REC     EQU     02                ; Extended Address Record, use to set CS
SSA_REC     EQU     03                ; Execute Address
;
         org   0C000h
;
; int 06h: output character in AL
%macro PUTC 0
         int   06h
%endmacro

; int 07h: print string in CS:SI
%macro PUTS 0
         int   07h
%endmacro

; int 08h: input character into AL, with echo
%macro GETC 0
         int   08h
         PUTC
%endmacro

; int 08h: input character into AL, no echo
%macro GETCNE 0
         int   08h
%endmacro

; int 09h: return to monitor
%macro MONITOR 0
         int   09h
%endmacro

; Write space
%macro WRSPACE 0
         mov   al,SPACE
         int   06h
%endmacro

; Write equal
%macro WREQUAL 0
         mov   al,'='
         int   06h
%endmacro

section  .text
         global   start
         
start:
         cli
; Set up the Stack Segment (SS)
         mov   ax, stack_group            ; Load the address of 'stack_group' into AX
         mov   ss, ax                     ; Move the address from AX to SS
         mov   sp, tos                    ; Set the stack pointer (SP) to the top of the stack
;
; Load the interrupt vector table.
; Default character output device is the serial port.
         mov   si, initial_ivt            ; source: initial vector table in ROM
         mov   ax, cs
         mov   ds, ax
         
         xor   di, di                     ; destination: 0000:0000
         mov   es, di
         mov   cx, (initial_ivt_end-initial_ivt)/2
         rep movsw

         mov   si, reg_init
         mov   di, uax
         mov   cx, 14                     ; initialise all 14 16-bit registers
         rep movsw
         
         mov   si, bp_init                ; initialise breakpoint table
         mov   di, bptab
         mov   cx, 16
         rep movsw

         mov   ax,BASE_SEG                ; Get Default Base segment
         mov   ss:[baseseg],ax            ; Initialise base segment
         mov   es,ax
         ; Move test program in place
         mov   si,test_prog
         mov   di,0100h
         mov   cx,(test_end-test_prog)
         rep movsb

         ; Set up the Data Segment (DS)
         mov ax, stack_group              ; Load the address of 'data_group' into AX
         mov ds, ax                       ; Move the address from AX to DS

         cld
initcom:
         mov   al, RESET                  ; reset ACIA
         out   ACIA, al
         mov   al, CONTROL                ; set up ACIA
         out   ACIA, al
;
         sti                              ; interrupts enabled! we're live!
         mov   si, str_welcome
         PUTS
         
command:                                  ; Re-establish initial conditions
; Set up the Stack Segment (SS)
         mov   ax, stack_group            ; Load the address of 'stack_group' into AX
         mov   ss, ax                     ; Move the address from AX to SS; stack segment points to monitor variable space
         mov   es, ss:[baseseg]           ; Extra segment points to base segment
         mov   sp, tos                    ; Set the stack pointer (SP) to the top of the stack
;
; Load the interrupt vector table.
; Default character output device is the serial port.
         mov   ax, cs                     ; Data segment points to in-ROM data
         mov   ds, ax

         cld
;
         mov   si, str_prompt             ; Command prompt
         PUTS
         GETC                             ; Read first command character
         call  to_upper                   ; convert to uppercase
         mov   dl,al

         mov   bx, cmdtab1                ; Point to the 1-character command jump table
cmpcmd1:
         mov   al,[bx]
         cmp   al,dl
         jne   nextcmd1                   ; Not found yet, try next command
         WRSPACE
         jmp   [BX+2]                     ; Execute Command
            
nextcmd1:
         add   bx,4
         cmp   bx,endtab1
         jne   cmpcmd1                    ; Continue looking
;
         GETC                             ; Get Second Command Byte, DX=command
         call  to_upper                   ; Convert to uppercase
         mov   dh,al

         mov   bx,cmdtab2                 ; Point to the 2-character command jump table
cmpcmd2:
         mov   ax,[bx]
         cmp   ax,dx
         jne   nextcmd2                   ; Not found yet, try next command
         WRSPACE
         jmp   [bx+2]                     ; Execute Command
            
nextcmd2:
         add   bx,4
         cmp   bx,endtab2
         jne   cmpcmd2                    ; Continue looking

         mov   si,str_errcmd              ; Display Unknown Command, followed by usage message
         PUTS                       
         jmp   command                    ; Try again 

cmdtab1  dw    'L',loadhex                ; Single char Command Jump Table
         dw    'R',dispreg   
         dw    'G',execprog
;         dw    'N',tracenext
;         dw    'T',traceprog
;         dw    'U',disassem
         dw    'H',disphelp
         dw    '?',disphelp
         dw    'Q',exitmon
         dw    CR,command
endtab1  dw    ' '

cmdtab2  dw    "FM",fillmem                ; Double char Command Jump Table
         dw    'DM',dumpmem            
         dw    'BP',setbreakp              ; Set Breakpoint
         dw    'CB',clrbreakp              ; Clear Breakpoint
         dw    'DB',dispbreakp             ; Display Breakpoint
         dw    'CR',changereg              ; Change Register
         dw    'OB',outportb           
         dw    'BS',changebs               ; Change Base Segment Address
         dw    'OW',outportw
         dw    'IB',inportb
         dw    'IW',inportw
         dw    'WB',wrmemb                 ; Write Byte to Memory
         dw    'WW',wrmemw                 ; Write Word to Memory
endtab2  dw    '??'
;
disphelp:
         mov   si,str_help
         PUTS
         jmp   command
;----------------------------------------------------------------------
; Quit Monitor
;----------------------------------------------------------------------
exitmon: jmp   command

;======================================================================
; Monitor routines
;======================================================================
;----------------------------------------------------------------------
; Return String Length in AL
; String pointed to by DS:[SI]
;----------------------------------------------------------------------
strlen:     push    si
            mov     ah,-1
            cld 
nextsl:     inc     ah
            lodsb                               ; AL=DS:[SI++]
            or      al,al                       ; Zero?
            jnz     nextsl                      ; No, continue
            mov     al,ah                       ; Return Result in AX
            xor     ah,ah                       
            pop     si
            ret
         
;----------------------------------------------------------------------
; Write Byte to Output port 
;----------------------------------------------------------------------
outportb:   
         call  gethex4                     ; Get Port address
         mov   dx,ax
         WREQUAL     
         call  gethex2                     ; Get Port value
         out   dx,al
         jmp   command                     ; Next Command  

;----------------------------------------------------------------------
; Write Word to Output port 
;----------------------------------------------------------------------
outportw:
         call  gethex4                     ; Get Port address
         mov   dx,ax
         WREQUAL     
         call  gethex4                     ; Get Port value
         out   dx,ax
         jmp   command                     ; Next Command  

;----------------------------------------------------------------------
; Read Byte from Input port 
;----------------------------------------------------------------------
inportb:
         call  gethex4                     ; Get Port address
         mov   dx,ax
         WREQUAL
         in    al,dx
         call  puthex2
         jmp   command                     ; Next Command  

;----------------------------------------------------------------------
; Read Word from Input port 
;----------------------------------------------------------------------
inportw:
         call    gethex4                     ; Get Port address
         WREQUAL
         PUTC
         in      ax,dx
         call    puthex4
         jmp     command                     ; Next Command  
;
;----------------------------------------------------------------------
; Display Memory    
;----------------------------------------------------------------------
dumpmem: call  getrange                    ; Range from BX to DX
nextdmp: mov   si,dumpmems                 ; Store ASCII values

         call  newline
         mov   ax,es
         call  puthex4
         mov   al,':'
         PUTC
         mov   ax,bx
         and   ax,0FFF0h
         call  puthex4
         WRSPACE                             ; Write Space
         WRSPACE                             ; Write Space
         
         mov   ah,bl                       ; Save lsb
         and   ah,0Fh                      ; 16 byte boundary

         call  wrnspace                    ; Write AH spaces
         call  wrnspace                    ; Write AH spaces
         call  wrnspace                    ; Write AH spaces
                        
dispbyte:
         mov   cx,16
         sub   cl,ah
                
loopdmp1:   
         mov     al,es:[bx]                  ; Get Byte and display it in HEX
         mov     ds:[si],al                  ; Save it
         call    puthex2
         WRSPACE                             ; Write Space
         inc     bx
         inc     si
         cmp     bx,dx
         jnc     showrem                     ; show remaining 
         loop    loopdmp1
                                             
         call    putsdmp                     ; Display it

         cmp     dx,bx                       ; End of memory range?
         jnc     nextdmp                     ; No, continue with next 16 bytes

showrem: mov     si,dumpmems                 ; Stored ASCII values
         mov     ax,bx
         and     ax,0000Fh
         test    al,al
         jz      skipclr
         add     si,ax                       ; Offset
         mov     ah,16
         sub     ah,al
         mov     cl,ah
         xor     ch,ch
         mov     al,' '                      ; Clear non displayed values
nextclr: mov     ds:[si],al                  ; Save it
         inc     si
         loop    nextclr
         call    wrnspace                    ; Write AH spaces
         call    wrnspace                    ; Write AH spaces
         call    wrnspace                    ; Write AH spaces
skipclr: xor     ah,ah
         call    putsdmp

exitdmp: jmp     command                     ; Next Command

putsdmp: mov     si,dumpmems                 ; Stored ASCII values
         WRSPACE                             ; Add 2 spaces
         WRSPACE
         call    wrnspace                    ; Write AH spaces
         mov     cx,16
         sub     cl,ah                       ; Adjust if not started at xxx0
nextch:  lodsb                               ; Get character AL=DS:[SI++]
         cmp     AL,01Fh                     ; 20..7E printable
         jbe     printdot
         cmp     AL,07Fh
         jae     printdot
         jmp     printch
printdot:   
         mov     al,'.'
printch: PUTC                          
         loop    nextch                      ; Next Character
         ret

wrnspace:   
         push    ax                          ; Write AH space, skip if 0 
         push    cx
         test    ah,ah
         jz      exitwrnp
         xor     ch,ch                       ; Write AH spaces
         mov     cl,ah
         mov     al,' '
nextdtx: PUTC
         loop    nextdtx
exitwrnp:
         pop     cx
         pop     ax
         ret

;----------------------------------------------------------------------
; Fill Memory   
;----------------------------------------------------------------------
fillmem: call    getrange                    ; First get range BX to DX
         WRSPACE
         call    gethex2
         push    ax                          ; Store fill character
         call    newline
                   
         cmp     dx,bx
         jb      exitfill
dofill:  sub     dx,bx
         mov     cx,dx            
         mov     di,bx                       ; ES:[DI]
         pop     ax                          ; Restore fill char
nextfill:
         stosb
         loop    nextfill
         stosb                               ; Last byte
exitfill:   
         jmp     command                         ; Next Command

;----------------------------------------------------------------------
; Set Breakpoint
;----------------------------------------------------------------------
setbreakp:  
         mov     bx,bptab                    ; BX point to Breakpoint table
         call    gethex1                     ; Set Breakpoint, first get BP number
         and     al,07h                      ; Allow 8 breakpoints
         xor     ah,ah
         shl     al,1                        ; *4 to get offset
         shl     al,1                        
         add     bx,ax                       ; point to table entry 
         mov     byte es:[bx+3],1            ; Enable Breakpoint
         WRSPACE
         call    gethex4                     ; Get Address
         mov     es:[bx],ax                  ; Save Address

         mov     di,ax
         mov     al,es:[di]                  ; Get the opcode
         mov     es:[bx+2],al                ; Store in table
                     
         jmp     dispbreakp                  ; Display Enabled Breakpoints  

;----------------------------------------------------------------------
; Clear Breakpoint
;----------------------------------------------------------------------
clrbreakp:  
         mov     bx,bptab                    ; BX point to Breakpoint table
         call    gethex1                     ; first get BP number
         and     al,07h                      ; Only allow 8 breakpoints
         xor     ah,ah
         shl     al,1                        ; *4 to get offset
         shl     al,1                        
         add     bx,ax                       ; point to table entry 
         mov     byte es:[bx+3],0            ; Clear Breakpoint
                                 
         jmp     dispbreakp                  ; Display Remaining Breakpoints

;----------------------------------------------------------------------
; Display all enabled Breakpoints
; # Addr
; 0 1234
;----------------------------------------------------------------------
dispbreakp:
         call    newline
         mov     bx,bptab
         mov     cx,8

nextcbp: mov     ax,8
         sub     al,cl

         test    byte es:[bx+3],1            ; Check enable/disable flag
         jz      nextdbp

         call    puthex1                     ; Display Breakpoint Number
         WRSPACE
         mov     ax,es:[bx]                  ; Get Address
         call    puthex4                     ; Display it
         WRSPACE

         mov     ax,es:[bx]                  ; Get Address
;         call    disasm_ax                  ; Disassemble instruction & Display it
         call    newline

nextdbp: add     bx,4                        ; Next entry
         loop    nextcbp
         jmp     command                     ; Next Command  

;
;----------------------------------------------------------------------
; Display Registers
;
; AX=0001 BX=0002 CX=0003 DX=0004 SP=0005 BP=0006 SI=0007 DI=0008
; DS=0009 ES=000A SS=000B CS=000C IP=0100   ODIT-SZAPC=0000-00000 
;----------------------------------------------------------------------
dispreg: call    newline
         mov     si,str_reg                  ; OFFSET -> SI
         lea     di,uax

         mov     cx,8
         push    es
         mov     ax,stack_group
         mov     es,ax
nextdr1: PUTS                                ; Point to first "AX=" string
         mov     ax,[es:di]                     ; DI points to AX value
         call    puthex4                     ; Display AX value
         add     si,5                        ; point to "BX=" string
         add     di,2                        ; Point to BX value
         loop    nextdr1                     ; etc

         call    newline
         mov     cx,5
nextdr2: PUTS                                ; Point to first "DS=" string
         mov     ax,[es:di]                     ; DI points to DS value
         call    puthex4                     ; Display DS value
         add     si,5                        ; point to "ES=" string
         add     di,2                        ; Point to ES value
         loop    nextdr2                     ; etc

         mov     si,str_flag
         PUTS
         mov     si,flag_valid               ; String indicating which bits to display
         mov     bx,[es:di]                     ; get flag value in BX
         
         mov     cx,8                        ; Display first 4 bits
nextbit1:
         lodsb                               ; Get display/notdisplay flag AL=DS:[SI++]
         cmp     al,'X'                      ; Display?
         jne     shftcar                     ; Yes, shift bit into carry and display it
         sal     bx,1                        ; no, ignore bit
         jmp     exitdisp1
shftcar: sal     bx,1
         jc      disp1
         mov     al,'0'
         jmp     dispbit
disp1:   mov     al,'1'
dispbit: PUTC
exitdisp1:
         loop    nextbit1

         mov     al,'-'                      ; Display seperator 0000-00000
         PUTC

         mov     cx,8                        ; Display remaining 5 bits
nextbit2:   
         lodsb                               ; Get display/notdisplay flag AL=DS:[SI++]
         cmp     al,'X'                      ; Display?
         jne     shftcar2                    ; Yes, shift bit into carry and display it
         sal     bx,1                        ; no, ignore bit
         jmp     exitdisp2
shftcar2:   
         sal     bx,1
         jc      disp2
         mov     al,'0'
         jmp     dispbit2
disp2:   mov     al,'1'
dispbit2:
         PUTC
exitdisp2:  
         loop    nextbit2

         call    newline                     ; Display CS:IP Instr
         mov     ax,[es:ucs]                        
         call    puthex4
         mov     al,':'
         PUTC
         mov     ax,[es:uip]
         call    puthex4
         WRSPACE

;         mov     ax,[es:uip]                    ; Address in AX
;         pop     es
;         call    disasm_ax                   ; Disassemble Instruction & Display

         jmp     command                         ; Next Command

;tracenext:
;traceprog:
exitdh:  jmp     command                   ; Next Command

;----------------------------------------------------------------------
; Execute program
; 1) Enable all Breakpoints (replace opcode with INT3 CC)
; 2) Restore User registers
; 3) Jump to CS:USER_OFFSET
;----------------------------------------------------------------------
execprog:
         mov     bx,bptab                    ; Enable All breakpoints
         mov     cx,8
         push    ds
         mov     ax,ss:[ucs]
         mov     ds,ax                       ; Set up the data segment to point to the code area

nextenbp:   
         mov     ax,8
         sub     al,cl
         test    byte ss:[bx+3],1            ; Check enable/disable flag
         jz      nextexbp
         mov     di,ss:[bx]                  ; Get Breakpoint Address
         mov     byte es:[di],0CCh           ; Write INT3 instruction to address

nextexbp:   
         add     bx,4                        ; Next entry
         loop    nextenbp
         pop     ds                          ; Restore the data segment
tracentry:
         mov     ax,ss:[ucs]                 ; Display Segment Address
         call    puthex4
         mov     al,':'
         PUTC
         call    gethex4                     ; Get new IP
         mov     ss:[uip],ax                 ; Update User IP
;         mov     ax,es
;         mov     es:[ucs],ax
            
; Single Step Registers
; bit3 bit2 bit1 bit0
;  |    |    |     \--- '1' =Enable Single Step     
;  |    |     \-------- '1' =Select TXMON output for UARTx  
;  \-----\------------- '00'=No Step    
;                       '01'=Step   
;                       '10'=select step_sw input   
;                       '11'=select not(step_sw) input          
;           MOV     DX,HWM_CONFIG
;           MOV     AL,07h                      ; xxxx-0111 step=1
;           OUT     DX,AL                       ; Enable Trace
            
TRACNENTRY: 
         mov     ax,ss
         mov     es,ax
         mov     ax,es:[uax]                    ; Restore User Registers
         mov     bx,es:[ubx]
         mov     cx,es:[ucx]
         mov     dx,es:[udx]
         mov     bp,es:[ubp]
         mov     si,es:[usi]
         mov     di,es:[udi]

         mov     ds,es:[uds]
         cli                                    ; User User Stack!!
         mov     ss,es:[uss]
         mov     sp,es:[usp]
         
         push    word es:[ufl]
         push    word es:[ucs]                       ; Push CS (Base Segment) 
         push    word es:[uip]
         mov     es,es:[ues]
         iret                                   ; Execute!


;----------------------------------------------------------------------
; Load Hex, terminate when ":00000001FF" is received
; Mon88 may hang if this string is not received
; Print '.' for each valid received frame, exit upon error 
; Bytes are loaded at Segment=ES
;----------------------------------------------------------------------
loadhex:    mov     si,str_load         ; Display Ready to receive upload
            PUTS
            
            mov     al,'>'
            jmp     dispch

rxbyte:     xchg    bh,ah                       ; save AH register
            call    rxnib
            mov     ah,al
            shl     ah,1                        ; Can't use CL
            shl     ah,1
            shl     ah,1
            shl     ah,1
            call    rxnib
            or      al,ah
            add     bl,al                       ; Add to check sum
            xchg    bh,ah                       ; Restore AH register
            ret            
            
rxnib:      GETCNE                              ; Get Hex Character in AL
            cmp     AL,'0'                      ; Check to make sure 0-9,A-F
            jb      error                       ; ERRHEX
            cmp     AL,'F'      
            ja      error                       ; ERRHEX
            cmp     AL,'9'      
            jbe     sub0        
            cmp     AL,'A'      
            jb      error                       ; ERRHEX
            sub     AL,07h                      ; Convert to hex
sub0:       sub     AL,'0'                      ; Convert to hex
            ret
            
                        
error:      mov     al,'E'
dispch:     PUTC

waitlds:    GETCNE                              ; Wait for ':'
            cmp     al,':'
            jne     waitlds

            xor     cx,cx                       ; CL=Byte count
            xor     bx,bx                       ; BL=Checksum

            call    rxbyte                      ; Get length in CX
            mov     cl,al

            call    rxbyte                      ; Get Address HIGH
            mov     ah,al
            call    rxbyte                      ; Get Address LOW
            mov     DI,AX                       ; DI=Store Address

            call    rxbyte                      ; Get Record Type
            cmp     al,EOF_REC                  ; End Of File Record
            je      goendld
            cmp     al,DATA_REC                 ; Data Record?
            je      goload
            cmp     al,EAD_REC                  ; Extended Address Record?
            je      goead
            cmp     al,SSA_REC                  ; Start Segment Address Record?
            je      gossa
            jmp     error                       ; ERRREC

gossa:      mov     cx,2                        ; Get 2 word
nextw:      call    rxbyte
            mov     ah,al
            call    rxbyte
            push    ax                          ; Push CS, IP
            loop    nextw
            call    rxbyte                      ; Get Checksum
            sub     bl,al                       ; Remove checksum from checksum
            not     al                          ; Two's complement
            add     al,1
            cmp     al,bl                       ; Checksum held in BL
            jne     error                       ; ERRCHKS           
            retf                                ; Execute loaded file

goendld:    call    rxbyte
            sub     bl,al                       ; Remove checksum from checksum
            not     al                          ; Two's complement
            add     al,1
            cmp     al,bl                       ; Checksum held in BL
            jne     error                       ; ERRCHKS
            jmp     loadok

gocheck:    call    rxbyte
            sub     bl,al                       ; Remove checksum from checksum
            not     al                          ; Two's complement
            add     al,1
            cmp     al,bl                       ; Checksum held in BL
            jne     error                       ; ERRCHKS
            mov     al,'.'                      ; After each successful record print a '.'
            jmp     dispch

goload:     call    rxbyte                      ; Read Bytes
            stosb                               ; ES:DI <= AL
            loop    goload
            jmp     gocheck

goead:      call    rxbyte
            mov     ah,al
            call    rxbyte
            mov     es,ax                       ; Set Segment address (ES)
            jmp     gocheck

loadok:     mov     si,str_ld_ok                 ; Display Load OK
            jmp     exitld
errhex:     mov     si,str_ld_hex                ; Display Error hex value
exitld:     PUTS
            jmp     command                      ; Exit Load Command

;----------------------------------------------------------------------
; Write Byte to Memory
;----------------------------------------------------------------------
wrmemb:  call    gethex4                     ; Get Address
         mov     bx,ax                       ; Store Address
         WRSPACE
            
         mov     al,es:[bx]                  ; Get current value and display it
         call    puthex2
         WREQUAL
         call    gethex2                     ; Get new value
         mov     es:[bx],al                  ; and write it
          
         jmp     command                     ; Next Command

;----------------------------------------------------------------------
; Write Word to Memory
;----------------------------------------------------------------------            
wrmemw:  call    gethex4                     ; Get Address
         mov     bx,ax
         WRSPACE 

         mov     ax,es:[bx]                  ; Get current value and display it
         call    puthex4
         WREQUAL
         call    gethex4                     ; Get new value
         mov     es:[bx],ax                  ; and write it
         
         jmp     command                         ; Next Command  

;----------------------------------------------------------------------
; Change Register
; Valid register names: AX,BX,CX,DX,SP,BP,SI,DI,DS,ES,SS,CS,IP,FL (flag)
;----------------------------------------------------------------------
changereg:  
         GETC                                ; Get Command First Register character
         call    to_upper
         mov     dl,al
         GETC                                ; Get Second Register character, DX=register
         call    to_upper
         mov     dh,al
         mov     bx,regtab
cmpreg:  mov     ax,[bx]
         cmp     ax,dx                       ; Compare register string with user input
         jne     nextreg                     ; No, continue search

         WREQUAL
         call    gethex4                     ; Get new value
         mov     cx,ax                       ; CX=New reg value

         push    es
         push    ax
         mov     ax,stack_group
         mov     es,ax
         pop     ax
         lea     di,uax                      ; Point to User Register Storage            
         mov     bl,[bx+2]                   ; Get Offset
         xor     bh,bh
         mov     [es:di+bx],cx
         pop     es
         jmp     dispreg                     ; Display All registers

nextreg:    
         add     bx,4
         cmp     bx,endreg
         jne     cmpreg                      ; Continue looking
         
         mov     si,str_errreg               ; Display Unknown Register Name
         PUTS                        

         jmp     command                     ; Try Again 

;----------------------------------------------------------------------
; Change Base Segment pointer
; Dump/Fill/Load operate on baseseg:[USER INPUT ADDRESS]
; Note: CB command will not update the User Registers!  
;----------------------------------------------------------------------
changebs:   
         mov     ax,ss:[baseseg]               ; current base segment
         call    puthex4                     ; Display current value
         WRSPACE
         call    gethex4
         push    ax
         mov     ss:[baseseg],ax               ; Save new base segment
         pop     es
         jmp     command                     ; Next Command  


;----------------------------------------------------------------------
; Write newline
;----------------------------------------------------------------------
newline: push    ax
         mov     al,CR
         PUTC
         mov     al,LF
         PUTC
         pop     ax
         ret
;----------------------------------------------------------------------
; Get Address range into BX, DX 
;----------------------------------------------------------------------
getrange:
         push    ax
         call    gethex4
         mov     bx,ax
         mov     al,'-'
         PUTC
         call    gethex4
         mov     dx,ax
         pop     ax
         ret

;----------------------------------------------------------------------
; Get Hex4,2,1 Into AX, AL, AL  
;----------------------------------------------------------------------
gethex4: push    bx
         call    gethex2                     ; Get Hex Character in AX
         mov     bl,al
         call    gethex2
         mov     ah,bl
         pop     bx
         ret

gethex2: push    bx
         call    gethex1                      ; Get Hex character in AL
         mov     bl,al
         shl     bl,1
         shl     bl,1
         shl     bl,1
         shl     bl,1
         call    gethex1
         or      al,bl
         pop     bx
         ret

gethex1: GETC                                ; Get Hex character in AL
         cmp     al,ESC
         jne     okchar
         jmp     command                     ; Abort if ESC is pressed
okchar:  call    to_upper
         cmp     al,39h                      ; 0-9?
         jle     convdec                     ; yes, subtract 30
         sub     al,07h                      ; A-F subtract 39
convdec: sub     al,30h
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
         PUTC                                ; Send to the console
         pop     ax
         ret

;----------------------------------------------------------------------
; Convert to Upper Case
; if (c >= 'a' && c <= 'z') c -= 32;
;----------------------------------------------------------------------
to_upper:
         cmp     al,'a'
         jge     checkz
         ret
checkz:  cmp     al,'z'
         jle     sub32
         ret
sub32:   sub     al,32
         ret

%include "src/int_handlers.asm"
;%include "src/monitor_disasm.asm"

str_reg: db    "AX=",0,0                       ; Display Register names table
         db    " BX=",0
         db    " CX=",0
         db    " DX=",0
         db    " SP=",0
         db    " BP=",0
         db    " SI=",0
         db     " DI=",0

         db    "DS=",0,0
         db    " ES=",0
         db    " SS=",0
         db    " CS=",0
         db    " IP=",0
;
str_flag:
         db  "   ODIT-SZAPC=",0
flag_valid:  
         db  "XXXX......X.X.X.",0        ; X=Don't display flag bit, .=Display
str_welcome:
         db    '8088 Monitor ver 0.10', CR, LF, EOT
str_errcmd:
         db    ' <- Unknown Command, type H to Display Help',EOT
str_errreg:
         db    ' <- Unknown Register, valid names: AX,BX,CX,DX,SP,BP,SI,DI,DS,ES,SS,CS,IP,FL',EOT
str_prompt:
         db    CR,LF,'Cmd> ',EOT
str_help:
         db    CR,LF,"Commands"
         db    CR,LF,"DM {from} {to}        : Dump Memory, example D 0000 0100"
         db    CR,LF,"FM {from} {to} {Byte} : Fill Memory, example FM 0200 020F 5A"
         db    CR,LF,"R                     : Display Registers"
         db    CR,LF,"CR {reg}              : Change Registers, example CR SP=1234"
         db    CR,LF,"L                     : Load Intel hexfile"
;         db    CR,LF,"U  {from} {to}        : Un(dis)assemble range, example U 0120 0128"
         db    CR,LF,"G  {Address}          : Execute, example G 0100"
;         db    CR,LF,"T  {Address}          : Trace from address, example T 0100"
;         db    CR,LF,"N                     : Trace Next"
         db    CR,LF,"BP {bp} {Address}     : Set BreakPoint, bp=0..7, example BP 0 2344"
         db    CR,LF,"CB {bp}               : Clear Breakpoint, example BS 7 8732"
         db    CR,LF,"DB                    : Display Breakpoints"
         db    CR,LF,"BS {Word}             : Change Base Segment Address, example BS 0340"
         db    CR,LF,"WB {Address} {Byte}   : Write Byte to address, example WB 1234 5A"
         db    CR,LF,"WW {Address} {Word}   : Write Word to address"
         db    CR,LF,"IB {Port}             : Read Byte from Input port, example IB 03F8"
         db    CR,LF,"IW {Port}             : Read Word from Input port"
         db    CR,LF,"OB {Port} {Byte}      : Write Byte to Output port, example OB 03F8 3A"
         db    CR,LF,"OW {Port} {Word}      : Write Word to Output port, example OB 03F8 3A5A"
         db    CR,LF,"Q                     : Restart Monitor",EOT

regtab   dw  'AX',0                      ; register name, offset
         dw  'BX',2                  
         dw  'CX',4                  
         dw  'DX',6                  
         dw  'SP',8                  
         dw  'BP',10                 
         dw  'SI',12                 
         dw  'DI',14                 
         dw  'DS',16                 
         dw  'ES',18                 
         dw  'SS',20                 
         dw  'CS',22                 
         dw  'IP',24                 
         dw  'FL',26                 
endreg   dw  '??'

str_load:
         db  CR,LF,"Start upload now, load is terminated by :00000001FF",CR,LF,EOT
str_ld_chks:
         db  CR,LF,"Error: CheckSum failure",CR,LF,EOT
std_ld_rec:
         db  CR,LF,"Error: Unknown Record Type",CR,LF,EOT
str_ld_hex:
         db  CR,LF,"Error: Non Hex value received",CR,LF,EOT
str_ld_ok:
         db  CR,LF,"Load done",CR,LF,EOT
str_term:
         db  CR,LF,"Program Terminated with exit code ",EOT
; Mess+18=? character, change by bp number
str_breakp:
         db  CR,LF,"**** BREAKPOINT ? ****",CR,LF,EOT

;
; Test program to pre-load
;
test_prog:
         db      0beh, 12h, 01h, 0E8h, 02h, 00h, 0cdh, 0ah, 0ach, 08h, 0c0h, 74h, 04h, 0cdh, 06h, 0ebh, 0f7h, 0c3h
         db      CR,LF,'Hello, World!', CR, LF, EOT
test_end:
;----------------------------------------------------------------------
; Initial Register values
;----------------------------------------------------------------------
reg_init:
         dw      00h                         ; AX
         dw      01h                         ; BX
         dw      02h                         ; CX
         dw      03h                         ; DX
         dw      0100h                       ; SP
         dw      05h                         ; BP
         dw      06h                         ; SI
         dw      07h                         ; DI
         dw      BASE_SEG                    ; DS
         dw      BASE_SEG                    ; ES
         dw      BASE_SEG                    ; SS
         dw      BASE_SEG                    ; CS
         dw      0100h                       ; IP
         dw      0F03Ah                      ; flags
bp_init:
         dw      00h dup 32
;
; pad out ROM with FFh
times    ROMSIZE-16-($-$$) db 0FFh
; reset vector
         jmp   ROMCS:start ;  Jump to start
; pad out the rest of the ROM with NOPs
times    ROMSIZE-($-$$) db 0x90
;
section  .bss
stack_group:
;
vectors: resw    512                     ; reserve space for 256 vectors (ip + seg)
baseseg: resw    1                       ; space for base segment
;----------------------------------------------------------------------
; Save Register values
;----------------------------------------------------------------------
uax      resw    1                       ; AX
ubx      resw    1                       ; BX
ucx      resw    1                       ; CX
udx      resw    1                       ; DX
usp      resw    1                       ; SP
ubp      resw    1                       ; BP
usi      resw    1                       ; SI
udi      resw    1                       ; DI
uds      resw    1                       ; DS
ues      resw    1                       ; ES
uss      resw    1                       ; SS
ucs      resw    1                       ; CS
uip      resw    1                       ; IP
ufl      resw    1                       ; flags
;
;----------------------------------------------------------------------
; Disassembler string storage
;----------------------------------------------------------------------
disasm_inst:
         resb  48                        ; Stored Disassemble string
disasm_code:
         resb  32                        ; Stored Disassemble Opcode 
                    
dumpmems resb  16                        ; Stored memdump read values
;----------------------------------------------------------------------
; Breakpoint Table, Address(2), Opcode(1), flag(1) enable=1, disable=0
;----------------------------------------------------------------------
bptab    resb   32                      ; 8 breakpoints
;
         resb  STACK_SIZE               ; Reserve space for the stack
tos      resb  1                        ; top of stack
;
