;
; MONITOR ROUTINE ADDRESSES
;
OUTCH    EQU      $F075
INCH     EQU      $F078
CONTRL   EQU      $F1BA
;
CR       EQU      $0D
LF       EQU      $0A
BELL     EQU      $07
SPACE    EQU      $20
EOT      EQU      $00

         ORG      $0100
;
         JMP      MEMTST
;
MSTART   ds.b     2
MEND     ds.b     2
STUF     ds.b     2              ; Seed for random function
;
MEMTST   LDS      #$0100         ; Reset stack
         LDX      #STRBEG
         JSR      PDATA
;
         LDX      #MSTART        ; Clear temporary variables
SETCLR   CLR      0,X
         INX
         CPX      #STUF          ; LAST VALUE OF RAM AREA
         BNE      SETCLR
;
         LDX      #$0000         ; Reset random seed
         STX      STUF
;
         LDX      #STRFIL
         JSR      PDATA
         LDX      #PRGEND        ; Fill lower part of free memory
         STX      MSTART
         LDX      #$7F00
         STX      MEND
         JSR      MFILL
;
         LDX      #$0000         ; Reset random seed
         STX      STUF
;
         LDX      #STRCHK
         JSR      PDATA
;
         LDX      #PRGEND        ; Check lower part of free memory
         STX      MSTART
         LDX      #$7F00
         STX      MEND
         JSR      MCHECK
;
         JMP      CONTRL
;
; MFILL - fill memory from MSTART to MEND (inclusive) with random values
;
MFILL    LDX      MSTART
         CLRB
MFILL1   JSR      RANDOM
         STAA     0,X
         INCB
         BNE      MFILL2
         LDAA     #'.'           ; Every 256 bytes write a '.'
         JSR      OUTCH
MFILL2   CMPX     MEND
         BEQ      MFILL3
         INX
         BRA      MFILL1
MFILL3   RTS
;
; MCHECK - check memory from MSTART to MEND (inclusive) against random values
;
MCHECK   LDX      MSTART
         CLRB
MCHECK1  JSR      RANDOM
         CMPA     0,X
         BNE      MCHECKE
         INCB
         BNE      MCHECK2
         LDAA     #'.'           ; Every 256 bytes write a '.'
         JSR      OUTCH
MCHECK2  CMPX     MEND
         BEQ      MCHECK3
         INX
         BRA      MCHECK1
MCHECK3  STX      STUF
         LDX      #STROK
         JSR      PDATA
         LDX      #STUF
         JSR      OUT4H
         JSR      PCRLF
         RTS
;
MCHECKE  STX      STUF
         LDX      #STRERR
         JSR      PDATA
         LDX      #STUF
         JSR      OUT4H
         JSR      PCRLF
         RTS
;
; String output on start up
STRBEG   dc.b     CR,LF
         dc.b     "MECB 6800/6802 Memory check in progress"
         dc.b     CR, LF, EOT
;
STRFIL   dc.b     "Filling memory with random data:"
         dc.b     CR,LF,EOT
;
STRCHK   dc.b     CR,LF
         dc.b     "Checking memory:"
         dc.b     CR,LF,EOT
;
; String output if memory check successful
STROK    dc.b     CR,LF
         dc.b     "Memory check successful. Valid up to $"
         dc.b     EOT
; String output if memory check failed
STRERR   dc.b     CR,LF,BELL
         dc.b     "Memory check failed. Error at $"
         dc.b     EOT
;
;
; Print a null-terminated string
PDATA    PSHA
PDATA1   LDAA     0,X
         BEQ      PDATA2
         JSR      OUTCH
         INX
         BRA      PDATA1
PDATA2   PULA
         RTS
;
; Print CRLF
PCRLF    LDAA     #CR
         JSR      OUTCH
         LDAA     #LF
         JMP      OUTCH
;
; Write four digit hex value pointed to by X
OUT4H    PSHA              ; Save A
         BSR      OUT2H    ; Output
         INX
         BSR      OUT2H    ; Output
         PULA              ; Resetore A
         DEX               ; Restore X
         RTS
;
; Write two digit hex value pointed to by X
OUT2H    LDAA     0,X      ; OUTPUT 2 HEX CHAR
         BSR      OUT2HA
         RTS
;
; Write two-digit hex value in A
OUT2HA   PSHA
         BSR      OUTHL    ; OUT LEFT HEX CHAR
         PULA              ; PICK UP BYTE AGAIN
         PSHA
         BSR      OUTHR    ; OUTPUT RIGHT HEX CHAR AND RTS
         PULA
         RTS
;
OUTHL    LSRA              ; OUT HEX LEFT BCD DIGIT
         LSRA
         LSRA
         LSRA
OUTHR    ANDA     #$F      ; OUT HEX RIGHT BCD DIGIT
         ADDA     #$30
         CMPA     #$39
         BLS      OUTHR2
         ADDA     #$7
OUTHR2   JMP      OUTCH
         
;
;
; LIB RANDOM
RANDOM	PSHB              ; RANDOM NUMBER GENERATOR - SAVE B
         LDAA     STUF+1   ; COMPUTE (STUF * 2 * * 9) MOD 2 ** 16
         CLC
         ROLA
         CLC
         ROLA
         ADDA     STUF     ; ADD STUFF TO RESULT
         LDAB     STUF+1
         CLC               ; MULTIPLY BY 2 ** 2
         ROLB
         ROLA
         CLC
         ROLB
         ROLA
         CLC
         ADDB     STUF+1   ; ADD STUFF TO RESULT
         ADCA     STUF
         CLC
         ADDB     #$19     ; ADD HEXADECIMAL 3619 TO THE RESULT
         ADDA     #$36
         STAA     STUF     ; STORE RESULT IN STUF
         STAB     STUF+1
         PULB              ; RESTORE B
         RTS
;
PRGEND   EQU      *
;
         END