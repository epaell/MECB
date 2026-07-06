;       NAM    OTHELLO
;===========================
; OTHELLO GAME
; BY UNKNOWN SOURCE
; RECOVERED FROM OLD FLOPPIES
;
; ADOPTED TO RUN ON THE MC3
; BY DANIEL TUFVESSON 2014
;===========================

       include "mecb.inc"
       include "DigiBug.inc"
;
;OUTCH  EQU    $F075
;INCH   EQU    $F078
;CONTRL EQU    $F1BA

       ORG    $100

MAIN   LDX    #GREET    ;		LDS    #$C07F    GREETINGS
       BSR    OUTIN
       CMPA   #'Y'
       BNE    PROMT1
       BRA    PROMT2

; SHOULD CPU WAIT?

PROMT1 LDX    #IWAIT
PROMT2 BSR    OUTIN     ; WAIT?
       CLRB
       CMPA   #'Y'
       BNE    STORWT
       JSR    PDATA1
       INCB
STORWT STAB   WAIT
       LDX    #BEST     ; STRATEGY?
       BSR    OUTIN
       CLRB
       CMPA   #'N'
       BEQ    STORBT
       LDAB   #2
STORBT STAB   STRTGY
       LDX    #XORO     ; WANT X OR O ?
       BSR    OUTIN
       CMPA   #'X'
       BEQ    STORXO
       LDAA   #'O'
STORXO STAA   XXOO
       LDX    #FIRST    ; MOVE?
       BSR    OUTIN
       CLRB
       CMPA   #'N'
       BEQ    STOR1
       INCB
STOR1  STAB   WHO1ST
       JSR    PCRLF

; INITIAL BOARD

INITAL LDAB   #'.'
       LDX    #MATRIX
ZAP    STAB   0,X			; STAB   0,X+
       INX
       CPX    #MATRIX+65
       BNE    ZAP
       LDX    #$4F58    ; O X
       STX    MATRIX+27
       LDX    #$584F    ; X O
       STX    MATRIX+35

; INITIAL PIECE SCORE

       LDX    #$0204
       STX    CPU       ; CPU=ME=2
       STX    ME        ; TOTAL=4
       STAA   FORFIT    ; =0

; PRINT INITIAL BOARD

       JSR    PRINT

; WHO'S FIRST?

       TST    WHO1ST
       BEQ    COMPTR
       JMP    HUMAN
OUTIN  JSR    PDATA1
INE    JSR    INCH
       CMPA   #$1B      ; ESCAPE
       BNE    RTS1
       JMP    REPLAY
RTS1   RTS

; SHOULD CPU WAIT

COMPTR TST    WAIT
       BEQ    CPUGO
       BSR    INE

; SETUP CPU'S PIECE

CPUGO  LDAA   XXOO
       EORA   #$17      ; FLIP
       STAA   PIECE

; INITIAL VARIABLES

       LDAA   #64
       STAA   CPUTRY
       CLR    ROW
       CLR    COL
       CLR    CPUSCR
       CLR    SCORE3

; CHECK FOR EMPTY SQUARE

TESTPT LDX    #ROW
       JSR    GETMTX
       CMPA   #'.'
       BNE    NOGOOD

; TEST FOR PROPER NEIGHBOR

       JSR    PROPER
       TSTA
       BEQ    NOGOOD

; CHECK FOR FLANKED ROW

       CLR    FLAG
       JSR    SCORE
       LDAB   SCORE1
       BEQ    NOGOOD

; BEST MOVE SO FAR?

       LDAA   ROW
       BEQ    CKROW
       CMPA   #7
       BNE    CKROW1
CKROW  ADDB   STRTGY
CKROW1 LDAA   COL
       BEQ    ADSTRT
       CMPA   #7
       BNE    CKSCOR
ADSTRT ADDB   STRTGY
CKSCOR CMPB   CPUSCR
       BHI    STCPUS
       BNE    NOGOOD
       BITB   #1        ; RANDOM CHOICE
       BEQ    NOGOOD

; FOUND BETTER MOVE FOR CPU

STCPUS LDAA   SCORE1
       STAA   SCORE3
       STAB   CPUSCR
       LDX    ROW
       STX    CROW

; ALL SQ'S TESTED?

NOGOOD DEC    CPUTRY
       BEQ    TSTSCR

; TRY AGAIN

       CLRB
       INC    COL
       LDAA   COL
       CMPA   #7
       BLS    DOROW
       STAB   COL
       INCB
DOROW  LDAA   ROW
       ABA
       STAA   ROW
       BRA    TESTPT

; ANY CAPTURED?

TSTSCR TST    SCORE3
       BEQ    CPUFOR

; UPDATE SCORES

GOODMV CLR    FORFIT
       LDAA   CPU
       ADDA   SCORE3
       INCA
       STAA   CPU
       LDAA   ME
       SUBA   SCORE3
       STAA   ME
       INC    TOTAL

; PRINT CPU'S MOVE

       LDX    #IMOVE
       JSR    PDATA1
       LDAA   CROW
       ADDA   #$31      ; MAKE ASCII
       JSR    OUTCH
       LDAA   CROW+1
       ADDA   #$41      ; MAKE ASCII LETTER
       JSR    OUTCH     ; OUTPUT LETTER

; PRINT # CAPTURED

       LDX    #THAT1
       JSR    PDATA1    ; THAT GIVES ME
       LDX    #SCORE3
       JSR    PRTDEC
       LDX    #YOUR
       JSR    PDATA1    ; YOUR PIECES

; FLIP CAPTURED PIECES

       LDX    CROW
       STX    ROW
       INC    FLAG
       JSR    SCORE
       JSR    PRINT

; TEST FOR END OF GAME

       LDAA   ME
       BEQ    THEND
TSTTOT LDAA   TOTAL
       CMPA   #64
       BNE    HUMAN
THEND  JMP    THEEND

; CPU FORFITS MOVE

CPUFOR LDX    #CPU0
       JSR    PDATA1
       LDAA   FORFIT
       BNE    THEND
 INC FORFIT

; GET HUMAN'S ROW,COL I/P

HUMAN  LDAA   XXOO
       STAA   PIECE
       LDX    #MOVE
       JSR    OUTIN
       CMPA   #'X'
       BNE    CHKCOL
       JSR    PRINT
       BRA    HUMAN
CHKCOL CMPA   #'8'
       BLS    LOWER
       JMP    HUMFOR
LOWER
       SUBA   #$31
       BCS    HUMFOR
       STAA   ROW
       JSR    INE
       CMPA   #'H'
       BHI    HUMFOR
       SUBA   #$41      ; =A
       BCS    HUMFOR
       STAA   COL

; OCCUPIED SQ?

       LDX    #ROW
       JSR    GETMTX
       LDX    #SORRY
       CMPA   #'.'
       BNE    PRNT2

; PROPER NEIGHBOR?

EMPTY  JSR    PROPER
       LDX    #NONEXT
       TSTA
       BEQ    PRNT2

; FLANK?

CKFLNK CLR    FLAG
       JSR    SCORE
       TST    SCORE1
       BNE    LEGAL
       LDX    #NOFLNK
PRNT2  JSR    PDATA1
HUM1   BRA    HUMAN

; ALL LEGAL

LEGAL  CLR    FORFIT
       LDX    #THAT
       JSR    PDATA1
       LDX    #SCORE1
       JSR    PRTDEC
       LDX    #OFMY
       JSR    PDATA1

; UPDATE SCORES

       LDAA   ME
       ADDA   SCORE1
       INCA
       STAA   ME
       LDAA   CPU
       SUBA   SCORE1
       STAA   CPU
       INC    TOTAL

; FLIP BOARD PIECES

       INC    FLAG
       JSR    SCORE
       JSR    PRINT

; TEST FOR END OF GAME

       LDAA   CPU
       BEQ    THEEND
       LDAA   TOTAL
       CMPA   #64
       BEQ    THEEND
GOCPU  JMP    COMPTR

; HUMAN FORFITS MOVE

HUMFOR LDX    #HUM0
       JSR    OUTIN
       CMPA   #'Y'
       BNE    HUM1
BYEBYE JSR    PCRLF
       LDAA   FORFIT
       BNE    THEEND
       INC    FORFIT
       BRA    GOCPU
THEEND LDX    #YOUHAV
       JSR    PDATA1
       LDX    #ME
       JSR    PRTDEC
       LDX    #ANDI
       JSR    PDATA1
       LDX    #CPU
       JSR    PRTDEC
       LDX    #PTEXT
       JSR    PDATA1

; DETERMINE WINNER

       LDX    #ATIE     ; TIE
       LDAA   ME
       CMPA   CPU
       BEQ    PRNT1     ; TIE
       BHI    HUMWON
       LDX    #IWON
       JSR    PDATA1
       LDAB   CPU
       SUBB   ME
       BRA    HOWBAD
HUMWON LDX    #MEWON
       JSR    PDATA1
       LDAB   ME
       SUBB   CPU

; HOW BAD WAS OTHER GUY TROUNCED?

HOWBAD LDX    #TTYPE
       JSR    PDATA1
       LDX    #PERFCT
       CMPB   TOTAL
       BEQ    PRNT1     ; PERFECT GAME
       LDX    #SQEAK
       CMPB   #5
       BLS    PRNT1     ; SQUEAKER
       LDX    #HOT
       CMPB   #10
       BLS    PRNT1     ; HOT GAME
       LDX    #FIGHT
       CMPB   #15
       BLS    PRNT1     ; FIGHT!
       LDX    #WALK     ; WALKAWAY!
PRNT1  JSR    PDATA1
REPLAY LDX    #ANOTHR   ; PLAY AGAIN?
       JSR    OUTIN
       CMPA   #'N'
       BEQ    FIN
       JSR    PCRLF
       JMP    INITAL
FIN    LDX    #THANX
       JSR    PDATA1
       JMP    CONTRL

;********************
; STORMX SUBROUTINE *
;********************

STORMX BSR    GETMTX    ; POINT TO PLACE
       LDAA   PIECE
       STAA   0,X
       RTS

;********************
; GETMTX SUBROUTINE *
;********************

GETMTX LDAA   0,X       ; PASSED ROW # (0-7)
       LDAB   1,X       ; PASSED COL # (0-7)
       ASLA             ; MULTIPLY
       ASLA             ; BY
       ASLA             ; EIGHT
       LDX    #MATRIX   ; START ADDR
       ABA
       BEQ    LOADA
BUILDX INX              ; BUMP
       DECA
       BNE    BUILDX
LOADA  LDAA   0,X       ; MATRIX ELEMENT REQ'D
       RTS

;********************
; PROPER SUBROUTINE *
;********************

PROPER LDAA   PIECE     ; OTHER PLAYER'S PIECE
       EORA   #$17      ; FLIP
       STAA   TEMP1
       LDAA   #8        ; 8 NEIGHBORS
       STAA   COUNT     ; TO CHECK
       LDX    #NEIBOR   ; START ADDR
       STX    TEMPX1    ; OF NEIGHBOR
GETROW LDAB   ROW       ; ROW COORD
       LDAA   0,X       ; ROW'S DIRECTION
       BEQ    SETR      ; =0
       BMI    MROW      ; =-
AROW   INCB
       CMPB   #7        ; OFF OF BOARD
       BHI    NONEIB    ; YES
       BRA    SETR      ; NO
MROW   TSTB             ; OFF OF BOARD
       BEQ    NONEIB    ; YES
       DECB             ; NO
SETR   STAB   TROW      ; STORE NEIGHBOR'S ROW #
GETCOL LDAB   COL       ; COL COORD
       LDX    TEMPX1    ; COL'S
       LDAA   1,X       ; DIRECTION
       BEQ    SETC      ; =0
       BMI    MCOL      ; =-
ACOL   INCB
       CMPB   #7        ; OFF OF BOARD
       BHI    NONEIB    ; YES
       BRA    SETC      ; NO
MCOL   TSTB             ; OFF OF BOARD
       BEQ    NONEIB    ; YES
       DECB             ; NO
SETC   STAB   TCOL      ; STORE NEIGHBOR'S COL #
       LDX    #TROW     ; GET PIECE
       BSR    GETMTX    ; AT NEIGHBOR'S COORDS
       CMPA   TEMP1     ; GET OTHER PLAYER'S PIECE
       BEQ    RTS2      ; IS PROPER

; NO NEIGHBOR

NONEIB LDX    TEMPX1
       INX              ; BUMP NEIGHBOR POINTER
       INX
       STX    TEMPX1
       DEC    COUNT     ; DEC COUNT
       BNE    GETROW    ; OF ENTRIES TO CHECK
       CLRA             ; FLAG=NO NEIGHBOR
RTS2   RTS
NEIBOR fcb    0,1       ; DOWN
       fcb    $FF,1     ; LOWER-LEFT
       fcb    $FF,0     ; LEFT
       fcb    $FF,$FF   ; UPPER-LEFT
       fcb    0,$FF     ; UP
       fcb    1,$FF     ; UPPER-RIGHT
       fcb    1,0       ; RIGHT
       fcb    1,1       ; LOWER RIGHT

;*******************
; PRINT SUBROUTINE *
;*******************

PRINT  LDX    #LETTER
       JSR    PDATA1
       LDX    #MATRIX
       LDAA   #'0'
BOARD  INCA
       STAA   COUNT
       JSR    OUTCH     ; LINE #
       LDAB   #8        ; 8 CHARS TO PRINT
EIGHT  LDAA   #$20
       JSR    OUTCH     ; SPACE
       LDAA   0,X       ; OUTPUT
       JSR    OUTCH     ; CHAR
       INX              ; BUMP CHAR PTR
       DECB             ; DEC CHAR COUNT
       BNE    EIGHT     ; MORE TO DO
       BSR    PCR
       LDAA   COUNT
       CMPA   #'8'
       BNE    BOARD     ; BOARD
PCR    JMP    PCRLF

;*******************
; SCORE SUBROUTINE *
;*******************

SCORE  TST    FLAG      ; HERE FOR SCORE ONLY
       BEQ    NOSTOR    ; YES
       LDX    #ROW
       JSR    STORMX    ; PUT PIECE ON BOARD
NOSTOR CLR    SCORE1    ; ZERO OVERALL CTR
       LDAA   #8
       STAA   COUNT     ; 8 NEIGHBORS TO CHECK
       LDX    #NEIBOR   ; START ADDR
       STX    TEMPX1    ; OF NEIGHBOR
LOOP1  LDX    TEMPX1    ; ADDR OF 'NEW' NEIGHBORS
       LDAA   0,X
       STAA   RDIR      ; ROW VECT
       LDAA   1,X
       STAA   CDIR      ; COL VECT
       CLR    FLAG1     ; ZERO STORAGE FLAG
LOOP1A LDAA   ROW       ; PASSED ROW #
       STAA   TROW
       LDAA   COL       ; PASSED COL #
       STAA   TCOL
       CLR    SCORE2    ; ZERO INTERMEDIATE SCORE
LOOP2  LDAA   RDIR      ; ROW VECT
       BEQ    NEWCOL    ; =0
       BMI    NROW      ; =-
PROW   INC    TROW      ; TROW=TROW+1
       LDAA   TROW
       CMPA   #7        ; OFF OF BOARD
       BHI    END1      ; YES
       BRA    NEWCOL    ; NO
NROW   TST    TROW      ; OFF OF BOARD
       BEQ    END1      ; YES
       DEC    TROW      ; ROW=ROW-1
NEWCOL LDAA   CDIR      ; COL VECT
       BEQ    CHECK     ; =0
       BMI    NCOL      ; =-
PCOL   INC    TCOL      ; COL=COL+1
       LDAA   TCOL
       CMPA   #7        ; OFF OF BOARD
       BHI    END1      ; YES
       BRA    CHECK
NCOL   TST    TCOL      ; OFF OF BOARD
       BEQ    END1      ; YES
       DEC    TCOL      ; COL=COL-1
CHECK  LDX    #TROW     ; GET PIECE
       JSR    GETMTX    ; AT TROW,TCOL
       TAB
       LDAA   PIECE     ; GET OPPONENTS CODE
       EORA   #$17      ; FLIP
       CBA              ; CAPTURED OPPONENT'S PIECE
       BNE    ISME      ; NO
       INC    SCORE2    ; YES
       TST    FLAG1     ; STORE IT?
       BEQ    LOOP2     ; NO
       LDX    #TROW     ; YES
       JSR    STORMX
       BRA    LOOP2
ISME   CMPB   PIECE     ; FOUND ONE OF MY PIECES
       BNE    END1      ; NO-FOUND BLANK
       TST    FLAG1     ; HERE ON SCORE PASS
       BNE    TEST      ; NO
       LDAA   SCORE2    ; UPDATE
       ADDA   SCORE1    ; # PIECES
       STAA   SCORE1    ; CAPTURED
TEST   TST    FLAG      ; FOR REAL?
       BEQ    END1      ; NO
       TST    FLAG1     ; OPPONENT'S PIECES FLIPPED YET
       BNE    END1      ; YES
       INC    FLAG1     ; NO-SET FLAG
       JMP    LOOP1A    ; FLIP OPPONENT
END1   LDAA   TEMPX1+1
       ADDA   #2        ; UPDATE
       LDAB   TEMPX1    ; NEIGHBOR
       ADCB   #0        ; POINTER
       STAA   TEMPX1+1
       STAB   TEMPX1
       DEC    COUNT     ; ALL CHECKED?
       BEQ    RETURN    ; YES
       JMP    LOOP1
RETURN RTS

;*******************
;PRTDEC SUBROUTINE *
;*******************

PRTDEC LDAB   0,X       ; LOAD PASSED HEX #
       CLRA             ; ZERO HIGH ORDER DIGIT
DECLOP INCA
       SUBB   #10       ; NN=NN-10
       BCC    DECLOP
       ADDB   #10       ; RESTORE B
       DECA
       BEQ    OUTB      ; SUPPRESS LEADING ZERO
       BSR    OUTASC
OUTB   TBA
OUTASC ADDA   #'0'
       JMP    OUTCH

;********************
; PDATA1 SUBROUTINE *
;********************

PDATA2 BSR    OUTE
PDATA1 LDAA   0,X
       INX
       CMPA   #'^'
       BNE    CKCR
       LDAA   #$10
       BSR    CLRSCN    ; CLEAR SCREEN
CKCR   CMPA   #'/'      ; C.R.?
       BNE    CKEND
       BSR    PCRLF     ; C.R. L.F.
CKEND  CMPA   #';'
       BNE    PDATA2
       RTS
PCRLF  LDAA   #$D
       BSR    OUTE
       LDAA   #$A
CLRSCN BSR    OUTE
NUL4   BSR    NUL2
NUL2   BSR    NUL1
NUL1   CLRA
OUTE   JMP    OUTCH

GREET  fcb    "/^^^"
       fcb    "GREETINGS FROM OTHELLO/"
INST0  fcb    "DO YOU WANT INSTRUCTIONS?;"
INST1  fcb    "//OTHELLO IS PLAYED ON AN "
       fcb    "8 BY 8 CHECKER BOARD WITH "
       fcb    "/ROWS NUMBERED 1 TO 8 "
       fcb    "AND COLUMNS A TO H."
       fcb    "/THE INITIAL CONFIGURATION "
       fcb    "IS ALL BLANK EXCEPT"
       fcb    "/FOR THE CENTER FOUR SQUARES, "
       fcb    "WHICH FORM THE PATTERN:/"
       fcb    "          O X/"
       fcb    "          X O/"
       fcb    "PUT YOUR PIECE SO THAT MINE IS "
       fcb    "BETWEEN 2 OF YOURS, SUCH AS:/"
       fcb    "        X O X/"
       fcb    "          X O/"
       fcb    "THIS WILL 'FLIP' MY TOP 'O' INTO YOUR 'X'/"
       fcb    "/NOTE: YOU MAY CAPTURE 1 OR MORE OF "
       fcb    "MY PIECES THIS WAY,/"
       fcb    "OR YOU MAY FORFEIT BY TYPING 'Z'"
IWAIT  fcb    "//SHOULD I WAIT BEFORE "
       fcb    "MAKING MY MOVES?;"
OKWAIT fcb    "/OK. TYPING ANY CHARACTER "
       fcb    "WILL LET ME GO!/;"
BEST   fcb    "/SHOULD I PLAY MY BEST "
       fcb    "STRATEGY?;"
SORRY  fcb    "/SORRY, THAT SQUARE IS "
       fcb    "OCCUPIED. TRY AGAIN!;"
MOVE   fcb    "/YOUR MOVE--(ROW,COL)?;"
XORO   fcb    "/DO YOU WANT TO HAVE X OR O?;"
FIRST  fcb    "/DO YOU WANT TO GO FIRST?;"
NONEXT fcb    "/SORRY, YOU ARE NOT NEXT TO "
       fcb    "ONE OF MY PIECES. TRY AGAIN!;"
NOFLNK fcb    "/SORRY, THAT MOVE DOES NOT "
       fcb    "FLANK A ROW. TRY AGAIN!;"
THAT   fcb    "^/THAT GIVES YOU ;"
OFMY   fcb    " OF MY PIECES/;"
YOUHAV fcb    7
       fcb    "YOU HAVE ;"
ANDI   fcb    " PIECES AND I HAVE ;"
PTEXT  fcb    " PIECES!/;"
IWON   fcb    "SORRY, I WON THAT ONE!/;"
ATIE   fcb    "A TIE!/;"
MEWON  fcb    "YOU WON!!/;"
TTYPE  fcb    "THAT WAS A ;"
PERFCT fcb    "PERFECT GAME!/;"
WALK   fcb    "WALKAWAY!/;"
FIGHT  fcb    "FIGHT!/;"
HOT    fcb    "HOT GAME!/;"
SQEAK  fcb    "SQUEAKER!/;"
ANOTHR fcb    "/DO YOU WANT TO PLAY"
       fcb    " ANOTHER GAME?;"
THANX  fcb    "/THANKS FOR PLAYING!/;"
IMOVE  fcb    "^^I MOVE TO ;"
THAT1  fcb    "/THAT GIVES ME ;"
YOUR   fcb    " OF YOUR PIECES./;"
CPU0   fcb    "I HAVE TO FORFIT MY MOVE!/;"
HUM0   fcb    "/ARE YOU FORFEITING "
       fcb    "YOUR TURN (Y OR N)?;"
LETTER fcb    "/  A B C D E F G H/;"
;
;       ORG    $0020

TROW   ds.b   1
TCOL   ds.b   1
CROW   ds.b   2
CPUTRY ds.b   1
CPUSCR ds.b   1
FORFIT ds.b   1
ROW    ds.b   1
COL    ds.b   1
PIECE  ds.b   1
;      ORG    *
XXOO   fcb    "O"
WAIT   fcb    0         ; NO WAIT
STRTGY fcb    2         ; BEST STRATEGY
WHO1ST fcb    1         ; HUMAN FIRST
COUNT  ds.b   1
TEMPX1 ds.b   2
TEMP1  ds.b   1
RDIR   ds.b   1
CDIR   ds.b   1

CPU    ds.b   1
ME     ds.b   1
TOTAL  ds.b   1
FLAG   ds.b   1
FLAG1  ds.b   1
SCORE1 ds.b   1
SCORE2 ds.b   1
SCORE3 ds.b   1
MATRIX ds.b   8*8
;
       END    START