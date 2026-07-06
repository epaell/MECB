; NAM STAR TREK
;****************************
; STAR TREK GAME 1.2
; BY UNKNOWN SOURCE
; RECOVERED FROM OLD FLOPPIES
;
; ADOPTED TO RUN ON THE MECB 6800
; BY DANIEL TUFVESSON 2014
;****************************
         include "mecb.inc"
         include "digibug.inc"
;
; MONITOR ROUTINE ADDRESSES
;
;OUTCH    EQU   $F075
;INCH     EQU   $F078
;CONTRL   EQU   $F1BA
;
;CR       EQU   $0D
;LF       EQU   $0A
;EOT      EQU   $04
BELL     EQU   $07
APOS     EQU   $27
;
; PROGRAM ENTRY
;
         ORG   $0100
         JMP   STRTRK
;
; STORAGE AREAS
;
STPSFL   rmb  1
BASEX    rmb  1
BASEY    rmb  1
BASESX   rmb  1
BASESY   rmb  1
GLMFLG   rmb  1
SECKLN   rmb  1
FLAGC    rmb  1
TIMDEC   rmb  1
STCFLG   rmb  1
SQFLG    rmb  1
PNTFLG   rmb  1
COURSE   rmb  1
WARP     rmb  1
FINCX    rmb  1
FINCY    rmb  1
COUNT    rmb  1
TEMP1    rmb  2
TEMP2    rmb  2
XTEMP1   rmb  2
TIME0    rmb  2
GAMTIM   rmb  1
TIMUSE   rmb  2
SHENGY   rmb  2
KLNENG   rmb  2
PHSENG   rmb  2
TOPFLG   rmb  1
BOTFLG   rmb  1
LSDFLG   rmb  1
RSDFLG   rmb  1
PHOTON   rmb  1
CURQUX   rmb  1
CURQUY   rmb  1
CURSCX   rmb  1
CURSCY   rmb  1
TRIALX   rmb  1
TRIALY   rmb  1
FLAG     rmb  1
CNDFLG   rmb  1
SCANX    rmb  1
SCANY    rmb  1
COUNT1   rmb  1
SECINF   rmb  1
MASK     rmb  1
KLNGCT   rmb  1
LENGTH   rmb  1
ASAVE    rmb  1
SHIELD   rmb  1
ENERGY   rmb  2
TSAVE1   rmb  1
HITKLS   rmb  1
HITSTR   rmb  1
HITBAS   rmb  1
TEMP3    rmb  2
GALCNT   rmb  1
DAMENG   rmb  1
DAMSRS   rmb  1
DAMLRS   rmb  1
DAMPHS   rmb  1
DAMPHT   rmb  1
DAMSHL   rmb  1
DAMTEL   rmb  1
DAMTRB   rmb  1
DAMCOM   rmb  1
PCOUNT   rmb  1 ; TORP SPREAD COUNT
PTZFLG   rmb  1 ; NO MORE TORP FLAG
GAMEND   rmb  1
AUTOSR   rmb  1
AUTOLR   rmb  1
SUPFLG   rmb  1
TELFLG   rmb  1
ATKENG   rmb  2
QUDPTR   rmb  2 ; POINTS TO CURR LOC IN QUDMAP
PASWRD   rmb  3
PHTFLG   rmb  1
SHUTCR   rmb  1
SHUTLX   rmb  1
SHUTLY   rmb  1
QUDMAP   rmb  64
COMMAP   rmb  64 ; MUST FOLLOW QUDMAP IMMEDIATELY
SECMAP   rmb  16 ; PACKED SECTOR (64*2 BITS) 00=., 01=*, 10=K, 11=B
STUF     rmb  4 ; SEED FOR RANDOM FUNCTION

;
; TABLE OF MOVE VECTORS
;
MOVTBL   fcb   $00,$FF,$01,$FF,$01,$00,$01,$01       ; FF=-1
         fcb   $00,$01,$FF,$01,$FF,$00,$FF,$FF
;
; CHARACTER PRINT TABLE
;
CHRTBL   fcb   ".*KBN"
;
; COMMAND CODE TABLE
;
CMDTBL   fcb   "ENSRLRPHPTDRSHTPSDTBCO"
;
; COMMAND JUMP TABLE
;
JMPTBL   fdb  SETCRS
         fdb  SRSCAN
         fdb  LRSCAN
         fdb  PHASOR
         fdb  PHOTOR
         fdb  DAMRPT
         fdb  SHLDS
         fdb  TELEPT
         fdb  SELFDE
         fdb  TRCTBM
         fdb  COMPTR
;
PDATA    JSR   OUTCH
         INX
PDATA3   LDAA  0,X
         BNE   PDATA
         RTS
;
PCRLF    LDAA  #$0D
         JSR   OUTCH
         LDAA  #$0A
         JMP   OUTCH
;
PSTRNG   BSR   PCRLF
         BRA   PDATA3
;
OUTHLST  PSHA
         LSRA
         LSRA
         LSRA
         LSRA
         BSR   OUTHRST
         PULA
         RTS
;
OUTHRST  PSHA
         ANDA  #$0F
         ORAA  #$30
         CMPA  #$39
         BLS   OUTDIG
         ADDA  #7
OUTDIG   JSR   OUTCH
         PULA
         RTS
;
OUTSST   PSHA
         LDAA  #$20
         BRA   OUTDIG
;
; LIB RANDOM
RANDOM	PSHB                 ; RANDOM NUMBER GENERATOR - SAVE B
         LDAA  STUF+1         ; COMPUTE (STUF * 2 * * 9) MOD 2 ** 16
         CLC
         ROLA
         CLC
         ROLA
         ADDA  STUF           ; ADD STUFF TO RESULT
         LDAB  STUF+1
         CLC                  ; MULTIPLY BY 2 ** 2
         ROLB
         ROLA
         CLC
         ROLB
         ROLA
         CLC
         ADDB  STUF+1         ; ADD STUFF TO RESULT
         ADCA  STUF
         CLC
         ADDB  #$19           ; ADD HEXADECIMAL 3619 TO THE RESULT
         ADDA  #$36
         STAA  STUF           ; STORE RESULT IN STUF
         STAB  STUF+1
         PULB                 ; RESTORE B
         RTS
;
; PRINT TITLE
;
STRTRK   LDX   #TITLE
         JSR   PSTRNG
;
; CLEAR ALL TEMP STORAGE
;
         LDX   #STPSFL
SETCLR   CLR   0,X
         INX
         CPX   #STUF          ; LAST VALUE OF RAM AREA
         BNE   SETCLR
         LDAA  #$FF
         LDX   #COMMAP
CLRMAP   STAA  0,X
         INX
         CPX   #COMMAP+64
         BNE   CLRMAP
         LDX   #SHTLNG
         JSR   PSTRNG
         JSR   INCH
         CMPA  #'S'
         BEQ   SETQD
         INC   LENGTH         ; SET LONG FLAG
;
; SETUP SPACE
;
SETQD    LDX   #QUDMAP
         LDAB  #64
SETUP0   JSR   RANDOM
         CMPA  #$FC
         BLS   SETUP1
         LDAA  #4
         BRA   SETUP5
SETUP1   CMPA  #$F7
         BLS   SETUP2
         LDAA  #3
         BRA   SETUP5
SETUP2   CMPA  #$E0
         BLS   SETUP3
         LDAA  #2
         BRA   SETUP5
SETUP3   CMPA  #$A0
         BLS   SETUP4
         LDAA  #1
         BRA   SETUP5
SETUP4   CLRA
SETUP5   CLR   ASAVE
         TST   LENGTH
         BEQ   SETUP8
         STAA  ASAVE
         JSR   RANDOM
         CMPA  #$F0
         BLS   SETUP6
         LDAA  #3
         BRA   SETUP8
SETUP6   CMPA  #$C0
         BLS   SETUP7
         LDAA  #2
         BRA   SETUP8
SETUP7   CLRA
SETUP8   ADDA  ASAVE
         STAA  0,X            ; STORE SECT KLNGON CNT
         ADDA  KLNGCT
         STAA  KLNGCT
STARS    JSR   RANDOM
         ANDA  #$38
         ORAA  0,X
         STAA  0,X
CONT     INX
         DECB
         BEQ   CONT1
         JMP   SETUP0
;
; GET STARBASE LOCATION
;
CONT1    JSR   RANDOM
         ANDA  #$7
         TAB
         JSR   RANDOM
         ANDA  #$7
         STAA  BASEX
         STAB  BASEY
         INC   STPSFL
         LDX   #QUDMAP
         JSR   STPSEX
         LDAA  #$40
         ORAA  0,X
         STAA  0,X
CONT2    BSR   REFUEL
         JSR   RANDOM
         ADDA  #0
         DAA
         STAA  TIME0+1
         JSR   RANDOM
         ANDA  #$7F
         ORAA  #$23
         ADDA  #0
         DAA
         STAA  TIME0
         BSR   MAKTIM
         TST   LENGTH
         BEQ   GATM
         TAB
         BSR   MAKTIM
         ABA
         DAA
GATM     STAA  GAMTIM
         JSR   RANDOM         ; SET SHUTTLECRAFT LOCATION
         ANDA  #$7
         STAA  SHUTLX
         JSR   RANDOM
         ANDA  #$7
         STAA  SHUTLY
         BRA   CONT3
;
; REFUEL THE ENTERPRISE
;
REFUEL   CLR   SHIELD
         LDAA  #$30
         STAA  ENERGY
         CLR   ENERGY+1
         STAA  SHENGY
         CLR   SHENGY+1
         LDAA  #15
         STAA  PHOTON
         LDX   #DAMENG ; FIX ALL DAMAGE
REFUL1   CLR   0,X
         INX
         CPX   #DAMENG+9
         BNE   REFUL1
         RTS
;
; CALCULATE GAME TIME
;
MAKTIM   JSR   RANDOM
         ANDA  #$0F
         ORAA  #$31
         ADDA  #0
         DAA
         RTS
;
; CONTINUE SETUP
;
CONT3    JSR   RANDOM
         ANDA  #7
         STAA  CURQUX
         JSR   RANDOM
         ANDA  #7
         STAA  CURQUY
         JSR   SETUPS
         LDX   #BASINF
         JSR   PSTRNG
         LDAA  BASEX
         BSR   FIXOUT
         JSR   OUTDSH
         LDAA  BASEY
         BSR   FIXOUT
         LDX   #INTRO0
         JSR   PSTRNG
         LDX   #PASWRD
         LDAB  #3
CONT4    JSR   INCH
         STAA  0,X
         INX
         DECB
         BNE   CONT4
         LDX   #INTRO1
         JSR   PSTRNG
         BSR   OUTDAT
         LDX   #INTRO2
         JSR   PSTRNG
         BSR   OUTKLN
         LDX   #INTRO3
         JSR   PSTRNG
         CLR   TEMP1
         LDAA  GAMTIM
         STAA  TEMP1+1
         JSR   OUTBCD
         LDX   #INTRO4
         JSR   PSTRNG
         BSR   OUTQUD
         LDX   #INTRO6
         JSR   PSTRNG
         BSR   OUTSEC
         JMP   COMAND
;
; OUTPUT A NUMBER
;
FIXOUT   ADDA  #$31
         JSR   OUTCH
         RTS
;
; OUTPUT STARDATE
;
OUTDAT   LDX   TIME0
         STX   TEMP1
         JSR   OUTBCD
         LDAA  #'.'
         JSR   OUTCH
         LDAA  TIMDEC
         JSR   OUTHRST
         RTS
;
; OUTPUT A KLINGON COUNT
;
OUTKLN   LDAA  KLNGCT
OUTK0    CLR   TEMP1
OUTK1    CLR   TEMP1+1
         LDAB  #10
OUTK2    SBA
         BCS   OUTK3
         INC   TEMP1+1
         CMPB  TEMP1+1
         BNE   OUTK2
         INC   TEMP1
         BRA   OUTK1
OUTK3    ABA
         LDAB  TEMP1+1
         ASLB
         ASLB
         ASLB
         ASLB
         ABA
         STAA  TEMP1+1
         JSR   OUTBCD
         RTS
;
; OUTPUT QUADRANT LOCATION
;
OUTQUD   LDAA  CURQUY
         BSR   FIXOUT
         BSR   OUTDSH
         LDAA  CURQUX
         BSR   FIXOUT
         RTS
;
; OUTPUT A SECTOR
;
OUTSEC   LDAA  CURSCY
         BSR   FIXOUT
         BSR   OUTDSH
         LDAA  CURSCX
         BSR   FIXOUT
         RTS
;
; OUTPUT A DASH
;
OUTDSH   LDAA  #'-'
         JSR   OUTCH
         RTS
;
; ADD THE A-REG TO THE INDEX REGISTER
;
FIXXRG   STX   TEMP1
         ADDA  TEMP1+1
         STAA  TEMP1+1
         LDX   TEMP1
         RTS
;
; GET COMMAND AND PERFORM IT
;
COMAND   LDAA  GAMTIM
         CMPA  TIMUSE+1
         BHI   NOEXTC
         JMP   NOMTIM
NOEXTC   TST   KLNGCT
         BNE   NOEXT2
         JMP   NOMKLN
NOEXT2   TST   SUPFLG
         BEQ   NOEXT4
         LDX   #SUPDES
         JSR   PSTRNG
         JSR   SELFDA
         JMP   ENDGAM
;
NOEXT4   JSR   CLRCQU         ; CLEAR K & S
         LDAA  #2
         CMPA  CNDFLG         ; DOCKED?
         BEQ   CMND27
         CLR   CNDFLG
         TST   SECKLN         ; RED?
         BEQ   CMNDAC
         DECA
         STAA  CNDFLG
CMNDAC   JSR   RANDOM
         CMPA  #$FC           ; SPACE STORM
         BLS   COMND2
         LDX   #SPSTRM
         JSR   PSTRNG
         LDAA  #2
         STAA  DAMSHL
         JSR   SHLDWN
;
COMND2   JSR   RANDOM
         CMPA  #$FC           ; SUPERNOVA?
         BLS   CMND25
         JSR   SUPNOV
CMND25   JSR   ATTACK         ; ALLOW ATTACK
         TST   ENERGY
         BPL   COMND0
         JMP   NRGOUT
;
COMND0   TST   SHUTCR
         BNE   CMND01
         LDAA  SHUTLX
         CMPA  CURQUX
         BNE   CMND01
         LDAA  SHUTLY
         CMPA  CURQUY
         BNE   CMND01
         LDX   #SHTSIG
         JSR   PSTRNG
CMND01   LDAA  #3
         CMPA  ENERGY
         BLS   CMNDAD
         STAA  CNDFLG
CMNDAD   TST   SHENGY
         BPL   CMND27
         CLRA
         STAA  SHIELD
         STAA  SHENGY
         STAA  SHENGY+1
CMND27   LDX   #COMST         ; PRINT COMMAND PROMPT
         JSR   PSTRNG
         CLR   STCFLG
         CLR   PHTFLG
COMND3   JSR   INCH
         CMPA  #CR
         BEQ   ILCMND
         TAB
         JSR   INCH
         LDX   #CMDTBL
CHKCM1   CMPB  0,X
         BNE   INX2
         CMPA  1,X
         BEQ   GOTCMD
INX2     INX
         INX
         CPX   #CMDTBL+22
         BNE   CHKCM1
ILCMND   LDX   #EXPCMD
         JSR   PSTRNG
         BRA   COMND3
;
GOTCMD   LDAA  #22            ; STEP FORWARD 22 BYTES TO ROUTINE ADDRESS
GCMD1    INX
         DECA
         BNE   GCMD1
         LDX   0,X
         JSR   0,X
         TST   GAMEND
         BEQ   CMND99
         JMP   ENDGAM
CMND99   JMP   COMAND
;
; OUTPUT A 4 DIGIT BCD NUMBER
;
OUTBCD   CLR   FLAG
         LDAA  TEMP1
         BEQ   OUTBC2
         ANDA  #$F0
         BEQ   OUTBC1
         LDAA  TEMP1
         JSR   OUTHLST
OUTBC1   LDAA  TEMP1
         ANDA  #$0F
         JSR   OUTHRST
         INC   FLAG
OUTBC2   LDAA  TEMP1+1
         TST   FLAG
         BNE   NOZERO
         ANDA  #$F0
         BEQ   OUTBC3
NOZERO   JSR   OUTHLST
OUTBC3   LDAA  TEMP1+1
         ANDA  #$0F
         JSR   OUTHRST
         RTS
;
; LOWER THE SHIELDS
;
SHLDS    TST   SHIELD
         BEQ   SHLDUP
SHLDWN   CLR   SHIELD
         LDX   #DWNST
SHLD0    JSR   PSTRNG
SHLD1    RTS
;
; RAISE THE SHIELDS
;
SHLDUP   LDAA  SHENGY
         CMPA  #1
         BLS   SHLD1
         TST   DAMSHL
         BNE   SHLDWN
         INC   SHIELD
         LDX   #SHENGY
         LDAA  #2
         STAA  TEMP1
         CLR   TEMP1+1
         JSR   BCDSUB
         LDX   #UPSTR
         BRA   SHLD0
;
; SHORT RANGE SCAN
;
SRSCAN   TST   DAMSRS
         BEQ   SSCAN1
         TST   SHUTCR
         BNE   SSCAN0
         JSR   RPTDAM
         RTS
SSCAN0   LDX   #SCBKUP
         JSR   PSTRNG
SSCAN1   JSR   PCRLF
         CLR   SCANY
         LDAA  CNDFLG
         CMPA  #2
         BNE   SSCAN2
         JSR   REFUEL
SSCAN2   LDX   #SECMAP
         STX   TEMP2
         JSR   DOSCAN
         LDX   #SDATE
         JSR   PDATA3
         JSR   OUTDAT
         JSR   DOSCAN
         LDX   #CNDTNS
         JSR   PDATA3
         LDAA  CNDFLG
         BEQ   SRSCN1
         CMPA  #1
         BEQ   SRSCN0
         CMPA  #3
         BEQ   OUTCN1
         LDX   #DOCKED
         BRA   OUTCND
OUTCN1   LDX   #YELLOW
OUTCND   JSR   PDATA3
         BRA   SRSCN2
;
SRSCN0   LDX   #RED
         BRA   OUTCND
;
SRSCN1   LDX   #GREEN
         BRA   OUTCND
;
SRSCN2   BSR   DOSCAN
         LDX   #QUADP
         JSR   PDATA3
         JSR   OUTQUD
         BSR   DOSCAN
         LDX   #SECP
         JSR   PDATA3
         JSR   OUTSEC
         BSR   DOSCAN
         LDX   #ENGSTR
         JSR   PDATA3
         LDX   ENERGY
         STX   TEMP1
         JSR   OUTBCD
         BSR   DOSCAN
         LDX   #KLSTR
         JSR   PDATA3
         JSR   OUTKLN
         BSR   DOSCAN
         LDX   #SHSTR
         JSR   PDATA3
         LDX   SHENGY
         STX   TEMP1
         JSR   OUTBCD
         TST   SHIELD
         BEQ   SRSCN4
         LDX   #UPSCAS
         BRA   SRSCN5
;
SRSCN4   LDX   #DNSCAS
SRSCN5   JSR   PDATA3
         BSR   DOSCAN
         LDX   #TRPSTR
         JSR   PDATA3
         CLR   TEMP1
         LDAA  PHOTON
         ADDA  #0
         DAA
         STAA  TEMP1+1
         JSR   OUTBCD
         LDX   QUDPTR      ; UPDATE COMPUTER MAP
         LDAA  0,X
         JSR   UPDCMP
         RTS
;
; OUTPUT 1 SHORT RANGE SCAN LINE
;
DOSCAN   JSR   PCRLF
         LDAA  #2
         STAA  COUNT
         CLR   SCANX
DOSCN    LDAA  #4
         STAA  COUNT1
         LDX   TEMP2
         LDAA  0,X
DOSCN0   STAA  ASAVE
         LDAA  CURSCY
         CMPA  SCANY       ; IS IT Y-LOC OF ENTERPRISE?
         BNE   CHK0
         LDAA  CURSCX
         CMPA  SCANX
         BNE   CHK0
         LDAA  #'E'
         JSR   OUTCH
         BRA   GOAHD
CHK0     LDAA  ASAVE
DOSCN1   LDX   #CHRTBL
         ANDA  #3
         JSR   FIXXRG
         LDAA  0,X
         JSR   OUTCH
GOAHD    JSR   OUTSST
         LDX   TEMP2
         INC   SCANX
         DEC   COUNT1
         BEQ   DOSCN2
         LDAA  ASAVE
         LSRA
         LSRA
         BRA   DOSCN0
DOSCN2   INX
         STX   TEMP2
         LDAA  0,X
         DEC   COUNT
         BNE   DOSCN
         INC   SCANY
         RTS
;
; SETUP SECTOR MAP
;
SETUPS   CLR   SECKLN
         LDX   #SECMAP
         LDAB  #16
         CLRA
SETPS1   STAA  0,X
         INX
         DECB
         BNE   SETPS1
         LDX   #QUDMAP
         LDAA  CURQUX
         LDAB  CURQUY
STPSEX   STAA  ASAVE
         TSTB
         BEQ   SETPS4
SETPS2   LDAA  #8
SETPS3   INX
         DECA
         BNE   SETPS3
         DECB
         BNE   SETPS2
SETPS4   LDAA  ASAVE
         BEQ   SETPS6
SETPS5   INX
         DECA
         BNE   SETPS5
SETPS6   TST   STPSFL
         BEQ   STPSNX
         CLR   STPSFL
         RTS
;
STPSNX   STX   QUDPTR
         LDAB  0,X
         STAB  SECINF
         BEQ   SETP10
         ANDB  #7
         BEQ   SETPS7
         STAB  COUNT
         STAB  SECKLN
         LDAA  #2
         STAA  MASK
         BSR   PUTINM
SETPS7   LDAB  SECINF
         ANDB  #$38
         BEQ   SETPS8
         LSRB
         LSRB
         LSRB
         STAB  COUNT
         LDAA  #1
         STAA  MASK
         BSR   PUTINM
SETPS8   LDAB  SECINF
         BITB  #$40
         BEQ   SETPS9
         LDAA  #1
         STAA  COUNT
         LDAA  #3
         STAA  MASK
         BSR   PUTINM
SETPS9   LDAB  SECINF
         BPL   SETP10
         INC   SUPFLG
SETP10   JSR   RANDOM
         ANDA  #7
         STAA  TRIALX
         JSR   RANDOM
         ANDA  #7
         STAA  TRIALY
         JSR   CHKPOS
         TST   FLAG
         BNE   SETP10
         LDAA  TRIALX
         STAA  CURSCX
         LDAA  TRIALY
         STAA  CURSCY
;
; COMPUTE LOCAL KLINGON ENERGY
;
CSCKEN   LDAB  SECKLN
         ASLB
         LDX   #KLNENG
CSCEXT   CLR   0,X
         CLR   1,X
CSCKN1   JSR   RANDOM
         ADDA  #0
         DAA
         CLR   TEMP1
         STAA  TEMP1+1
         JSR   BCDADD
         DECB
         BNE   CSCKN1
         RTS
;
; PUT OBJECTS IN SECTOR MAP
;
PUTINM   LDX   #SECMAP
         JSR   RANDOM
         ANDA  #$F
         STAA  TSAVE1
         JSR   FIXXRG
         LDAB  0,X
         JSR   RANDOM
         ANDA  #3
         STAA  ASAVE
         BEQ   PUTIN2
PUTIN1   RORB
         RORB
         DECA
         BNE   PUTIN1
PUTIN2   BITB  #3
         BNE   PUTINM
         ORAB  MASK
         LDAA  ASAVE
         BEQ   PUTIN4
PUTIN3   ROLB
         ROLB
         DECA
         BNE   PUTIN3
PUTIN4   STAB  0,X
         DEC   COUNT
         BNE   PUTINM
         LDAA  MASK
         CMPA  #3
         BNE   PUTIN6
         LDAB  TSAVE1
         CLC
         RORB
         LDAA  ASAVE
         BCC   PUTIN5
         ADDA  #4
PUTIN5   STAA  BASESX
         STAB  BASESY
PUTIN6   RTS
;
; CHECK FOR EMPTY POSITIONS
;
CHKPOS   CLR   FLAG
         STX   XTEMP1
         LDX   #SECMAP
         LDAA  TRIALY
         BEQ   CHKPO2
CHKPO1   INX
         INX
         DECA
         BNE   CHKPO1
CHKPO2   LDAA  TRIALX
         CMPA  #3
         BLS   CHKPO3
         INX
         SUBA  #4
CHKPO3   LDAB  0,X
         STAA  ASAVE
         BEQ   CHKPO5
CHKPO4   LSRB
         LSRB
         DECA
         BNE   CHKPO4
CHKPO5   ANDB  #3
         BEQ   CHKPO6
         STAB  FLAG
         TST   STCFLG
         BEQ   CHKPO6
         TST   PHTFLG
         BNE   CHKPO7
         CMPB  #2
         BEQ   CHKPO7
CHKPO6   LDX   XTEMP1
         RTS
;
CHKPO7   LDAB  #$FC
         LDAA  ASAVE
         BEQ   CHKPO9
         SEC
CHKPO8   ROLB
         ROLB
         DECA
         BNE   CHKPO8
CHKPO9   ANDB  0,X
         STAB  0,X
         BRA   CHKPO6
;
; FIRE PHOTON TORPEDO
;
PHOTOR   TST   DAMPHT
         BEQ   PTRNDM
PTRND9   JSR   RPTDAM
         RTS
PTRNDM   TST   PHOTON      ; ANY LEFT
         BNE   PHOTRO
PTEMPT   LDX   #PTEMST
         JSR   PSTRNG
         INC   PTZFLG
         RTS
;
PHOTRO   INC   PHTFLG
         JSR   RANDOM
         ANDA  #$F
         ORAA  #4
         STAA  WARP
         DEC   PHOTON
;
; WARP ENGINES AND PHOTON TORP COURSE
;
SETCRS   CLR   SQFLG
         CLR   GLMFLG
         LDX   #CRSSTR
         JSR   PSTRNG
         JSR   INCHCK
         CMPA  #7
         BHI   ABC29
         JSR   OUTSST
         JSR   OUTSST
         STAA  COURSE
         TST   PHTFLG
         BNE   PHTOR1
         LDX   #WRPSTR
         JSR   PSTRNG
         JSR   INCHCK
         STAA  WARP
         TST   PNTFLG
         BNE   STCRS2
         STAA  SQFLG
         TST   DAMENG
         BNE   PTRND9
;
STCRS2   JSR   INCH
         CMPA  #CR
         BNE   STCRS2
         LDAA  COURSE
PHTOR1   LDX   #MOVTBL
         ASLA
         JSR   FIXXRG
         LDAA  WARP
         BNE   ABC30
ABC29    RTS
;
ABC30    STAA  COUNT
         TST   SQFLG
         BEQ   STCRS3
         LDAA  #$0F
         STAA  COUNT
STCRS3   LDAA  CURSCX
         LDAB  CURSCY
PHTOR2   ADDA  0,X
         ADDB  1,X
         JSR   TSTBND
         TST   FINCX
         BEQ   ABC1
         JMP   STCRS5
;
ABC1     TST   FINCY
         BEQ   ABC5
         JMP   STCRS5
;
ABC5     STAA  TRIALX      ; SAVE TRIAL POSITION
         STAB  TRIALY
         TST   PHTFLG
         BEQ   ABC4
         JSR   OUTSST
         BSR   OBATSO
ABC4     INC   STCFLG
         JSR   CHKPOS      ; CHK IF BLKD
         LDAA  FLAG
         BEQ   STCRS4
         TST   PHTFLG
         BEQ   ABC2
         JMP   PHTOR3
;
ABC2     CMPA  #2
         BNE   ABC3
         JMP   KLGRAM
;
ABC3     LDX   #BLOKST
         JSR   PSTRNG
OBATSO   LDAA  TRIALY
         JSR   FIXOUT
         JSR   OUTDSH
         LDAA  TRIALX
         JSR   FIXOUT
         TST   PHTFLG
         BEQ   STCRET
         RTS
;
STCRET   JMP   STCRS6
;
STCRS4   TST   PHTFLG
         BEQ   STCRSB      ; JUMP IF NOT
         LDAA  TRIALX
         LDAB  TRIALY
         DEC   COUNT
         BNE   PHTOR2
PHTOR4   LDX   #PNOENG
         JSR   PSTRNG
         JMP   STCRS6
;
STCRSB   LDAA  TRIALX
         STAA  CURSCX
         LDAA  TRIALY
         STAA  CURSCY
         JSR   RANDOM
         CMPA  #$80
         BLS   STCRSC
         LDAA  #1
         JSR   FIXTIM
         LDAA  #3
         JSR   FIXENG
STCRSC   DEC   COUNT       ; DEC MOVE CNTR
         BEQ   STCRSD
         JMP   STCRS3
;
STCRSD   TST   SQFLG
         BNE   STCRS5      ; QUADRANT MOVE!
         JMP   STCRS6
;
STCRS5   TST   PHTFLG
         BEQ   ABC6
         JMP   PHTOR4
ABC6     LDAA  WARP
         STAA  COUNT
ABC7     LDAA  CURQUX
         LDAB  CURQUY
         TST   SQFLG
         BEQ   STCRS7
         ADDA  0,X
         ADDB  1,X
         STAA  TRIALX
         STAB  TRIALY
         JSR   TSTBND
         TST   FINCX
         BEQ   ABCD0
         JMP   GALBND
;
ABCD0    TST   FINCY
         BEQ   ABCD1
         JMP   GALBND
;
ABCD1    LDAA  TRIALX
         STAA  CURQUX
         LDAA  TRIALY
         STAA  CURQUY
         INC   GLMFLG
         LDAA  #6
         JSR   FIXTIM
         LDAA  #$30
         JSR   FIXENG
         DEC   COUNT
         BNE   ABC7
STCRSA   JSR   SETUPS
STCRS6   CLR   CNDFLG
         LDAA  BASEX
         CMPA  CURQUX
         BNE   SEXIT1
         LDAB  BASEY
         CMPB  CURQUY
         BNE   SEXIT1
         LDAA  BASESX
         LDAB  BASESY      ; DOCKED?
         INCA
         SUBA  CURSCX
         CMPA  #2
         BHI   SEXIT1
SEXIT0   INCB
         SUBB  CURSCY
         CMPB  #2
         BHI   SEXIT1
SDOCK    LDAA  #2
         STAA  CNDFLG
SEXIT1   TST   AUTOSR
         BEQ   SEXIT2
         JSR   SRSCAN
SEXIT2   TST   AUTOLR
         BEQ   SEXIT3
         JSR   LRSCAN
SEXIT3   RTS
;
STCRS7   ADDA  FINCX
         ADDB  FINCY
         CMPA  #7
         BHI   GALBND
         CMPB  #7
         BHI   GALBND
         STAA  CURQUX
         STAB  CURQUY
         LDAA  #7
         JSR   FIXTIM
         BRA   STCRSA
;
; RAMMED A KLINGON ROUTINE
;
KLGRAM   LDX   #KRMSTR
         JSR   PSTRNG
         LDAA  #1
         STAA  COUNT
         CLR   SQFLG
         INC   HITKLS
         DEC   KLNGCT      ; DEC KLINGON COUNT
         DEC   SECKLN
         INC   PHTFLG
         JSR   OBATSO
         LDX   #HEVDAM
         JSR   PSTRNG
         LDAB  #$6A
         JSR   MANDAM
         LDX   #STILFT
         JSR   PSTRNG
         JSR   OUTKLN
         JMP   STCRSB
;
; PRINT GALAXY LIMIT MESSAGE
;
GALBND   LDX   #GLBNDS
         JSR   PSTRNG
         LDAA  GALCNT
         INCA
         CMPA  #3
         BNE   GALBN2
         LDX   #GALDUM
         JSR   PSTRNG
         INC   GAMEND
         RTS
;
GALBN2   STAA  GALCNT
         TST   GLMFLG
         BNE   ABC20
         JMP   STCRS6
;
ABC20    JMP   STCRSA
;
; TORPEDO HAS HIT SOMETHING
;
PHTOR3   LDX   #PHITST
         JSR   PSTRNG
         LDAA  FLAG
         CMPA  #2          ; KLINGON?
         BNE   ABC8
         DEC   SECKLN
         DEC   KLNGCT
         INC   HITKLS
         LDX   #KLGSTR
         JSR   PDATA3
         LDX   #STILFT
         JSR   PSTRNG
         JSR   OUTKLN
         BRA   ABC10
;
ABC8     CMPA  #1          ; STAR?
         BNE   ABC11
         INC   HITSTR
         LDX   #STARST
ABC9     JSR   PDATA3
ABC10    RTS
;
ABC11    LDX   #BASEST     ; HIT BASE!
         INC   HITBAS
         BRA   ABC9
;
; SEE IF GALAXY EDGE REACHED
;
TSTBND   CLR   FINCX
         CLR   FINCY
         TSTA
         BPL   TSTBN1
         DEC   FINCX
         BRA   TSTBN2
;
TSTBN1   CMPA  #7
         BLS   TSTBN2
         INC   FINCX
TSTBN2   TSTB
         BPL   TSTBN3
         DEC   FINCY
         RTS
;
TSTBN3   CMPB  #7
         BLS   TSTBN4
         INC   FINCY
TSTBN4   RTS
;
; INPUT CHARACTER AND CHECK
;
INCHCK   CLRA
INCHK0   STAA  PNTFLG
         JSR   INCH
         CMPA  #'.'
         BEQ   INCHK0
         CMPA  #'9'
         BHI   INCHK1
         CMPA  #'0'-1
         BLS   INCHK1
         SUBA  #$30
         RTS
;
INCHK1   LDX   #ERR
         JSR   PDATA3
         BRA   INCHCK
;
; ADD TO GAME TIME
;
FIXTIM   ADDA  TIMDEC
         CMPA  #9
         BLS   FIXTM1
         SUBA  #10
         STAA  TIMDEC
         CLR   TEMP1
         LDAA  #1
         STAA  TEMP1+1
         STX   XTEMP1
         LDX   #TIME0
         JSR   BCDADD
         LDX   #TIMUSE
         JSR   BCDADD
         JSR   FIXDAM
         LDX   XTEMP1
         RTS
;
FIXTM1   STAA  TIMDEC
         RTS
;
;SUBTRACT FROM ENERGY AMOUNT
;
FIXENG   STX   XTEMP1
         LDX   #ENERGY
         CLR   TEMP1
         STAA  TEMP1+1
         JSR   BCDSUB
         LDX   XTEMP1
         RTS
;
; BCD ADDITION
;
BCDADD   CLC
         BRA   BCDFIX
;
; BCD SUBTRACTION
;
BCDSUB   LDAA  #$99
         SUBA  TEMP1
         STAA  TEMP1
         LDAA  #$99
         SUBA  TEMP1+1
         STAA  TEMP1+1
         SEC
;
BCDFIX   LDAA  1,X
         ADCA  TEMP1+1
         DAA
         STAA  1,X
         LDAA  0,X
         ADCA  TEMP1
         DAA
         STAA  0,X
         RTS
;
; LONG RANGE SCAN
;
LRSCAN   TST   DAMLRS
         BEQ   LRSNDM
         JSR   RPTDAM
         RTS
;
LRSNDM   CLR   TOPFLG
         CLR   BOTFLG
         CLR   LSDFLG
         CLR   RSDFLG
         LDX   #LRSCST
         JSR   PSTRNG
         JSR   OUTQUD
         JSR   PCRLF
         LDAA  CURQUX
         BNE   LRSCNT
         INC   LSDFLG
LRSCNT   CMPA  #7
         BNE   LRSCN2
         INC   RSDFLG
LRSCN2   LDAA  CURQUY
         BNE   LRSCN3
         INC   TOPFLG
LRSCN3   CMPA  #7
         BNE   LRSCN4
         INC   BOTFLG
LRSCN4   LDX   QUDPTR
LRSCNC   LDAA  #$F7
         JSR   FIXXRG
         TST   TOPFLG
         BEQ   LRSCN7
         BSR   OUTTH0
         BRA   LRSCN8
;
LRSCN7   BSR   OUTLIN
LRSCN8   LDAA  #5
         JSR   FIXXRG
         BSR   OUTLIN
         LDAA  #5
         JSR   FIXXRG
         TST   BOTFLG
         BEQ   LRSCN9
         BSR   OUTTH0
         BRA   LRSC10
;
LRSCN9   BSR   OUTLIN
LRSC10   RTS
;
; OUTPUT 1 LINE OF LONG RANGE SCAN
;
OUTLIN   LDAA  0,X
         TST   LSDFLG
         BEQ   OUTLN1
         CLRA
         BRA   OUTLN2
OUTLN1   BSR   UPDCMP
OUTLN2   BSR   OUTQIN
         LDAA  0,X
         BSR   UPDCMP
         BSR   OUTQIN
         LDAA  0,X
         TST   RSDFLG
         BEQ   OUTLN3
         CLRA
         BRA   OUTLN4
OUTLN3   BSR   UPDCMP
OUTLN4   BSR   OUTQIN
         JSR   PCRLF
         RTS
;
; UPDATE COMPUTER HISTORY MAP
;
UPDCMP   STAA  64,X
         RTS
;
; OUTPUT QUADRANT INFORMATION
;
OUTQIN   TAB
         ANDA  #$80
         CLC
         ROLA
         ROLA
         JSR   OUTHRST
         TBA
         ANDA  #$40
         LSRA
         LSRA
         JSR   OUTHLST
         TBA
         ANDA  #$38     ; STARS
         ASLA
         JSR   OUTHLST
         TBA
         ANDA  #$07     ; KLINGONS
         JSR   OUTHRST
         INX
         JSR   OUTSST
         RTS
;
; OUTPUT A LINE OF ZEROS
;
OUTTH0   LDAA  #3
         STAA  COUNT
OUTTH1   CLRA
         BSR   OUTQIN
         DEC   COUNT
         BNE   OUTTH1
         JSR   PCRLF
         RTS
;
; FIRE PHASORS
;
PHASOR   TST   DAMPHS
         BEQ   PHSNDM
         JSR   RPTDAM
         RTS
;
PHSNDM   TST   SHIELD
         BEQ   PHASR1
         LDX   #MLSHLD
         BRA   TOOMC1
;
PHASR1   LDX   #ENAVLB        ; REPORT ENERGY
         JSR   PSTRNG
         LDX   ENERGY
         STX   TEMP1
         JSR   OUTBCD
         LDX   #FIRENG
         JSR   PSTRNG
         JSR   INBCD
         LDAA  PHSENG
         CMPA  ENERGY
         BHI   TOOMCH
         BNE   PHASR2
         LDAA  PHSENG+1
         CMPA  ENERGY+1
         BLS   PHASR2
TOOMCH   LDX   #TOMUCH
TOOMC1   JSR   PSTRNG
         RTS
;
PHASR2   JSR   RANDOM
         CMPA  #$F4
         BLS   PHASR3
         LDX   #PHAMIS
         JSR   PSTRNG
         BRA   PHASR6
;
PHASR3   LDAA  PHSENG
         CMPA  KLNENG
         BHI   PHASR4
         BNE   PHASR5
         LDAA  PHSENG+1
         CMPA  KLNENG+1
         BLS   PHASR5
PHASR4   CLR   KLNENG
         CLR   KLNENG+1
         LDX   #ALKILL
         JSR   PSTRNG
         LDX   #STILFT
         JSR   PSTRNG
         LDAB  SECKLN
         STAB  HITKLS
         LDAA  KLNGCT
         SBA
         STAA  KLNGCT
         JSR   OUTKLN
         CLR   SECKLN
KILALK   LDX   #SECMAP
         LDAA  #16
         STAA  COUNT
KILAL1   LDAB  #4
         LDAA  0,X
KILAL2   RORA
         BCS   KILAL4
         RORA
         BCC   KILAL3
         CLC
KILAL3   DECB
         BNE   KILAL2
         RORA
         STAA  0,X
         INX
         DEC   COUNT
         BNE   KILAL1
         BRA   PHASR6
;
KILAL4   RORA
         BRA   KILAL3
;
PHASR5   LDX   #PHSENG
         STX   TEMP1
         LDX   #KLNENG
         JSR   BCDSUB
         LDX   #KHTADM
         JSR   PSTRNG
PHASR6   LDX   PHSENG
         STX   TEMP1
         LDX   #ENERGY
         JSR   BCDSUB
         RTS
;
; INPUT A BCD NUMBER
;
INBCD    CLR   PHSENG
         CLR   PHSENG+1
INBCD1   JSR   INCH
         CMPA  #'0'
         BLO   EXIT
         BSR   CHECK
         TST   FLAGC
         BNE   INEROR
         LDAB  #4
INBCD2   ASL   PHSENG+1
         ROL   PHSENG
         DECB
         BNE   INBCD2
         ADDA  PHSENG+1
         STAA  PHSENG+1
         BRA   INBCD1
;
INEROR   LDX   #ERR
         JSR   PDATA3
         BRA   INBCD1
;
EXIT     RTS
;
CHECK    CLR   FLAGC
         CMPA  #'9'
         BHI   SETFLG
         ANDA  #$0F
         RTS
;
SETFLG   INC   FLAGC
         RTS
;
; SELF DESTRUCT ROUTINE
;
SELFDE   LDX   #ABORT1
         JSR   PSTRNG
         LDX   #PASWRD
         LDAB  #3
SELFD1   JSR   INCH
         CMPA  0,X
         BNE   SELFD2
         INX
         DECB
         BNE   SELFD1
SELFDA   LDX   #DISINT
         JSR   PSTRNG
         INC   GAMEND
         RTS
;
SELFD2   LDX   #ABORT2
         JSR   PSTRNG
         RTS
;
; TELEPORT ROUTINE
;
TELEPT   LDAA  #$12
         CMPA  TIMUSE+1
         BHI   TELEP2
         TST   TELFLG
         BNE   TELEP4
         JSR   RANDOM
         CMPA  #$B0        ; POSS DAMAGED
         BLS   TELEP1
         INC   TELFLG
TELEP1   JSR   RANDOM      ; MALFUNCTION?
         CMPA  #$80
         BHI   TELEP5
         LDAA  BASEX
         STAA  CURQUX
         LDAA  BASEY
         STAA  CURQUY
TELEPA   JMP   STCRSA
;
TELEP2   LDX   #CANTUS
TELEP3   JSR   PSTRNG
         RTS
;
TELEP4   LDX   #DMGDST
         BRA   TELEP3
;
TELEP5   JSR   RANDOM
         ANDA  #7
         STAA  CURQUX
         JSR   RANDOM
         ANDA  #7
         STAA  CURQUY
         LDX   #SOMWHR
         JSR   PSTRNG
         BRA   TELEPA
;
; KLINGON ATTACK ROUTINE
;
ATTACK   TST   SECKLN         ; ANY Ks?
         BNE   ATTAC1
         RTS
;
ATTAC1   JSR   RANDOM         ; MAY NOT ATTACK
         CMPA  #$B0
         BHI   ATTAC2
         LDX   #ATKENG
         LDAB  SECKLN
         ASLB
         JSR   CSCEXT
         LDX   ATKENG
         STX   TEMP1
         TST   SHIELD
         BNE   ATTAC3
         LDX   #ENERGY
         JSR   BCDSUB
         JSR   PCRLF
         LDX   ATKENG
         STX   TEMP1
         JSR   OUTBCD
         LDX   #KATKDN
         JSR   PDATA3
         LDAB  #$FA
         JSR   MANDAM
ATTAC2   RTS
;
ATTAC3   LDX   #SHENGY
         JSR   BCDSUB
         LDX   #KATKUP
         JSR   PSTRNG
         RTS
;
; END OF GAME CLEANUP ROUTINE
;
NRGOUT   LDX   #NMENGS
NRGOU1   JSR   PSTRNG
         BRA   ENDGAM
;
NOMTIM   LDX   #NMTMST
         BRA   NRGOU1
;
NOMKLN   LDX   #NMKLST
         JSR   PSTRNG
         BRA   ENDGM2
;
ENDGAM   LDX   #FAILST
         JSR   PSTRNG
         BRA   ENDGM3
;
ENDGM2   LDX   #SUCCST
         JSR   PSTRNG
ENDGM3   LDX   #PLAYAG
         JSR   PSTRNG
         JSR   INCH
         CMPA  #'Y'
         BEQ   ENDGM4
         JMP   CONTRL
;
ENDGM4   JMP   STRTRK
;
; CLEAR OUT CURRENT QUADRANT
;
CLRCQU   LDX   QUDPTR
         LDAA  0,X
         SUBA  HITKLS      ; CLEAR Ks
         LDAB  HITSTR      ; CLEAR Ss
         ASLB
         ASLB
         ASLB
         SBA
         TST   HITBAS      ; CLEAR B?
         BEQ   CLRCQ2
         ANDA  #$BF
         LDAB  #$A
         STAB  BASEX
         STAB  BASEY
         CLR   CNDFLG
CLRCQ2   STAA  0,X
         CLRA
         STAA  HITKLS
         STAA  HITSTR
         STAA  HITBAS
         RTS
;
; FIX DAMAGE ROUTINE
;
FIXDAM   LDX   #DAMENG
FIXDM1   TST   0,X
         BEQ   FIXDM2
         DEC   0,X
FIXDM2   INX
         CPX   #DAMENG+9
         BNE   FIXDM1
         RTS
;
; SUPERNOVA GENERATOR
;
SUPNOV   JSR   RANDOM
         ANDA  #7
         TAB
         JSR   RANDOM
         ANDA  #7
         STAB  TSAVE1
         LDX   #QUDMAP
         INC   STPSFL
         JSR   STPSEX
         LDAB  0,X
         ANDB  #7          ; CLEAR Ks
         LDAA  KLNGCT
         SBA
         STAA  KLNGCT
         LDAA  #$80
         STAA  0,X
         LDX   #SUPSTR
         JSR   PSTRNG
         LDAA  TSAVE1
         JSR   FIXOUT
         JSR   OUTDSH
         LDAA  ASAVE
         JSR   FIXOUT
         RTS
;
; GENERATE MAIN DAMAGE
;
MANDAM   LDX   #DAMENG
MANDM1   JSR   RANDOM
         CBA
         BLS   MANDM2
         JSR   RANDOM
         ANDA  #3
         SEC
         ADCA  0,X
         STAA  0,X
MANDM2   INX
         CPX   #DAMENG+9
         BNE   MANDM1
         TST   DAMSHL
         BEQ   MANDM3
         CLR   SHIELD
MANDM3   TST   DAMCOM
         BEQ   MANDM4
         CLR   AUTOSR
         CLR   AUTOLR
MANDM4   RTS
;
; REPORT DAMAGE HAS OCCURED
;
RPTDAM   LDX   #DMGDST
         JSR   PSTRNG
RPTDM8   RTS
;
; GENERATE A DAMAGE REPORT
;
DAMRPT   LDX   #DMRPST
         JSR   PSTRNG
         LDX   #DEVSTR
         STX   TEMP2
         LDX   #DAMENG
DMRPT2   TST   0,X
         BNE   DMRPT3
BMPX4    STX   TEMP3
         LDX   TEMP2
         INX
         INX
         INX
         INX
         INX
         INX
         INX
         INX
         INX
         INX
         INX
         STX   TEMP2
         LDX   TEMP3
         BRA   DMRPT4
;
DMRPT3   STX   TEMP3
         LDX   TEMP2
         JSR   PSTRNG
         INX
         STX   TEMP2
         LDX   TEMP3
         LDAB  #3
OUTS4    JSR   OUTSST
         DECB
         BNE   OUTS4
         LDAA  0,X
         JSR   OUTK0
DMRPT4   INX
         CPX   #DAMENG+9
         BNE   DMRPT2
         BRA   RPTDM8
;
; COMPUTER CODE
;
COMPTR   TST   DAMCOM
         BEQ   CMPTR1
         JSR   RPTDAM
         RTS
;
CMPTR1   LDX   #CPRMPT
         JSR   PSTRNG
         JSR   INCH
         CMPA  #'T'
         BEQ   TSPRED
         CMPA  #'M'
         BEQ   CMPMAP
         CMPA  #'S'
         BNE   CMPTR1
         LDX   #SRMODE
         JSR   PSTRNG
         CLR   AUTOSR
         JSR   INCH
         CMPA  #'Y'
         BNE   AUTO2
         INC   AUTOSR
AUTO2    LDX   #LRMODE
         JSR   PSTRNG
         CLR   AUTOLR
         JSR   INCH
         CMPA  #'Y'
         BNE   AUTOEX
         INC   AUTOLR
AUTOEX   RTS
;
CMPMAP   LDX   #CMPHST
         JSR   PSTRNG
         LDX   #COMMAP
CMPMP1   JSR   PCRLF
         LDAA  #8
         STAA  COUNT
CMPMP2   LDAA  0,X
         CMPA  #$FF
         BNE   CMPMP3
         STX   TEMP3
         LDX   #NOSCAN
         JSR   PDATA3
         LDX   TEMP3
         INX
         BRA   CMPMP4
;
CMPMP3   JSR   OUTQIN
CMPMP4   DEC   COUNT
         BNE   CMPMP2
         CPX   #COMMAP+64
         BNE   CMPMP1
         RTS
;
TSPRED   TST   DAMPHT
         BEQ   TS2
         JSR   RPTDAM
         RTS
;
TS2      CLR   PTZFLG
         LDX   #HWMANY
         JSR   PSTRNG
         JSR   INCH
         CMPA  #'0'
         BLO   TS2
         BEQ   TSEX
         CMPA  #'9'
         BGT   TS2
         ANDA  #$0F
         STAA  PCOUNT
TS3      JSR   PTRNDM
         DEC   PCOUNT
         BEQ   TSEX
         TST   PTZFLG
         BEQ   TS3
TSEX     RTS
;
; TRACTOR BEAM ROUTINE
;
TRCTBM   TST   SHUTCR
         BNE   NPCKUP
         LDAA  SHUTLX
         CMPA  CURQUX
         BNE   NPCKUP
         LDAA  SHUTLY
         CMPA  CURQUY
         BNE   NPCKUP
         LDX   #SCONBD
         INC   SHUTCR
         BRA   TRCTEX
;
NPCKUP   LDX   #NOPICK
TRCTEX   JSR   PSTRNG
         RTS
;
; TEXT STRINGS
;
TITLE    fcb   LF
         fcb   "- - - -   S T A R   T R E K   - - - -      VERSION 1.2"
         fcb   EOT
SHTLNG   fcb   "SHORT OR LONG GAME? (S-L): "
         fcb   EOT
UPSCAS   fcb   " UP"
         fcb   EOT
BASINF   fcb   "STARBASE IN QUADRANT: "
         fcb   EOT
DOCKED   fcb   "DOCKED"
         fcb   EOT
DNSCAS   fcb   " DOWN"
         fcb   EOT
PTEMST   fcb   "ALL TORPEDOS FIRED!"
         fcb   EOT
INTRO1   fcb   LF
         fcb   "IT IS STARDATE "
         fcb   EOT
INTRO2   fcb   "THE KLINGONS NUMBER "
         fcb   EOT
INTRO3   fcb   "YOUR TIME LIMIT (IN STARDATES) = "
         fcb   EOT
INTRO4   fcb   "YOU ARE IN QUADRANT "
         fcb   EOT
INTRO6   fcb   "AND SECTOR "
         fcb   EOT
COMST    fcb   LF
         fcb   "COMMAND? "
         fcb   EOT
DWNST    fcb   "THE SHIELDS ARE DOWN, SIR"
         fcb   EOT
UPSTR    fcb   "THE SHIELDS ARE UP, SIR"
         fcb   EOT
CRSSTR   fcb   "WHAT COURSE, SIR? (0-7): "
         fcb   EOT
WRPSTR   fcb   "WHAT WARP FACTOR, SIR: "
         fcb   EOT
BLOKST   fcb   "THE ENTERPRISE IS BLOCKED AT SECTOR "
         fcb   EOT
KRMSTR   fcb   "WE",APOS,"VE RAMMED A KLINGON AT SECTOR "
         fcb   EOT
GLBNDS   fcb   "YOU",APOS,"VE REACHED THE EDGE OF THE GALAXY AND UNKNOWN"
         fcb   CR,LF
         fcb   "FORCES HAVE STOPPED THE ENTERPRISE!"
         fcb   EOT
PHITST   fcb   "YOUR TORPEDO HAS HIT A "
         fcb   EOT
PNOENG   fcb   "THE TORPEDO HAS RUN OUT OF ENERGY"
         fcb   EOT
SDATE    fcb   "  STARDATE: "
         fcb   EOT
CNDTNS   fcb   "  CONDITION: "
         fcb   EOT
YELLOW   fcb   "YELLOW!"
         fcb   EOT
RED      fcb   "RED!!!"
         fcb   EOT
GREEN    fcb   "GREEN"
         fcb   EOT
QUADP    fcb   "  QUADRANT: "
         fcb   EOT
SECP     fcb   "  SECTOR:   "
         fcb   EOT
ENGSTR   fcb   "  ENERGY: "
         fcb   EOT
KLSTR    fcb   "  KLINGONS: "
         fcb   EOT
SHSTR    fcb   "  SHIELDS: "
         fcb   EOT
TRPSTR   fcb   "  TORPEDOS: "
         fcb   EOT
LRSCST   fcb   "SCAN FOR QUADRANT "
         fcb   EOT
MLSHLD   fcb   "YOU MUST FIRST LOWER SHIELDS!"
         fcb   EOT
ENAVLB   fcb   "THE AVAILABLE ENERGY IS: "
         fcb   EOT
FIRENG   fcb   "HOW MUCH ENERGY SHALL I USE: "
         fcb   EOT
TOMUCH   fcb   "YOU DON",APOS,"T HAVE ENOUGH ENERGY!"
         fcb   EOT
PHAMIS   fcb   "PHASORS HAVE MISFIRED!"
         fcb   EOT
ALKILL   fcb   "ALL KLINGONS IN THIS SECTOR HAVE BEEN DESTROYED!"
         fcb   EOT
KHTADM   fcb   "THE ENEMY HAS BEEN DAMAGED"
         fcb   EOT
ERR      fcb   " INVALID ENTRY! "
         fcb   EOT
STARST   fcb   "STAR, BILLIONS HAVE DIED"
         fcb   EOT
BASEST   fcb   "BASE, YOUR ONLY SOURCE OF SUPPLY IS NOW GONE!"
         fcb   EOT
KLGSTR   fcb   "KLINGON, CONGRATULATIONS"
         fcb   EOT
INTRO0   fcb   "ENTER YOUR 3 LETTER ABORT PASSWORD: "
         fcb   EOT
STILFT   fcb   "THE REMAINING KLINGONS NUMBER "
         fcb   EOT
KATKDN   fcb   " UNIT HIT ON THE ENTERPRISE"
         fcb   EOT
KATKUP   fcb   "KLINGONS HAVE ATTACKED, BUT THE SHIELDS ARE HOLDING!"
         fcb   EOT
DISINT   fcb   "ENTERPRISE HAS BEEN DESTROYED - ALL HANDS LOST!"
         fcb   EOT
ABORT1   fcb   "ABORT SEQUENCE STARTED - WHAT WAS YOUR PASSWORD? "
         fcb   EOT
ABORT2   fcb   "ABORT SEQUENCE ABANDONED - PASSWORD ERROR"
         fcb   EOT
CANTUS   fcb   "THE TELEPORTER REPAIRS ARE NOT YET FINISHED, SORRY"
         fcb   EOT
SOMWHR   fcb   "TELEPORTER MALFUNCTION - BASE NOT REACHED"
         fcb   EOT
SPSTRM   fcb   BELL
         fcb   "WE",APOS,"VE HIT A SPACE STORM - SHIELDS DAMAGED!"
         fcb   EOT
GALDUM   fcb   "THE 3RD ATTEMPT TO LEAVE THE GALAXY HAS CAUSED AN"
         fcb   CR,LF
         fcb   "AUTOMATIC SELF-DESTRUCT SEQUENCE. IT CANNOT BE STOPPED!!!"
         fcb   EOT
NMENGS   fcb   BELL
         fcb   "THE ENTERPRISE IS OUT OF ENERGY. IT CAN NO LONGER EXIST."
         fcb   EOT
NMTMST   fcb   BELL
         fcb   "YOU HAVE RUN OUT OF STARDATES FOR THIS MISSION."
         fcb   EOT
NMKLST   fcb   LF,BELL
         fcb   "CONGRATULATIONS!"
         fcb   LF,CR,0,0,0,0
         fcb   "YOU HAVE DESTROYED ALL THE KLINGONS."
         fcb    EOT
FAILST   fcb   "YOUR MISSION WAS A FAILURE, THE FEDERATION MUST SURRENDER."
         fcb    EOT
SUCCST   fcb   "THE FEDERATION HAS BEEN SAVED BY YOUR GALLANT ACTIONS."
         fcb   CR,LF
         fcb   "YOU ARE AWARDED THE STARFLEET MEDAL OF HONOR."
         fcb    EOT
SUPDES   fcb   "MESSAGE FROM STARFLEET COMMAND:"
         fcb   CR,LF
         fcb   "     THE ENTERPRISE HAS JUST BEEN DESTROYED BY A"
         fcb   CR,LF
         fcb   "     SUPERNOVA IN IT",APOS,"S CURRENT QUADRANT - ALL HANDS LOST."
         fcb   EOT
SUPSTR   fcb   BELL
         fcb   "SENSORS REPORT A SUPER NOVA IN QUADRANT "
         fcb    EOT
HEVDAM   fcb   "BADLY DAMAGED"
         fcb    EOT
DMGDST   fcb   "DEVICE IS DAMAGED AND UNUSABLE.  REPAIRS HAVE BEEN STARTED"
         fcb    EOT
DMRPST   fcb   LF
         fcb   "DEVICE     STATUS"
         fcb    EOT
DEVSTR   fcb   "ENGINES   "
         fcb    EOT
         fcb   "SHORT SCAN"
         fcb    EOT
         fcb   "LONG SCAN "
         fcb    EOT
         fcb   "PHASORS   "
         fcb    EOT
         fcb   "TORPEDOS  "
         fcb    EOT
         fcb   "SHIELDS   "
         fcb    EOT
         fcb   "TELEPORTER"
         fcb    EOT
         fcb   "TRACTOR BM"
         fcb    EOT
         fcb   "COMPUTER  "
         fcb    EOT
PLAYAG   fcb   "WOULD YOU LIKE TO PLAY AGAIN? (Y-N): "
         fcb    EOT
SCONBD   fcb   "THE SHUTTLE CRAFT IS REPORTED ON BOARD, SIR"
         fcb    EOT
NOPICK   fcb   "THE SENSORS SHOW NOTHING TO BE PICKED UP, SIR"
         fcb    EOT
EXPCMD   fcb   "THE COMMANDS ARE AS FOLLOWS:"
         fcb   CR,LF,$A
         fcb   "CMND   ACTION"
         fcb   CR,LF
         fcb   " EN    ACTIVATE WARP ENGINES"
         fcb   CR,LF
         fcb   " SR    SHORT RANGE SCAN"
         fcb   CR,LF
         fcb   " LR    LONG RANGE SCAN"
         fcb   CR,LF
         fcb   " PH    FIRE PHASOR BEAMS"
         fcb   CR,LF
         fcb   " PT    FIRE PHOTON TORPEDOS"
         fcb   CR,LF
         fcb   " DR    DAMAGE REPORT"
         fcb   CR,LF
         fcb   " SH    SHIELDS UP OR DOWN"
         fcb   CR,LF
         fcb   " TP    TELEPORT TO BASE QUADRANT"
         fcb   CR,LF
         fcb   " SD    SELF DESTRUCT SEQUENCE"
         fcb   CR,LF
         fcb   " TB    ACTIVATE TRACTOR BEAMS"
         fcb   CR,LF
         fcb   " CO    BATTLE COMPUTER"
         fcb   CR,LF
         fcb   EOT
SHTSIG   fcb   "SENSORS REPORT SHUTTLE CRAFT GALILLEO IN THIS QUADRANT, SIR"
         fcb   EOT
SCBKUP   fcb  "SHUTTLE CRAFT SENSORS PROVIDING BACKUP SCAN, SIR"
         fcb   EOT
CPRMPT   fcb   "COMPUTER IS CAPABLE OF 3 FUNCTIONS:"
         fcb   CR,LF
         fcb   "   T = TORPEDO SPREAD"
         fcb   CR,LF
         fcb   "   M = PRINT SCAN HISTORY MAP"
         fcb   CR,LF
         fcb   "   S = SET AUTO SCAN"
         fcb   CR,LF,LF
         fcb   "ENTER COMPUTER COMMAND: "
         fcb   EOT
CMPHST   fcb   "STATUS OF QUADRANTS WHEN LAST SCANNED (**** = NO SCAN YET)"
         fcb   CR,LF,EOT
NOSCAN   fcb   "**** "
         fcb   EOT
HWMANY   fcb  "ENTER NUMBER OF TORPEDOS IN SPREAD (0-9): "
         fcb   EOT
SRMODE   fcb  "AUTO SCAN ON FOR SHORT RANGE SENSORS? (Y-N): "
         fcb   EOT
LRMODE   fcb  "AUTO SCAN ON FOR LONG RANGE SENSORS? (Y-N): "
         fcb   EOT
;
