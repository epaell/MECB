               cpu      68008
;
; NAM STAR TREK
;****************************
; STAR TREK GAME 1.2
; BY UNKNOWN SOURCE
;
; ADOPTED TO RUN ON THE 68008
; BY EMIL LENC 2025
;****************************

;
; MONITOR ROUTINE ADDRESSES
;
CR       EQU   $0D
LF       EQU   $0A
EOT      EQU   $04
BELL     EQU   $07
APOS     EQU   $27
;
; STORAGE AREAS
;

STPSFL   EQU   $8020
BASEX    EQU   $8021
BASEY    EQU   $8022
BASESX   EQU   $8023
BASESY   EQU   $8024
GLMFLG   EQU   $8025
SECKLN   EQU   $8026
FLAGC    EQU   $8027
TIMDEC   EQU   $8028
STCFLG   EQU   $8029
SQFLG    EQU   $802A
PNTFLG   EQU   $802B
COURSE   EQU   $802C
WARP     EQU   $802D
FINCX    EQU   $802E
FINCY    EQU   $802F
COUNT    EQU   $8030
GAMTIM   EQU   $8039
TOPFLG   EQU   $8042
BOTFLG   EQU   $8043
LSDFLG   EQU   $8044
RSDFLG   EQU   $8045
PHOTON   EQU   $8046
CURQUX   EQU   $8047
CURQUY   EQU   $8048
CURSCX   EQU   $8049
CURSCY   EQU   $804A
TRIALX   EQU   $804B
TRIALY   EQU   $804C
FLAG     EQU   $804D
CNDFLG   EQU   $804E
SCANX    EQU   $804F
SCANY    EQU   $8050
COUNT1   EQU   $8051
SECINF   EQU   $8052
MASK     EQU   $8053
KLNGCT   EQU   $8054
LENGTH   EQU   $8055
ASAVE    EQU   $8056
SHIELD   EQU   $8057
TSAVE1   EQU   $805A
HITKLS   EQU   $805B
HITSTR   EQU   $805C
HITBAS   EQU   $805D
GALCNT   EQU   $8060
DAMENG   EQU   $8061
DAMSRS   EQU   $8062
DAMLRS   EQU   $8063
DAMPHS   EQU   $8064
DAMPHT   EQU   $8065
DAMSHL   EQU   $8066
DAMTEL   EQU   $8067
DAMTRB   EQU   $8068
DAMCOM   EQU   $8069
PCOUNT   EQU   $806A       ; TORP SPREAD COUNT
PTZFLG   EQU   $806B       ; NO MORE TORP FLAG
GAMEND   EQU   $806C
AUTOSR   EQU   $806D
AUTOLR   EQU   $806E
SUPFLG   EQU   $806F
TELFLG   EQU   $8070
PASWRD   EQU   $8075
PHTFLG   EQU   $8078
SHUTCR   EQU   $8079
SHUTLX   EQU   $807A
SHUTLY   EQU   $807B
QUDMAP   EQU   $807C
COMMAP   EQU   $80BC       ; MUST FOLLOW QUDMAP IMMEDIATELY
SECMAP   EQU   $80FC       ; PACKED SECTOR (64*2 BITS) 00=., 01=*, 10=K, 11=B
;
STUF     EQU   $810C       ; SEED FOR RANDOM FUNCTION
TEMP1    EQU   $8110       ; word temporary variable
TIME0    EQU   $8112
TIMUSE   EQU   $8114
SHENGY   EQU   $8116
KLNENG   EQU   $8118
PHSENG   EQU   $811A
ENERGY   EQU   $811C
ATKENG   EQU   $811D
;
TEMP2    EQU   $8120       ; long-word temporary variable
TEMP3    EQU   $8124
XTEMP1   EQU   $8128
QUDPTR   EQU   $812C       ; POINTS TO CURR LOC IN QUDMAP

         include  'tutor.inc'
         include  'mecb.inc'
; PROGRAM ENTRY
;
         ORG   $4000
         JMP   STRTRK
;
; TABLE OF MOVE VECTORS
;
MOVTBL   dc.b  $00,$FF,$01,$FF,$01,$00,$01,$01       ; FF=-1
         dc.b  $00,$01,$FF,$01,$FF,$00,$FF,$FF
;
; CHARACTER PRINT TABLE
;
CHRTBL   dc.b  '.*KBN'
;
; COMMAND CODE TABLE
;
         align 2
CMDTBL   dc.b  'ENSRLRPHPTDRSHTPSDTBCO'
         align 2
;
; COMMAND JUMP TABLE
;
JMPTBL   dc.l  SETCRS
         dc.l  SRSCAN
         dc.l  LRSCAN
         dc.l  PHASOR
         dc.l  PHOTOR
         dc.l  DAMRPT
         dc.l  SHLDS
         dc.l  TELEPT
         dc.l  SELFDE
         dc.l  TRCTBM
         dc.l  COMPTR
;
INCH     move.b   #INCHE,d7
         trap     #14
         rts
;
CONTRL   move.b   #TUTOR,d7
         trap     #14
;
PDATA    move.b   #OUTCH,d7
         trap     #14
         lea.l    1(a1),a1
PDATA3   move.b   (a1),d0
         cmp.b    #EOT,d0
         bne      PDATA
         rts
;
PCRLF    move.b   #CR,d0
         move.b   #OUTCH,d7
         trap     #14
         move.b   #LF,d0
         move.b   #OUTCH,d7
         trap     #14
         rts
;
PSTRNG   bsr   PCRLF
         bsr   PDATA3
         rts
;
OUTHLST  move.l   d0,-(a7)    ; save register
         lsr.b    #4,d0       ; get the upper nybble
         bsr      OUTHRST
         move.l   (a7)+,d0    ; restore register
         rts
;
OUTHRST  move.l   d0,-(a7)    ; save register
         and.b    #$0F,d0
         or.b     #$30,d0
         cmp.b    #$39,d0
         bls      OUTDIG      ; 0-9 then output
         add.b    #7,d0       ; convert to A-F
OUTDIG   move.b   #OUTCH,d7   ; Output a digit
         trap     #14
         move.l   (a7)+,d0    ; restore register
         rts
;
OUTSST   move.l   d0,-(a7)    ; save register
         move.b   #SP,d0
         bsr      OUTDIG
         rts
;
; LIB RANDOM
RANDOM   move.w   STUF,d0     ; COMPUTE (STUF * 2 * * 10) MOD 2 ** 16
         lsl.w    #10,d0
         add.w    stuff,d0    ; Add STUF
         lsl.w    #2,d0       ; *4
         add.w    stuff,d0    ; Add STUF
         add.w    #$3619,d0   ; Add $3619
         move.w   d0,STUF     ; Save
         move.b   STUF,d0     ; get the MSB
         rts
;
; PRINT TITLE
;
STRTRK   move.l   #TITLE,a1
         bsr      PSTRNG
;
; CLEAR ALL TEMP STORAGE
;
         move.l   #STPSFL,a0
SETCLR   move.b   #$00,(a0)+
         cmp.l    #STUF,a0    ; LAST VALUE OF RAM AREA
         bne      SETCLR
         move.l   #COMMAP,a0
CLRMAP   move.n   #$ff,(a0)+
         cmp.l    #COMMAP+64,a0
         bne      CLRMAP
         move.l   #SHTLNG,a1
         bsr      PSTRNG
         bsr      INCH
         cmp.b    #'S',d0
         beq      SETQD
         add.b    #1,LENGTH         ; SET LONG FLAG
;
; SETUP SPACE
;
SETUPQD  move.l   #QUDMAP,a0
         move.b   #64,d1
SETUP0   bsr      RANDOM
         cmp.b    #$FC,d0
         bls      SETUP1
         move.b   #4,d0
         bra      SETUP5
SETUP1   cmp.b    #$F7,d0
         bls      SETUP2
         move.b   #3,d0
         bra      SETUP5
SETUP2   cmp.b    #$E0,d0
         bls      SETUP3
         move.b   #2,d0
         bra      SETUP5
SETUP3   cmp.b    #$A0,d0
         bls      SETUP4
         move.b   #1,d0
         bra      SETUP5
SETUP4   move.b   #0,d0
SETUP5   move.b   #0,ASAVE
         tst.b    LENGTH
         beq      SETUP8
         move.b   d0,ASAVE
         bsr      RANDOM
         cmp.b    #$F0
         bls      SETUP6
         move.b   #3,d0
         bra      SETUP8
SETUP6   cmp.b    #$C0,d0
         bls      SETUP7
         move.b   #2,d0
         bra      SETUP8
SETUP7   move.b   #0,d0
SETUP8   add.b    ASAVE,d0
         move.b   d0,(a0)            ; STORE SECT KLNGON CNT
         add.b    d0,KLNGCT
STARS    bsr      RANDOM
         and.b    #$38,d0
         or.b     d0,(a0)
CONT     lea.l    1(a0),a0
         sub.b    #1,d1
         beq      CONT1
         bra      SETUP0
;
DAA      move.l   d2,-(a7)   
         move.b   d0,d2
         and.b    #$f0,d2        ; d2 has upper nybble
         and.b    #$0F,d0
         cmp.b    #$0A,d0
         blt      DAA2
         add.b    #6,d0
         add.b    #$10,d2        ; adjust d2
DAA2     cmp.b    #$A0,d2
         blt      DAA3
         add.b    #6,d2
DAA3     add.b    d2,d0          ; d0 has decimal adjusted number
         move.l   (a7)+,d2
         rts

;
; GET STARBASE LOCATION
;
CONT1    bsr      RANDOM
         and.b    #$7,d0
         move.b   d0,d1
         bsr      RANDOM
         and.b    #$7,d0
         move.b   d0,BASEX
         move.b   d1,BASEY
         add.b    #1,STPSFL
         move.l   #QUDMAP,a0
         bsr      STPSEX
         move.b   #$40,d0
         or.b     (a0),d0
         move.b   d0,(a0)
CONT2    bsr      REFUEL
         bsr      RANDOM
         bsr      DAA
         move.b   d0,TIME0+1
         bsr      RANDOM
         and.b    #$7F,d0
         or.b     #$23,d0
         bsr      DAA
         move.b   d0,TIME0
         bsr      MAKTIM
         tst.b    LENGTH
         beq      GATM
         move.b   d0,d2
         bsr      MAKTIM
         add.b    d2,d0
         bsr      DAA
GATM     move.b   d0,GAMTIM
         bsr      RANDOM         ; SET SHUTTLECRAFT LOCATION
         and.b    #$7,d0
         move.b   d0,SHUTLX
         bsr      RANDOM
         and.b    #$7,d0
         move.b   d0,SHUTLY
         bra      CONT3
;
; REFUEL THE ENTERPRISE
;
REFUEL   move.b   #$00,SHIELD
         move.w   #$3000,ENERGY
         move.w   #$3000,SHENGY
         move.b   #15,PHOTON
         move.l   #DAMENG,a1     ; FIX ALL DAMAGE
REFUL1   move.b   #$00,(a1)+
         cmp.l    #DAMENG+9,a1
         bne      REFUL1
         rts
;
; CALCULATE GAME TIME
;
MAKTIM   bsr      RANDOM
         and.b    #$0F,d0
         or.b     #$31,d0
         bsr      DAA
         rts
;
; CONTINUE SETUP
;
CONT3    bsr      RANDOM
         and.b    #7,d0
         move.b   d0,CURQUX
         bsr      RANDOM
         and.b    #7,d0
         move.b   d0,CURQUY
         bsr      SETUPS
         move.l   #BASINF,a1
         bsr      PSTRNG
         move.b   BASEX,d0
         bsr      FIXOUT
         bsr      OUTDSH
         move.b   BASEY,d0
         bsr      FIXOUT
         move.l   #INTRO0,a1
         bsr      PSTRNG
         move.l   #PASWRD,a1
         move.b   #3,d1
CONT4    bsr      INCH
         move.b   d0,(a1)+
         sub.b    #1,d1
         bne      CONT4
         move.l   #INTRO1,a1
         bsr      PSTRNG
         bsr      OUTDAT
         move.l   #INTRO2,a1
         bsr      PSTRNG
         bsr      OUTKLN
         move.l   #INTRO3,a1
         bsr      PSTRNG
         move.b   #0,TEMP1
         move.b   GAMTIM,d0
         move.b   d0,TEMP1+1
         bsr      OUTBCD
         move.l   #INTRO4,a1
         bsr      PSTRNG
         bsr      OUTQUD
         move.l   #INTRO6,a1
         bsr      PSTRNG
         bsr      OUTSEC
         bra      COMAND
;
; OUTPUT A NUMBER
;
FIXOUT   add.b    #$31,d0
         bsr      OUTCH
         rts
;
; OUTPUT STARDATE
;
OUTDAT   move.w   TIME0,d0
         move.w   d0,TEMP1
         bsr      OUTBCD
         move.b   #'.',d0
         bsr      OUTCH
         move.b   TIMDEC,d0
         bsr      OUTHRST
         rts
;
; OUTPUT A KLINGON COUNT
;
OUTKLN   move.b   KLNGCT,d0
OUTK0    move.b   #0,TEMP1
OUTK1    move.b   #0,TEMP1+1
         move.b   #10,d1
OUTK2    sub.b    d1,d0
         bcs      OUTK3
         add.b    #1,TEMP1+1
         cmp.b    TEMP1+1,d1
         bne      OUTK2
         add.b    #1,TEMP1
         bra      OUTK1
OUTK3    add.b    d1,d0
         move.b   TEMP1+1,d1
         asl.b    #4,d1
         add.b    d1,d0
         move.b   d0,TEMP1+1
         bsr      OUTBCD
         rts
;
; OUTPUT QUADRANT LOCATION
;
OUTQUD   move.b   CURQUY,d0
         bsr      FIXOUT
         bsr      OUTDSH
         move.b   CURQUX,d0
         bsr      FIXOUT
         rts
;
; OUTPUT A SECTOR
;
OUTSEC   move.b   CURSCY,d0
         bsr      FIXOUT
         bsr      OUTDSH
         move.b   CURSCX,d0
         bsr      FIXOUT
         rts
;
; OUTPUT A DASH
;
OUTDSH   move.b   #'-',d0
         bsr      OUTCH
         rts
;
; ADD THE A-REG TO THE INDEX REGISTER
;
FIXXRG   and.l    #$ff,d0
         add.l    d0,a0
         rts
;
; GET COMMAND AND PERFORM IT
;
COMAND   move.b   GAMTIM,d0
         cmp.b    TIMUSE+1,d0
         bhi      NOEXTC
         bra      NOMTIM
NOEXTC   tst.b    KLNGCT
         bne      NOEXT2
         bra      NOMKLN
NOEXT2   tst.b    SUPFLG
         beq      NOEXT4
         move.l   #SUPDES,a1
         bsr      PSTRNG
         bsr      SELFDA
         bra      ENDGAM
;
NOEXT4   bsr      CLRCQU         ; CLEAR K & S
         move.b   #2,d0
         cmp.b    CNDFLG,d0         ; DOCKED?
         beq      CMND27
         move.b   #0,CNDFLG
         tst.b    SECKLN         ; RED?
         beq      CMNDAC
         sub.b    #1,d0
         move.b   d0,CNDFLG
CMNDAC   bsr      RANDOM
         cmp.b    #$FC,d0           ; SPACE STORM
         bls      COMND2
         move.l   #SPSTRM,a1
         bsr      PSTRNG
         move.b   #2,d0
         move.b   d0,DAMSHL
         bsr      SHLDWN
;
COMND2   bsr      RANDOM
         cmp.b    #$FC,d0           ; SUPERNOVA?
         bls      CMND25
         bsr      SUPNOV
CMND25   bsr      ATTACK         ; ALLOW ATTACK
         tst.b    ENERGY
         bpl      COMND0
         bra      NRGOUT
;
COMND0   tst.b    SHUTCR
         bne      CMND01
         move.b   SHUTLX,d0
         cmp.b    CURQUX,d0
         bne      CMND01
         move.b   SHUTLY,d0
         cmp.b    CURQUY,d0
         bne      CMND01
         move.l   #SHTSIG,a1
         bsr      PSTRNG
CMND01   move.b   #3,d0
         cmp.b    ENERGY,d0
         bls      CMNDAD
         move.b   d0,CNDFLG
CMNDAD   tst.b    SHENGY
         bpl      CMND27
         move.b   #0,d0
         move.b   d0,SHIELD
         move.b   d0,SHENGY
         move.b   d0,SHENGY+1
CMND27   move.l   #COMST,a1      ; PRINT COMMAND PROMPT
         bsr      PSTRNG
         move.b   #0,STCFLG
         move.b   #0,PHTFLG
COMND3   bsr      INCH
         cmp.b    #CR,d0
         beq      ILCMND
         move.b   d0,d1
         lsl.w    #8,d1
         bsr      INCH
         and.w    #$FF,d0
         add.w    d1,d0          ; d0.w now has two character command
         move.l   #CMDTBL,a0
         move.l   #0,d2          ; Command offset
CHKCM1   cmp.w    (a0),d0
         beq      GOTCMD
INX2     lea.l    2(a0),a0       ; point to next potential command in table
         add.l    #1,d2          ; next command
         cmp.l    #JMPTBL,a0     ; last command?
         bne      CHKCM1         ; no, loop back
ILCMND   move.l   #EXPCMD,a1
         bsr      PSTRNG
         bra      COMND3
;
GOTCMD   lsl.l    #2,d2          ; Offset to command jump table (long words)
         move.l   #JMPTBL,a0
         add.l    d2,a0
GCMD1    move.l   (a0),a0        ; Get the routine address
         jsr      (a0)
         tst.b    GAMEND
         beq      CMND99
         bra      ENDGAM
CMND99   bra      COMAND
;
; OUTPUT A 4 DIGIT BCD NUMBER
;
OUTBCD   move.b   #0,FLAG
         move.b   TEMP1,d0       ; Get thousands and hundreds digits
         beq      OUTBC2         ; check for zero
         and.b    #$F0,d0        ; Get thousands digit
         beq      OUTBC1         ; check for zero
         move.b   TEMP1,d0
         bsr      OUTHLST        ; output thousands digit
OUTBC1   move.b   TEMP1,d0
         and.b    #$0F,d0
         bsr      OUTHRST        ; output hundreds digit
         add.b    #1,FLAG
OUTBC2   move.b   TEMP1+1,d0     ; get tens and units digits
         tst.b    FLAG           ; check if digits already output
         bne      NOZERO
         and.b    #$F0,d0        ; check tens digit
         beq      OUTBC3
NOZERO   bsr      OUTHLST        ; output tens digit
OUTBC3   move.b   TEMP1+1,d0
         and.b    #$0F,d0
         bsr      OUTHRST        ; output units digit
         rts
;
; LOWER THE SHIELDS
;
SHLDS    tst.b    SHIELD
         beq      SHLDUP
SHLDWN   move.b   #0,SHIELD
         move.l   #DWNST,a1
         bsr      PSTRNG
SHLD1    rts
;
; RAISE THE SHIELDS
;
SHLDUP   move.b   SHENGY,d0
         cmp.b    #1,d0
         bls      SHLD1
         tst.b    DAMSHL
         bne      SHLDWN
         add.b    #1,SHIELD
         move.l   #SHENGY,a0
         move.b   #2,TEMP1
         move.b   #0,TEMP1+1
         bsr      BCDSUB
         move.l   #UPSTR,a1
         bsr      PSTRNG
         rts
;
; SHORT RANGE SCAN
;
SRSCAN   tst.b    DAMSRS
         beq      SSCAN1
         tst.b    SHUTCR
         bne      SSCAN0
         bsr      RPTDAM
         rts
SSCAN0   move.l   #SCBKUP,a1
         bsr      PSTRNG
SSCAN1   bsr      PCRLF
         move.b   #0,SCANY
         move.b   CNDFLG,d0
         cmp.b    #2,d0
         bne      SSCAN2
         bsr      REFUEL
SSCAN2   move.l   #SECMAP,a0
         move.l   a0,TEMP2
         bsr      DOSCAN
         move.l   #SDATE,a1
         bsr      PDATA3
         bsr      OUTDAT
         bsr      DOSCAN
         move.l   #CNDTNS,a1
         bsr      PDATA3
         move.b   CNDFLG,d0
         beq      SRSCN1
         cmp.b    #1,d0
         beq      SRSCN0
         cmp.b    #3,d0
         beq      OUTCN1
         move.l   #DOCKED,a1
         bsr      PDATA3
         bra      SRSCN2
;
OUTCN1   move.l   #YELLOW,a1
         bsr      PDATA3
         bra      SRSCN2
;
SRSCN0   move.l   #RED,a1
         bsr      PDATA3
         bra      SRSCN2
;
SRSCN1   move.l   #GREEN,a1
         bsr      PDATA3
         bra      SRSCN2
;
SRSCN2   bsr      DOSCAN
         move.l   #QUADP,a1
         bsr      PDATA3
         bsr      OUTQUD
         bsr      DOSCAN
         move.l   #SECP,a1
         bsr      PDATA3
         bsr      OUTSEC
         bsr      DOSCAN
         move.l   #ENGSTR,a1
         bsr      PDATA3
         move.w   ENERGY,a1
         move.w   a1,TEMP1
         bsr      OUTBCD
         bsr      DOSCAN
         move.l   #KLSTR,a1
         bsr      PDATA3
         bsr      OUTKLN
         bsr      DOSCAN
         move.l   #SHSTR,a1
         bsr      PDATA3
         move.w   SHENGY,a1
         move.w   a1,TEMP1
         bsr      OUTBCD
         tst.b    SHIELD
         beq      SRSCN4
         move.l   #UPSCAS,a1
         bra      SRSCN5
;
SRSCN4   move.l   #DNSCAS,a1
SRSCN5   bsr      PDATA3
         bsr      DOSCAN
         move.l   #TRPSTR,a1
         bsr      PDATA3
         move.b   #0,TEMP1
         move.b   PHOTON,d0
         bsr      DAA
         move.b   TEMP1+1
         bsr      OUTBCD
         move.l   QUDPTR,a0   ; UPDATE COMPUTER MAP
         move.b   (a0)d0
         bsr      UPDCMP
         rts
;
; OUTPUT 1 SHORT RANGE SCAN LINE
;
DOSCAN   bsr      PCRLF
         move.b   #2,COUNT
         move.b   #0,SCANX
DOSCN    move.b   #4,COUNT1
         move.l   TEMP2,a0
         move.b   (a0),d0
DOSCN0   move.b   d0,ASAVE
         move.b   CURSCY,d0
         cmp.b    SCANY,d0       ; IS IT Y-LOC OF ENTERPRISE?
         bne      CHK0
         move.b   CURSCX,d0
         cmp.b    SCANX,d0
         bne      CHK0
         move.b   #'E',d0
         bsr      OUTCH
         bra      GOAHD
CHK0     move.b   ASAVE,d0
DOSCN1   move.l   #CHRTBL,a0
         and.l    #$03,d0
         bsr      FIXXRG
         move.b   (a0),d0
         bsr      OUTCH
GOAHD    bsr      OUTSST
         move.l   TEMP2,a0
         add.b    #1,SCANX
         sub.b    #1,COUNT1
         beq      DOSCN2
         move.b   ASAVE,d0
         lsr.b    #2,d0
         bra      DOSCN0
DOSCN2   lea.l    1(a0),a0
         move.l   a0,TEMP2
         move.b   (a0),d0
         sub.b    #1,COUNT
         bne      DOSCN
         add.b    #1,SCANY
         rts
;
; SETUP SECTOR MAP
;
SETUPS   move.b   #0,SECKLN
         move.l   #SECMAP,a0
         move.b   #16,d1
         move.b   #0,d0
SETPS1   move.b   d0,(a0)+
         sub.b    #1,d1
         bne      SETPS1
         move.l   #QUDMAP,a0
         move.b   CURQUX,d0
         move.b   CURQUY,d1
STPSEX   move.b   d0,ASAVE
         tst.b    d1
         beq      SETPS4
SETPS2   move.b   #8,d0
SETPS3   lea.l    1(a0),a0
         sub.b    #1,d0
         bne      SETPS3
         sub.b    #1,d1
         bne      SETPS2
SETPS4   move.b   ASAVE,d0
         beq      SETPS6
SETPS5   lea.l    1(a0),a0
         sub.b    #1,d0
         bne      SETPS5
SETPS6   tst.b    STPSFL
         beq      STPSNX
         move.b   #0,STPSFL
         rts
;
STPSNX   move.l   a0,QUDPTR
         move.b   (a0),d1
         move.b   d1,SECINF
         beq      SETP10
         and.b    #7,d1
         beq      SETPS7
         move.b   d1,COUNT
         move.b   d1,SECKLN
         move.b   #2,d0
         move.b   d0,MASK
         bsr      PUTINM
SETPS7   move.b   SECINF,d1
         and.b    #$38,d1
         beq      SETPS8
         lsr.b    #3,d1
         move.b   d1,COUNT
         move.b   #1,d0
         move.b   d0,MASK
         bsr      PUTINM
SETPS8   move.b   SECINF,d1
         btst.b   #6,d1       ; bitb #$40
         beq      SETPS9
         move.b   #1,d0
         move.b   d0,COUNT
         move.b   #3,d0
         move.b   d0,MASK
         bsr      PUTINM
SETPS9   move.b   SECINF,d1
         bpl      SETP10
         add.b    #1,SUPFLG
SETP10   bsr      RANDOM
         and.b    #7,d0
         move.b   d0,TRIALX
         bsr      RANDOM
         and.b    #7,d0
         move.b   d0,TRIALY
         bsr      CHKPOS
         tst.b    FLAG
         bne      SETP10
         move.b   TRIALX,d0
         move.b   d0,CURSCX
         move.b   TRIALY,d0
         move.b   d0,CURSCY
;
; COMPUTE LOCAL KLINGON ENERGY
;
CSCKEN   move.b   SECKLN,d1
         asl.b    #1,d1
         move.l   #KLNENG,a0
CSCEXT   move.b   #0,(a0)
         move.b   #0,1(a0)
CSCKN1   bsr      RANDOM
         bsr      DAA
         move.b   #0,TEMP1
         move.b   d0,TEMP1+1
         bsr      BCDADD
         sub.b    #1,d1
         bne      CSCKN1
         rts
;
; PUT OBJECTS IN SECTOR MAP
;
PUTINM   move.l   #SECMAP,a0
         bsr      RANDOM
         and.b    #$0F,d0
         move.b   d0,TSAVE1
         bsr      FIXXRG
         move.b   (a0),d1
         bsr      RANDOM
         and.b    #3,d0
         move.b   d0,ASAVE
         beq      PUTIN2
PUTIN1   ror.b    #2,d1
         sub.b    #1,d0
         bne      PUTIN1
PUTIN2   move.b   d1,d2
         and.b    #3,d2
         bne      PUTINM
         or.b     MASK,d1
         move.b   ASAVE,d0
         beq      PUTIN4
PUTIN3   rol.b    #2,d1
         sub.b    #1,d0
         bne      PUTIN3
PUTIN4   move.b   d1,(a0)
         sub.b    #1,COUNT
         bne      PUTINM
         move.b   MASK,d0
         cmp.b    #3,d0
         bne      PUTIN6
         move.b   TSAVE1,d1
         and.b    #$FE,ccr    ; CLC
         ror.b    #1,d1
         move.b   ASAVE,d0
         bcc      PUTIN5
         add.b    #4,d0
PUTIN5   move.b   d0,BASESX
         move.b   d1,BASESY
PUTIN6   rts
;
; CHECK FOR EMPTY POSITIONS
;
CHKPOS   move.b   #0,FLAG
         move.l   a0,XTEMP1
         move.l   #SECMAP,a0
         move.b   TRIALY,d0
         beq      CHKPO2
CHKPO1   lea.l    2(a),a0
         sub.b    #1,d0
         bne      CHKPO1
CHKPO2   move.b   TRIALX,d0
         cmp.b    #3,d0
         bls      CHKPO3
         lea.l    1(a0),a0
         sub.b    #4,d0
CHKPO3   move.b   (a0),d0
         move.b   d0,ASAVE
         beq      CHKPO5
CHKPO4   lsl.b    #2,d1
         sub.b    #1,d0
         bne      CHKPO4
CHKPO5   and.b    #3,d1
         beq      CHKPO6
         move.b   d1,FLAG
         tst.b    STCFLG
         beq      CHKPO6
         tst.b    PHTFLG
         bne      CHKPO7
         cmp.b    #2,d1
         beq      CHKPO7
CHKPO6   move.l   XTEMP1,a0
         rts
;
CHKPO7   move.b   #$FC,d1
         move.b   ASAVE,d0
         beq      CHKPO9
         or.b     #1,ccr      ;SEC
CHKPO8   rol.b    #2,d1
         sub.b    #1,d0
         bne      CHKPO8
CHKPO9   and.b    (a0),d1
         move.b   s1,(a0)
         bra      CHKPO6
;
; FIRE PHOTON TORPEDO
;
PHOTOR   tst.b    DAMPHT
         beq      PTRNDM
PTRND9   bsr      RPTDAM
         rts
PTRNDM   tst.b    PHOTON      ; ANY LEFT
         bne      PHOTRO
PTEMPT   move.l   #PTEMST,a1
         bsr      PSTRNG
         add.b    #1,PTZFLG
         rts
;
PHOTRO   add.b    #1,PHTFLG
         bsr      RANDOM
         and.b    #$0F,d0
         or.b     #4,d0
         move.b   d0,WARP
         sub.b    #1,PHOTON
;
; WARP ENGINES AND PHOTON TORP COURSE
;
SETCRS   move.b   #0,SQFLG
         move.b   #0,GLMFLG
         move.l   #CRSSTR,a1
         bsr      PSTRNG
         bsr      INCHCK
         cmp.b    #7,d0
         bhi      ABC29
         bsr      OUTSST
         bsr      OUTSST
         move.b   d0,COURSE
         tst.b    PHTFLG
         bne      PHTOR1
         move.l   #WRPSTR,a1
         bsr      PSTRNG
         bsr      INCHCK
         move.b   d0,WARP
         tst.b    PNTFLG
         bne      STCRS2
         move.b   d0,SQFLG
         tst.b    DAMENG
         bne      PTRND9
;
STCRS2   bsr      INCH
         cmp.b    #CR,d0
         bne      STCRS2
         move.b   COURSE,d0
PHTOR1   move.l   #MOVTBL,a0
         asl.b    #1,d0
         bsr      FIXXRG
         move.b   WARP,d0
         bne      ABC30
ABC29    rts
;
ABC30    move.b   d0,COUNT
         tst.b    SQFLG
         beq      STCRS3
         move.b   #$0F,d0
         move.b   d0,COUNT
STCRS3   move.b   CURSCX,d0
         move.b   CURSCY,d1
PHTOR2   add.b    (a0),d0
         add.b    1(a0),d1
         bsr      TSTBND
         tst.b    FINCX
         beq      ABC1
         bra      STCRS5
;
ABC1     tst.b    FINCY
         beq      ABC5
         bra      STCRS5
;
ABC5     move.b   d0,TRIALX      ; SAVE TRIAL POSITION
         move.b   d1,TRIALY
         tst.b    PHTFLG
         beq      ABC4
         bsr      OUTSST
         bsr      OBATSO
ABC4     add.b    #1,STCFLG
         bsr      CHKPOS      ; CHK IF BLKD
         move.b   FLAG,d0
         beq      STCRS4
         tst.b    PHTFLG
         beq      ABC2
         bra      PHTOR3
;
ABC2     cmp.b    #2,d0
         bne      ABC3
         bra      KLGRAM
;
ABC3     move.l   #BLOKST,a1
         bsr      PSTRNG
OBATSO   move.b   TRIALY,d0
         bsr      FIXOUT
         bsr      OUTDSH
         move.b   TRIALX,d0
         bsr      FIXOUT
         tst.b    PHTFLG
         beq      STCRET
         rts
;
STCRET   bra      STCRS6
;
STCRS4   tst.b    PHTFLG
         beq      STCRSB      ; JUMP IF NOT
         move.b   TRIALX,d0
         move.b   TRIALY,d1
         sub.b    #1,COUNT
         bne      PHTOR2
PHTOR4   move.l   #PNOENG,a1
         bsr      PSTRNG
         bra      STCRS6
;
STCRSB   move.b   TRIALX,d0
         move.b   d0,CURSCX
         move.b   TRIALY,d0
         move.b   d0,CURSCY
         bsr      RANDOM
         cmp.b    #$80,d0
         bls      STCRSC
         move.b   #1,d0
         bsr      FIXTIM
         move.b   #3,d0
         bsr      FIXENG
STCRSC   sub.b    #1,COUNT       ; DEC MOVE CNTR
         beq      STCRSD
         bra      STCRS3
;
STCRSD   tst.b    SQFLG
         bne      STCRS5      ; QUADRANT MOVE!
         bra      STCRS6
;
STCRS5   tst.b    PHTFLG
         beq      ABC6
         bra      PHTOR4
ABC6     move.b   WARP,d0
         move.b   d0,COUNT
ABC7     move.b   CURQUX,d0
         move.b   CURQUY,d1
         tst.b    SQFLG
         beq      STCRS7
         add.b    (a0),d0
         add.b    1(a0),d1
         move.b   d0,TRIALX
         move.b   d1,TRIALY
         bsr      TSTBND
         tst.b    FINCX
         beq      ABCD0
         bra      GALBND
;
ABCD0    tst.b    FINCY
         beq      ABCD1
         bra      GALBND
;
ABCD1    move.b   TRIALX,d0
         move.b   d0,CURQUX
         move.b   TRIALY,d0
         move.b   d0,CURQUY
         add.b    #1,GLMFLG
         move.b   #6,d0
         bsr      FIXTIM
         move.b   #$30,d0
         bsr      FIXENG
         sub.b    #1,COUNT
         bne      ABC7
STCRSA   bsr      SETUPS
STCRS6   move.b   #0,CNDFLG
         move.b   BASEX,d0
         cmp.b    CURQUX,d0
         bne      SEXIT1
         move.b   BASEY,d1
         cmp.b    CURQUY,d1
         bne      SEXIT1
         move.b   BASESX,d0
         move.b   BASESY,d1      ; DOCKED?
         add.b    #1,d0
         sub.b    CURSCX,d0
         cmp.b    #2,d0
         bhi      SEXIT1
SEXIT0   add.b    #1,d1
         sub.b    CURSCY,d1
         cmp.b    #2,d1
         bhi      SEXIT1
SDOCK    move.b   #2,d0
         move.b   d0,CNDFLG
SEXIT1   tst.b    AUTOSR
         beq      SEXIT2
         bsr      SRSCAN
SEXIT2   tst.b    AUTOLR
         beq      SEXIT3
         bsr      LRSCAN
SEXIT3   rts
;
STCRS7   add.b    FINCX,d0
         add.b    FINCY,d1
         cmp.b    #7,d0
         bhi      GALBND
         cmp.b    #7,d1
         bhi      GALBND
         move.b   d0,CURQUX
         move.b   d1,CURQUY
         move.b   #7,d0
         jsr      FIXTIM
         bra      STCRSA
;
; RAMMED A KLINGON ROUTINE
;
KLGRAM   move.l   #KRMSTR,a1
         bsr      PSTRNG
         move.b   #1,d0
         move.b   d0,COUNT
         move.b   #0,SQFLG
         add.b    #1,HITKLS
         sub.b    #1,KLNGCT      ; DEC KLINGON COUNT
         sub.b    #1,SECKLN
         add.b    #1,PHTFLG
         bsr      OBATSO
         move.l   #HEVDAM,a1
         bsr      PSTRNG
         move.b   #$6A,d1
         bsr      MANDAM
         move.l   #STILFT,a1
         bsr      PSTRNG
         bsr      OUTKLN
         bra      STCRSB
;
; PRINT GALAXY LIMIT MESSAGE
;
GALBND   move.l   #GLBNDS,a1
         bsr      PSTRNG
         move.b   GALCNT,d0
         add.b    #1,d0
         cmp.b    #3,d0
         bne      GALBN2
         move.l   #GALDUM,a1
         bsr      PSTRNG
         add.b    #1,GAMEND
         rts
;
GALBN2   move.b   d0,GALCNT
         tst.b    GLMFLG
         bne      ABC20
         bra      STCRS6
;
ABC20    bra      STCRSA
;
; TORPEDO HAS HIT SOMETHING
;
PHTOR3   move.l   #PHITST,a1
         bsr      PSTRNG
         move.b   FLAG,d0
         cmp.b    #2,d0          ; KLINGON?
         bne      ABC8
         sub.b    #1,SECKLN
         sub.b    #1,KLNGCT
         add.b    #1,HITKLS
         move.l   #KLGSTR,a1
         bsr      PDATA3
         move.l   #STILFT,a1
         bsr      PSTRNG
         bsr      OUTKLN
         bra      ABC10
;
ABC8     cmp.b    #1,d0          ; STAR?
         bne      ABC11
         add.b    #1,HITSTR
         move.l   #STARST,a1
ABC9     bsr      PDATA3
ABC10    rts
;
ABC11    move.l   #BASEST,a0     ; HIT BASE!
         add.b    #1,HITBAS
         bra      ABC9
;
; SEE IF GALAXY EDGE REACHED
;
TSTBND   move.b   #0,FINCX
         move.b   #0,FINCY
         tst.b    d0
         bpl      TSTBN1
         sub.b    #1,FINCX
         bra      TSTBN2
;
TSTBN1   cmp.b    #7,d0
         bls      TSTBN2
         add.b    #1,FINCX
TSTBN2   tst.b    d1
         bpl      TSTBN3
         sub.b    #1,FINCY
         rts
;
TSTBN3   cmp.b    #7,d1
         bls      TSTBN4
         add.b    #1,FINCY
TSTBN4   rts
;
; INPUT CHARACTER AND CHECK
;
INCHCK   move.b   #0,d0
INCHK0   move.b   d0,PNTFLG
         bsr      INCH
         cmp.b    #'.',d0
         beq      INCHK0
         cmp.b    #'9',d0
         bhi      INCHK1
         cmp.b    #'0'-1,d0
         bls      INCHK1
         sub.b    #$30,d0
         rts
;
INCHK1   move.l   #ERR,a1
         bsr      PDATA3
         bra      INCHCK
;
; ADD TO GAME TIME
;
FIXTIM   add.b    TIMDEC,d0
         cmp.b    #9,d0
         bls      FIXTM1
         sub.b    #10,d0
         move.b   d0,TIMDEC
         move.b   #0,TEMP1
         move.b   #1,d0
         move.b   d0,TEMP1+1
         move.l   a0,XTEMP1
         move.l   #TIME0,a0
         bsr      BCDADD
         move.l   #TIMUSE,a0
         bsr      BCDADD
         bsr      FIXDAM
         move.l   XTEMP1,a0
         rts
;
FIXTM1   move.b   d0,TIMDEC
         rts
;
;SUBTRACT FROM ENERGY AMOUNT
;
FIXENG   move.l   a0,XTEMP1
         move.l   #ENERGY,a0
         move.b   #0,TEMP1
         move.b   d0,TEMP1+1
         bsr      BCDSUB
         move.l   XTEMP1,a0
         rts
;
; BCD ADDITION
;
BCDADD   move.b   #$04,ccr    ; clear x and z bits
         move.l   TEMP1+2,a1  ; point to the byte AFTER the value we want to add
         lea.l    2(a0),a0
         abcd     -(a0),-(a1) ; add 4-digit BCD value pointed to by a0 from TEMP1
         abcd     -(a0),-(a1)
         rts
;
; BCD SUBTRACTION
;
BCDSUB   move.b   #$04,ccr    ; clear x and z bits
         move.l   TEMP1+2,a1  ; point to the byte AFTER the value we want to subtract
         lea.l    2(a0),a0
         sbcd     -(a0),-(a1) ; subtract 4-digit BCD value pointed to by a0 from TEMP1
         sbcd     -(a0),-(a1)
         rts
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
         move.l   #LRSCST,a1
         bsr      PSTRNG
         bsr      OUTQUD
         bsr      PCRLF
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
PHASR1   move.l   #ENAVLB,a1        ; REPORT ENERGY
         bsr      PSTRNG
         LDX   ENERGY
         STX   TEMP1
         JSR   OUTBCD
         move.l   #FIRENG,a1
         bsr      PSTRNG
         bsr      INBCD
         LDAA  PHSENG
         CMPA  ENERGY
         BHI   TOOMCH
         BNE   PHASR2
         LDAA  PHSENG+1
         CMPA  ENERGY+1
         BLS   PHASR2
TOOMCH   move.l   #TOMUCH,a1
TOOMC1   bsr      PSTRNG
         rts
;
PHASR2   bsr      RANDOM
         cmp.b    #$F4,d0
         bls      PHASR3
         move.l   #PHAMIS,a1
         bsr      PSTRNG
         bra      PHASR6
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
         move.l   #ALKILL,a1
         bsr      PSTRNG
         move.l   #STILFT,a1
         bsr      PSTRNG
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
         move.l   #KHTADM,a1
         bsr      PSTRNG
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
INEROR   move.l   #ERR,a1
         bsr      PDATA3
         bra      INBCD1
;
EXIT     rts
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
SELFDE   move.l   #ABORT1,a1
         bsr      PSTRNG
         LDX   #PASWRD
         LDAB  #3
SELFD1   bsr      INCH
         CMPA  0,X
         BNE   SELFD2
         INX
         DECB
         BNE   SELFD1
SELFDA   move.l   #DISINT,a1
         bsr      PSTRNG
         INC   GAMEND
         rts
;
SELFD2   move.l   #ABORT2,a1
         bsr      PSTRNG
         rts
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
TELEP2   move.l   #CANTUS,a1
         bsr      PSTRNG
         rts
;
TELEP4   move.l   #DMGDST,a1
         bsr      PSTRNG
         rts
;
TELEP5   bsr      RANDOM
         ANDA  #7
         STAA  CURQUX
         JSR   RANDOM
         ANDA  #7
         STAA  CURQUY
         move.l   #SOMWHR,a1
         bsr      PSTRNG
         bra      TELEPA
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
         move.l   #KATKDN,a1
         bsr      PDATA3
         LDAB  #$FA
         JSR   MANDAM
ATTAC2   RTS
;
ATTAC3   LDX   #SHENGY
         JSR   BCDSUB
         move.l   #KATKUP,a1
         bsr      PSTRNG
         rts
;
; END OF GAME CLEANUP ROUTINE
;
NRGOUT   move.l   #NMENGS,a1
NRGOU1   bsr      PSTRNG
         bra      ENDGAM
;
NOMTIM   move.l   #NMTMST,a1
         bsr      PSTRNG
         bra      ENDGAM
;
NOMKLN   move.l   #NMKLST,a1
         bsr      PSTRNG
         bra      ENDGM2
;
ENDGAM   move.l   #FAILST,a1
         bsr      PSTRNG
         bra      ENDGM3
;
ENDGM2   move.l   #SUCCST,a1
         bsr      PSTRNG
ENDGM3   move.l   #PLAYAG,a1
         bsr      PSTRNG
         bsr      INCH
         cmp.b    #'Y',d0
         beq      ENDGM4
         bsr      CONTRL
;
ENDGM4   bra      STRTRK
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
         move.l   #SUPSTR,a1
         bsr      PSTRNG
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
RPTDAM   move.l   #DMGDST,a1
         bsr      PSTRNG
RPTDM8   rts
;
; GENERATE A DAMAGE REPORT
;
DAMRPT   move.l   #DMRPST,a1
         bsr      PSTRNG
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
         move.l   TEMP2,a1
         bsr      PSTRNG
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
CMPTR1   move.l   #CPRMPT,a1
         bsr      PSTRNG
         bsr      INCH
         CMPA  #'T'
         BEQ   TSPRED
         CMPA  #'M'
         BEQ   CMPMAP
         CMPA  #'S'
         BNE   CMPTR1
         move.l   #SRMODE,a1
         bsr      PSTRNG
         CLR   AUTOSR
         bsr      INCH
         cmp.b    #'Y',d0
         bne      AUTO2
         INC   AUTOSR
AUTO2    move.l   #LRMODE,a1
         bsr      PSTRNG
         CLR   AUTOLR
         bsr      INCH
         cmp.b    #'Y',d0
         bne      AUTOEX
         INC   AUTOLR
AUTOEX   rts
;
CMPMAP   move.l   #CMPHST,a1
         bsr      PSTRNG
         LDX   #COMMAP
CMPMP1   bsr      PCRLF
         LDAA  #8
         STAA  COUNT
CMPMP2   LDAA  0,X
         CMPA  #$FF
         BNE   CMPMP3
         STX   TEMP3
         move.l   #NOSCAN,a1
         bsr      PDATA3
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
         move.l   #HWMANY,a1
         bsr      PSTRNG
         bsr      INCH
         cmp.b    #'0',d0
         blo      TS2
         beq      TSEX
         cmp.b    #'9',d0
         bgt      TS2
         and.b    #$0F,d0
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
NPCKUP   move.l   #NOPICK,a1
TRCTEX   bsr      PSTRNG
         rts
;
; TEXT STRINGS
;
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
;
