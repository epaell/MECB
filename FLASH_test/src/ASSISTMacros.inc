;
; ASSIST09 SWI functions
;
INCHNP          EQU     0               ; INPUT CHAR IN A REG - NO PARITY
OUTCH           EQU     1               ; OUTPUT CHAR FROM A REG
PDATA1          EQU     2               ; OUTPUT STRING
PDATA           EQU     3               ; OUTPUT CR/LF THEN STRING
OUT2HS          EQU     4               ; OUTPUT TWO HEX AND SPACE
OUT4HS          EQU     5               ; OUTPUT FOUR HEX AND SPACE
PCRLF           EQU     6               ; OUTPUT CR/LF
SPACEF          EQU     7               ; OUTPUT A SPACE
MONITR          EQU     8               ; ENTER ASSIST09 MONITOR
VCTRSW          EQU     9               ; VECTOR EXAMINE/SWITCH
BRKPT           EQU     10              ; USER PROGRAM BREAKPOINT
PAUSE           EQU     11              ; TASK PAUSE FUNCTION
;
; Define some macros for the various ASSIST09 system calls used
;
monitr          MACRO                   ; Macro to return to ASSIST09
                LDA     #\1
                SWI
                FCB     MONITR
                ENDM
;
inchnp          MACRO                   ; Input a character in to A accumulator (No parity)
                SWI
                FCB     INCHNP
                ENDM
;
outch           MACRO                   ; Output character in A accumulator
                SWI
                FCB     OUTCH
                ENDM
;
pdata           MACRO                   ; Macro to output a string
                LDX     #\1
                SWI
                FCB     PDATA
                ENDM
;
pdata1          MACRO                   ; Macro to output a new line and a string
                LDX     #\1
                SWI
                FCB     PDATA1
                ENDM
;
pcrlf           MACRO                   ; Macro to output a new line
                SWI
                FCB     PCRLF
                ENDM
;
spacef          MACRO                   ; Macro to output a space
                SWI
                FCB     SPACEF
                ENDM
;
out4hs          MACRO                   ; Macro to output a 16-bit Hex value point to by X
                SWI
                FCB     OUT4HS
                ENDM
;
out2hs          MACRO                   ; Macro to output a 8-bit Hex value pointed to by X
                SWI
                FCB     OUT2HS
                ENDM
;
vctrsw          MACRO                   ; Macro to swap vector number passed as parameter with X (if X=0 then returns current value)
                LDA     #\1
                SWI
                FCB     VCTRSW
                ENDM
;
; Vector Table
;
_AVTBL  EQU     0               ; ADDRESS OF VECTOR TABLE (ELENC BEGIN Changed "." to "_" to enable compilation)
_CMDL1  EQU     2               ; FIRST COMMAND LIST
_RSVD   EQU     4               ; RESERVED HARDWARE VECTOR
_SWI3   EQU     6               ; SWI3 ROUTINE
_SWI2   EQU     8               ; SWI2 ROUTINE
_FIRQ   EQU     10              ; FIRQ ROUTINE
_IRQ    EQU     12              ; IRQ ROUTINE
_SWI    EQU     14              ; SWI ROUTINE
_NMI    EQU     16              ; NMI ROUTINE
_RESET  EQU     18              ; RESET ROUTINE
_CION   EQU     20              ; CONSOLE ON
_CIDTA  EQU     22              ; CONSOLE INPUT DATA
_CIOFF  EQU     24              ; CONSOLE INPUT OFF
_COON   EQU     26              ; CONSOLE OUTPUT ON
_CODTA  EQU     28              ; CONSOLE OUTPUT DATA
_COOFF  EQU     30              ; CONSOLE OUTPUT OFF
_HSDTA  EQU     32              ; HIGH SPEED PRINTDATA
_BSON   EQU     34              ; PUNCH/LOAD ON
_BSDTA  EQU     36              ; PUNCH/LOAD DATA
_BSOFF  EQU     38              ; PUNCH/LOAD OFF
_PAUSE  EQU     40              ; TASK PAUSE ROUTINE
_EXPAN  EQU     42              ; EXPRESSION ANALYZER
_CMDL2  EQU     44              ; SECOND COMMAND LIST
_ACIA   EQU     46              ; ACIA ADDRESS
_PAD    EQU     48              ; CHARACTER PAD AND NEW LINE PAD
_ECHO   EQU     50              ; ECHO/LOAD AND NULL BKPT FLAG
_PTM    EQU     52              ; PTM ADDRESS (ELENC END Changed "." to "d" to enable compilation)
NUMVTR  EQU     52/2+1          ; NUMBER OF VECTORS
HIVTR   EQU     52              ; HIGHEST VECTOR OFFSET

;
; Convenience Macros
;
sez             MACRO                   ; Macro to set zero flag
                ORCC    #$04
                ENDM
;
clz             MACRO                   ; Macro to clear zero flag
                ANDCC    #$FB
                ENDM
