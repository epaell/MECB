;   NAM    MIKBUG
;   REV 009
;   COPYRIGHT 1974 BY MOTOROLA INC
;
;   MIKBUG (TM)
;
;   L  LOAD
;   G  GO TO TARGET PROGRAM
;   M  MEMORY CHANGE
;   P  PRINT/PUNCH DUMP
;   R  DISPLAY CONTENTS OF TARGET STACK
;      CC   B   A   X   P   S
;
;   ADDRESS
ACIACS   EQU   $8008
ACIADA   EQU   $8009
VAR      EQU   $7F00

IOV     EQU    VAR         ; IO INTERRUPT POINTER
BEGA    EQU    VAR+2       ; BEGINING ADDR PRINT/PUNCH
ENDA    EQU    VAR+4       ; ENDING ADDR PRINT/PUNCH
NIO     EQU    VAR+6       ; NMI INTERRUPT POINTER
SP      EQU    VAR+8       ; S-HIGH and S-LOW
CKSM    EQU    VAR+10      ; CHECKSUM

BYTECT  EQU    VAR+11      ; BYTE COUNT
XHI     EQU    VAR+12      ; XREG HIGH
XLOW    EQU    VAR+13      ; XREG LOW
TEMP    EQU    VAR+14      ; CHAR COUNT (INADD)
TW      EQU    VAR+15      ; TEMP
MCONT   EQU    VAR+17      ; TEMP
XTEMP   EQU    VAR+18      ; X-REG TEMP STORAGE
STACK   EQU    VAR+66      ; STACK POINTER

;
         ORG   $8000
         ds.b  $7800
         ORG   $F800
;
;   I/O INTERRUPT SEQUENCE
IO       LDX   IOV
         JMP   0,X
;
;   NMI SEQUENCE
POWDWN   LDX   NIO         ; GET NMI VECTOR
         JMP   0,X
;
;   T COMMAND
;
MEMTST   LDX   #MTEST
         JSR   PDATA1
;
         LDX   #$0000      ; Start memory test
MEMTST2  STX   0,X         ; Write X at location X
         INX
         INX               ; Move to next word
         CMPX  #$8000      ; End of memory
         BNE   MEMTST2     ; Loop back until memory filled
;
         LDX   #$0000      ; Check starting from first location
MEMTST3  CMPX  0,X         ; Check if the value is still in memory
         BNE   MEMERR      ; No, issue an error
         INX               ; Otherwise move on to the next word
         INX
         CMPX  #$8000      ; End of memory
         BNE   MEMTST3
         LDS   #STACK      ; Reset the stack
         LDX   #MTESTOK
         JSR   PDATA1
         JMP   CONTRL
;
MEMERR   LDS   #STACK
         STX   $2000
         LDX   #MERR
         JSR   PDATA1
         LDX   #$2000
         JSR   OUT4HS
         JMP   CONTRL
;
MTEST    dc.b  $0d,$0a,'Starting memory test',$04
MTESTOK  dc.b  $0d,$0a,'Memory check OK',$04
MERR     dc.b  $0d,$0a,'Memory check failed at $',$04
;   t COMMAND
;
ROMTST   LDX   #RTEST
         JSR   PDATA1
;
         LDX   #$8100      ; Check starting from first location
         LDAB  #$00
ROMTST3  CMPB  0,X         ; Check if the value is still in memory
         BNE   MEMERR      ; No, issue an error
         INCB
         INX               ; Otherwise move on to the next word
         CMPX  #$F800      ; End of memory
         BNE   ROMTST3
         LDS   #STACK      ; Reset the stack
         LDX   #RTESTOK
         JSR   PDATA1
         JMP   CONTRL
;
ROMERR   LDS   #STACK
         STX   $2000
         LDX   #RERR
         JSR   PDATA1
         LDX   #$2000
         JSR   OUT4HS
         JMP   CONTRL
;
RTEST    dc.b  $0d,$0a,'Starting ROM read test',$04
RTESTOK  dc.b  $0d,$0a,'ROM check OK',$04
RERR     dc.b  $0d,$0a,'ROM check failed at $',$04
;
;   L COMMAND
LOAD     LDAA  #$0D
         BSR   OUTCH
         NOP
         LDAA  #$0A
         BSR   OUTCH
;
;   CHECK TYPE
LOAD3    BSR   INCH
         CMPA  #'S'
         BNE   LOAD3       ; 1ST CHAR NOT (S)
         BSR   INCH        ; READ CHAR
         CMPA  #'9'
         BEQ   C1          ; START ADDRESS
         CMPA  #'1'
         BNE   LOAD3       ; 2ND CHAR NOT (1)
         CLR   CKSM        ; ZERO CHECKSUM
         BSR   BYTE        ; READ BYTE
         SUBA  #2
         STAA  BYTECT      ; BYTE COUNT
;
;   BUILD ADDRESS
         BSR   BADDR
;
;   STORE DATA
LOAD11   BSR   BYTE
         DEC   BYTECT
         BEQ   LOAD15      ; ZERO BYTE COUNT
         STAA  0,X         ; STORE DATA
         INX
         BRA   LOAD11
;
;   ZERO BYTE COUNT
LOAD15   INC   CKSM
         BEQ   LOAD3
LOAD19   LDAA  #'?'        ; PRINT QUESTION MARK
         BSR   OUTCH
C1       JMP   CONTRL
;
;   BUILD ADDRESS
BADDR    BSR   BYTE        ; READ 2 FRAMES
         STAA  XHI
         BSR   BYTE
         STAA  XLOW
         LDX   XHI         ; (X) ADDRESS WE BUILT
         RTS
;
;   INPUT BYTE (TWO FRAMES)
BYTE     BSR   INHEX       ; GET HEX CHAR
         ASLA
         ASLA
         ASLA
         ASLA
         TAB
         BSR   INHEX
         ABA
         TAB
         ADDB  CKSM
         STAB  CKSM
         RTS
;
;   OUT HEX BCD DIGIT
OUTHL    LSRA              ; OUT HEX LEFT BCD DIGIT
         LSRA
         LSRA
         LSRA
OUTHR    ANDA  #$F         ; OUT HEX RIGHT BCD DIGIT
         ADDA  #$30
         CMPA  #$39
         BLS   OUTCH
         ADDA  #$7
;
;   OUTPUT ONE CHAR
OUTCH    JMP   OUTEEE
INCH     JMP   INEEE
;
;   PRINT DATA POINTED AT BY X-REG
PDATA2   BSR   OUTCH
         INX
PDATA1   LDAA  0,X
         CMPA  #4
         BNE   PDATA2
         RTS               ; STOP ON EOT
;
;   CHANGE MEMORY (M AAAA DD NN)
CHANGE   BSR   BADDR       ; BUILD ADDRESS
CHA51    LDX   #MCL
         BSR   PDATA1      ; C/R L/F
         LDX   #XHI
         BSR   OUT4HS      ; PRINT ADDRESS
         LDX   XHI
         BSR   OUT2HS      ; PRINT DATA (OLD)
         STX   XHI         ; SAVE DATA ADDRESS
         BSR   INCH        ; INPUT ONE CHAR
         CMPA  #$20
         BNE   CHA51       ; NOT SPACE
         BSR   BYTE        ; INPUT NEW DATA
         DEX
         STAA  0,X         ; CHANGE MEMORY
         CMPA  0,X
         BEQ   CHA51       ; DID CHANGE
         BRA   LOAD19      ; NOT CHANGED
;
;   INPUT HEX CHAR
INHEX    BSR   INCH
         SUBA  #$30
         BMI   C1          ; NOT HEX
         CMPA  #$09
         BLE   IN1HG
         CMPA  #$11
         BMI   C1          ; NOT HEX
         CMPA  #$16
         BGT   C1          ; NOT HEX
         SUBA  #7
IN1HG    RTS
;
;   OUTPUT 2 HEX CHAR
OUT2H    LDAA  0,X         ; OUTPUT 2 HEX CHAR
OUT2HA   BSR   OUTHL       ; OUT LEFT HEX CHAR
         LDAA  0,X
         INX
         BRA   OUTHR       ; OUTPUT RIGHT HEX CHAR AND R
;
;   OUTPUT 2-4 HEX CHAR + SPACE
OUT4HS   BSR   OUT2H       ; OUTPUT 4 HEX CHAR + SPACE
OUT2HS   BSR   OUT2H       ; OUTPUT 2 HEX CHAR + SPACE
;
;   OUTPUT SPACE
OUTS     LDAA  #$20        ; SPACE
         BRA   OUTCH       ; (BSR & RTS)
;
;   ENTER POWER  ON SEQUENCE
START    LDS   #STACK
         STS   SP          ; INZ TARGET'S STACK PNTR
;
;   ACIA INITIALIZE
         LDAA  #$03        ; RESET CODE
         STAA  ACIACS
         NOP
         NOP
         NOP
         LDAA  #$51        ; 8N1 NON-INTERRUPT
         STAA  ACIACS
;
;   COMMAND CONTROL
CONTRL   LDS   #STACK      ; SET CONTRL STACK POINTER
         LDX   #MCL
         BSR   PDATA1      ; PRINT DATA STRING
         BSR   INCH        ; READ CHARACTER
         TAB
         BSR   OUTS        ; PRINT SPACE
         CMPB  #'L'
         BNE   CHECKM
         JMP   LOAD
CHECKM   CMPB  #'M'
         BEQ   CHANGE
         CMPB  #'R'
         BEQ   PRINT       ; STACK
         CMPB  #'P'
         BEQ   PUNCH       ; PRINT/PUNCH
         CMPB  #'T'
         BNE   CHECKT
         JMP   MEMTST
CHECKT   CMPB  #'t'
         BNE   CHECKG
         JMP   ROMTST
CHECKG   CMPB  #'G'
         BNE   CONTRL
         LDS   SP          ; RESTORE PGM'S STACK PTR
         RTI               ; GO
;
         dc.b  $01,$01     ; GRUE
         dc.b  $01,$01
         dc.b  $01,$01
         dc.b  $01,$01
;
;   ENTER FROM SOFTWARE INTERRUPT
SFE      STS   SP          ; SAVE TARGET'S STACK POINTER
;
;   DECREMENT P-COUNTER
         TSX
         TST   6,X
         BNE   SFE2
         DEC   5,X
SFE2     DEC   6,X
;
;   PRINT CONTENTS OF STACK
PRINT    LDX   SP
         INX
         BSR   OUT2HS      ; CONDITION CODES
         BSR   OUT2HS      ; ACC-B
         BSR   OUT2HS      ; ACC-A
         BSR   OUT4HS      ; X-REG
         BSR   OUT4HS      ; P-COUNTER
         LDX   #SP
         BSR   OUT4HS      ; STACK POINTER
C2       BRA   CONTRL
;
;   PUNCH DUMP
;   PUNCH FROM BEGINING ADDRESS (BEGA) THRU ENDI
;   ADDRESS (ENDA)
MTAPE1   dc.b  $0D,$0A     ; PUNCH FORMAT
         dc.b  'S','1',$04
         dc.b  $01,$01     ; GRUE
         dc.b  $01,$01
PUNCH    LDX   BEGA
         STX   TW          ; TEMP BEGINING ADDRESS
PUN11    LDAA  ENDA+1
         SUBA  TW+1
         LDAB  ENDA
         SBCB  TW
         BNE   PUN22
         CMPA  #16
         BCS   PUN23
PUN22    LDAA  #15
PUN23    ADDA  #4
         STAA  MCONT       ; FRAME COUNT THIS RECORD
         SUBA  #3
         STAA  TEMP        ; BYTE COUNT THIS RECORD
;
;   PUNCH C/R,L/F,NULL,S,1
         LDX   #MTAPE1
         JSR   PDATA1
         CLRB              ; ZERO CHECKSUM
;
;   PUNCH FRAME COUNT
         LDX   #MCONT
         BSR   PUNT2       ; PUNCH 2 HEX CHAR
;
;   PUNCH ADDRESS
         LDX   #TW
         BSR   PUNT2
         BSR   PUNT2
;
;   PUNCH DATA
         LDX   TW
PUN32    BSR   PUNT2       ; PUNCH ONE BYTE (2 FRAMES)
         DEC   TEMP        ; DEC BYTE COUNT
         BNE   PUN32
         STX   TW
         COMB
         PSHB
         TSX
         BSR   PUNT2       ; PUNCH CHECKSUM
         PULB              ; RESTORE STACK
         LDX   TW
         DEX
         CPX   ENDA
         BNE   PUN11
         BRA   C2          ; JMP TO CONTRL
;
;   PUNCH 2 HEX CHAR UPDATE CHECKSUM
PUNT2    ADDB  0,X         ; UPDATE CHECKSUM
         JMP   OUT2H       ; OUTPUT TWO HEX CHAR AND RTS
;
         dc.b  $01,$01     ; GRUE
         dc.b  $01,$01
         dc.b  $01,$01
;
MCL      dc.b  $0D,$0A
         dc.b  '*',$04
         dc.b  $01,$01     ; GRUE
         dc.b  $01,$01
;
;   SAVE X REGISTER
SAV      STX   XTEMP
         RTS
;
         dc.b  $01,$01,$01 ; GRUE
;
;   INPUT ONE CHAR INTO A-REGISTER
INEEE    BSR   SAV
IN1      LDAA  ACIACS
         ASRA
         BCC   IN1         ; RECEIVE NOT READY
         LDAA  ACIADA      ; INPUT CHARACTER
         ANDA  #$7F        ; RESET PARITY BIT
         CMPA  #$7F
         BEQ   IN1         ; IF RUBOUT, GET NEXT CHAR
         BSR   OUTEEE
         RTS
;
         dc.b  $01,$01     ; GRUE
         dc.b  $01,$01
         dc.b  $01,$01
         dc.b  $01,$01
         dc.b  $01,$01
         dc.b  $01,$01
         dc.b  $01,$01
         dc.b  $01,$01
         dc.b  $01         ; GRUE
;
;   OUTPUT ONE CHAR 
OUTEEE   PSHA
OUTEEE1  LDAA  ACIACS
         ASRA
         ASRA
         BCC   OUTEEE1
         PULA
         STAA  ACIADA
         RTS
;
;   VECTOR
         ORG   $FFF8
;
         dc.w  IO
         dc.w  SFE
         dc.w  POWDWN
         dc.w  START

         END    
