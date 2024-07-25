; Based on code from Matt Sarnoff (msarnoff.org/6809)
;
; Plasma effect.

;
                INCLUDE "src/mecb.inc"
                INCLUDE "src/ASSISTMacros.inc"

SOUND           EQU     0       ; Don't include sound handling yet

; VRAM addresses (for Graphics I)
SPRPATTABLE     EQU     0x0000
PATTABLE        EQU     0x0800
SPRATTABLE      EQU     0x1000
NAMETABLE       EQU     0x1400
COLORTABLE      EQU     0x2000

; Parameters
GRID_WIDTH      EQU     32
GRID_HEIGHT     EQU     24          ; ELENC was 34
GRID_SIZE       EQU     GRID_WIDTH*GRID_HEIGHT
NUM_COLORS      EQU     8
ACIA            EQU     $C008       ; MC6851 ACIA base address

;------------------------------------------------------------------------------
; variables
;------------------------------------------------------------------------------

; variables in direct page
                SETDP	#$00

VARSTART        ORG     $0080

; grid pointers
CURRENTGRID     RMB     2
NEXTGRID        RMB     3       ; Pointer to GRID1/GRID2

T               RMB     1
T_3             RMB     1
DIV3_COUNT      RMB     1
SIN_T           RMB     1
SIN_T_3         RMB     1

; evaluation function pointer
PLASMA_FN       RMB     2

; temporary values usable by computation functions
TEMP1           RMB     1
TEMP2           RMB     1
HEX16           RMB     2

;------------------------------------------------------------------------------
; setup
;------------------------------------------------------------------------------
                org     USERPROG_ORG
;
                CLRA                    ; Initialise Direct Page Register for Zero page
                TFR     A,DP

                LEAX    VBLANK,PCR
                vctrsw  _IRQ

                JSR     VDP_CLEAR       ; clear VRAM
                LDX     #vdp_regs       ; initialize VDP registers
                JSR     VDP_SET_REGS

; set up the pattern table
                LDD     #(VRAM|PATTABLE)
                STB     VDP_REG
                STA     VDP_REG
                LDA     #NUM_COLORS     ; write 8 copies of the cell patterns
                PSHS    A
loadcellpats    LDX     #CELLPATS
                LDB     #16
                JSR     VDP_LOADPATS
                DEC     ,S
                BNE     loadcellpats
                PULS    A

; set up the color table
                LDD     #(VRAM|COLORTABLE)
                STB     VDP_REG
                STA     VDP_REG
                LDX     #COLORS
                LDB     #2              ; 2*8 = 16 bytes
                JSR     VDP_LOADPATS

; Clear grids
                LDX     #GRID1
                LDY     #GRID_SIZE
clear_grid1     CLR     ,X+
                LEAY    -1,Y
                BNE     clear_grid1
                LDX     #GRID2
                LDY     #GRID_SIZE
clear_grid2     CLR     ,X+
                LEAY    -1,Y
                BNE     clear_grid2

; set up variables
                LDD     #GRID1
                STD     CURRENTGRID
                LDD     #GRID2
                STD     NEXTGRID
                CLR     T
                CLR     T_3
                LDA     #3
                STA     DIV3_COUNT
                LDD     #WAVE2
                STD     PLASMA_FN

; set up sound
                IF SOUND
                JSR     stg_init
                LDA     #$01              ; Turn on channel 0
                JSR     stg_atten0
                LDA     #$01              ; Turn on channel 1
                JSR     stg_atten1
                ENDIF

; enable interrupts
                ANDCC   #0b11101111         ; Enable IRQ Interrupts

; turn on the display, enable vertical blanking interrupt
                LDD     #0xE081             ; set bits 6 and 5 of register 1
                STA     VDP_REG
                STB     VDP_REG
                JMP     loop


;------------------------------------------------------------------------------
; logic update routine
;------------------------------------------------------------------------------
loop	
; iterate and generate NEXTGRID
                LDY     NEXTGRID
                LDD     #(GRID_WIDTH<<8)|GRID_HEIGHT ; initialize x and y counters
                PSHS    D

                LDU     #SIN8
                LDD     T           ; take sin of T and T/3
                LDA     A,U
                LDB     B,U
                STD     SIN_T

; x is in ,s and y is in 1,s
yloop
;---- inner loop
                LDA     #GRID_WIDTH
                STA     ,S
;-------- calculation
xloop           JMP     [PLASMA_FN]
setcell         ANDA    #0b01111111
                STA     ,Y+
;-------- end calculation
                DEC     ,S
                BNE     xloop
;---- end inner loop
                DEC     1,S
                BNE     yloop

; advance timers
                INC     T
                DEC     DIV3_COUNT
                BNE     flipbuffers
                INC     T_3

; flip buffers
flipbuffers     LDX     CURRENTGRID
                LDU     NEXTGRID
                STU     CURRENTGRID
                STX     NEXTGRID

; update sound
                IF      SOUND
                PSHS    A,B,X
                CLRA
                LDB     SIN_T
                ADDD    #$180
                LSLB
                ROLA
                LSLB
                ROLA
                TFR     D,X
                JSR     stg_freq0

                CLRA
                LDB	    GRID1
                LSLB
                ROLA
                LSLB
                ROLA
                LSLB
                ROLA
                TFR     D,X
                JSR     stg_freq1
                PULS    X,B,A
                ENDIF
                
                LBSR    CIDTA
                BCC     continue
                CMPA    #'q'
                BEQ     exit
continue        SYNC
                JMP     loop
;
exit            
                IF      SOUND
                LBSR    stg_stop
                ENDIF
                monitr  #$01            ; Return to ASSIST09


;------------------------------------------------------------------------------
; cell evaluator functions
;------------------------------------------------------------------------------
; x coordinate in ,s (0-32)
; y coordinate in 1,s (0-23)
; sin table pointer in u
; return value in a
; do not rts, branch to setcell

GRADIENT        LDA     ,S
                ADDA    1,S
                ADDA    T
                BRA     setcell

MUNCHING        LDA     ,S
                DECA
                EORA    1,S
                ADDA    T
                BRA     setcell

WAVE            LDA     ,S
                ADDA    T
                LDU     #SIN8
                LDA     A,U
                ADDA    1,S
                SUBA    T
                LDA     A,U
                LBRA    setcell

WAVE2           LDA     ,S          ; first component, sin(y)
                ADDA    T_3
                LDA     A,U
                ADDA    T
                LDA     A,U
                STA     TEMP1

                LDA     1,S
                ADDA    T
                LDA     A,U
                ADDA    T_3
                LDA     A,U

                ADDA    TEMP1
                LBRA    setcell

;------------------------------------------------------------------------------
; vertical blanking interrupt handler
;------------------------------------------------------------------------------
VBLANK          LDA     VDP_REG     ; read status, clear interrupt flag
; copy the grid into the name table
                LDD     #(VRAM|NAMETABLE)
                STB     VDP_REG
                STA     VDP_REG
                LDU     CURRENTGRID
                LDX     #VDP_VRAM
                LDY     #GRID_WIDTH*GRID_HEIGHT/2
; stack-blast the grid into VRAM (pulu d is faster than ldd ,u++)
vbloop          PULU    D
                STA     ,X
                vdp_wait
                STB     ,X
                LEAY   -1,Y
                BNE    vbloop
                RTI

;------------------------------------------------------------------------------
; subroutines
;------------------------------------------------------------------------------

;
delay1MS
; Function:	Delay 1ms (Approximately. Actually 1.004ms at 1Mhz clock)
; Parameters:	-
; Returns:	-
; Destroys:	X, Y
                LDX     #1              ; 3 Cycles
DelayMSLoop	    LDY     #123            ; 4 Cycles - Assumes 1Mhz Clock
Delay1MSLoop	LEAY    -1,Y            ; 5 cycles
                BNE     Delay1MSLoop    ; 3 cycles
                LEAX    -1,X            ; 5 cycles
                BNE     DelayMSLoop     ; 3 cycles
                RTS                     ; 5 cycles

delayMS
; Function:	Delay X ms (Actually X * 1.004ms + 0.003ms at 1Mhz clock)
; Parameters:	X - Specifies desired delay in millseconds (note above)
; Returns:	-
; Destroys:	X, Y
                BRA	    DelayMSLoop     ; 3 cycles

; Check for character in receive buffer
CIDTA           LDA     ACIA            ; LOAD STATUS REGISTER
                LSRA                    ; TEST RECEIVER REGISTER FLAG
                BCC     CIRTN           ; RETURN IF NOTHING
                LDA     ACIA+1          ; LOAD DATA BYTE
CIRTN           RTS                     ; RETURN TO CALLER

;------------------------------------------------------------------------------
; includes
;------------------------------------------------------------------------------

                INCLUDE "src/vdp.asm"
                IF SOUND
                INCLUDE "src/stg.asm"
                ENDIF

; trig table
                INCLUDE "src/sin8.inc"

; cell graphics
CELLPATS        INCLUDE "src/cells16.inc"
CELLPATS_END    EQU     *

; color order:
; medium red   (0x8)
; light red    (0x9)
; light yellow (0xB)
; light green  (0x3)
; cyan         (0x7)
; light blue   (0x5)
; dark blue    (0x4)
; magenta      (0xD)
COLORS          FCB     0x98,0x98
                FCB     0xB9,0xB9
                FCB     0x3B,0x3B
                FCB     0x73,0x73
                FCB     0x57,0x57
                FCB     0x45,0x45
                FCB     0xD4,0xD4
                FCB     0x8D,0x8D

;------------------------------------------------------------------------------
; data structures
;------------------------------------------------------------------------------

; two grid buffers
GRID1           RMB     GRID_SIZE
GRID2           RMB     GRID_SIZE

