BASE     EQU  $3800           ; BASE for RAM use
CHIP8    EQU   BASE           ; CHIP-8 Interpreter entry point
ENTRY    EQU   BASE+$2800     ; Entry (Reset) Address
CHIPFTBL EQU   BASE+$2F00     ; CHIPOS Function jump table
VECTORS  EQU   BASE+$37F8     ; 6800 Hardware vectors
CONTRL   EQU   $F1BA          ; Return control to MIKBUG2
;
VAR      EQU   $7F00
IOV      EQU    VAR           ; IO INTERRUPT POINTER
;
IO_BASE  EQU   $8000          ; I/O Base address
IO1_BASE EQU   IO_BASE        ; First Motorola I/O Card
IO2_BASE EQU   IO_BASE+$20    ; Second Motorol I/O Card
;
; DEFINITIONS FOR FIRST MOTOROLA I/O CARD
;
;
; I/O mapping for VDP
;
VDP      EQU   IO_BASE+$80     ; TMS9918A Video Display Processor
VDP_VRAM EQU   VDP+0           ; used for VRAM reads/writes
VDP_REG  EQU   VDP+1           ; control registers/address latch
;
; I/O mapping for OLED
;
OLED     EQU   IO_BASE+$88     ; OLED Panel base address
OLED_CMD EQU   OLED            ; OLED Command address
OLED_DTA EQU   OLED+1          ; OLED Data address
;
; Motorola 6850 ACIA
;
ACIA1          EQU      IO1_BASE+$08 ; Location of ACIA
ACIA1_STATUS   EQU      ACIA1        ; Status
ACIA1_CONTROL  EQU      ACIA1        ; Control
ACIA1_DATA     EQU      ACIA1+1      ; Data
PIA      EQU   IO1_BASE+$10   ; MC6821 PIA base address
PIA_PRTA EQU   PIA            ; MC6821 PIA Port B & DDR B address
PIA_CTLA EQU   PIA+1          ; MC6821 PIA Control Register B address
PIA_PRTB EQU   PIA+2          ; MC6821 PIA Port B & DDR B address
PIA_CTLB EQU   PIA+3          ; MC6821 PIA Control Register B address
PTM      EQU   IO1_BASE       ; MC6840 PTM address
PTMSTA   EQU   PTM+1          ; PTM Read Status Register
PTMC13   EQU   PTM            ; PTM Control Registers 1 and 3
PTMC2    EQU   PTM+1          ; PTM Control Register 2
PTMTM3   EQU   PTM+6          ; PTM Latch 3 (MSB)
;
; SCRATCHPAD RAM ASSIGNMENTS (PAGE 0)
;
IRQV     EQU   $0000          ; INTERRUPT VECTOR
BEGA     EQU   $0002          ; BEGIN ADRS FOR LOAD/DUMP
ENDA     EQU   $0004          ; ENDING ADRS FOR LOAD/DUMP
ADRS     EQU   $0006          ; ADRS FOR GO AND MEMOD
;DDPAT   EQU   $0008          ; DIGIT PATTERN TEMP (5 BYTES)
RND      EQU   $000D          ; RANDOM BYTE (SEED)
N        EQU   $000E          ; TEMP
ATEMP    EQU   $000F          ; TEMP
XTEMP    EQU   $0012          ; 2-BYTE SAVE FOR X, SP
ZHI      EQU   $0014          ; TEMP ADRS
ZLO      EQU   $0015          ; 
KEYCOD   EQU   $0017          ; KEYCODE TEMP
BADRED   EQU   $0018          ; KEY BAD-READ FLAG
OLEDRES  EQU   $001C          ; Oled Resolution (was BLOC) 0=Off / 1=128x64 / 2=64x32
;PATNH   EQU   $001E          ; PATTERN TEMP
;PATNL   EQU   $001F          ;
TX1      EQU   $001E          ; Temporary X storage
TIME     EQU   $0020          ; RTC TIMER VALUE
TONE     EQU   $0021          ; DURATION COUNT FOR TONE
PPC      EQU   $0022          ; PSEUDO PRGM-COUNTER
PSP      EQU   $0024          ; PSEUDO STACK-PTR
I        EQU   $0026          ; CHIP8 MEMORY POINTER
PIR      EQU   $0028          ; PSEUDO INST-REG
VXLOC    EQU   $002A          ; POINTS TO VX
RNDX     EQU   $002C          ; RANDOM POINTER
VX       EQU   $002E          ; VARIABLE X (ALSO X-COORD)
VY       EQU   $002F          ; VARIABLE Y (ALSO Y-COORD)
;
; CHIP8 VARIABLES (TABLE)
;
VO       EQU   $0030
VF       EQU   $003F
;
; CHIP8 SUBROUTINE STACK
;
STACK    EQU   $005F
;
; OPERATING-SYSTEM STACK
;
STOP     EQU   $007F          ; STACK TOP (MONITOR)
TX2      EQU   $0080          ; Temporary word variable
TB1      EQU   $0082          ; Temporary byte variable
TP2      EQU   $0083          ; Temporary word variable for pushx/pullx
TP1      EQU   $0085          ; Temporary byte variable for pushx/pullx

         macro pushsx
         stx   TP2
         staa  TP1
         ldaa  TP2+1
         psha
         ldaa  TP2
         psha
         ldaa  TP1
         endm
         
         macro pullsx
         staa  TP1
         pula
         staa  TP2
         pula
         staa  TP2+1
         ldx   TP2
         lda   TP1
         endm
;
         ORG   ENTRY
;
         LDS   #STOP
; Initialise the ACIA
         LDAA  #$03           ; RESET CODE
         STAA  ACIA1_CONTROL
         LDAA  #$51           ; 8N1 NON-INTERRUPT
         STAA  ACIA1_CONTROL
;
; Initialise our OLED Display Panel
; There are many settings for the SSD1327, but most are correctly initialised
; following a Reset.  Therefore, I only update the settings here that I wish to
; change from their default Reset value (as per the SSD1327 datasheet). 
;
         LDX   #OledInitCmds  ; Load X as pointer to Initialise Command table
         LDAB  #16            ; Number of Command bytes in table
LoadCmdLoop	
         LDAA  0,X            ; Load register data pointed to by X and increment X
         INX
         STAA  OLED_CMD       ; Store Command byte
         DECB                 ; Point to next register
         BNE   LoadCmdLoop    ; Have we done all Command bytes?
; Clear the Display Buffer (VRAM)
         CLRA                 ; Zero byte to Clear Display buffer (VRAM)
         CLRB                 ; Full Display (Start row = 0)
         JSR   OledFill       ; Fill OLED Display
; Turn ON the Display
         LDAA  #$AF           ; Turn Display ON (after clearing buffer)
         STAA  OLED_CMD       ;
; Initially Setup PIA Port B for Sound output (Silence SN76489)
         LDAA  #$22           ; Select DDR Register B
         STAA  PIA_CTLB       ; CB2 goes low following data write, returned high by IRQB1 set by low to high transition on CB1
         LDAA  #$FF           ; Set Port B as all outputs
         STAA  PIA_PRTB       ; DDR B register write
         LDAA  #$26           ; Select Port B Data Register (rest as above) 
         STAA  PIA_CTLB
; Silence Sound output
         JSR   PSGOFF
;
         LDAA  #$01           ; Set OLED Display enabled,
         STAA  OLEDRES        ;  at OLED Resolution 128x64
         JMP   CONTRL
;
; Function:	Set the Display buffer Column Start and End addresses (128x64 res)
; Parameters:  A - Start column (0 - 127)
;              B - End column  (0 - 127)
; Returns:  -
; Destroys: A,B
ColSetF  PSHA                 ;
         LDAA  #$15           ; Set Column Address Command
         STAA  OLED_CMD       ;
         PULA                 ; Start column (left)
         LSRA                 ; Div A by 2 (2 pixels per byte)
         STAA  OLED_CMD       ;
         LSRB                 ; Div B by 2 (2 pixels per byte)
         STAB  OLED_CMD       ; End column address (right)
         RTS
;
; Function:	Set the Display buffer Column Start and End addresses (64x32 res)
; Parameters:  A - Start column (0 - 63)
;              B - End column  (0 - 63)
; Returns:  -
; Destroys: -
ColSetH  PSHA                 ;
         LDAA  #$15           ; Set Column Address Command
         STAA  OLED_CMD       ;
         PULA                 ; Start column (left)
         STAA  OLED_CMD       ;
         STAB  OLED_CMD       ; End column address (right)
         RTS
;
; Function:	Set the Display buffer Row Start and End addresses (128x64 res)
; Parameters:  A - Start row (0 - 63)
;              B - End row (0 - 63) 
; Returns:	-
; Destroys:	-
RowSetF  PSHA                 ; Save A
         LDAA  #$75           ; Set Row Address Command
         STAA  OLED_CMD       ;
         PULA                 ; Start row (top)
         STAA  OLED_CMD       ;
         STAB  OLED_CMD       ; End row (bottom)
         RTS
;
; Function:	Set the Display buffer Row Start and End addresses (64x32 res)
; Parameters:  A - Start row (0 - 31)
;              B - End row (0 - 31) 
; Returns:	-
; Destroys:	A,B
RowSetH  PSHA                 ; Save A
         LDAA  #$75           ; Set Row Address Command
         STAA  OLED_CMD       ;
         PULA                 ; Start row (top)
         LSLA                 ;
         STAA  OLED_CMD       ;
         LSLB                 ;
         ADDB  #$01           ;
         STAB  OLED_CMD       ; End row (bottom)
         RTS
;
; Function:	Fill OLED display VRAM with byte, from a specified start row
; Parameters:  A - Byte to fill OLED buffer with
;              B - Start Row (i.e. 0 for full panel fill)
; Returns:	-
; Destroys:	B,Y
; Turn ON the Display		
OledFill JSR   DUMPREG
         pushsx               ; Save X
         PSHA                 ; Save byte to fill
         PSHB                 ; Save start row
         LDAA  #$A4           ; Normal Display
         STAA  OLED_CMD       ;
;
         CLRA                 ; Start = 0
         LDAB  #$7F           ; End = 127
         BSR   ColSetF        ; Set Column Address range
;
         PULA                 ; Restore start row
         STAA  TB1            ; Save start row
         LDAB  #$3F           ; Start = A, End = 63
         JSR   DUMPREG
         BSR   RowSetF        ; Set Row Address range
         JSR   DUMPREG
         CLR   TX2            ; Reset 16-bit counter
         CLR   TX2+1
OledF1   LDAA  TX2
         LDAB  TX2+1
         ADDB  #128           ; 16-bit add with 128 (number of columns)
         ADCA  #0
         STAA  TX2            ; Save in TX2
         STAB  TX2+1
         INC   TB1
         LDAB  TB1
         CMPB  #64
         BNE   OledF1         ; Check for last row
;
         JSR   DUMPREG
         PULA                 ; Restore Byte to fill
;
         LDX   TX2            ; Number of pixels to write
         JSR   DUMPREG
OledF2   STAA  OLED_DTA       ; Write Byte to current buffer location
         DEX                  ; Dec X
         BNE   OledF2	      ; Done?
         pullsx               ; Restore X
         RTS
;
; Function:	Fill OLED display VRAM with byte (note 1 byte = 2 pixels)
; Parameters:	A - Byte to fill OLED buffer with
; Returns:	-
; Destroys:	Y
OledFA   pushsx
         LDX   #4096          ; 64 x 64 bytes (128 x 64 pixels)
         PSHA                 ; Save Byte we want to fill with
         LDAA  #$A4           ; Normal Display
         STAA  OLED_CMD       ;
;
         CLRA                 ; Set Column Address range
         LDAB  #$7F           ; Start =0, End = 128
         JSR 	ColSetF        ;
;
         LDAA  #$00           ; Set Row Address range
         LDAB  #$3F           ; Start = 0, End = 64
         JSR   RowSetF        ;
;
         PULA                 ; Restore Byte we want to fill with
OledFA2  STAA  OLED_DTA       ; Write Byte to curent buffer location
         DEX                  ; Dec X
         BNE   OledFA2        ; Done?
         pullsx
         RTS
;
; Function:	Write Sound Byte (A) to SN76489 and wait for not busy
; Parameters:	A - Sound Byte to write
; Returns:	-
; Destroys:	A
PSGWR    STAA  PIA_PRTB
PSGBSY   LDAA  PIA_CTLB       ; Read control Register
         BPL   PSGBSY         ; Wait for CB1 transition (IRQB1 flag)	
         LDAA  PIA_PRTB       ; Reset the IRQ flag by reading the data register
         RTS
;
; Function:	Silence all SN76489 Sound Channels
; Parameters:	-
; Returns:	-
; Destroys:	A
PSGOFF   LDAA  #$9F           ; Turn Off Channel 0
         BSR   PSGWR
         LDAA  #$BF           ; Turn Off Channel 1
         BSR   PSGWR
         LDAA  #$CF           ; Turn Off Channel 2
         BSR   PSGWR
         LDAA  #$FF           ; Turn Off Noise Channel
         BSR   PSGWR
         RTS
;
OledInitCmds   
         dc.b  $B3,$71        ; Set Clk Divider / Osc Fequency
         dc.b  $A0,$51        ; Set appropriate Display re-map
         dc.b  $D5,$62        ; Enable second pre-charge
         dc.b  $81,$7F        ; Set contrast (0 - $FF)
         dc.b  $B1,$74        ; Set phase length - Phase 1 = 4 DCLK / Phase 2 = 7 DCLK
         dc.b  $B6,$0F        ; Set second pre-charge period
         dc.b  $BC,$07        ; Set pre-charge voltage - 0.613 x Vcc
         dc.b  $BE,$07        ; Set VCOMH - 0.86 x Vcc
;
;
;   SEND ONE CHAR TO ACIA
;
OUTCH    PSHA
OUTEEE1  LDAA  ACIA1_STATUS
         ASRA
         ASRA
         BCC   OUTEEE1
         PULA
         STAA  ACIA1_DATA
         RTS
;
;   OUTPUT 2 HEX CHAR POINTED TO BY X
;   - X incremented
;
OUT2H    PSHA
         LDAA  0,X         ; OUTPUT 2 HEX CHAR
OUT2HA   BSR   OUTHL       ; OUT LEFT HEX CHAR
         LDAA  0,X
         INX
         BSR   OUTHR       ; OUTPUT RIGHT HEX CHAR AND R
         PULA
         RTS
;
;   OUT HEX BCD DIGIT IN A
;
OUTHL    LSRA              ; OUT HEX LEFT BCD DIGIT
         LSRA
         LSRA
         LSRA
OUTHR    ANDA  #$F         ; OUT HEX RIGHT BCD DIGIT
         ADDA  #$30
         CMPA  #$39
         BLS   OUTCH
         ADDA  #$7
         BRA   OUTCH
;
DUMPREG  BSR   PRINTA
         BSR   PRINTB
         BSR   PRINTX
         RTS
;
PRINTA   PSHA
         STAA  TP1
         BSR   PCRLF
         STX   TP2
         LDAA  #'A'
         JSR   OUTCH
         LDAA  #'='
         JSR   OUTCH
         LDAA  #'$'
         JSR   OUTCH
         LDX   #TP1
         JSR   OUT2H
         LDAA  #';'
         JSR   OUTCH
         LDX   TP2
         PULA
         RTS
;
PRINTB   PSHA
         STAB  TP1
         STX   TP2
         LDAA  #'B'
         JSR   OUTCH
         LDAA  #'='
         JSR   OUTCH
         LDAA  #'$'
         JSR   OUTCH
         LDX   #TP1
         JSR   OUT2H
         LDAA  #';'
         JSR   OUTCH
         LDX   TP2
         PULA
         RTS
;
PRINTX   PSHA
         STAB  TP1
         STX   TP2
         LDAA  #'X'
         JSR   OUTCH
         LDAA  #'='
         JSR   OUTCH
         LDAA  #'$'
         JSR   OUTCH
         LDX   #TP2
         JSR   OUT2H
         JSR   OUT2H
         LDAA  #';'
         JSR   OUTCH
         LDX   TP2
         PULA
         RTS
;
PCRLF    LDAA  #$0d
         JSR   OUTCH
         LDAA  #$0a
         JSR   OUTCH
         RTS

;
         END