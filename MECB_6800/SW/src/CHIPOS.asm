; CHIPOS for the 6800 MECB based re-Creation
; ------------------------------------------
;
; Original CHIPOS source file header below.
;
; Original source has been modified for:
; - 6800 assembly by the vasm Assembler
; - DigicoolThings MECB based DREAM re-Creation, comprising of:
;	- 2MHz 6809 CPU Card configured as 48K RAM / 16K ROM / $C0 IO (MECB)
;	- Motorola I/O Card for PIA + PTM (MECB)
;	- 128x64 OLED Display (MECB)
;	- 4x5 matrix Keypad (with 4x Function Keys)
;	- Keypad / Tape / Sound interface
; - Keypad routines updated for 4x5 Matrix and removal of CA1 flag use
; - Alternate FN key exit from the FN0 MEMOD mode (reset unnecessary)
; - Tape Load / Dump display of Start / End address as completion feedback
; - Removal of DMA-ENAB (as no longer using DMA driven memory-mapped display)
; - Support for 128x64 HiRes display mode and original 64x32 resolution.
; - Addition of new CHIP-8 instruction (Fx95) to switch display mode (OLEDRES)
; - Removal of DDPAT, as now replaced with pre-expanded 3x5 & 6x10 fonts
; - Removal of PATNH & PATNL, no longer needed with removal of DDPAT
; - Removal of BLOC, now replaced with new OLEDRES
; - Removal of DISBUF & ENDBUF, as display buffer not required for OLED display
; - CHIP-8 Interpreter entry address changed to C800 (instead of original C000)
; - CHIPOS subroutines all relocated to re-direct jumps located from $F700
;
; Assembled binary intended for ROM bootable location from $C800 - $FFFF
;	(with plenty of room for future expansions / monitor additions etc.)
;
; Note: Comments in UPPER CASE are the original source comments (mjbauer),
;	my added / ammended comments are all in Mixed Case.
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;                           C H I P O S
;
;  COMPACT HEXADECIMAL INTERPRETIVE PROGRAMMING AND OPERATING SYSTEM
;
;     DREAM-6800 OPERATING SYSTEM WITH CHIP8 LANGUAGE INTERPRETER 
;
;       ORIGINATED BY MICHAEL J BAUER, DEAKIN UNIVERSITY, 1978
;
;                  www.mjbauer.biz/DREAM6800.htm
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; (1) Upon Relocation, the data at ZRANDOM must be changed accordingly.
;
;BASE     EQU   $C800          ; BASE for ROM use
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
         
         macro printa
         PSHA
         STAA  TP1
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
         endm

         macro printb
         PSHA
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
         endm

         macro printx
         PSHA
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
         endm
;

;
; CHIP-8 INTERPRETER MAINLINE
;
         ORG   CHIP8
;
         JSR   ZERASE         ; NORMAL ENTRY POINT
         LDX   #$0200         ; RESET PSEUDO-PC
         STX   PPC
         LDX   #STACK         ; RESET   STACK PTR
         STX   PSP
FETCH    LDX   PPC            ; POINT TO NEXT INSTR
         LDX   0,X            ; COPY TO PIR
         STX   PIR
         STX   ZHI            ; SAVE ADRS (MMM)
         JSR   SKIP2          ; BUMP PRGM-CTR
         LDAA  ZHI            ; MASK OFF ADRS
         ANDA  #$0F
         STAA  ZHI
         BSR   FINDV          ; EXTRACT VX ALSO
         STAA  VX             ; STASH VX
         STX   VXLOC          ; SAVE LOCATION OF VX
         LDAA  PIR+1          ; FIND Y
         LSRA
         LSRA
         LSRA
         LSRA
         BSR	FINDV          ; EXTRACT VY
         STAA  VY             ; STASH VY
EXEC     LDX   #JUMTAB-2      ; POINT TO JUMP TABLE
         LDAA  PIR            ; EXTRACT MSD
         ANDA  #$F0
EXEl     INX                  ; FlND ROUTINE ADRS
         INX
         SUBA  #$10
         BCC   EXEl           ; BRANCH IF HIGHER OR SAME
         LDX   0,X            ; LOAD ROUTINE ADRS
         JSR   0,X            ; PERFORM ROUTINE
         BRA   FETCH          ; NEXT INSTR...
FINDV    LDX   #VO-1          ; POINT TO VARIABLES TABLE
FIND1    INX                  ; FIND LOCN VX
         DECA
         BPL   FIND1
         LDAA  0,X            ; FETCH VX FROM TABLE
         RTS
;
; JUMP TABLE(ROUTINE ADDRESSES)
; 
JUMTAB   dc.w  EXCALL         ; ERASE, RET, CALL, NOP
         dc.w  GOTO           ; GOTO MMM
         dc.w  DOSUB          ; DO MMM
         dc.w  SKFEK          ; SKF VX=KK
         dc.w  SKFNK          ; SKF VX#KK
         dc.w  SKFEV          ; SKF VX=VY
         dc.w  LETK           ; Vx=KK
         dc.w  LETVK          ; VX=VX+KK
         dc.w  LETVV          ; VX=[VX][+-&!]VY
         dc.w  SKFNV          ; SKF  VX#VY
         dc.w  LETI           ; I=MMM
         dc.w  GOTOV          ; GOTO MMM+VO
         dc.w  RANDV          ; VX-RND.KK
         dc.w  SHOW           ; SHOW  N@VX, VY
         dc.w  SKFKEY         ; SKF VX[=#]KEY
         dc.w  MISC           ; (MINOR JUMP TABL)
;
; ERASE, RETURN, CALL (MLS), OR NOP INTRN:
;
EXCALL   LDAB  PIR            ; GET INSTR REG
         BNE   CALL
         LDAA  PIR+1
         CMPA  #$E0
         BEQ   ZERASE
         CMPA  #$EE
         BEQ   RETDO
         RTS                  ; NOP, FETCH
;
; ERASE routine	
ZERASE   CLRA                 ; WRITE ZEROS TO SCREEN
         CLRB                 ;
ZFILL    JMP   OledFill
RETDO    TSX                  ; SAVE REAL SP
         LDS   PSP
         PULA
         STAA  PPC            ; PULL PPC
         PULA
         STAA  PPC+1
         STS   PSP            ; SAVE CHIP8 SP
         TXS                  ; RESTORE SP
         RTS
;
CALL     LDX   ZHI            ; GET OPRND ADRS(MMM)
         JMP   0,X            ; PERFORM MLS
GOTOV    LDAA  VO             ; 16-BIT ADD VO TO ADRS
         CLRB
         ADDA  ZLO
         STAA  ZLO
         ADCB  ZHI
         STAB  ZHI
GOTO     LDX   ZHI            ; MOVE ADRS TO PPC
         STX   PPC
         RTS                  ; FETCH
LETI     LDX   ZHI            ; MOVE ADRS TO MI PTR
         STX   I
         RTS                  ; FETCH
DOSUB    TSX                  ; SAVE SP
         LDS   PSP
         LDAA  PPC+1          ; PUSH PPC
         PSHA
         LDAA  PPC
         PSHA
         STS   PSP            ; SAVE CHIP SP
         TXS                  ; RESTORE REAL SP
         BRA   GOTO           ; JUMP TO ADRS(MMM)
;
; CONDITIONAL SKIP ROUTINES
;
SKFEK    LDAA  PIR+1          ; GET KK
SKFEQ    CMPA  VX
         BEQ   SKIP2
         RTS
SKFNK    LDAA  PIR+1          ; GET KK
SKFNE    CMPA  VX
         BNE   SKIP2
         RTS
SKFEV    LDAA  VY             ; GET VY
         BRA   SKFEQ
SKFNV    LDAA  VY
         BRA   SKFNE
SKIP2    LDX   PPC            ; ADD 2 TO PPC
         INX
         INX
         STX   PPC
         RTS
SKFKEY   JSR   ZKEYINP        ; INTERROGATE KEYBOARD
         TST   BADRED         ; KEY DOWN?
         BEQ   SKFK1
         LDAB  #$A1           ; WHAT INSTRN?
         CMPB  PIR+1          ; SKF VX#KEY
         BEQ   SKIP2
         RTS                  ; NO KEY GO FETCH
SKFK1    LDAB  #$9E
         CMPB  PIR+1          ; WHAT INSTRN?
         BEQ   SKFEQ
         BRA   SKFNE
;
; ARITHMETIC/LOGIC ROUTINES
;
LETK     LDAA  PIR+1          ; GET KK
         BRA   PUTVX
LETVK    LDAA  PIR+1
         ADDA  VX
         BRA   PUTVX
RANDV    BSR   ZRANDOM        ; GET RANDOM BYTE
         ANDA  PIR+1
         BRA   PUTVX
LETVV    LDAA  VX
         LDAB  PIR+1
         ANDB  #$0F           ; EXTRACT N
         BNE   LETV1
         LDAA  VY             ; VX=VY
LETV1    DECB
         BNE   LETV2
         ORAA  VY             ; VX=VX!VY (OR)
LETV2    DECB
         BNE   LETV4
         ANDA  VY             ; VX=VX.VY
LETV4    DECB
         DECB
         BNE   LETV5
         CLR   VF             ; VF=0
         ADDA  VY             ; VX=VX+VY
         BCC   LETV5          ; RESULT < 256
         INC   VF             ; VF=1(OVERFLOW)
LETV5    DECB
         BNE   PUTVX
         CLR   VF             ; VF=0
         SUBA  VY             ; VX=VX-VY
         BCS   PUTVX          ; VX<VY? (UNSIGNED)
         INC   VF             ; NO PUT VF=l
PUTVX    LDX   VXLOC          ; REPLACE VX
         STAA  0,X
         RTS
;
; RANDOM BYTE GENERATOR
;
; RANDOM routine
;
ZRANDOM  LDAA  #(BASE>>8)     ; HIGH-ORDER BYTE OF RNDX =
         STAA  RNDX           ; =MSB OF CHIP8 START ADRS
         INC   RNDX+1
         LDX   RNDX           ; POINT TO NEXT PROGRAM BYTE
         LDAA  RND            ; GET SEED (LAST VALUE)
         ADDA  0,X            ; MANGLE IT
         EORA  $FF,X
         STAA  RND            ; STASH IT
         RTS
;
; JUMP TABLE FOR MISCELLANEOUS INSTRNS [FXZZ]
;
MINJMP   dc.b  $07            ; VX=TIME
         dc.w  VTIME
         dc.b  $0A            ; VX=KEY
         dc.w  VKEY
         dc.b  $15            ; TIME=VX
         dc.w  TIMEV
         dc.b  $18            ; TONE=VX
         dc.w  TONEV
         dc.b  $1E            ; I=I+VX
         dc.w  LETIV
         dc.b  $29            ; I=DSPL,VX
         dc.w  ZLETDSP
         dc.b  $33            ; MI=DEQ,VX
         dc.w  LETDEQ
         dc.b  $55            ; MI=VO:VX
         dc.w  STORV
         dc.b  $65            ; VO:VX=MI
         dc.w  LOADV
         dc.b  $95            ; Set Graphics Mode
         dc.w  GRAPHM
;
MISC     LDX   #MINJMP        ; POINT TO TABLE
         LDAB  #10            ; DO 10 TIMES		
MIS1     LDAA  0,X            ; GET TABLE OPCODE
         CMPA  PIR+1
         BEQ   MIS2
         INX
         INX
         INX
         DECB
         BNE   MIS1
         JMP   ZSTART         ; BAD OPCODE, RETURN TO MON.
MIS2     LDX   1,X            ; GET ROUTINE ADRS FROM TABLE
         LDAA  VX             ; GET VX
         JMP   0,X            ; GO TO ROUTINE
GRAPHM   LDAA  ZHI
         STAA  OLEDRES
         RTS
VTIME    LDAA  TIME
         BRA   PUTVX
VKEY     JSR   ZGETKEY
         BRA   PUTVX
TIMEV    STAA  TIME
         RTS
TONEV    TAB                  ; SET DURATION=VX
         JMP   ZBTONE
LETIV    CLRB                 ; 16-BIT ADD VX TO I
         ADDA  I+1
         STAA  I+1
         ADCB  I
         STAB  I
         RTS
;
; Determine Font & Character (A) to use, & set I for 'SHOW'
;
; LETDSP routine
;
ZLETDSP  LDAB  OLEDRES        ; Set X to the correct Font Table
         LDX   #FONTH-5       ; Initialise for Half res Font Table
         LSRB                 ; Test for Full res mode
         BNE   LETDSP1        ; Assume Half res mode
         LDX   #FONTF-10      ; We want Full res Font Table
LETDSP1  PSHA                 ; Save character
         LDAA  OLEDRES        ; Select the correct Font character
         LDAB  #5             ; 5 pixel high font characters
         LSRA                 ; Test for Full res mode
         BNE   LETDSP2        ; Assume Half res mode
         LSLB                 ; Double (10) for Full Res mode
LETDSP2  PULA                 ; Retrieve character
         ANDA  #$0F           ; Isolate LS digit
LETDSP3  STX   TX1
         STAB  TB1            ; Save B
         PSHA                 ; Equivalent to ABX; Save A first
         LDA   TX1
         ADDB  TX1+1
         ADCA  #$00
         STAA  TX1
         STAB  TX1+1
         LDX   TX1            ; X = X + B
         PULA                 ; Restore A
         LDAB  TB1            ; Restore B
         DECA                 ; (A=VX)
         BPL   LETDSP3
         STX   I              ; SET MI POINTER
         RTS
;
; Hexadecimal Font Patterns (3x5 matrix)
;
FONTH    dc.b  $E0,$A0,$A0,$A0,$E0     ; 0
         dc.b  $40,$40,$40,$40,$40     ; 1
         dc.b  $E0,$20,$E0,$80,$E0     ; 2
         dc.b  $E0,$20,$E0,$20,$E0     ; 3
         dc.b  $80,$A0,$A0,$E0,$20     ; 4
         dc.b  $E0,$80,$E0,$20,$E0     ; 5
         dc.b  $E0,$80,$E0,$A0,$E0     ; 6
         dc.b  $E0,$20,$20,$20,$20     ; 7
         dc.b  $E0,$A0,$E0,$A0,$E0     ; 8
         dc.b  $E0,$A0,$E0,$20,$E0     ; 9
         dc.b  $E0,$A0,$E0,$A0,$A0     ; A
         dc.b  $C0,$A0,$E0,$A0,$C0     ; B
         dc.b  $E0,$80,$80,$80,$E0     ; C
         dc.b  $C0,$A0,$A0,$A0,$C0     ; D
         dc.b  $E0,$80,$E0,$80,$E0     ; E
         dc.b  $E0,$80,$E0,$80,$80     ; F
;
; Hexadecimal Font Patterns (6x10 matrix)
;
FONTF    dc.b  $78,$FC,$CC,$CC,$CC,$CC,$CC,$CC,$FC,$78   ; 0
         dc.b  $10,$30,$70,$30,$30,$30,$30,$30,$78,$78   ; 1
         dc.b  $78,$FC,$CC,$0C,$18,$30,$60,$C0,$FC,$FC   ; 2
         dc.b  $78,$FC,$CC,$0C,$38,$38,$0C,$CC,$FC,$78   ; 3
;        dc.b  $0C,$1C,$3C,$6C,$CC,$FC,$FC,$0C,$0C,$0C   ; 4
;        dc.b  $18,$38,$78,$F8,$D8,$FC,$FC,$18,$18,$18   ; 4
         dc.b  $CC,$CC,$CC,$CC,$FC,$7C,$0C,$0C,$0C,$0C   ; 4
         dc.b  $FC,$FC,$C0,$C0,$F8,$FC,$0C,$CC,$FC,$78   ; 5
         dc.b  $78,$FC,$CC,$C0,$F8,$FC,$CC,$CC,$FC,$78   ; 6
         dc.b  $FC,$FC,$0C,$18,$18,$30,$30,$60,$60,$60   ; 7
         dc.b  $78,$FC,$CC,$CC,$78,$FC,$CC,$CC,$FC,$78   ; 8
         dc.b  $78,$FC,$CC,$CC,$FC,$7C,$0C,$CC,$FC,$78   ; 9
         dc.b  $30,$78,$CC,$CC,$FC,$FC,$CC,$CC,$CC,$CC   ; A
         dc.b  $F8,$FC,$CC,$CC,$F8,$FC,$CC,$CC,$FC,$F8   ; B
         dc.b  $78,$FC,$CC,$C0,$C0,$C0,$C0,$CC,$FC,$78   ; C
         dc.b  $F0,$F8,$DC,$CC,$CC,$CC,$CC,$DC,$F8,$F0   ; D
         dc.b  $FC,$FC,$C0,$C0,$F8,$F8,$C0,$C0,$FC,$FC   ; E
         dc.b  $FC,$FC,$C0,$C0,$F8,$F8,$C0,$C0,$C0,$C0   ; F
;
LETDEQ   LDX   I              ; GET MI POINTER
ZDECEQ   LDAB  #100           ; N=100
         BSR   DECI           ; CALC 100'S DIGIT
         LDAB  #10            ; N=10
         BSR   DECI           ; CALC l0'S DIGIT
         LDAB  #1
DECI     STAB  N
         CLRB
LDEQ1    CMPA  N              ; DO UNTIL A<N  ...
         BCS   LDEQ2          ; BRANCH IF LOWER NOT SAME.
         INCB
         SUBA  N
         BRA   LDEQ1          ; END-DO...
LDEQ2    STAB  0,X            ; STASH
         INX                  ; FOR NEXT DIGIT
         RTS
;
STORV    SEI                  ; KILL IRQ FOR DATA STACK
         STS   XTEMP          ; SAVE SP
         LDS   #VO-1          ; POINT TO VARIABLES TABLE
         LDX   I              ; FOINT MI
         BRA   MOVX           ; TRANSFER NB BYTES
LOADV    SEI                  ; KILL IRQ
         STS   XTEMP
         LDS   I              ; POINT MI
         DES
         LDX   #VO            ; POINT TO VO
MOVX     LDAB  VXLOC+1        ; CALC. X  (AS IN VX)
         ANDB  #$0F           ; LOOP (X+l) TIMES.....
MOVX1    PULA                 ; GET NEXT V
         STAA  0,X            ; COPY IT
         INX
         INC   I+1            ; I=I+X+1(ASSUMES SAME PAGE)
         DECB
         BPL   MOVX1          ; CONTINUE...
         LDS   XTEMP          ; RESTORE SP
         CLI                  ; RESTORE IRQ
         RTS
;
; DISPLAY ROUTINES 
;   
SHOW     LDAA  OLEDRES        ; Get OLED Display Enable / Resolution flag
         BEQ   OLEDOFF        ; OLED is Off
         LDAB  PIR+1          ; GET N (OPCODE LSB)
         CLR   VF             ; CLEAR OVERLAP FLAG
;
; SHOWI routine
;
ZSHOWI
         LDX   I              ; POINT TO PATTERN BYTES
;
; SHOWX routine
;
ZSHOWX   ANDB  #$0F           ; COMPUTE NO. OF BYTES (N)
         BNE   SHOW2          ; IF N=0, MAKE N=16
         LDAB  #16
SHOW2    PSHB                 ; DO N TIMES,...,.
         STX   ZHI            ; SAVE MI POINTER

         LDAA  0,X            ; FETCH NEW PATTERN BYTE
         LDAB  #8             ; Do all 8 bits of pattern byte

SHOW3    ASLA                 ; Next bit to display into Carry
         BCC   SHOW4          ; Skip if bit not set
         JSR   TglPxl         ; If bit was set then toggle pixel
SHOW4    INC   VX             ; Move VX to next bit pixel
         DECB                 ; Decrement byte bit count
         BNE   SHOW3          ; Do all 8 bits
         LDAA  VX             ; Finished, so restore VX
         SUBA  #8             ;
         STAA  VX             ;
         INC   VY
         LDX   ZHI            ; POINT NEXT PATTERN BYTE
         INX
         PULB
         DECB
         BNE   SHOW2          ; CONT.....
OLEDOFF  RTS
;
; KEYPAD ROUTINES 
;
; PAINZ & PAINV routines
;
ZPAINZ   RTS
ZPAINV   RTS
;
ZPAINZX  LDAB  #$F0           ; INITIALIZE PORT
ZPAINVX  LDX   #PIA_PRTA      ; (ENTRY PT FOR INV. DDR)
         CLR   1,X            ; RESET & SELECT DDR
         STAB  0,X            ; SET DATA DIRECTION
         LDAB  #$3E           ; Setup Ctrl with CA2 High
         STAB  1,X
         CLR   0,X            ; Output PA4-7 Low
         RTS
;
; KEYPAD INPUT SERVICE ROUTINE
;
; KEYINP routine
;
ZKEYINPX BSR   ZPAINZ         ; RESET KEYPAD PORT
         CLR   BADRED         ; RESET BAD-READ FLAG
         JSR   ZDEL333        ; DELAY FOR DEBOUNCE
         LDAB  0,X            ; INPUT ROW DATA
         BSR	KBILD          ; FORM CODE BITS 0,1
         STAA  KEYCOD
         LDAB  #$0F           ; SET DDR FOR...
         BSR	ZPAINV         ; INVERSE ROW/COL  DIR N
         LDAB  0,X            ; INPUT COLUM DATA
         LSRB                 ; RIGHT JUSTIFY
         LSRB
         LSRB
         LSRB
         BSR   KBILD          ; FORM CODE BITS 2,3
         ASLA
         ASLA
         ADDA  KEYCOD
         STAA  KEYCOD         ; BUILD COMPLETE KEYCODE
         RTS
;
KBILD    CMPB  #$0F           ; CHECK KEY STATUS
         BNE   KBILD0         ; KEY IS DOWN, GO DECODE IT
         STAB  BADRED         ; NO KEY, SET BAD-READ FLAG
KBILD0   LDAA  #$FF
KBILD1   INCA                 ; (A=RESULT)
         LSRB                 ; SHIFT DATA BIT TO CARRY
         BCS   KBILD1         ; FOUND ZERO BIT ?
         RTS
;
; GETKEY routine - WAIT FOR KEYDOWN, THEN INPUTS
; As we no longer use the CA1 low to high transition flag to signal a key down,
; we first ensure that no key is still down, then await a new key down.
;
ZGETKEYX pushsx               ; SAVE X FOR CALLING ROUTINE
         BSR   ZPAINZ         ; RESET PORT, CLEAR FLAGS
         LDAB  #$36           ; Set CA2 Low (to include FN keys)
         STAB  1,X
GETK1    LDAA  0,X            ; Get PortA Data
         EORA  #$0F           ; Any Key Down?
         BNE   GETK1          ; Yes, Wait for Key Release
GETK2    BSR   ZPAINZ         ; Re-establish PortA default
         LDAA  0,X            ; Get PortA Data
         EORA  #$0F           ; Any Hex Key Down?
         BNE   HEXKEY         ; Yes Fetch it in
         CLRB
         BSR   ZPAINV         ; Output PA4-7 High (All inputs)
         LDAB  #$36           ; Set CA2 Low (to check FN keys)
         STAB  1,X
         LDAA  0,X            ; Get PortA Data
         EORA  #$FF           ; Any Function Key Down?
         BEQ   GETK2          ; No, Loop for Keydown
         ORAA  #$80           ; Set MSb to indicate FN Key
         BRA   HEXK1          ; Return Without Hex Code
HEXKEY   JSR   ZKEYINP        ; DECODE THE KEYPAD
         TST   BADRED         ; WAS IT A BAD READ?
         BNE   GETK2          ; YES, TRY  AGAIN
HEXK1    JSR   ZBLEEP         ; Acknowledge Key-down
         BSR   ZPAINZ         ; Re-establish PortA default
         pullsx               ; RESTORE CALLER'S X-REG
         RTS                  ; RETURN (WITH A<O FOR FN KEY)
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
; ACIA equivalent of ZKEYINP
;
ZKEYINP  CLR   BADRED         ; RESET BAD-READ FLAG
         LDAA  ACIA1_STATUS   ; CHECK ACIA STATUS
         ASRA
         BCC   ZGETBADA       ; RECEIVE NOT READY
         LDAA  ACIA1_DATA     ; OTHERWISE READ CHARACTER
         BSR   ASCIID         ; CONVERT TO KEYPAD EQUIVALENT
         STAA  KEYCOD         ; SAVE KEY CODE
         RTS                  ; DONE
ZGETBADA LDAA  #$FF           ; NO CHARACTER AVAILABLE
         STAA  BADRED         ; MARK AS BAD READ
         RTS                  ; DONE
;
; ACIA equivalent of ZGETKEY
;
ZGETKEY  pushsx
ZGETKEY2 BSR   ZKEYINP
         TST   BADRED         ; Check if it was a valid key
         BNE   ZGETKEY2
         BSR   ZBLEEP         ; Acknowledge Key-down
         pullsx
         RTS
;
; Decode ASCII Character into keypad equivalent
; On try: A = ASCII character
; On exit: A = keypad equivalent or if invalid BADRED is non-zero
ASCIID   CMPA  #'0'
         BLT   ZBADA          ; <'0', not a valid key
         CMPA  #'9'
         BLE   ZDIGITA        ; A digit key
         CMPA  #'a'
         BLT   ZUPPERA        ; Is it uppercase
         SUBA  #$20           ; If not, convert to upper case
ZUPPERA  CMPA  #'A'
         BLT   ZBADA          ; <'A', not a valid key
         CMPA  #'F'
         BLE   ZDIGITB        ; A HEX key
         CMPA  #'M'           ; FN0/MEMMOD key?
         BNE   ZCHECKA1
         LDAA  #$81           ; Load code for FN0
         BRA   ZDONEA
ZCHECKA1 CMPA  #'L'           ; FN1/LOAD key?
         BNE   ZCHECKA2
         LDAA  #$82           ; Load code for FN1
         BRA   ZDONEA
ZCHECKA2 CMPA  #'S'           ; FN2/DUMP key?
         BNE   ZCHECKA3
         LDAA  #$84           ; Load code for FN2
         BRA   ZDONEA
ZCHECKA3 CMPA  #'G'           ; FN3/GO key?
         BNE   ZCHECKA4
         LDAA  #$88           ; Load code for FN3
         BRA   ZDONEA
ZCHECKA4 CMPA  #'X'           ; Exit back to MIKBUG?
         BNE   ZBADA          ; Not a valid key
         JMP   CONTRL
ZDIGITA  SUBA  #'0'           ; Convert '0'-'9' to 0x00-0x09
         BRA   ZDONEA
ZDIGITB  SUBA  #$37           ; Convert 'A'-'F' to 0x0A-0x0F
         BRA   ZDONEA
ZBADA    LDAA  #$FF           ; Invalid key
         STAA  BADRED         ; Set BADRED flag
ZDONEA   RTS

;
; TONE GENERATING ROUTINES
;
; BLEEP routine
;
ZBLEEPX  LDAB  #4             ; 80ms 2400Hz
ZBTONEX  STAB  TONE           ; Set Duration (RTC Cycles)
         CLRB                 ; Ensure Tone Duration doesn't affect Freq
ZBTONX   PSHA                 ; Entry point for Variable Duration/Freq 
         LDAA  #$7F           ; Sound On - DDR
         CMPB  #$40           ; Do we want 1200Hz?
         BEQ   BTON1X
         JSR   ZPBINZ
         LDAB  #$41           ; Sound On 2400Hz - PB6 Output High
         BRA   BTON2X
BTON1X   JSR   ZPBINZ
         LDAB  #$40           ; Sound On 1200Hz - PB6 Output High

BTON2X   STAB  0,X            ; PB6 High / 1200Hz or 2400Hz 
BTON3X   TST   TONE           ; WAIT FOR RTC TIME-OUT
         BNE   BTON3
         LDAA  #$3F           ; Sound Off - DDR
         JSR   ZPBINZ
         PULA
         RTS

; PSG version - epaell
; for PSG 600Hz = $003A; 1200 Hz = $001A; 2400 Hz = $000D (Assuming 1 MHz clock cycle)
ZBLEEP   LDAB  #4             ; 80 mS, 2400 Hz
ZBTONE   STAB  TONE
         CLRB
ZBTON    PSHA
         CMPB  #$40           ; Do we want 1200 Hz?
         BEQ   BTON1
         LDA   #$8D           ; 2400 Hz
         JSR   PSGWR          ; Write Tone LSB
         LDA   #$00
         JSR   PSGWR          ; Write Tone MSB
         BRA   BTON2
;
BTON1    LDA   #$8A           ; 1200 Hz
         JSR   PSGWR          ; Write Tone LSB
         LDA   #$01
         JSR   PSGWR          ; Write Tone MSB
;
BTON2    LDA   #$9C           ; Enable attenuator 0, set at low level
         JSR   PSGWR
;
BTON3    TST   TONE
         BNE   BTON3
         LDA   #$9F           ; Set attenuator 0 to off
         JSR   PSGWR
         PULA
         RTS
;
; SOFTWARE DELAY ROUTINE FOR SERIAL I/O:
;
; DEL333 routine
;
ZDEL333  BSR   ZDEL167        ; DELAY FOR 3.33 MILLISEC
;
; DEL167 routine
;
ZDEL167  pushsx               ; Save X
         LDX   #412           ; Delay for 1.67 Millisec (@ 2Mhz)
DEL      DEX                  ; Dec X
         BNE   DEL
         pullsx               ; Restore X
         RTS
;
; TAPE INPUT/OUTPUT ROUTINES
; Initialize Port B for Tape I/O and Sound
; A=DDR - $7F for PB7 input, $3F for PB6 & PB7 input (Sound Off)
;
; PBINZ routine
;
ZPBINZ   RTS
;
ZPBINZX  LDX   #PIA_PRTB
         LDAB  #$32           ; SELECT DDR
         STAB  1,X
         STAA  0,X            ; Write DDR
         LDAB  #$36           ; Select Output Reg
         STAB  1,X            ; WRITE CTRL REG
         LDAB  #01            ; OUTPUT FOR...
         STAB  0,X            ; TAPE DATA-OUT HIGH (MARKING)
         RTS
;
; INBYT routine - INPUT ONE BYTE FROM TAPE PORT
;
ZINBYT   BSR   XCHG           ; EXCHANGE X FOR PIA ADRS
IN1      LDAA  0,X
         BMI   IN1            ; LOOK FOR START BIT
         BSR   ZDEL167        ; DELAY HALF BIT-TIME (300BD)
         LDAB  #9             ; DO 9 TIMES....
IN2      SEC                  ; ENSURE PB0 MARKING
         ROL   0,X            ; INPUT & SHIFT NEXT BIT
         RORA                 ; INTO ACC-A
         BSR   ZDEL333        ; WAIT 1 BIT-TIME
         DECB
         BNE   IN2            ; CONT....
         BRA   OUTX           ; RESTORE X AND RETURN
;
XCHG     STX   XTEMP          ; SAVE X-REG
         LDX   #PIA_PRTB
         RTS
;
; OUTBYT routine - OUTPUT ONE BYTE TO TAPE PORT 
;
ZOUTBYT  BSR   XCHG
;        PSHA
         DEC   0,X            ; RESET START BIT
         LDAB  #10            ; DO 10 TIMES....
OUT1     BSR   ZDEL333        ; DELAY 1 BIT-TIME
         PSHA
         ANDA  #$01           ; Mask Bit to send (PB0)
         STAA  0,X            ; NEXT BIT TO OUT LINE (PB0)
         SEC
         PULA                 ; RESTORE A
         RORA
         DECB
         BNE   OUT1           ; CONT....
;        PULA                 ; RESTORE A
OUTX     LDX	XTEMP          ; RESTORE X
         RTS
;
; TAPE LOAD AND DUMP ROUTINES
;
LODUMX   LDAA  #$3F           ; Sound Off
         BSR   ZPBINZ
         LDX   BEGA           ; POINT TO FIRST LOAD/DUMP ADR
         RTS
DUMP     BSR   LODUMX
         STX   ADRS
         JSR   SHOADR         ; Display Begin Address
         LDX   BEGA           ; Restore Begin Address
DUMP1    LDAA  0,X            ; FETCH RAM BYTE
         BSR   ZOUTBYT
         INX
         CMPX  ENDA           ; (ENDA = LAST ADRS+1)
         BNE   DUMP1
         STX   ADRS
         JSR   SHOADR         ; Display End Address
         BRA   ZSTART
LOAD     BSR   LODUMX
         STX   ADRS
         JSR   SHOADR         ; Display Begin Address
         LDX   BEGA           ; Restore Begin Address
LOAD1    BSR   ZINBYT
         STAA  0,X            ; STASH BYTE IN RAM
         INX
         CMPX  ENDA           ; DONE?
         BNE   LOAD1          ; CONT....
         STX   ADRS
         JSR   SHOADR         ; Display End Address
;       (BRA   ZSTART)
;
; START routine - MONITOR ENTRY POINT
;
ZSTART   LDS   #STOP          ; RESET SP TO TOP
         LDX   #RTC           ; SETUP IRQ VECTOR FOR RTC
         STX   IOV            ; epaell set up for mikbug
         LDAA  #$3F           ; Sound Off
         JSR   ZPBINZ
         JSR   SHOADR         ; PROMPT
         CLI                  ; Clear CC IRQ Flag - Enable IRQ Interrupts
COMAND   JSR   ZGETKEY        ; INPUT SOMETHING
         TSTA
         BPL   INADRS         ; IF HEX, GET AN ADDRESS
         BITA  #$01
         BNE   MEMOD          ; FN0 = MEM0RY MODIFY
         BITA  #$02
         BNE   LOAD           ; FN1 = TAPE LOAD
         BITA  #$04
         BNE   DUMP           ; FN2 = TAPE DUMP
GO       LDX   ADRS           ; FN3, so FETCH ADRS FOR GO
         JMP   0,X
INADRS   BSR   BYT1           ; BUILD ADRS MS BYTE
         STAA  ADRS
         BSR   ZBYTIN         ; INPUT & BUILD LSB
         STAA  ADRS+1
         JSR   SHOADR         ; DISPLAY RESULTANT ADRS
         BRA   COMAND
;
; BYTIN routine
;
ZBYTIN   JSR   ZGETKEY        ; INPUT 2 HEX DIGITS
BYT1     ASLA                 ; LEFT JUSTIFY FIRST DIGIT
         ASLA
         ASLA
         ASLA
         STAA  ATEMP          ; HOLD IT
         JSR   ZGETKEY        ; INPUT ANOTHER DIGIT
         ADDA  ATEMP          ; BUILD A BYTE
         RTS
;
; MEMORY MODIFY ROUTINE
;
MEMOD    BSR   SHOADR         ; SHOW CURRENT ADRS
;
         LDX   ADRS           ; SHOW DATA AT ADRS
         BSR   ZSHODAT        ;
         JSR   ZGETKEY        ; WAIT FOR INPUT
         
         LDX   ADRS
         
         TSTA
         BPL   MEM1           ; Hex Key; Get New Data Byte
         BITA  #$01
         BNE   MEM2           ; FN0 Key; Next Adrs
         JMP   ZSTART         ; Any other FN key; Exit Memod
MEM1     BSR   BYT1           ; HEX KEY; NEW DATA BYTE
         STAA  0,X            ; DEPOSIT IT
MEM2     INX
         STX   ADRS           ; BUMP ADRS
         BRA   MEMOD
;
SHOADR   LDAB  OLEDRES        ;
         LDAA  #$10           ; Set Cursor for Half Res mode
         LSRB                 ; Test for Full res mode
         BNE   SHOWADRC       ; Assume Half res mode
         LSLA                 ; Double for Full Res mode
SHOWADRC BSR   ZCURS1
         LDAA  #$FF           ; Illuminate last 14 / 7 rows
         LDAB  #50
         JSR   OledFill
         LDX   #ADRS          ; POINT TO ADRS MS BYTE
         BSR   ZSHODAT
         INX                  ; POINT TO ADRS LS BYTE
         BSR   ZSHODAT
         BSR   ZCURSR         ; MOVE CURSOR RIGHT
         RTS
;
; SHODAT routine
;
ZSHODAT  LDAA  0,X            ; FETCH DATA @ X
;
; SHOBYT routine
;
ZSHOBYT  PSHA
         LSRA                 ; ISOLATE MS DIGIT
         LSRA
         LSRA
         LSRA
         BSR   ZDIGOUT        ; SHOW ONE DIGIT
         PULA
;
; DIGOUT routine
;
ZDIGOUT  STX   XTEMP          ; SAVE X
         JSR   ZLETDSP        ; POINT TO DIGIT PATTERN
         LDAA  OLEDRES        ;
         LDAB  #5             ; Show 5 byte Pattern
         LSRA                 ; Test for Full res mode
         BNE   DIGOUTC        ; Assume Half res mode
         LSLB                 ; Double (10 byte) for Full res mode
DIGOUTC  JSR   ZSHOWI
;
; CURSR routine
;
ZCURSR   LDAB  OLEDRES        ;
         LDAA  #4             ; SHIFT CURSOR RIGHT 4 DOTS
         LSRB                 ; Test for Full res mode
         BNE   CURSRC         ; Assume Half res mode
         LSLA                 ; Double (8 dots) for Full res mode
CURSRC   ADDA  VX
;
; CURS1 routine
;
ZCURS1   STAA  VX             ; SET X COORD
         LDAB  OLEDRES        ;
         LDAA  #26            ; SET Y COORD
         LSRB                 ; Test for Full res mode
         BNE   CURSR1C        ; Assume Half res mode
         LSLA                 ; Double (52) for Full Res mode
CURSR1C  STAA  VY
         LDX   XTEMP          ; RESTORE X_REG
         RTS
;
; REAL TIME CLOCK INTERRUPT SERVICE ROUTINE
;
RTC      DEC   TIME
         DEC   TONE
                              ; Clear PTM Counter3 IRQ Flag
         LDAA  PTMC2          ; Read PTM Status Register
         LDAA  PTMTM3         ; Read PTM Counter3
         LDAB  PTMTM3+1
         RTI
;
; ---------------------------------
; Hardware Reset - Code Entry Point
; ---------------------------------
         ORG   ENTRY
; Initialise Direct Page Register for Zero page
;         CLRA
;         TFR   A,DP	
; Tell asm6809 (Assembler) what page the DP register has been set to
;         SETDP #$00
; Set Stack to Stack Top
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
;
; Initialise PTM (Counter 3 for 20ms periodic IRQ)
         LDX   #PTM           ; LOAD PTM ADDRESS
         LDAA  #$01
         LDAB  #$00           ; Select Timer 1 / Clear Reset
         STAA  PTMC2-PTM,X    ; Setup for Control Register 1
         STAB  PTMC13-PTM,X   ; Clear Reset
         LDAA  #$00
         LDAB  #$43           ; Select Timer 3 / Timer 3 IRQ E /8 mode
         STAA  PTMC2-PTM,X    ; Setup to write Control Register3
         STAB  PTMC13-PTM,X   ; Set Output Disabled / IRQ Enabled
         ; Continous / 16 bit / E div 8 prescaled
         LDAA  #$09           ; Latch for 20ms (with 2MHz /8 prescale)
         LDAB  #$C4           ; = 5000 / 2500 for 1 MHz
         STAA  PTMTM3-PTM,X   ; Write Counter 3 Latch MSB
         STAB  PTMTM3+1-PTM,X ; Write Counter 3 Latch LSB
;
; Setup IRQ Handler - Note: We now do this in the CHIPOS START
;        LDX   #RTC           ; SETUP IRQ VECTOR FOR RTC
;        STX   IRQV
;        CLI                  ; Clear CC IRQ Flag - Enable IRQ Interrupts
;
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
;
         JMP   ZSTART         ; Jump to CHIPOS Entry point
;
;
; Subroutines
; -----------
; Function:	Update Pixel - Setup for Set, Clr, Tgl subroutines (128x64 res)
;		Note: As SSD1327 stores 2 pixels in each byte, it's
;		necessary to get the VRAM byte first, to avoid overwriting
;		the neighbouring pixel (hence call to GetPxlBytF).
; Parameters:	VX - X coord (0 - 127)
;		VY - Y coord (0 - 63)
; Returns:	B - Pixel value at X,Y (appropriate nibble)
; Destroys:	A,B
UpdPxlStpF
         BSR   GetPxlBytF     ; Get curent pixel byte values
         PSHB                 ; Save current pixel byte
         LDAB  VY             ; Retrieve Y coord
         TBA                  ; 
         JSR   RowSetF        ; Set Row of pixel
         LDAA  VX             ; Retrieve X coord
         TAB                  ; 
         JSR 	ColSetF        ; Set Column of pixel
         PULB                 ; Retrieve current pixel
         RTS
;
; Function:	Update Pixel - Setup for SetH, ClrH, TglH subroutines (64x32 res)
;		Note: As SSD1327 stores 2 pixels in each byte, half Resolution
;		is easily achieved as we're updating 2 pixels for every "pixel"
; Parameters:	VX - X coord (0 - 63)
;		VY - Y coord (0 - 31)
; Returns:	B - Pixel value at A,B (dual even pixel byte)
; Destroys:	A,B
UpdPxlStpH
         BSR   GetPxlBytH     ; Get curent pixel byte value
         PSHB                 ; Save current pixel byte
         LDAB  VY             ; Retrieve Y coord
         TBA                  ; 
         JSR   RowSetH        ; Set Row of pixel
         LDAA  VX             ; Retrieve X coord
         TAB                  ; 
         JSR 	ColSetH        ; Set Column of pixel
         PULB                 ; Retrieve current pixel
         RTS
;
; Function:	Get the Pixel Byte at VX,VY
; Parameters:	VX - X coord (0 - 127)
;		VY - Y coord (0 - 63)
; Returns:	B - Pixel value at A,B (appropriate nibble)
; Destroys:	A,B
GetPxlBytF
         LDAB  VY             ; Retrieve Y coord
         TBA                  ; 
         JSR 	RowSetF        ; Set Row of pixel
         LDAA  VX             ; Retrieve X coord
         TAB                  ; 
         JSR   ColSetF        ; Set Column of pixel
         LDAB  OLED_DTA       ; Dummy Read
         LDAB  OLED_DTA       ; Actual Read
         RTS
;
; Function:	Get the Pixel Byte at VX,VY
; Parameters:	VX - X coord (0 - 63)
;		VY - Y coord (0 - 31)
; Returns:	B - Pixel value at A,B (dual even pixel byte)
; Destroys:	A,B
GetPxlBytH
         LDAB  VY             ; Retrieve V coord
         TBA                  ; 
         JSR 	RowSetH        ; Set Row of pixel
         LDAA	VX             ; Retrieve X coord
         TAB                  ; 
         JSR 	ColSetH        ; Set Column of pixel
         LDAB	OLED_DTA       ; Dummy Read
         LDAB	OLED_DTA       ; Actual Read
         RTS
;
; Function:	Set the Pixel at VX,VY (128x64 Res)
;		Note: As SSD1327 stores 2 pixels in each byte, it's
;		necessary to get the VRAM byte first, to avoid overwriting
;		the neighbouring pixel.
; Parameters:	VX - X coord (0 - 127)
;		VY - Y coord (0 - 63)
; Returns:	-
; Destroys:	A,B
SetPxlF  BSR   UpdPxlStpF     ; Setup for updating the pixel
         LDAA  VX
         BITA  #$01           ; Test if we're updating odd column?
         BEQ   WasEvnSet      ;
         ORAB  #$0F           ; Set for odd column pixel
         BRA   StrPxlSet      ;
WasEvnSet
         ORAB  #$F0           ; Set for even column pixel
StrPxlSet
         STAB  OLED_DTA       ;
         RTS
;
; Function:	Set the Pixel at VX,VY (64x32 Res)
;		Note: As SSD1327 stores 2 pixels in each byte, half resolution
;		is easily achieved as we're updating 2 pixels for every "pixel"
; Parameters:	VX - X coord (0 - 63)
;		VY - Y coord (0 - 31)
; Returns:	-
; Destroys:	A,B
SetPxlH  JSR   UpdPxlStpH     ; Setup for updating the pixel
         LDAB  #$FF           ; Set double pixel
         STAB  OLED_DTA       ;
         STAB  OLED_DTA       ;
         RTS
;
; Function:	Set the Pixel at VX,VY (Res as per OLEDRES)
; Parameters:	VX - X coord (0 - 63 / 127)
;		VY - Y coord (0 - 31 / 63)
; Returns:	-
; Destroys:	-
SetPxl   PSHB
         PSHA
         LDAA  OLEDRES        ; Get OLED resolution flag
         BEQ   SetPxlRts      ; Nothing to do
         LSRA                 ; Test for Full res mode
         BEQ   SetPxl2        ;
         BSR   SetPxlH        ; Assume Half Res Mode
         BRA   SetPxlRts      ;
SetPxl2  BSR   SetPxlF        ; Full Res Mode
SetPxlRts
         PULA
         PULB
         RTS
;
; Function:	Clear the Pixel at VX,VY (128x64 Res)
;		Note: As SSD1327 stores 2 pixels in each byte, it's
;		necessary to get the VRAM byte first, to avoid overwriting
;		the neighbouring pixel.
; Parameters:	VX - X coord (0 - 127)
;		VY - Y coord (0 - 63)
; Returns:	-
; Destroys:	A,B
ClrPxlF  JSR   UpdPxlStpF     ; Setup for updating the pixel
         LDAA  VX
         BITA  #$01           ; Test if we're updating odd column?
         BEQ   WasEvnClr      ;
         ANDB  #$F0           ; Clear odd column pixel
         BRA   StrPxlClr      ;
WasEvnClr
         ANDB  #$0F           ; Clear even column pixel
StrPxlClr
         STAB  OLED_DTA       ;
         RTS
;
; Function:	Clear the Pixel at VX,VY (64x32 Res)
;		Note: As SSD1327 stores 2 pixels in each byte, half resolution
;		is easily achieved as we're updating 2 pixels for every "pixel"
; Parameters:	VX - X coord (0 - 63)
;		VY - Y coord (0 - 31)
; Returns:	-
; Destroys:	A,B
ClrPxlH  JSR   UpdPxlStpH     ; Setup for updating the pixel
         CLRB                 ; Clear double pixel
         STAB  OLED_DTA       ;
         STAB  OLED_DTA       ;
         RTS
;
; Function:	Clear the Pixel at VX,VY (Res as per OLEDRES)
; Parameters:	VX - X coord (0 - 63 / 127)
;		VY - Y coord (0 - 31 / 63)
; Returns:	-
; Destroys:	-
ClrPxl   PSHA
         PSHB
         LDAA  OLEDRES        ; Get OLED resolution flag
         BEQ   ClrPxlRts      ; Nothing to do
         LSRA                 ; Test for Full res mode
         BEQ   ClrPxl2        ;
         BSR   ClrPxlH        ; Assume Half Res Mode
         BRA   ClrPxlRts      ;
ClrPxl2  BSR   ClrPxlF        ; Full Res Mode
ClrPxlRts
         PULB
         PULA
         RTS
;
; Function:	Toggle (invert) the Pixel value at VX,VY (128x64 res)
;		Note: As SSD1327 stores 2 pixels in each byte, it's
;		necessary to get the VRAM byte first, to avoid overwriting
;		the neighbouring pixel.
; Parameters:	VX - X coord (0 - 127)
;		VY - Y coord (0 - 63)
; Returns:	-
; Destroys:	A,B
TglPxlF  JSR   UpdPxlStpF     ; Setup for updating the pixel
         LDAA  VX
         BITA  #$01           ; Test if we're updating odd column?
         BEQ   WasEvnTgl      ;
         EORB  #$0F           ; Invert odd column pixel
         BITB  #$0F           ; Was Pixel toggled OFF?
         BNE   StrPxlTglF     ; No, pixel was originally OFF
         LDAA  #1             ; SET CHIPOS OVERLAP FLAG (VF)
         STAA  VF
         BRA   StrPxlTglF     ;
WasEvnTgl
         EORB  #$F0           ; Invert even column pixel
         BITB  #$F0           ; Was Pixel toggled OFF?
         BNE   StrPxlTglF     ; No, pixel was originally OFF
         LDAA  #1             ; SET CHIPOS OVERLAP FLAG (VF)
         STAA  VF
StrPxlTglF
         STAB  OLED_DTA       ;
         RTS
;
; Function:	Toggle (invert) the Pixel value at VX,VY (64x32 res)
;		Note: As SSD1327 stores 2 pixels in each byte, half resolution
;		is easily achieved as we're updating 2 pixels for every "pixel"
; Parameters:	VX - X coord (0 - 63)
;		VY - Y coord (0 - 31)
; Returns:	-
; Destroys:	A,B
TglPxlH  JSR   UpdPxlStpH     ; Setup for updating the pixel
         EORB  #$FF           ; Invert column dual pixel
         BITB  #$FF           ; Was Pixel toggled OFF?
         BNE   StrPxlTglH     ; No, pixel was originally OFF
         LDAA  #1             ; SET CHIPOS OVERLAP FLAG (VF)
         STAA  VF
StrPxlTglH	
         STAB  OLED_DTA       ;
         STAB  OLED_DTA       ;
         RTS
;
; Function:	Toggle (invert) the Pixel value at VX,VY (Res as per OLEDRES)
; Parameters:	VX - X coord (0 - 63 / 127)
;		VY - Y coord (0 - 31 / 63)
; Returns:	-
; Destroys:	-
TglPxl   PSHB
         PSHA
         LDAA  OLEDRES        ; Get OLED resolution flag
         BEQ   TglPxlRts      ; Nothing to do
         LSRA                 ; Test for Full res mode
         BEQ   TglPxl2        ;
         BSR   TglPxlH        ; Assume Half Res Mode
         BRA   TglPxlRts      ;
TglPxl2  BSR   TglPxlF        ; Full Res Mode
TglPxlRts
         PULA
         PULB
         RTS
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
OledFill pushsx               ; Save X
         PSHA                 ; Save byte to fill
         PSHB                 ; Save start row
         LDAA  #$A4           ; Normal Display
         STAA  OLED_CMD       ;
;
         CLRA                 ; Start = 0
         LDAB  #127           ; End = 127
         BSR   ColSetF        ; Set Column Address range
;
         PULA                 ; Restore start row
         STAA  TB1            ; Save start row
         LDAB  #63            ; Start = A, End = 63
         BSR   RowSetF        ; Set Row Address range
         CLR   TX2            ; Reset 16-bit counter
         CLR   TX2+1
OledF1   LDAA  TX2
         LDAB  TX2+1
         ADDB  #64            ; 16-bit add with 128 (number of columns)
         ADCA  #0
         STAA  TX2            ; Save in TX2
         STAB  TX2+1
         INC   TB1
         LDAB  TB1
         CMPB  #64
         BNE   OledF1         ; Check for last row
;
         PULA                 ; Restore Byte to fill
         LDX   TX2            ; Number of pixels to write
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
         LDAA  #$00           ; Set Column Address range
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
; Default Interrupt Handlers (Redirects)
;
;RSRVD   RTI                  ; Reserved Vector / Handler
;SWI3    RTI                  ; SWI3 Vector / Handler
;SWI2    RTI                  ; SWI2 Vector / Handler
;FIRQ    RTI                  ; FIRQ Vector / Handler
IRQ      LDX   IRQV           ; IRQ Vector - Redirect to IRQV
         JMP   0,X
SWI      RTI                  ; SWI Vextor / Handler
NMI      RTI                  ; NMI Vector / Handler

;
; Standard CHIPOS functions (subroutines) - Redirects
;
         ORG   CHIPFTBL       ; Establish Standard base address for Redirects
ERASE    JMP   ZERASE         ; Clear the display buffer.
FILL     JMP   ZFILL          ; Fill part or all of display buffer with constant byte.
RANDOM   JMP   ZRANDOM        ; Generate a pseudorandom byte.
LETDSP   JMP   ZLETDSP        ; Called prior to SHOWI to display a hex digit.
DECEQ    JMP   ZDECEQ         ; Store 3-digit BCD equivalent of A at X, X+1, X+2.
SHOWI    JMP   ZSHOWI         ; Displays an N-byte symbol in memory pointed at by I.
SHOWX    JMP   ZSHOWX         ; Displays an N-byte symbol in memory pointed at by X.
PAINZ    JMP   ZPAINZ         ; Initialises the keypad port.
PAINV    JMP   ZPAINV         ; Inverts DDR for Keypad port.
KEYINP   JMP   ZKEYINP        ; Decodes the Hex keypad. after a 3.33msec debounce delay.
GETKEY   JMP   ZGETKEY        ; Waits for a Key to be pressed, ackowledges with a BLEEP.
BLEEP    JMP   ZBLEEP         ; Generates a 1200Hz tone in the speaker for approx 80ms.
BTONE    JMP   ZBTONE         ; Generates a variable length tone (B).
BTON     JMP   ZBTON	         ; Generates a variable length tone (TONE) at either 1200Hz or 600Hz (B).
DEL333   JMP   ZDEL333        ; Delay for 3.33ms.
DEL167   JMP   ZDEL167        ; Delay for 1.67ms.
PBINZ    JMP   ZPBINZ         ; Initialise Tape and Sound port.
INBYT    JMP   ZINBYT         ; Inputs a serial byte at 300 baud.
OUTBYT   JMP   ZOUTBYT        ; Outputs a serial byte at 300 baud.
BYTIN    JMP   ZBYTIN         ; Accepts 2 Hex digits from Keypad and builds a byte.
START    JMP   ZSTART         ; CHIPOS Monitor entry point.
SHODAT   JMP   ZSHODAT        ; Display a byte (2 Hex digits) pointed at by X.
SHOBYT   JMP   ZSHOBYT        ; Display a byte (2 Hex digits) in A reg.
DIGOUT   JMP   ZDIGOUT        ; Display lesast significant digit in A reg.
CURSR    JMP   ZCURSR         ; Moves cursor position to the right.
CURS1    JMP   ZCURS1         ; Reset cursor horizontal position (as per A). 
;
;
; Hardware Vector Table
;
         ORG   VECTORS        ; Setup 6800 Hardware Vectors
;
;        dc.w  RSRVD          ; Reserved
;        dc.w  SWI3           ; Software Interrupt 3
;        dc.w  SWI2           ; Software Interrupt 2
;        dc.w  FIRQ           ; Fast Interrupt Request
         dc.w  IRQ            ; Interrupt Request
         dc.w  SWI            ; Software Interrupt
         dc.w  NMI            ; Non-Maskable Interrupt
         dc.w  ENTRY          ; Reset
;
         END
