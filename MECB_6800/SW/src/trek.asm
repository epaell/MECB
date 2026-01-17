* NAM STAR TREK
*****************************
* STAR TREK GAME 1.2
* BY UNKNOWN SOURCE
* RECOVERED FROM OLD FLOPPIES
*
* ADOPTED TO RUN ON THE MECB 6800
* BY DANIEL TUFVESSON 2014
*****************************

*
* MONITOR ROUTINE ADDRESSES
*
OUTCH    EQU   $F075
INCH     EQU   $F078
CONTRL   EQU   $F1BA
;
CR       EQU   $0D
LF       EQU   $0A
EOT      EQU   $04
BELL     EQU   $07
APOS     EQU   $27
*
* PROGRAM ENTRY
*
         ORG   $0100
         JMP   STRTRK
*
* STORAGE AREAS
*
STPSFL   ds.b 1
BASEX    ds.b 1
BASEY    ds.b 1
BASESX   ds.b 1
BASESY   ds.b 1
GLMFLG   ds.b 1
SECKLN   ds.b 1
FLAGC    ds.b 1
TIMDEC   ds.b 1
STCFLG   ds.b 1
SQFLG    ds.b 1
PNTFLG   ds.b 1
COURSE   ds.b 1
WARP     ds.b 1
FINCX    ds.b 1
FINCY    ds.b 1
COUNT    ds.b 1
TEMP1    ds.b 2
TEMP2    ds.b 2
XTEMP1   ds.b 2
TIME0    ds.b 2
GAMTIM   ds.b 1
TIMUSE   ds.b 2
SHENGY   ds.b 2
KLNENG   ds.b 2
PHSENG   ds.b 2
TOPFLG   ds.b 1
BOTFLG   ds.b 1
LSDFLG   ds.b 1
RSDFLG   ds.b 1
PHOTON   ds.b 1
CURQUX   ds.b 1
CURQUY   ds.b 1
CURSCX   ds.b 1
CURSCY   ds.b 1
TRIALX   ds.b 1
TRIALY   ds.b 1
FLAG     ds.b 1
CNDFLG   ds.b 1
SCANX    ds.b 1
SCANY    ds.b 1
COUNT1   ds.b 1
SECINF   ds.b 1
MASK     ds.b 1
KLNGCT   ds.b 1
LENGTH   ds.b 1
ASAVE    ds.b 1
SHIELD   ds.b 1
ENERGY   ds.b 2
TSAVE1   ds.b 1
HITKLS   ds.b 1
HITSTR   ds.b 1
HITBAS   ds.b 1
TEMP3    ds.b 2
GALCNT   ds.b 1
DAMENG   ds.b 1
DAMSRS   ds.b 1
DAMLRS   ds.b 1
DAMPHS   ds.b 1
DAMPHT   ds.b 1
DAMSHL   ds.b 1
DAMTEL   ds.b 1
DAMTRB   ds.b 1
DAMCOM   ds.b 1
PCOUNT   ds.b 1 TORP SPREAD COUNT
PTZFLG   ds.b 1 NO MORE TORP FLAG
GAMEND   ds.b 1
AUTOSR   ds.b 1
AUTOLR   ds.b 1
SUPFLG   ds.b 1
TELFLG   ds.b 1
ATKENG   ds.b 2
QUDPTR   ds.b 2 POINTS TO CURR LOC IN QUDMAP
PASWRD   ds.b 3
PHTFLG   ds.b 1
SHUTCR   ds.b 1
SHUTLX   ds.b 1
SHUTLY   ds.b 1
QUDMAP   ds.b 64
COMMAP   ds.b 64 MUST FOLLOW QUDMAP IMMEDIATELY
SECMAP   ds.b 16 PACKED SECTOR (64*2 BITS) 00=., 01=*, 10=K, 11=B
STUF     ds.b 4 SEED FOR RANDOM FUNCTION

*
         
*
* TABLE OF MOVE VECTORS
*
MOVTBL   dc.b  $00,$FF,$01,$FF,$01,$00,$01,$01       ; FF=-1
         dc.b  $00,$01,$FF,$01,$FF,$00,$FF,$FF
*
* CHARACTER PRINT TABLE
*
CHRTBL   dc.b  '.*KBN'
*
* COMMAND CODE TABLE
*
CMDTBL   dc.b  'ENSRLRPHPTDRSHTPSDTBCO'
*
* COMMAND JUMP TABLE
*
JMPTBL   dc.w  SETCRS
         dc.w  SRSCAN
         dc.w  LRSCAN
         dc.w  PHASOR
         dc.w  PHOTOR
         dc.w  DAMRPT
         dc.w  SHLDS
         dc.w  TELEPT
         dc.w  SELFDE
         dc.w  TRCTBM
         dc.w  COMPTR
*
PDATA    JSR   OUTCH
         INX
PDATA3   LDAA  0,X
         CMPA  #$04
         BNE   PDATA
         RTS
*
PCRLF    LDAA  #$0D
         JSR   OUTCH
         LDAA  #$0A
         JMP   OUTCH
*
PSTRNG   BSR   PCRLF
         BRA   PDATA3
*
OUTHLST  PSHA
         LSRA
         LSRA
         LSRA
         LSRA
         BSR   OUTHRST
         PULA
         RTS
*
OUTHRST  PSHA
         ANDA  #$0F
         ORAA  #$30
         CMPA  #$39
         BLS   OUTDIG
         ADDA  #7
OUTDIG   JSR   OUTCH
         PULA
         RTS
*
OUTSST   PSHA
         LDAA  #$20
         BRA   OUTDIG
*
* LIB RANDOM
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
*
* PRINT TITLE
*
STRTRK   LDX   #TITLE
         JSR   PSTRNG
*
* CLEAR ALL TEMP STORAGE
*
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
*
* SETUP SPACE
*
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
*
* GET STARBASE LOCATION
*
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
*
* REFUEL THE ENTERPRISE
*
REFUEL   CLR   SHIELD
         LDAA  #$30
         STAA  ENERGY
         CLR   ENERGY+1
         STAA  SHENGY
         CLR   SHENGY+1
         LDAA  #15
         STAA  PHOTON
         LDX   #DAMENG FIX ALL DAMAGE
REFUL1   CLR   0,X
         INX
         CPX   #DAMENG+9
         BNE   REFUL1
         RTS
*
* CALCULATE GAME TIME
*
MAKTIM   JSR   RANDOM
         ANDA  #$0F
         ORAA  #$31
         ADDA  #0
         DAA
         RTS
*
* CONTINUE SETUP
*
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
*
* OUTPUT A NUMBER
*
FIXOUT   ADDA  #$31
         JSR   OUTCH
         RTS
*
* OUTPUT STARDATE
*
OUTDAT   LDX   TIME0
         STX   TEMP1
         JSR   OUTBCD
         LDAA  #'.'
         JSR   OUTCH
         LDAA  TIMDEC
         JSR   OUTHRST
         RTS
*
* OUTPUT A KLINGON COUNT
*
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
*
* OUTPUT QUADRANT LOCATION
*
OUTQUD   LDAA  CURQUY
         BSR   FIXOUT
         BSR   OUTDSH
         LDAA  CURQUX
         BSR   FIXOUT
         RTS
*
* OUTPUT A SECTOR
*
OUTSEC   LDAA  CURSCY
         BSR   FIXOUT
         BSR   OUTDSH
         LDAA  CURSCX
         BSR   FIXOUT
         RTS
*
* OUTPUT A DASH
*
OUTDSH   LDAA  #'-'
         JSR   OUTCH
         RTS
*
* ADD THE A-REG TO THE INDEX REGISTER
*
FIXXRG   STX   TEMP1
         ADDA  TEMP1+1
         STAA  TEMP1+1
         LDX   TEMP1
         RTS
*
* GET COMMAND AND PERFORM IT
*
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
*
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
*
COMND2   JSR   RANDOM
         CMPA  #$FC           ; SUPERNOVA?
         BLS   CMND25
         JSR   SUPNOV
CMND25   JSR   ATTACK         ; ALLOW ATTACK
         TST   ENERGY
         BPL   COMND0
         JMP   NRGOUT
*
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
*
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
*
* OUTPUT A 4 DIGIT BCD NUMBER
*
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
*
* LOWER THE SHIELDS
*
SHLDS    TST   SHIELD
         BEQ   SHLDUP
SHLDWN   CLR   SHIELD
         LDX   #DWNST
SHLD0    JSR   PSTRNG
SHLD1    RTS
*
* RAISE THE SHIELDS
*
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
*
* SHORT RANGE SCAN
*
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
*
SRSCN0   LDX   #RED
         BRA   OUTCND
*
SRSCN1   LDX   #GREEN
         BRA   OUTCND
*
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
*
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
*
* OUTPUT 1 SHORT RANGE SCAN LINE
*
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
*
* SETUP SECTOR MAP
*
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
*
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
*
* COMPUTE LOCAL KLINGON ENERGY
*
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
*
* PUT OBJECTS IN SECTOR MAP
*
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
*
* CHECK FOR EMPTY POSITIONS
*
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
*
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
*
* FIRE PHOTON TORPEDO
*
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
*
PHOTRO   INC   PHTFLG
         JSR   RANDOM
         ANDA  #$F
         ORAA  #4
         STAA  WARP
         DEC   PHOTON
*
* WARP ENGINES AND PHOTON TORP COURSE
*
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
*
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
*
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
*
ABC1     TST   FINCY
         BEQ   ABC5
         JMP   STCRS5
*
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
*
ABC2     CMPA  #2
         BNE   ABC3
         JMP   KLGRAM
*
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
*
STCRET   JMP   STCRS6
*
STCRS4   TST   PHTFLG
         BEQ   STCRSB      ; JUMP IF NOT
         LDAA  TRIALX
         LDAB  TRIALY
         DEC   COUNT
         BNE   PHTOR2
PHTOR4   LDX   #PNOENG
         JSR   PSTRNG
         JMP   STCRS6
*
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
*
STCRSD   TST   SQFLG
         BNE   STCRS5      ; QUADRANT MOVE!
         JMP   STCRS6
*
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
*
ABCD0    TST   FINCY
         BEQ   ABCD1
         JMP   GALBND
*
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
*
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
*
* RAMMED A KLINGON ROUTINE
*
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
*
* PRINT GALAXY LIMIT MESSAGE
*
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
*
GALBN2   STAA  GALCNT
         TST   GLMFLG
         BNE   ABC20
         JMP   STCRS6
*
ABC20    JMP   STCRSA
*
* TORPEDO HAS HIT SOMETHING
*
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
*
ABC8     CMPA  #1          ; STAR?
         BNE   ABC11
         INC   HITSTR
         LDX   #STARST
ABC9     JSR   PDATA3
ABC10    RTS
*
ABC11    LDX   #BASEST     ; HIT BASE!
         INC   HITBAS
         BRA   ABC9
*
* SEE IF GALAXY EDGE REACHED
*
TSTBND   CLR   FINCX
         CLR   FINCY
         TSTA
         BPL   TSTBN1
         DEC   FINCX
         BRA   TSTBN2
*
TSTBN1   CMPA  #7
         BLS   TSTBN2
         INC   FINCX
TSTBN2   TSTB
         BPL   TSTBN3
         DEC   FINCY
         RTS
*
TSTBN3   CMPB  #7
         BLS   TSTBN4
         INC   FINCY
TSTBN4   RTS
*
* INPUT CHARACTER AND CHECK
*
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
*
INCHK1   LDX   #ERR
         JSR   PDATA3
         BRA   INCHCK
*
* ADD TO GAME TIME
*
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
*
FIXTM1   STAA  TIMDEC
         RTS
*
*SUBTRACT FROM ENERGY AMOUNT
*
FIXENG   STX   XTEMP1
         LDX   #ENERGY
         CLR   TEMP1
         STAA  TEMP1+1
         JSR   BCDSUB
         LDX   XTEMP1
         RTS
*
* BCD ADDITION
*
BCDADD   CLC
         BRA   BCDFIX
*
* BCD SUBTRACTION
*
BCDSUB   LDAA  #$99
         SUBA  TEMP1
         STAA  TEMP1
         LDAA  #$99
         SUBA  TEMP1+1
         STAA  TEMP1+1
         SEC
*
BCDFIX   LDAA  1,X
         ADCA  TEMP1+1
         DAA
         STAA  1,X
         LDAA  0,X
         ADCA  TEMP1
         DAA
         STAA  0,X
         RTS
*
* LONG RANGE SCAN
*
LRSCAN   TST   DAMLRS
         BEQ   LRSNDM
         JSR   RPTDAM
         RTS
*
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
*
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
*
LRSCN9   BSR   OUTLIN
LRSC10   RTS
*
* OUTPUT 1 LINE OF LONG RANGE SCAN
*
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
*
* UPDATE COMPUTER HISTORY MAP
*
UPDCMP   STAA  64,X
         RTS
*
* OUTPUT QUADRANT INFORMATION
*
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
*
* OUTPUT A LINE OF ZEROS
*
OUTTH0   LDAA  #3
         STAA  COUNT
OUTTH1   CLRA
         BSR   OUTQIN
         DEC   COUNT
         BNE   OUTTH1
         JSR   PCRLF
         RTS
*
* FIRE PHASORS
*
PHASOR   TST   DAMPHS
         BEQ   PHSNDM
         JSR   RPTDAM
         RTS
*
PHSNDM   TST   SHIELD
         BEQ   PHASR1
         LDX   #MLSHLD
         BRA   TOOMC1
*
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
*
PHASR2   JSR   RANDOM
         CMPA  #$F4
         BLS   PHASR3
         LDX   #PHAMIS
         JSR   PSTRNG
         BRA   PHASR6
*
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
*
KILAL4   RORA
         BRA   KILAL3
*
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
*
* INPUT A BCD NUMBER
*
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
*
INEROR   LDX   #ERR
         JSR   PDATA3
         BRA   INBCD1
*
EXIT     RTS
*
CHECK    CLR   FLAGC
         CMPA  #'9'
         BHI   SETFLG
         ANDA  #$0F
         RTS
*
SETFLG   INC   FLAGC
         RTS
*
* SELF DESTRUCT ROUTINE
*
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
*
SELFD2   LDX   #ABORT2
         JSR   PSTRNG
         RTS
*
* TELEPORT ROUTINE
*
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
*
TELEP2   LDX   #CANTUS
TELEP3   JSR   PSTRNG
         RTS
*
TELEP4   LDX   #DMGDST
         BRA   TELEP3
*
TELEP5   JSR   RANDOM
         ANDA  #7
         STAA  CURQUX
         JSR   RANDOM
         ANDA  #7
         STAA  CURQUY
         LDX   #SOMWHR
         JSR   PSTRNG
         BRA   TELEPA
*
* KLINGON ATTACK ROUTINE
*
ATTACK   TST   SECKLN         ; ANY Ks?
         BNE   ATTAC1
         RTS
*
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
*
ATTAC3   LDX   #SHENGY
         JSR   BCDSUB
         LDX   #KATKUP
         JSR   PSTRNG
         RTS
*
* END OF GAME CLEANUP ROUTINE
*
NRGOUT   LDX   #NMENGS
NRGOU1   JSR   PSTRNG
         BRA   ENDGAM
*
NOMTIM   LDX   #NMTMST
         BRA   NRGOU1
*
NOMKLN   LDX   #NMKLST
         JSR   PSTRNG
         BRA   ENDGM2
*
ENDGAM   LDX   #FAILST
         JSR   PSTRNG
         BRA   ENDGM3
*
ENDGM2   LDX   #SUCCST
         JSR   PSTRNG
ENDGM3   LDX   #PLAYAG
         JSR   PSTRNG
         JSR   INCH
         CMPA  #'Y'
         BEQ   ENDGM4
         JMP   CONTRL
*
ENDGM4   JMP   STRTRK
*
* CLEAR OUT CURRENT QUADRANT
*
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
*
* FIX DAMAGE ROUTINE
*
FIXDAM   LDX   #DAMENG
FIXDM1   TST   0,X
         BEQ   FIXDM2
         DEC   0,X
FIXDM2   INX
         CPX   #DAMENG+9
         BNE   FIXDM1
         RTS
*
* SUPERNOVA GENERATOR
*
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
*
* GENERATE MAIN DAMAGE
*
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
*
* REPORT DAMAGE HAS OCCURED
*
RPTDAM   LDX   #DMGDST
         JSR   PSTRNG
RPTDM8   RTS
*
* GENERATE A DAMAGE REPORT
*
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
*
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
*
* COMPUTER CODE
*
COMPTR   TST   DAMCOM
         BEQ   CMPTR1
         JSR   RPTDAM
         RTS
*
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
*
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
*
CMPMP3   JSR   OUTQIN
CMPMP4   DEC   COUNT
         BNE   CMPMP2
         CPX   #COMMAP+64
         BNE   CMPMP1
         RTS
*
TSPRED   TST   DAMPHT
         BEQ   TS2
         JSR   RPTDAM
         RTS
*
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
*
* TRACTOR BEAM ROUTINE
*
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
*
NPCKUP   LDX   #NOPICK
TRCTEX   JSR   PSTRNG
         RTS
*
* TEXT STRINGS
*
TITLE    dc.b  LF
         dc.b  '- - - -   S T A R   T R E K   - - - -      VERSION 1.2'
         dc.b  EOT
SHTLNG   dc.b  'SHORT OR LONG GAME? (S-L): '
         dc.b  EOT
UPSCAS   dc.b  ' UP'
         dc.b  EOT
BASINF   dc.b  'STARBASE IN QUADRANT: '
         dc.b  EOT
DOCKED   dc.b  'DOCKED'
         dc.b  EOT
DNSCAS   dc.b  ' DOWN'
         dc.b  EOT
PTEMST   dc.b  'ALL TORPEDOS FIRED!'
         dc.b  EOT
INTRO1   dc.b  LF
         dc.b  'IT IS STARDATE '
         dc.b  EOT
INTRO2   dc.b  'THE KLINGONS NUMBER '
         dc.b  EOT
INTRO3   dc.b  'YOUR TIME LIMIT (IN STARDATES) = '
         dc.b  EOT
INTRO4   dc.b  'YOU ARE IN QUADRANT '
         dc.b  EOT
INTRO6   dc.b  'AND SECTOR '
         dc.b  EOT
COMST    dc.b  LF
         dc.b  'COMMAND? '
         dc.b  EOT
DWNST    dc.b  'THE SHIELDS ARE DOWN, SIR'
         dc.b  EOT
UPSTR    dc.b  'THE SHIELDS ARE UP, SIR'
         dc.b  EOT
CRSSTR   dc.b  'WHAT COURSE, SIR? (0-7): '
         dc.b  EOT
WRPSTR   dc.b  'WHAT WARP FACTOR, SIR: '
         dc.b  EOT
BLOKST   dc.b  'THE ENTERPRISE IS BLOCKED AT SECTOR '
         dc.b  EOT
KRMSTR   dc.b  'WE',APOS,'VE RAMMED A KLINGON AT SECTOR '
         dc.b  EOT
GLBNDS   dc.b  'YOU',APOS,'VE REACHED THE EDGE OF THE GALAXY AND UNKNOWN'
         dc.b  CR,LF
         dc.b  'FORCES HAVE STOPPED THE ENTERPRISE!'
         dc.b  EOT
PHITST   dc.b  'YOUR TORPEDO HAS HIT A '
         dc.b  EOT
PNOENG   dc.b  'THE TORPEDO HAS RUN OUT OF ENERGY'
         dc.b  EOT
SDATE    dc.b  '  STARDATE: '
         dc.b  EOT
CNDTNS   dc.b  '  CONDITION: '
         dc.b  EOT
YELLOW   dc.b  'YELLOW!'
         dc.b  EOT
RED      dc.b  'RED!!!'
         dc.b  EOT
GREEN    dc.b  'GREEN'
         dc.b  EOT
QUADP    dc.b  '  QUADRANT: '
         dc.b  EOT
SECP     dc.b  '  SECTOR:   '
         dc.b  EOT
ENGSTR   dc.b  '  ENERGY: '
         dc.b  EOT
KLSTR    dc.b  '  KLINGONS: '
         dc.b  EOT
SHSTR    dc.b  '  SHIELDS: '
         dc.b  EOT
TRPSTR   dc.b  '  TORPEDOS: '
         dc.b  EOT
LRSCST   dc.b  'SCAN FOR QUADRANT '
         dc.b  EOT
MLSHLD   dc.b  'YOU MUST FIRST LOWER SHIELDS!'
         dc.b  EOT
ENAVLB   dc.b  'THE AVAILABLE ENERGY IS: '
         dc.b  EOT
FIRENG   dc.b  'HOW MUCH ENERGY SHALL I USE: '
         dc.b  EOT
TOMUCH   dc.b  'YOU DON',APOS,'T HAVE ENOUGH ENERGY!'
         dc.b  EOT
PHAMIS   dc.b  'PHASORS HAVE MISFIRED!'
         dc.b  EOT
ALKILL   dc.b  'ALL KLINGONS IN THIS SECTOR HAVE BEEN DESTROYED!'
         dc.b  EOT
KHTADM   dc.b  'THE ENEMY HAS BEEN DAMAGED'
         dc.b  EOT
ERR      dc.b  ' INVALID ENTRY! '
         dc.b  EOT
STARST   dc.b  'STAR, BILLIONS HAVE DIED'
         dc.b  EOT
BASEST   dc.b  'BASE, YOUR ONLY SOURCE OF SUPPLY IS NOW GONE!'
         dc.b  EOT
KLGSTR   dc.b  'KLINGON, CONGRATULATIONS'
         dc.b  EOT
INTRO0   dc.b  'ENTER YOUR 3 LETTER ABORT PASSWORD: '
         dc.b  EOT
STILFT   dc.b  'THE REMAINING KLINGONS NUMBER '
         dc.b  EOT
KATKDN   dc.b  ' UNIT HIT ON THE ENTERPRISE'
         dc.b  EOT
KATKUP   dc.b  'KLINGONS HAVE ATTACKED, BUT THE SHIELDS ARE HOLDING!'
         dc.b  EOT
DISINT   dc.b  'ENTERPRISE HAS BEEN DESTROYED - ALL HANDS LOST!'
         dc.b  EOT
ABORT1   dc.b  'ABORT SEQUENCE STARTED - WHAT WAS YOUR PASSWORD? '
         dc.b  EOT
ABORT2   dc.b  'ABORT SEQUENCE ABANDONED - PASSWORD ERROR'
         dc.b  EOT
CANTUS   dc.b  'THE TELEPORTER REPAIRS ARE NOT YET FINISHED, SORRY'
         dc.b  EOT
SOMWHR   dc.b  'TELEPORTER MALFUNCTION - BASE NOT REACHED'
         dc.b  EOT
SPSTRM   dc.b  BELL
         dc.b  'WE',APOS,'VE HIT A SPACE STORM - SHIELDS DAMAGED!'
         dc.b  EOT
GALDUM   dc.b  'THE 3RD ATTEMPT TO LEAVE THE GALAXY HAS CAUSED AN'
         dc.b  CR,LF
         dc.b  'AUTOMATIC SELF-DESTRUCT SEQUENCE. IT CANNOT BE STOPPED!!!'
         dc.b  EOT
NMENGS   dc.b  BELL
         dc.b  'THE ENTERPRISE IS OUT OF ENERGY. IT CAN NO LONGER EXIST.'
         dc.b  EOT
NMTMST   dc.b  BELL
         dc.b  'YOU HAVE RUN OUT OF STARDATES FOR THIS MISSION.'
         dc.b  EOT
NMKLST   dc.b  LF,BELL
         dc.b  'CONGRATULATIONS!'
         dc.b  LF,CR,0,0,0,0
         dc.b  'YOU HAVE DESTROYED ALL THE KLINGONS.'
         dc.b   EOT
FAILST   dc.b  'YOUR MISSION WAS A FAILURE, THE FEDERATION MUST SURRENDER.'
         dc.b   EOT
SUCCST   dc.b  'THE FEDERATION HAS BEEN SAVED BY YOUR GALLANT ACTIONS.'
         dc.b  CR,LF
         dc.b  'YOU ARE AWARDED THE STARFLEET MEDAL OF HONOR.'
         dc.b   EOT
SUPDES   dc.b  'MESSAGE FROM STARFLEET COMMAND:'
         dc.b  CR,LF
         dc.b  '     THE ENTERPRISE HAS JUST BEEN DESTROYED BY A'
         dc.b  CR,LF
         dc.b  '     SUPERNOVA IN IT',APOS,'S CURRENT QUADRANT - ALL HANDS LOST.'
         dc.b  EOT
SUPSTR   dc.b  BELL
         dc.b  'SENSORS REPORT A SUPER NOVA IN QUADRANT '
         dc.b   EOT
HEVDAM   dc.b  'BADLY DAMAGED'
         dc.b   EOT
DMGDST   dc.b  'DEVICE IS DAMAGED AND UNUSABLE.  REPAIRS HAVE BEEN STARTED'
         dc.b   EOT
DMRPST   dc.b  LF
         dc.b  'DEVICE     STATUS'
         dc.b   EOT
DEVSTR   dc.b  'ENGINES   '
         dc.b   EOT
         dc.b  'SHORT SCAN'
         dc.b   EOT
         dc.b  'LONG SCAN '
         dc.b   EOT
         dc.b  'PHASORS   '
         dc.b   EOT
         dc.b  'TORPEDOS  '
         dc.b   EOT
         dc.b  'SHIELDS   '
         dc.b   EOT
         dc.b  'TELEPORTER'
         dc.b   EOT
         dc.b  'TRACTOR BM'
         dc.b   EOT
         dc.b  'COMPUTER  '
         dc.b   EOT
PLAYAG   dc.b  'WOULD YOU LIKE TO PLAY AGAIN? (Y-N): '
         dc.b   EOT
SCONBD   dc.b  'THE SHUTTLE CRAFT IS REPORTED ON BOARD, SIR'
         dc.b   EOT
NOPICK   dc.b  'THE SENSORS SHOW NOTHING TO BE PICKED UP, SIR'
         dc.b   EOT
EXPCMD   dc.b  'THE COMMANDS ARE AS FOLLOWS:'
         dc.b  CR,LF,$A
         dc.b  'CMND   ACTION'
         dc.b  CR,LF
         dc.b  ' EN    ACTIVATE WARP ENGINGS'
         dc.b  CR,LF
         dc.b  ' SR    SHORT RANGE SCAN'
         dc.b  CR,LF
         dc.b  ' LR    LONG RANGE SCAN'
         dc.b  CR,LF
         dc.b  ' PH    FIRE PHASOR BEAMS'
         dc.b  CR,LF
         dc.b  ' PT    FIRE PHOTON TORPEDOS'
         dc.b  CR,LF
         dc.b  ' DR    DAMAGE REPORT'
         dc.b  CR,LF
         dc.b  ' SH    SHIELDS UP OR DOWN'
         dc.b  CR,LF
         dc.b  ' TP    TELEPORT TO BASE QUADRANT'
         dc.b  CR,LF
         dc.b  ' SD    SELF DESTRUCT SEQUENCE'
         dc.b  CR,LF
         dc.b  ' TB    ACTIVATE TRACTOR BEAMS'
         dc.b  CR,LF
         dc.b  ' CO    BATTLE COMPUTER'
         dc.b  CR,LF
         dc.b  EOT
SHTSIG   dc.b  'SENSORS REPORT SHUTTLE CRAFT GALILLEO IN THIS QUADRANT, SIR'
         dc.b  EOT
SCBKUP   dc.b 'SHUTTLE CRAFT SENSORS PROVIDING BACKUP SCAN, SIR'
         dc.b  EOT
CPRMPT   dc.b  'COMPUTER IS CAPABLE OF 3 FUNCTIONS:'
         dc.b  CR,LF
         dc.b  '   T = TORPEDO SPREAD'
         dc.b  CR,LF
         dc.b  '   M = PRINT SCAN HISTORY MAP'
         dc.b  CR,LF
         dc.b  '   S = SET AUTO SCAN'
         dc.b  CR,LF,LF
         dc.b  'ENTER COMPUTER COMMAND: '
         dc.b  EOT
CMPHST   dc.b  'STATUS OF QUADRANTS WHEN LAST SCANNED (**** = NO SCAN YET)'
         dc.b  CR,LF,EOT
NOSCAN   dc.b  '**** '
         dc.b  EOT
HWMANY   dc.b 'ENTER NUMBER OF TORPEDOS IN SPREAD (0-9): '
         dc.b  EOT
SRMODE   dc.b 'AUTO SCAN ON FOR SHORT RANGE SENSORS? (Y-N): '
         dc.b  EOT
LRMODE   dc.b 'AUTO SCAN ON FOR LONG RANGE SENSORS? (Y-N): '
         dc.b  EOT
*
