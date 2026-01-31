         cpu     8086

;ROMSIZE     equ     04000h
;ROMCS       equ     0F000h
;INIT_SS     equ     07000h
;INIT_SP     equ     0FFF0h
;STACK_SIZE  equ     0100h
;
RAM_BASE    equ     0x000000            ; RAM start
RAM_END     equ     0x07FFFF            ; RAM end
ROM_BASE    equ     0x080000            ; ROM start
ROM_END     equ     0x0FFFFF            ; ROM end
;
IO_BASE     equ     0x00                ; I/O Base address
IO1_BASE    equ     IO_BASE             ; First Motorola I/O Card
IO2_BASE    equ     IO_BASE+0x20        ; Second Motorol I/O Card
;
; DEFINITIONS FOR FIRST MOTOROLA I/O CARD
;
;
; Motorola 6850 ACIA
;
ACIA1          equ      IO1_BASE+$08 ; Location of ACIA
ACIA1_STATUS   equ      ACIA1        ; Status
ACIA1_CONTROL  equ      ACIA1        ; Control
ACIA1_DATA     equ      ACIA1+1      ; Data
;
; Motorola 6840 PTM (Programmable Timer Module)
;
PTM1           equ     IO1_BASE
PTM1_CR13      equ     PTM1         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM1_SR        equ     PTM1+1
PTM1_CR2       equ     PTM1+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM1_T1MSB     equ     PTM1+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM1_T1LSB     equ     PTM1+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM1_T2MSB     equ     PTM1+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM1_T2LSB     equ     PTM1+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM1_T3MSB     equ     PTM1+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM1_T3LSB     equ     PTM1+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PIA1BASE       equ     IO1_BASE+$10    ; PIA Base address (ELENC updated for MECB)
PIA1REGA       equ     PIA1BASE       ; data reg A
PIA1DDRA       equ     PIA1BASE       ; data dir reg A
PIA1CTLA       equ     PIA1BASE+1     ; control reg A
PIA1REGB       equ     PIA1BASE+2     ; data reg B
PIA1DDRB       equ     PIA1BASE+2     ; data dir reg B
PIA1CTLB       equ     PIA1BASE+3     ; control reg B
;
; DEFINITIONS FOR SECOND MOTOROLA I/O CARD
;
; Motorola 6850 ACIA
;
ACIA2         equ      IO2_BASE+$08 ; Location of ACIA
ACIA2_STATUS  equ      ACIA2        ; Status
ACIA2_CONTROL equ      ACIA2        ; Control
ACIA2_DATA    equ      ACIA2+1      ; Data
;
PTM2           equ     IO2_BASE
PTM2_CR13      equ     PTM2         ; Write: Timer Control Registers 1 & 3   Read: NOP
PTM2_SR        equ     PTM2+1
PTM2_CR2       equ     PTM2+1       ; Write: Control Register 2              Read: Status Register (least significant bit selects TCR as TCSR1 or TCSR3)
;
PTM2_T1MSB     equ     PTM2+2       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM2_T1LSB     equ     PTM2+3       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM2_T2MSB     equ     PTM2+4       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM2_T2LSB     equ     PTM2+5       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PTM2_T3MSB     equ     PTM2+6       ; Write: MSB Buffer Register             Read: Timer 1 Counter
PTM2_T3LSB     equ     PTM2+7       ; Write: Timer #1 Latches                Read: LSB Buffer Register
;
PIA2BASE       equ     IO2_BASE+$10    ; PIA Base address (ELENC updated for MECB)
PIA2REGA       equ     PIA2BASE        ; data reg A
PIA2DDRA       equ     PIA2BASE        ; data dir reg A
PIA2CTLA       equ     PIA2BASE+1      ; control reg A
PIA2REGB       equ     PIA2BASE+2      ; data reg B
PIA2DDRB       equ     PIA2BASE+2      ; data dir reg B
PIA2CTLB       equ     PIA2BASE+3      ; control reg B
;
; I/O mapping for VDP
;
VDP            equ     IO_BASE+$80     ; TMS9918A Video Display Processor
VDP_VRAM       equ     VDP+0           ; used for VRAM reads/writes
VDP_REG        equ     VDP+1           ; control registers/address latch
;
; I/O mapping for OLED
;
OLED           equ     IO_BASE+$88     ; OLED Panel base address
OLED_CMD       equ     OLED            ; OLED Command address
OLED_DTA       equ     OLED+1          ; OLED Data address
;
; ASCII control characters
BS          equ     08h               ; backspace
CR          equ     0Dh               ; carraige return
LF          equ     0Ah               ; form feed
ESC         equ     1Bh               ; escape
SPACE       equ     20h               ; space
EOT         equ     00h               ; End of Text
;
v_a:        equ     0xfa00      ; Y-coordinate 
v_b:        equ     0xfa02      ; X-coordinate
v_x:        equ     0xfa04      ; x 32-bit for Mandelbrot 24.8 fraction
v_y:        equ     0xfa08      ; y 32-bit for Mandelbrot 24.8 fraction
v_s1:       equ     0xfa0c      ; temporal s1
v_s2:       equ     0xfa10      ; temporal s2
;
         org      0100h
;
section  .text
         global   start
         
start:
         cli
;
; Initialise the ACIA / Serial interface
; Default character output device is the serial port.
;
;         call     init_acia
         mov      ax,cs
         mov      ds,ax
         mov      si, str_mandel_start
         call     puts
         call     setgmode7                  ; Set graphics mode 7 (8-bit colour 256 x 192)
         mov      dx,0x0000                  ; Set VRAM write address to 0x00000
         mov      bx,0x0000
         call     vdp_vram_waddr
         mov      cx,0x0000
         mov      al,0x00
clear:   out      VDP_VRAM,al
         dec      cx
         jnz      clear
         mov      dx,0x0000                  ; Set VRAM write address to 0x00000
         mov      bx,0x0000
         call     vdp_vram_waddr
         
         call     mandel
         mov      ax,cs
         mov      ds,ax
         mov      si, str_mandel_end
         call     puts
;
loop:    jmp      loop
;
;
setgmode7:
         push  ax
         mov   al,0x0E
         mov   ah,0x00
         call  vdp_write_reg
         mov   al,0x40
         mov   ah,0x01
         call  vdp_write_reg
         mov   al,0x82
         mov   ah,0x09
         call  vdp_write_reg
         mov   al,0x00
         mov   ah,0x07
         call  vdp_write_reg
         mov   al,0x0A
         mov   ah,0x08
         call  vdp_write_reg
         mov   al,0x1F
         mov   ah,0x02
         call  vdp_write_reg
         pop   ax
         ret

; Function:	Setup VRAM Address for subsequent VRAM write
; Parameters:  bx - VRAM address (lower 16 bits)
;              dx - bit 0 = A16
; Returns:     -
; Destroys:    -
vdp_vram_waddr:
         push     ax
         mov      al,0x00        ; Set VRAM bank (VRAM, not Expansion RAM)
         mov      ah,45          ; Register #45
         call     vdp_write_reg
         mov      ah,dl
         mov      al,bh
         shr      ax,1
         shr      ax,1
         shr      ax,1
         shr      ax,1
         shr      ax,1
         shr      ax,1           ; al now contains A16-A14
         mov      ah,14          ; Register #14
         call     vdp_write_reg
;
         mov      al,bl
         out      VDP_REG,al     ; Write bits A7-A0
         mov      al,bh
         and      al,0x3F
         or       al,0x40
         out      VDP_REG,al     ; Write A13-A8 and set for write
         pop      ax
         ret

; Function:	Write a data byte into a specified VDP register
; Parameters:  al - Data Byte
;              ah - Register number
; Returns:     -
; Destroys:    -
vdp_write_reg:
         push     ax
         out      VDP_REG,al     ; Store data byte
         and      ah,0x3F
         or       ah,0x80
         mov      al,ah
         out      VDP_REG,al     ; Store masked register number
         pop      ax
         ret

; Function:	Write byte to current VRAM write address
; Note:		Routine intended for functional documentation only
;		i.e. Just directly inline implement: out VDP_VRAM,al
; Parameters:	A - VRAM Byte to write
; Returns:	-
; Destroys:	-
vdp_write_vram:
         out   VDP_VRAM,al
         ret
;
mandel:
         cld                     ; String operations forward
         mov      ax,0x2000      ; 0x2000 video segment
         mov      ds,ax          ; Setup data segment
         mov      es,ax          ; Setup extended segment

m4:
         mov ax,191              ; 199 is the bottommost row
         mov [v_a],ax            ; Save into v_a
m0:      mov ax,255              ; 319 is the rightmost column
         mov [v_b],ax            ; Save into v_b

m1:      xor ax,ax       
         mov [v_x],ax            ; x = 0.0
         mov [v_x+2],ax
         mov [v_y],ax            ; y = 0.0
         mov [v_y+2],ax
         mov cx,0                ; Iteration counter

m2:      push cx                 ; Save counter
         mov ax,[v_x]            ; Read x
         mov dx,[v_x+2]
         call square32           ; Get x² (x * x)
         push dx                 ; Save result to stack
         push ax
         mov ax,[v_y]            ; Read y
         mov dx,[v_y+2]
         call square32           ; Get y² (y * y)

         pop bx          
         add ax,bx               ; Add both (x² + y²)
         pop bx
         adc dx,bx

         pop cx                  ; Restore counter
         cmp dx,0                ; Result is >= 4.0 ?
         jne m3
         cmp ax,4*256
         jnc m3                  ; Yes, jump

         push cx
         mov ax,[v_y]            ; Read y
         mov dx,[v_y+2]
         call square32           ; Get y² (y * y)
         push dx
         push ax
         mov ax,[v_x]            ; Read x
         mov dx,[v_x+2]
         call square32           ; Get x² (x * x)

         pop bx
         sub ax,bx               ; Subtract (x² - y²)	
         pop bx
         sbb dx,bx

;
; Adding x coordinate like a fraction
; to current value.
;
         add ax,[v_b]            ; Add x coordinate
         adc dx,0
         add ax,[v_b]            ; Add x coordinate
         adc dx,0
         add ax,[v_b]            ; Add x coordinate
         adc dx,0
         add ax,[v_b]            ; Add x coordinate
         adc dx,0
         sub ax,550              ; Center coordinate
         sbb dx,0        

         push ax                 ; Save result to stack
         push dx

         mov ax,[v_x]            ; Get x
         mov dx,[v_x+2]
         mov bx,[v_y]            ; Get y
         mov cx,[v_y+2]
         call mul32              ; Multiply (x * y)

         shl ax,1                ; Multiply by 2
         rcl dx,1

         add ax,[v_a]            ; Add y coordinate
         adc dx,0
         add ax,[v_a]            ; Add y coordinate
         adc dx,0
         add ax,[v_a]            ; Add y coordinate
         adc dx,0
         add ax,[v_a]            ; Add y coordinate
         adc dx,0
         sub ax,300              ; Center coordinate
         sbb dx,0

         mov [v_y],ax            ; Save as new y value
         mov [v_y+2],dx

         pop dx                  ; Restore value from stack
         pop ax

         mov [v_x],ax            ; Save as new x value
         mov [v_x+2],dx

         pop cx
         inc cx                  ; Increase iteration counter
         cmp cx,100              ; Attempt 100?
         je m3                   ; Yes, jump
         jmp m2                  ; No, continue

m3:      mov ax,[v_a]            ; Get Y-coordinate
         mov dx,256              ; Multiply by 256 (size of pixel row)
         mul dx
         add ax,[v_b]            ; Add X-coordinate to result
         xchg ax,di              ; Pass AX to DI

         add cl,0x20             ; Index counter into rainbow colors
         mov   al,cl
         out VDP_VRAM,al
;         mov [di],cl             ; Put pixel on the screen
        
         dec word [v_b]          ; Decrease column
         jns m1                  ; Is it negative? No, jump
        
         dec word [v_a]          ; Decrease row
         jns m0                  ; Is it negative? No, jump
         ret
;
; Calculate a squared number
; DX:AX = (DX:AX * DX:AX) / 256
;
square32:
                                 ; Copy multiplicand to multiplier
         mov bx,ax               ; Copy AX -> BX 
         mov cx,dx               ; Copy DX -> CX
;
; 32-bit signed fractional multiplication
; DX:AX = (DX:AX * CX:BX) / 256
;
mul32:
         xor dx,cx               ; Look for different signs
         pushf
         xor dx,cx               ; Restore DX (pair of XOR = unaffected)
         jns mul32_2             ; If multiplicand is positive then jump.
         not ax                  ; Negate multiplicand
         not dx
         add ax,1
         adc dx,0
mul32_2:
         test cx,cx              ; Test if multiplier is positive
         jns mul32_3             ; Is it positive? Yes, jump.
         not bx                  ; Negate multiplier
         not cx
         add bx,1
         adc cx,0
mul32_3:
         mov [v_s1],ax           ; Save multiplicand (S1)
         mov [v_s1+2],dx

; In this diagram each point and letter
; is a word.
;    . = not calculated
;    + = calculated
;    A = AX value
;    B = multiplier
;    C = result
; rightmost column of result goes into v_s2
; next to last goes into v_s2+2
; next into v_s2+4

;       .A
;     x .B
;     ----
;       .C
;      ..

         mul bx                  ; S1:low * BX = DX:AX
         mov [v_s2],ax           ; Save provisional result
         mov [v_s2+2],dx

;       A.
;     x B.
;     ----
;       .+
;      C.

         mov ax,[v_s1+2]         ; S1:high * CX = DX:AX
         mul cx         
         mov [v_s2+4],ax         ; Save next word of result
; Notice it doesn't need DX

;       A.
;     x .B
;     ----
;       C+
;      +.

         mov ax,[v_s1+2]         ; S1:high * BX = DX:AX
         mul bx
         add [v_s2+2],ax         ; Adds to previous result
         adc [v_s2+4],dx
        
;       .A
;     x B.
;     ----
;       ++
;      +C

         mov ax,[v_s1]           ; S1:low * CX = DX:AX
         mul cx
         add [v_s2+2],ax         ; Adds to previous result
         adc [v_s2+4],dx

         mov ax,[v_s2+1]         ; Reads result shifted by 1 byte
         mov dx,[v_s2+3]         ; equivalent to divide by 256

         popf                    ; Restore flags
         jns mul32_1             ; Different signs? No, jump.
         not ax                  ; Negate result.
         not dx
         add ax,1
         adc dx,0
mul32_1:
         ret                     ; Return.

%include "src/acia_io.asm"
;
str_mandel_start:
         db       CR,LF,'Mandelbrot 8088',CR,LF,CR,LF,EOT
str_mandel_end:
         db       'Done.',CR,LF,CR,LF,EOT

;
; pad out ROM with FFh
;times    ROMSIZE-16-($-$$) db 0FFh
; reset vector
;         jmp   ROMCS:start ;  Jump to start
; pad out the rest of the ROM with NOPs
;times    ROMSIZE-($-$$) db 0x90

;
; Variable space
;
;section  .bss
;stack_group:
;
;         resb  STACK_SIZE               ; Reserve space for the stack
;tos      resb  1                        ; top of stack
;

