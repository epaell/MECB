*         TTL       MC68343 FAST FLOATING POINT COPYRIGHT NOTICE (FFPCPYRT)

*FFPCPYRT IDNT      1,1                   ;FFP COPYRIGHT NOTICE
*         XDEF      FFPCPYRT
*         SECTION   9

*************************************
* FFP LIBRARY COPYRIGHT NOTICE STUB *
*                                   *
*  THIS MODULE IS INCLUDED BY ALL   *
*  LINK EDITS WITH THE FFPLIB.RO    *
*  LIBRARY TO PROTECT MOTOROLA'S    *
*  COPYRIGHT STATUS.                *
*                                   *
*  CODE: 68 BYTES                   *
*                                   *
*  NOTE: THIS MODULE MUST RESIDE    *
*  LAST IN THE LIBRARY AS IT IS     *
*  REFERENCED BY ALL OTHER MC68343  *
*  MODULES.                         *
*************************************

FFPCPYRT  EQU       *
          DC.B      'MC68343 FLOATING POINT FIRMWARE '
          DC.B      '(C) COPYRIGHT 1981 BY MOTOROLA INC.'
          DC.B      0

*         END

*         TTL       FAST FLOATING POINT POWER OF TEN TABLE (FFP10TBL)
************************************
* (C) COPYRIGHT 1980 MOTORLA INC.  *
************************************

*FFP10TBL IDNT      1,1                   ;FFP POWER OF TEN TABLE
*         XDEF      FFP10TBL              ;ENTRY POINT
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*         SECTION   9

*****************************************
*         POWER OF TEN TABLE            *
*                                       *
*  EACH ENTRY CORRESPONDS TO A FLOATING *
*  POINT POWER OF TEN WITH A 16 BIT     *
*  EXPONENT AND 32 BIT MANTISSA.        *
*  THIS TABLE IS USED TO INSURE         *
*  PRECISE CONVERSIONS TO AND FROM      *
*  FLOATING POINT AND EXTERNAL FORMATS. *
*  THS IS USED IN ROUTINES "FFPDBF" AND *
*  "FFPFASC".                           *
*                                       *
*          CODE SIZE: 288 BYTES         *
*                                       *
*****************************************
*         PAGE

          DC.W      64                    ;10**19
          DC.L      $8AC72305
          DC.W      60                    ;10**18
          DC.L      $DE0B6B3A
          DC.W      57                    ;10**17
          DC.L      $16345785<<3+7
          DC.W      54                    ;10**16
          DC.L      $2386F26F<<2+3
          DC.W      50                    ;10**15
          DC.L      $38D7EA4C<<2+2
          DC.W      47                    ;10**14
          DC.L      $5AF3107A<<1+1
          DC.W      44                    ;10**13
          DC.L      $9184E72A
          DC.W      40                    ;10**12
          DC.L      $E8D4A510
          DC.W      37                    ;10**11
          DC.L      $174876E8<<3
          DC.W      34                    ;10**10
          DC.L      $2540BE40<<2
          DC.W      30                    ;10**9
          DC.L      1000000000<<2
          DC.W      27                    ;10**8
          DC.L      100000000<<5
          DC.W      24                    ;10**7
          DC.L      10000000<<8
          DC.W      20                    ;10**6
          DC.L      1000000<<12
          DC.W      17                    ;10**5
          DC.L      100000<<15
          DC.W      14                    ;10**4
          DC.L      10000<<18
          DC.W      10                    ;10**3
          DC.L      1000<<22
          DC.W      7                     ;10**2
          DC.L      100<<25
          DC.W      4                     ;10**1
          DC.L      10<<28
FFP10TBL  DC.W      1                     ;10**0
          DC.L      1<<31
          DC.W      -3                    ;10**-1
          DC.L      $CCCCCCCD
          DC.W      -6                    ;10**-2
          DC.L      $A3D70A3D
          DC.W      -9                    ;10**-3
          DC.L      $83126E98
          DC.W      -13                   ;10**-4
          DC.L      $D1B71759
          DC.W      -16                   ;10**-5
          DC.L      $A7C5AC47
          DC.W      -19                   ;10**-6
          DC.L      $8637BD06
          DC.W      -23                   ;10**-7
          DC.L      $D6BF94D6
          DC.W      -26                   ;10**-8
          DC.L      $ABCC7712
          DC.W      -29                   ;10**-9
          DC.L      $89705F41
          DC.W      -33                   ;10**-10
          DC.L      $DBE6FECF
          DC.W      -36                   ;10**-11
          DC.L      $AFEBFF0C
          DC.W      -39                   ;10**-12
          DC.L      $8CBCCC09
          DC.W      -43                   ;10**-13
          DC.L      $E12E1342
          DC.W      -46                   ;10**-14
          DC.L      $B424DC35
          DC.W      -49                   ;10**-15
          DC.L      $901D7CF7
          DC.W      -53                   ;10**-16
          DC.L      $E69594BF
          DC.W      -56                   ;10**-17
          DC.L      $B877AA32
          DC.W      -59                   ;10**-18
          DC.L      $9392EE8F
          DC.W      -63                   ;10**-19
          DC.L      $EC1E4A7E
          DC.W      -66                   ;10**-20
          DC.L      $BCE50865
          DC.W      -69                   ;10**-21
          DC.L      $971DA050
          DC.W      -73                   ;10**-22
          DC.L      $F1C90081
          DC.W      -76                   ;10**-23
          DC.L      $C16D9A01
          DC.W      -79                   ;10**-24
          DC.L      $9ABE14CD
          DC.W      -83                   ;10**-25
          DC.L      $F79687AE
          DC.W      -86                   ;10**-26
          DC.L      $C6120625
          DC.W      -89                   ;10**-27
          DC.L      $9E74D1B8
          DC.W      -93                   ;10**-28
          DC.L      $FD87B5F3

*         END
*         TTL       FAST FLOATING POINT ABS/NEG (FFPABS/FFPNEG)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPABS   IDNT      1,1                   ;FFP ABS/NEG
*         XDEF      FFPABS                ;FAST FLOATING POINT ABSOLUTE VALUE
*         XDEF      FFPNEG                ;FAST FLOATING POINT NEGATE
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*         SECTION   9

*************************************************************
*                     FFPABS                                *
*           FAST FLOATING POINT ABSOLUTE VALUE              *
*                                                           *
*  INPUT:  D7 - FAST FLOATING POINT ARGUMENT                *
*                                                           *
*  OUTPUT: D7 - FAST FLOATING POINT ABSOLUTE VALUE RESULT   *
*                                                           *
*      CONDITION CODES:                                     *
*              N - CLEARED                                  *
*              Z - SET IF RESULT IS ZERO                    *
*              V - CLEARED                                  *
*              C - UNDEFINED                                *
*              X - UNDEFINED                                *
*                                                           *
*               ALL REGISTERS TRANSPARENT                   *
*                                                           *
*************************************************************
*         PAGE

******************************
* ABSOLUTE VALUE ENTRY POINT *
******************************
FFPABS    AND.B     #$7F,D7               ;CLEAR THE SIGN BIT
          RTS                             ;AND RETURN TO THE CALLER

*         PAGE
*************************************************************
*                     FFPNEG                                *
*           FAST FLOATING POINT NEGATE                      *
*                                                           *
*  INPUT:  D7 - FAST FLOATING POINT ARGUMENT                *
*                                                           *
*  OUTPUT: D7 - FAST FLOATING POINT NEGATED RESULT          *
*                                                           *
*      CONDITION CODES:                                     *
*              N - SET IF RESULT IS NEGATIVE                *
*              Z - SET IF RESULT IS ZERO                    *
*              V - CLEARED                                  *
*              C - UNDEFINED                                *
*              X - UNDEFINED                                *
*                                                           *
*               ALL REGISTERS TRANSPARENT                   *
*                                                           *
*************************************************************
*         PAGE

**********************
* NEGATE ENTRY POINT *
**********************
FFPNEG    TST.B     D7                    ;? IS ARGUMENT A ZERO
          BEQ.S     FFPRTN                ;RETURN IF SO
          EOR.B     #$80,D7               ;INVERT THE SIGN BIT
FFPRTN    RTS                             ;AND RETURN TO CALLER

*         END
*         TTL       FAST FLOATING POINT ADD/SUBTRACT (FFPADD/FFPSUB)
***************************************
* (C) COPYRIGHT 1980 BY MOTOROLA INC. *
***************************************

*FFPADD   IDNT      1,1                   ;FFP ADD/SUBTRACT
*         XDEF      FFPADD,FFPSUB         ;ENTRY POINTS
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*         SECTION   9

*************************************************************
*                  FFPADD/FFPSUB                            *
*             FAST FLOATING POINT ADD/SUBTRACT              *
*                                                           *
*  FFPADD/FFPSUB - FAST FLOATING POINT ADD AND SUBTRACT     *
*                                                           *
*  INPUT:                                                   *
*      FFPADD                                               *
*          D6 - FLOATING POINT ADDEND                       *
*          D7 - FLOATING POINT ADDER                        *
*      FFPSUB                                               *
*          D6 - FLOATING POINT SUBTRAHEND                   *
*          D7 - FLOATING POINT MINUEND                      *
*                                                           *
*  OUTPUT:                                                  *
*          D7 - FLOATING POINT ADD RESULT                   *
*                                                           *
*  CONDITION CODES:                                         *
*          N - RESULT IS NEGATIVE                           *
*          Z - RESULT IS ZERO                               *
*          V - OVERFLOW HAS OCCURED                         *
*          C - UNDEFINED                                    *
*          X - UNDEFINED                                    *
*                                                           *
*           REGISTERS D3 THRU D5 ARE VOLATILE               *
*                                                           *
*  CODE SIZE: 228 BYTES       STACK WORK AREA:  0 BYTES     *
*                                                           *
*  NOTES:                                                   *
*    1) ADDEND/SUBTRAHEND UNALTERED (D6).                   *
*    2) UNDERFLOW RETURNS ZERO AND IS UNFLAGGED.            *
*    3) OVERFLOW RETURNS THE HIGHEST VALUE WITH THE         *
*       CORRECT SIGN AND THE 'V' BIT SET IN THE CCR.        *
*                                                           *
*  TIME: (8 MHZ NO WAIT STATES ASSUMED)                     *
*                                                           *
*           COMPOSITE AVERAGE  20.625 MICROSECONDS          *
*                                                           *
*  ADD:         ARG1=0              7.75 MICROSECONDS       *
*               ARG2=0              5.25 MICROSECONDS       *
*                                                           *
*          LIKE SIGNS  14.50 - 26.00  MICROSECONDS          *
*                    AVERAGE   18.00  MICROSECONDS          *
*         UNLIKE SIGNS 20.13 - 54.38  MICROCECONDS          *
*                    AVERAGE   22.00  MICROSECONDS          *
*                                                           *
*  SUBTRACT:    ARG1=0              4.25 MICROSECONDS       *
*               ARG2=0              9.88 MICROSECONDS       *
*                                                           *
*          LIKE SIGNS  15.75 - 27.25  MICROSECONDS          *
*                    AVERAGE   19.25  MICROSECONDS          *
*         UNLIKE SIGNS 21.38 - 55.63  MICROSECONDS          *
*                    AVERAGE   23.25  MICROSECONDS          *
*                                                           *
*************************************************************
*         PAGE

************************
* SUBTRACT ENTRY POINT *
************************
FFPSUB    MOVE.B    D6,D4                 ;TEST ARG1
          BEQ.S     FPART2                ;RETURN ARG2 IF ARG1 ZERO
          EOR.B     #$80,D4               ;INVERT COPIED SIGN OF ARG1
          BMI.S     FPAMI1                ;BRANCH ARG1 MINUS
* + ARG1
          MOVE.B    D7,D5                 ;COPY AND TEST ARG2
          BMI.S     FPAMS                 ;BRANCH ARG2 MINUS
          BNE.S     FPALS                 ;BRANCH POSITIVE NOT ZERO
          BRA.S     FPART1                ;RETURN ARG1 SINCE ARG2 IS ZERO

*******************
* ADD ENTRY POINT *
*******************
FFPADD    MOVE.B    D6,D4                 ;TEST ARGUMENT1
          BMI.S     FPAMI1                ;BRANCH IF ARG1 MINUS
          BEQ.S     FPART2                ;RETURN ARG2 IF ZERO

* + ARG1
          MOVE.B    D7,D5                 ;TEST ARGUMENT2
          BMI.S     FPAMS                 ;BRANCH IF MIXED SIGNS
          BEQ.S     FPART1                ;ZERO SO RETURN ARGUMENT1

* +ARG1 +ARG2
* -ARG1 -ARG2
FPALS     SUB.B     D4,D5                 ;TEST EXPONENT MAGNITUDES
          BMI.S     FPA2LT                ;BRANCH ARG1 GREATER
          MOVE.B    D7,D4                 ;SETUP STRONGER S+EXP IN D4

* ARG1EXP <= ARG2EXP
          CMP.B     #24,D5                ;OVERBEARING SIZE
          BCC.S     FPART2                ;BRANCH YES, RETURN ARG2
          MOVE.L    D6,D3                 ;COPY ARG1
          CLR.B     D3                    ;CLEAN OFF SIGN+EXPONENT
          LSR.L     D5,D3                 ;SHIFT TO SAME MAGNITUDE
          MOVE.B    #$80,D7               ;FORCE CARRY IF LSB-1 ON
          ADD.L     D3,D7                 ;ADD ARGUMENTS
          BCS.S     FPA2GC                ;BRANCH IF CARRY PRODUCED
FPARSR    MOVE.B    D4,D7                 ;RESTORE SIGN/EXPONENT
          RTS                             ;RETURN TO CALLER

* ADD SAME SIGN OVERFLOW NORMALIZATION
FPA2GC    ROXR.L    #1,D7                 ;SHIFT CARRY BACK INTO RESULT
          ADD.B     #1,D4                 ;ADD ONE TO EXPONENT
          BVS.S     FPA2OS                ;BRANCH OVERFLOW
          BCC.S     FPARSR                ;BRANCH IF NO EXPONENT OVERFLOW
FPA2OS    MOVEQ     #-1,D7                ;CREATE ALL ONES
          SUB.B     #1,D4                 ;BACK TO HIGHEST EXPONENT+SIGN
          MOVE.B    D4,D7                 ;REPLACE IN RESULT
          OR.B      #$02,CCR              ;SHOW OVERFLOW OCCURRED
          RTS                             ;RETURN TO CALLER

* RETURN ARGUMENT1
FPART1    MOVE.L    D6,D7                 ;MOVE IN AS RESULT
          MOVE.B    D4,D7                 ;MOVE IN PREPARED SIGN+EXPONENT
          RTS                             ;RETURN TO CALLER

* RETURN ARGUMENT2
FPART2    TST.B     D7                    ;TEST FOR RETURNED VALUE
          RTS                             ;RETURN TO CALLER

* -ARG1EXP > -ARG2EXP
* +ARG1EXP > +ARG2EXP
FPA2LT    CMP.B     #-24,D5               ;? ARGUMENTS WITHIN RANGE
          BLE.S     FPART1                ;NOPE, RETURN LARGER
          NEG.B     D5                    ;CHANGE DIFFERENCE TO POSITIVE
          MOVE.L    D6,D3                 ;SETUP LARGER VALUE
          CLR.B     D7                    ;CLEAN OFF SIGN+EXPONENT
          LSR.L     D5,D7                 ;SHIFT TO SAME MAGNITUDE
          MOVE.B    #$80,D3               ;FORCE CARRY IF LSB-1 ON
          ADD.L     D3,D7                 ;ADD ARGUMENTS
          BCS.S     FPA2GC                ;BRANCH IF CARRY PRODUCED
          MOVE.B    D4,D7                 ;RESTORE SIGN/EXPONENT
          RTS                             ;RETURN TO CALLER

* -ARG1
FPAMI1    MOVE.B    D7,D5                 ;TEST ARG2'S SIGN
          BMI.S     FPALS                 ;BRANCH FOR LIKE SIGNS
          BEQ.S     FPART1                ;IF ZERO RETURN ARGUMENT1

* -ARG1 +ARG2
* +ARG1 -ARG2
FPAMS     MOVEQ     #-128,D3              ;CREATE A CARRY MASK ($80)
          EOR.B     D3,D5                 ;STRIP SIGN OFF ARG2 S+EXP COPY
          SUB.B     D4,D5                 ;COMPARE MAGNITUDES
          BEQ.S     FPAEQ                 ;BRANCH EQUAL MAGNITUDES
          BMI.S     FPATLT                ;BRANCH IF ARG1 LARGER
* ARG1 <= ARG2
          CMP.B     #24,D5                ;COMPARE MAGNITUDE DIFFERENCE
          BCC.S     FPART2                ;BRANCH ARG2 MUCH BIGGER
          MOVE.B    D7,D4                 ;ARG2 S+EXP DOMINATES
          MOVE.B    D3,D7                 ;SETUP CARRY ON ARG2
          MOVE.L    D6,D3                 ;COPY ARG1
FPAMSS    CLR.B     D3                    ;CLEAR EXTRANEOUS BITS
          LSR.L     D5,D3                 ;ADJUST FOR MAGNITUDE
          SUB.L     D3,D7                 ;SUBTRACT SMALLER FROM LARGER
          BMI.S     FPARSR                ;RETURN FINAL RESULT IF NO OVERFLOW

* MIXED SIGNS NORMALIZE
FPANOR    MOVE.B    D4,D5                 ;SAVE CORRECT SIGN
FPANRM    CLR.B     D7                    ;CLEAR SUBTRACT RESIDUE
          SUB.B     #1,D4                 ;MAKE UP FOR FIRST SHIFT
          CMP.L     #$00007FFF,D7         ;? SMALL ENOUGH FOR SWAP
          BHI.S     FPAXQN                ;BRANCH NOPE
          SWAP      D7                    ;SHIFT LEFT 16 BITS REAL FAST
          SUB.B     #16,D4                ;MAKE UP FOR 16 BIT SHIFT
FPAXQN    ADD.L     D7,D7                 ;SHIFT UP ONE BIT
          DBMI      D4,FPAXQN             ;DECREMENT AND BRANCH IF POSITIVE
          EOR.B     D4,D5                 ;? SAME SIGN
          BMI.S     FPAZRO                ;BRANCH UNDERFLOW TO ZERO
          MOVE.B    D4,D7                 ;RESTORE SIGN/EXPONENT
          BEQ.S     FPAZRO                ;RETURN ZERO IF EXPONENT UNDERFLOWED
          RTS                             ;RETURN TO CALLER

* EXPONENT UNDERFLOWED - RETURN ZERO
FPAZRO    MOVEQ     #0,D7                 ;CREATE A TRUE ZERO
          RTS                             ;RETURN TO THE CALLER

* ARG1 > ARG2
FPATLT    CMP.B     #-24,D5               ;? ARG1 >> ARG2
          BLE.S     FPART1                ;RETURN IT IF SO
          NEG.B     D5                    ;ABSOLUTIZE DIFFERENCE
          MOVE.L    D7,D3                 ;MOVE ARG2 AS LOWER VALUE
          MOVE.L    D6,D7                 ;SETUP ARG1 AS HIGH
          MOVE.B    #$80,D7               ;SETUP ROUNDING BIT
          BRA.S     FPAMSS                ;PERFORM THE ADDITION

* EQUAL MAGNITUDES
FPAEQ     MOVE.B    D7,D5                 ;SAVE ARG1 SIGN
          EXG       D5,D4                 ;SWAP ARG2 WITH ARG1 S+EXP
          MOVE.B    D6,D7                 ;INSURE SAME LOW BYTE
          SUB.L     D6,D7                 ;OBTAIN DIFFERENCE
          BEQ.S     FPAZRO                ;RETURN ZERO IF IDENTICAL
          BPL.S     FPANOR                ;BRANCH IF ARG2 BIGGER
          NEG.L     D7                    ;CORRECT DIFFERENCE TO POSITIVE
          MOVE.B    D5,D4                 ;USE ARG2'S SIGN+EXPONENT
          BRA.S     FPANRM                ;AND GO NORMALIZE

*         END
*         TTL       FAST FLOATING POINT ASCII TO FLOAT (FFPAFP)
************************************
* (C) COPYRIGHT 1980 MOTORLA INC.  *
************************************

*FFPAFP   IDNT      1,1                   ;FFP ASCII TO FLOAT
*         OPT       PCS
*         XDEF      FFPAFP                ;ENTRY POINT
*         XREF      9:FFPDBF,FFPCPYRT
*         SECTION   9

***********************************************************
*                        FFPAFP                           *
*                    ASCII TO FLOAT                       *
*                                                         *
*      INPUT:  A0 - POINTER TO ASCII STRING OF A FORMAT   *
*                   DESCRIBED BELOW                       *
*                                                         *
*      OUTPUT: D7 - FAST FLOATING POINT EQUIVALENT        *
*              A0 - POINTS TO THE CHARACTER WHICH         *
*                   TERMINATED THE SCAN                   *
*                                                         *
*      CONDITION CODES:                                   *
*                N - SET IF RESULT IS NEGATIVE            *
*                Z - SET IF RESULT IS ZERO                *
*                V - SET IF RESULT OVERFLOWED             *
*                C - SET IF INVALID FORMAT DETECTED       *
*                X - UNDEFINED                            *
*                                                         *
*      REGISTERS D3 THRU D6 ARE VOLATILE                  *
*                                                         *
*      CODE SIZE: 246 BYTES     STACK WORK: 8 BYTES       *
*                                                         *
*      INPUT FORMAT:                                      *
*                                                         *
*     {SIGN}{DIGITS}{'.'}{DIGITS}{'E'}{SIGN}{DIGITS}      *
*     <*********MANTISSA********><*****EXPONENT****>      *
*                                                         *
*                   SYNTAX RULES                          *
*          BOTH SIGNS ARE OPTIONAL AND ARE '+' OR '-'.    *
*          THE MANTISSA MUST BE PRESENT.                  *
*          THE EXPONENT NEED NOT BE PRESENT.              *
*          THE MANTISSA MAY LEAD WITH A DECIMAL POINT.    *
*          THE MANTISSA NEED NOT HAVE A DECIMAL POINT.    *
*                                                         *
*      EXAMPLES:  ALL OF THESE VALUES REPRESENT THE       *
*                 NUMBER ONE-HUNDRED-TWENTY.              *
*                                                         *
*                       120            .120E3             *
*                       120.          +.120E+03           *
*                      +120.          0.000120E6          *
*                   0000120.00  1200000E-4                *
*                               1200000.00E-0004          *
*                                                         *
*      FLOATING POINT RANGE:                              *
*                                                         *
*          FAST FLOATING POINT SUPPORTS THE VALUE ZERO    *
*          AND NON-ZERO VALUES WITHIN THE FOLLOWING       *
*          BOUNDS -                                       *
*                                                         *
*                   18                             -20    *
*    9.22337177 X 10   > +NUMBER >  5.42101070 X 10       *
*                                                         *
*                   18                             -20    *
*   -9.22337177 X 10   > -NUMBER > -2.71050535 X 10       *
*                                                         *
*      PRECISION:                                         *
*                                                         *
*          THIS CONVERSION RESULTS IN A 24 BIT PRECISION  *
*          WITH GUARANTEED ERROR LESS THAN OR EQUAL TO    *
*          ONE-HALF LEAST SIGNIFICANT BIT.                *
*                                                         *
*                                                         *
*      NOTES:                                             *
*          1) THIS ROUTINE CALLS THE DUAL-BINARY TO FLOAT *
*             ROUTINE AND CAN BE USED AS AN ILLUSTRATION  *
*             OF HOW TO 'FRONT-END' THAT ROUTINE WITH     *
*             A CUSTOMIZED SCANNER.                       *
*          2) UNDERFLOWS RETURN A ZERO WITHOUT ANY        *
*             INDICATORS SET.                             *
*          3) OVERFLOWS WILL RETURN THE MAXIMUM VALUE     *
*             POSSIBLE WITH PROPER SIGN AND THE 'V' BIT   *
*             SET IN THE CCR.                             *
*          4) IF THE 'C' BIT IN THE CCR INDICATES AN      *
*             INVALID PATTERN DETECTED, THEN A0 WILL      *
*             POINT TO THE INVALID CHARACTER.             *
*                                                         *
*      LOGIC SUMMARY:                                     *
*                                                         *
*          A) PROCESS LEADING SIGN                        *
*          B) PROCESS PRE-DECIMALPOINT DIGITS AND         *
*             INCREMENT 10 POWER BIAS FOR EACH            *
*             DIGIT BYPASSED DUE TO 32 BIT OVERFLOW       *
*          C) PROCESS POST-DECIMALPOINT DIGITS            *
*             DECREMENTING THE 10 POWER BIAS FOR EACH     *
*          D) PROCESS THE EXPONENT                        *
*          E) ADD THE 10 POWER BIAS TO THE EXPONENT       *
*          F) CALL 'FFPDBF' ROUTINE TO FINISH CONVERSION  *
*                                                         *
*   TIMES: (8 MHZ NO WAIT STATES)                         *
*          374 MICROSECONDS CONVERTING THE STRING         *
*                                                         *
*                                                         *
***********************************************************
*         PAGE

FFPAFP    MOVEQ     #0,D7                 ;CLEAR MANTISSA BUILD
          MOVEQ     #0,D6                 ;CLEAR SIGN+BASE10 BUILD

* CHECK FOR LEADING SIGN
          BSR       FPANXT                ;OBTAIN NEXT CHARACTER
          BEQ.S     FPANMB                ;BRANCH DIGIT FOUND
          BCS.S     FPANOS                ;BRANCH NO SIGN ENCOUNTERED

* LEADING SIGN ENCOUNTERED
          CMP.B     #'-',D5               ;COMPARE FOR MINUS
          SEQ       D6                    ;SET ONES IF SO
          SWAP      D6                    ;SIGN TO HIGH WORD IN D6

* TEST FOR DIGIT OR PERIOD
          BSR       FPANXT                ;OBTAIN NEXT CHARACTER
          BEQ.S     FPANMB                ;BRANCH DIGIT TO BUILD MANTISSA
FPANOS    CMP.B     #'.',D5               ;? LEADING DECIMALPOINT
          BNE.S     FPABAD                ;BRANCH INVALID PATTERN IF NOT

* INSURE AT LEAST ONE DIGIT
          BSR       FPANXT                ;OBTAIN NEXT CHARACTER
          BEQ.S     FPADOF                ;BRANCH IF FRACTION DIGIT

* INVALID PATTERN DETECTED
FPABAD    SUBQ.L    #1,A0                 ;POINT TO INVALID CHARACTER
          ORI.B     #$01,CCR              ;FORCE CARRY BIT ON
          RTS                             ;RETURN TO CALLER

* PRE-DECIMALPOINT MANTISSA BUILD
FPANXD    BSR       FPANXT                ;NEXT CHARACTER
          BNE.S     FPANOD                ;BRANCH NOT A DIGIT
FPANMB    BSR.S     FPAX10                ;MULTIPLY TIMES TEN
          BCC.S     FPANXD                ;LOOP FOR MORE DIGITS

* PRE-DECIMALPOINT MANTISSA OVERFLOW, COUNT TILL END OR DECIMAL REACHED
FPAMOV    ADD.W     #1,D6                 ;INCREMENT TEN POWER BY ONE
          BSR.S     FPANXT                ;OBTAIN NEXT PATTERN
          BEQ.S     FPAMOV                ;LOOP UNTIL NON-DIGIT
          CMP.B     #'.',D5               ;? DECIMAL POINT REACHED
          BNE.S     FPATSE                ;NO, NO CHECK FOR EXPONENT

* FLUSH REMAINING FRACTIONAL DIGITS
FPASRD    BSR.S     FPANXT                ;NEXT CHARACTER
          BEQ.S     FPASRD                ;IGNORE IT IF STILL DIGIT
FPATSE    CMP.B     #'E',D5               ;? EXPONENT HERE
          BNE.S     FPACNV                ;NO, FINISHED - GO CONVERT

* NOW PROCESS THE EXPONENT
          BSR.S     FPANXT                ;OBTAIN FIRST DIGIT
          BEQ.S     FPANTE                ;BRANCH GOT IT
          BCS.S     FPABAD                ;BRANCH INVALID FORMAT, NO SIGN OR DIGITS
          ROL.L     #8,D6                 ;HIGH BYTE OF D6 INTO LOW
          CMP.B     #'-',D5               ;? MINUS SIGN
          SEQ       D6                    ;SET ONES OR ZERO
          ROR.L     #8,D6                 ;D6 HIGH BYTE IS EXPONENTS SIGN
          BSR.S     FPANXT                ;NOW TO FIRST DIGIT
          BNE.S     FPABAD                ;BRANCH INVALID - DIGIT EXPECTED

* PROCESS EXPONENT'S DIGITS
FPANTE    MOVE.W    D5,D4                 ;COPY DIGIT JUST LOADED
FPANXE    BSR.S     FPANXT                ;EXAMINE NEXT CHARACTER
          BNE.S     FPAFNE                ;BRANCH END OF EXPONENT
          MULU.W    #10,D4                ;PREVIOUS VALUE TIMES TEN
          CMP.W     #2000,D4              ;? TOO LARGE
          BHI.S     FPABAD                ;BRANCH EXPONENT WAY OFF BASE
          ADD.W     D5,D4                 ;ADD LATEST DIGIT
          BRA.S     FPANXE                ;LOOP FOR NEXT CHARACTER

* ADJUST FOR SIGN AND ADD TO ORIGINAL INDEX
FPAFNE    TST.L     D6                    ;? WAS EXPONENT NEGATIVE
          BPL.S     FPAADP                ;BRANCH IF SO
          NEG.W     D4                    ;CONVERT TO NEGATIVE VALUE
FPAADP    ADD.W     D4,D6                 ;FINAL RESULT
FPACNV    SUBQ.L    #1,A0                 ;POINT TO TERMINATION CHARACTER
          BRA       FFPDBF                ;NOW CONVERT TO FLOAT

* PRE-DECIMALPOINT NON-DIGIT ENCOUNTERED
FPANOD    CMP.B     #'.',D5               ;? DECIMAL POINT HERE
          BNE.S     FPATSE                ;NOPE, TRY FOR THE 'E'

* POST-DECIMALPOINT PROCESSING
FPADPN    BSR.S     FPANXT                ;OBTAIN NEXT CHARACTER
          BNE.S     FPATSE                ;NOT A DIGIT, TEST FOR 'E'
FPADOF    BSR.S     FPAX10                ;TIMES TEN PREVIOUS VALUE
          BCS.S     FPASRD                ;FLUSH IF OVERFLOW NOW
          SUB.W     #1,D6                 ;ADJUST 10 POWER BIAS
          BRA.S     FPADPN                ;AND TO NEXT CHARACTER

*   *
*   * FPAX10 SUBROUTINE - PROCESS NEXT DIGIT
*   *  OUTPUT: C=0 NO OVERFLOW, C=1 OVERFLOW (D7 UNALTERED)
*   *
FPAX10    MOVE.L    D7,D3                 ;COPY VALUE
          LSL.L     #1,D3                 ;TIMES TWO
          BCS.S     FPAXRT                ;RETURN IF OVERFLOW
          LSL.L     #1,D3                 ;TIMES FOUR
          BCS.S     FPAXRT                ;RETURN IF OVERFLOW
          LSL.L     #1,D3                 ;TIMES EIGHT
          BCS.S     FPAXRT                ;RETURN IF OVERFLOW
          ADD.L     D7,D3                 ;ADD ONE TO MAKE X 9
          BCS.S     FPAXRT                ;RETURN IF OVERFLOW
          ADD.L     D7,D3                 ;ADD ONE TO MAKE X 10
          BCS.S     FPAXRT                ;RETURN IF OVERFLOW
          ADD.L     D5,D3                 ;ADD NEW UNITS DIGIT
          BCS.S     FPAXRT                ;RETURN IF OVERFLOW
          MOVE.L    D3,D7                 ;UPDATE RESULT
FPAXRT    RTS                             ;RETURN TO CALLER


*
* FPANXT SUBROUTINE - RETURN NEXT INPUT PATTERN
*
*    INPUT:  A0
*
*    OUTPUT:  A0 INCREMENTED BY ONE
*             IF Z=1 THEN DIGIT ENCOUNTERED AND D5.L SET TO BINARY VALUE
*             IF Z=0 THEN D6.B SET TO CHARACTER ENCOUNTERED
*                         AND C=0 IF PLUS OR MINUS SIGN
*                             C=1 IF NOT PLUS OR MINUS SIGN
*

FPANXT    MOVEQ     #0,D5                 ;ZERO RETURN REGISTER
          MOVE.B    (A0)+,D5              ;LOAD CHARACTER
          CMP.B     #'+',D5               ;? PLUS SIGN
          BEQ.S     FPASGN                ;BRANCH IF SIGN
          CMP.B     #'-',D5               ;? MINUS SIGN
          BEQ.S     FPASGN                ;BRANCH IF SIGN
          CMP.B     #'0',D5               ;? LOWER THAN A DIGIT
          BCS.S     FPAOTR                ;BRANCH IF NON-SIGNDIGIT
          CMP.B     #'9',D5               ;? HIGHER THAN A DIGIT
          BHI.S     FPAOTR                ;BRANCH IF NON-SIGNDIGIT
* IT IS A DIGIT
          AND.B     #$0F,D5               ;TO BINARY
          MOVE.W    #$0004,CCR            ;SET Z=1 FOR DIGIT
          RTS                             ;RETURN TO CALLER

* IT IS A SIGN
FPASGN    MOVE.W    #$0000,CCR            ;CLEAR Z=0 AND C=0
          RTS                             ;RETURN TO CALLER

* IT IS NEITHER SIGN NOR DIGIT
FPAOTR    MOVE.W    #$0001,CCR            ;CLEAR Z=0 AND SET C=1
          RTS                             ;RETURN TO CALLER

*         END
*         TTL       FAST FLOATING POINT ASCII ROUND ROUTINE (FFPARND)
****************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC.  *
****************************************

*FFPARND  IDNT      1,5                   ;FFP ASCII ROUND SUBROUTINE
*         XDEF      FFPARND               ;ENTRY POINT
*         SECTION   9

***********************************************
*                  FFPARND                    *
*           ASCII ROUND SUBROUTINE            *
*                                             *
*  THIS ROUTINE IS NORMALLY CALLED AFTER THE  *
*  'FFPFPA' FLOAT TO ASCII ROUTINE AND ACTS   *
*  UPON ITS RESULTS.                          *
*                                             *
*  INPUT:  D6 - ROUNDING MAGNITUDE IN BINARY  *
*               AS EXPLAINED BELOW.           *
*          D7 - BINARY REPRESENTATION OF THE  *
*               BASE 10 EXPONENT.             *
*          SP ->  RETURN ADDRESS AND OUTPUT   *
*                 FROM FFPFPA ROUTINE         *
*                                             *
*  OUTPUT: THE ASCII VALUE ON THE STACK IS    *
*          CORRECTLY ROUNDED                  *
*                                             *
*          THE CONDITION CODES ARE UNDEFINED  *
*                                             *
*          ALL REGISTERS TRANSPARENT          *
*                                             *
*     THE ROUNDING PRECISION REPRESENTS THE   *
*     POWER OF TEN TO WHICH THE ROUNDING WILL *
*     OCCUR.  (I.E. A -2 MEANS ROUND THE DIGIT*
*     IN THE HUNDREDTH POSITION FOR RESULTANT *
*     ROUNDING TO TENTHS.)  A POSITIVE VALUE  *
*     INDICATES ROUNDING TO THE LEFT OF THE   *
*     DECIMAL POINT (0 IS UNITS, 1 IS TENS    *
*     E.T.C.)                                 *
*                                             *
*     THE BASE TEN EXPONENT IN BINARY IS D7   *
*     FROM THE 'FFPFPA' ROUTINE OR COMPUTED BY*
*     THE CALLER.                             *
*                                             *
*     THE STACK CONTAINS THE RETURN ADDRESS   *
*     FOLLOWED BY THE ASCII NUMBER AS FROM    *
*     THE 'FFPFPA' ROUTINE.  SEE THE          *
*     DESCRIPTION OF THAT ROUTINE FOR THE     *
*     REQUIRED FORMAT.                        *
*                                             *
*  EXAMPLE:                                   *
*                                             *
*  INPUT PATTERN '+.98765432+01' = 9.8765432  *
*                                             *
*     ROUND +1 IS +.00000000+00 =  0.         *
*     ROUND  0 IS +.10000000+02 = 10.         *
*     ROUND -1 IS +.10000000+02 = 10.         *
*     ROUND -2 IS +.99000000+01 =  9.9        *
*     ROUND -3 IS +.98800000+01 =  9.88       *
*     ROUND -6 IS +.98765400+01 =  9.87654    *
*                                             *
*  NOTES:                                     *
*     1) IF THE ROUNDING DIGIT IS TO THE LEFT *
*        OF THE MOST SIGNIFICANT DIGIT, A ZERO*
*        RESULTS.  IF THE ROUNDING DIGIT IS TO*
*        THE RIGHT OF THE LEAST SIGNIFICANT   *
*        DIGIT, THEN NO ROUNDING OCCURS       *
*     2) ROUNDING IS HANDY FOR ELIMINATING THE*
*        DANGLING '999...' PROBLEM COMMON WITH*
*        FLOAT TO DECIMAL CONVERSIONS.        *
*     3) POSITIONS FROM THE ROUNDED DIGIT AND *
*        TO THE RIGHT ARE SET TO ZEROES.      *
*     4) THE EXPONENT MAY BE AFFECTED.        *
*     5) ROUNDING IS FORCED BY ADDING FIVE.   *
*     6) THE BINARY EXPONENT IN D7 MAY BE     *
*        PRE-BIASED BY THE CALLER TO PROVIDE  *
*        ENHANCED EDITING CONTROL.            *
*     7) THE RETURN ADDRESS IS REMOVED FROM   *
*        THE STACK UPON EXIT.                 *
***********************************************
*         PAGE

FFPARND   MOVEM.L   D7/A0,-(SP)           ;SAVE WORK ON STACK
          SUB.W     D6,D7                 ;COMPUTE ROUNDING DIGIT OFFSET
          BLE.S     FAFZRO                ;BRANCH IF LARGER THAN VALUE
          CMP.W     #8,D7                 ;INSURE NOT PAST LAST DIGIT
          BHI       FARTN                 ;RETURN IF SO
          LEA       8+4+1(SP,D7),A0       ;POINT TO ROUNDING DIGIT
          CMP.B     #'5',(A0)             ;? MUST ROUND UP
          BCC.S     FADORND               ;YEP - GO ROUND
          SUB.W     #1,D7                 ;? ROUND LEADING DIGIT ZERO (D7=1)
          BNE.S     FAZEROL               ;NOPE, JUST ZERO OUT
FAFZRO    LEA       8+4+2(SP),A0          ;FORCE ZEROES ALL THE WAY ACROSS
          MOVE.L    #'E+00',8+4+10(SP)    ;FORCE ZERO EXPONENT

          MOVE.B    #'+',8+4(SP)          ;ZERO IS ALWAYS POSITIVE
          BRA.S     FAZEROL               ;ZERO MANTISSA THEN RETURN

* ROUND UP MUST OCCUR
FADORND   MOVE.L    A0,-(SP)              ;SAVE ZERO START ADDRESS ON STACK
FACARRY   CMP.B     #'.',-(A0)            ;? HIT BEGINNING
          BEQ.S     FASHIFT               ;YES, MUST SHIFT DOWN
          ADD.B     #1,(A0)               ;UP BY ONE
          CMP.B     #'9'+1,(A0)           ;? PAST NINE
          BNE.S     FAZERO                ;NO, NOW ZERO THE END
          MOVE.B    #'0',(A0)             ;FORCE ZERO FOR OVERFLOW
          BRA       FACARRY               ;LOOP FOR CARRY

* OVERFLOW PAST TOP DIGIT - SHIFT RIGHT AND UP EXPONENT
FASHIFT   ADD.L     #1,(SP)               ;ZERO PADD STARTS ONE LOWER NOW
          ADDQ.L    #1,A0                 ;BACK TO LEADING DIGIT
          MOVEQ     #$31,D7               ;DEFAULT FIRST DIGIT ASCII ONE
          SWAP      D7                    ;INITIALIZE OLD DIGIT
          MOVE.B    (A0),D7               ;PRE-LOAD CURRENT DIGIT
FASHFTR   SWAP      D7                    ;TO PREVIOUS DIGIT
          MOVE.B    D7,(A0)+              ;STORE INTO THIS POSITION
          MOVE.B    (A0),D7               ;LOAD UP NEXT DIGIT
          CMP.B     #'E',D7               ;? THE END
          BNE.S     FASHFTR               ;NO, SHIFT ANOTHER TO THE RIGHT

* INCREMENT EXPONENT FOR SHIFT RIGHT
          CMP.B     #'+',1(A0)            ;? POSITIVE EXPONENT
          ADDQ.L    #3,A0                 ;POINT TO LEAST EXP DIGIT
          BNE.S     FANGEXP               ;BRANCH NEGATIVE EXPONENT
          ADD.B     #1,(A0)               ;ADD ONE TO EXPONENT
          CMP.B     #'9'+1,(A0)           ;? OVERFLOW PAST NINE
          BNE.S     FAZERO                ;NO, NOW ZERO
          SUB.B     #10,(A0)              ;V1,5 9/26/89
          ADD.B     #1,-(A0)              ;CARRY TO NEXT DIGIT
          BRA.S     FAZERO                ;AND NOW ZERO END
FANGEXP   CMP.W     #'01',-1(A0)          ;? GOING FROM -1 TO +0
          BNE.S     FANGOK                ;BRANCH IF NOT
          MOVE.B    #'+',-2(A0)           ;CHANGE MINUS TO PLUS
FANGOK    SUB.B     #1,(A0)               ;SUBTRACT ONE FROM EXPONENT
          CMP.B     #'0'-1,(A0)           ;? UNDERFLOW BELOW ZERO
          BNE.S     FAZERO                ;NO, ZERO REMAINDER
          SUB.B     #1,-(A0)              ;BORROW FROM NEXT DIGIT

* ZERO THE DIGITS PAST PRECISION REQUIRED
FAZERO    MOVE.L    (SP)+,A0              ;RELOAD SAVED PRECISION
FAZEROL   CMP.B     #'E',(A0)             ;? AT END
          BEQ.S     FARTN                 ;BRANCH IF SO
          MOVE.B    #'0',(A0)+            ;ZERO NEXT DIGIT
          BRA.S     FAZEROL               ;AND TEST AGAIN

* RETURN TO THE CALLER
FARTN     MOVEM.L   (SP)+,D7/A0           ;RESTORE REGISTERS
          RTS                             ;RETURN TO CALLER

*         END
*         TTL       FAST FLOATING POINT ARCTANGENT (FFPATAN)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPATAN  IDNT      1,2                   ;FFP ARCTANGENT
*         OPT       PCS
*         SECTION   9
*         XDEF      FFPATAN               ;ENTRY POINT
*         XREF      9:FFPTHETA            ;ARCTANGENT TABLE
*         XREF      9:FFPDIV,9:FFPSUB     ;ARITHMETIC PRIMITIVES
*         XREF      9:FFPTNORM            ;TRANSCENDENTAL NORMALIZE ROUTINE
*         XREF      FFPCPYRT              ;COPYRIGHT STUB

*************************************************
*                  FFPATAN                      *
*       FAST FLOATING POINT ARCTANGENT          *
*                                               *
*  INPUT:   D7 - INPUT ARGUMENT                 *
*                                               *
*  OUTPUT:  D7 - ARCTANGENT RADIAN RESULT       *
*                                               *
*     ALL OTHER REGISTERS TOTALLY TRANSPARENT   *
*                                               *
*  CODE SIZE: 132 BYTES   STACK WORK: 32 BYTES  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF THE RESULT IS ZERO          *
*        N - CLEARED                            *
*        V - CLEARED                            *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*                                               *
*  NOTES:                                       *
*    1) SPOT CHECKS SHOW AT LEAST SIX DIGIT     *
*       PRECISION ON ALL SAMPLED CASES.         *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*        THE TIME IS VERY DATA SENSITIVE WITH   *
*        SAMPLE VALUES RANGING FROM 238 TO      *
*        465 MICROSECONDS                       *
*                                               *
*************************************************
*         PAGE

PIOV2     EQU       $C90FDB41             ;FLOAT PI/2
FPONEA    EQU       $80000041             ;FLOAT 1

********************
* ARCTANGENT ENTRY *
********************

* SAVE REGISTERS AND PERFORM ARGUMENT REDUCTION
FFPATAN   MOVEM.L   D1-D6/A0,-(SP)        ;SAVE CALLER'S REGISTERS
          MOVE.B    D7,-(SP)              ;SAVE ORIGINAL SIGN ON STACK
          AND.B     #$7F,D7               ;TAKE ABSOLUTE VALUE OF ARG
* INSURE LESS THAN ONE FOR CORDIC LOOP
          MOVE.L    #FPONEA,D6            ;LOAD UP 1
          CLR.B     -(SP)                 ;DEFAULT NO INVERSE REQUIRED
          CMP.B     D6,D7                 ;? LESS THAN ONE
          BCS.S     FPAINRG               ;BRANCH IN RANGE
          BHI.S     FPARDC                ;HIGHER - MUST REDUCE
          CMP.L     D6,D7                 ;? LESS OR EQUAL TO ONE
          BLS.S     FPAINRG               ;BRANCH YES, IS IN RANGE
* ARGUMENT > 1:  ATAN(1/X) =  PI/2 - ATAN(X)
FPARDC    NOT.B     (SP)                  ;FLAG INVERSE TAKEN
          EXG       D6,D7                 ;TAKE INVERSE OF ARGUMENT
          BSR       FFPDIV                ;PERFORM DIVIDE

* PERFORM CORDIC FUNCTION
* CONVERT TO BIN(31,29) PRECISION
FPAINRG   SUB.B     #64+3,D7              ;ADJUST EXPONENT
          NEG.B     D7                    ;FOR SHIFT NECESSARY
          CMP.B     #31,D7                ;? TOO SMALL TO WORRY ABOUT
          BLS.S     FPANOTZ               ;BRANCH IF NOT TOO SMALL
          MOVEQ     #0,D6                 ;CONVERT TO A ZERO
          BRA.S     FPAZR1                ;BRANCH IF ZERO
FPANOTZ   LSR.L     D7,D7                 ;SHIFT TO BIN(31,29) PRECISION

*****************************************
* CORDIC CALCULATION REGISTERS:         *
* D1 - LOOP COUNT   A0 - TABLE POINTER  *
* D2 - SHIFT COUNT                      *
* D3 - Y'   D5 - Y                      *
* D4 - X'   D6 - Z                      *
* D7 - X                                *
*****************************************

          MOVEQ     #0,D6                 ;Z=0
          MOVE.L    #1<<29,D5             ;Y=1
          LEA       FFPTHETA+4,A0         ;TO ARCTANGENT TABLE
          MOVEQ     #24,D1                ;LOOP 25 TIMES
          MOVEQ     #1,D2                 ;PRIME SHIFT COUNTER
          BRA.S     CORDICA               ;ENTER CORDIC LOOP

* CORDIC LOOP
FPLPLSA   ASR.L     D2,D4                 ;SHIFT(X')
          ADD.L     D4,D5                 ;Y = Y + X'
          ADD.L     (A0),D6               ;Z = Z + ARCTAN(I)
CORDICA   MOVE.L    D7,D4                 ;X' = X
          MOVE.L    D5,D3                 ;Y' = Y
          ASR.L     D2,D3                 ;SHIFT(Y')
FPLNLPA   SUB.L     D3,D7                 ;X = X - Y'
          BPL.S     FPLPLSA               ;BRANCH NEGATIVE
          MOVE.L    D4,D7                 ;RESTORE X
          ADDQ.L    #4,A0                 ;TO NEXT TABLE ENTRY
          ADD.B     #1,D2                 ;INCREMENT SHIFT COUNT
          LSR.L     #1,D3                 ;SHIFT(Y')
          DBRA      D1,FPLNLPA            ;AND LOOP UNTIL DONE

* NOW CONVERT TO FLOAT AND RECONSTRUCT THE RESULT
          BSR       FFPTNORM              ;FLOAT Z
FPAZR1    MOVE.L    D6,D7                 ;COPY ANSWER TO D7
          TST.B     (SP)+                 ;? WAS INVERSE TAKEN
          BEQ.S     FPANINV               ;BRANCH IF NOT
          MOVE.L    #PIOV2,D7             ;TAKE AWAY FROM PI OVER TWO
          BSR       FFPSUB                ;SUBTRACT
FPANINV   MOVE.B    (SP)+,D6              ;LOAD ORIGINAL SIGN
          TST.B     D7                    ;? RESULT ZERO
          BEQ.S     FPARTN                ;RETURN IF SO
          AND.B     #$80,D6               ;CLEAR EXPONENT PORTION
          OR.B      D6,D7                 ;IF MINUS, GIVE MINUS RESULT
FPARTN    MOVEM.L   (SP)+,D1-D6/A0        ;RESTORE CALLER'S REGISTERS
          RTS                             ;RETURN TO CALLER

*         END
*         TTL       FAST FLOATING POINT CMP/TST (FFPCMP/FFPTST)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPCMP   IDNT      1,3                   ;FFP CMP/TST
*         XDEF      FFPCMP                ;FAST FLOATING POINT COMPARE
*         XDEF      FFPTST                ;FAST FLOATING POINT TEST
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*         SECTION   9

*************************************************************
*                      FFPCMP                               *
*              FAST FLOATING POINT COMPARE                  *
*                                                           *
*  INPUT:  D6 - FAST FLOATING POINT ARGUMENT (SOURCE)       *
*          D7 - FAST FLOATING POINT ARGUMENT (DESTINATION)  *
*                                                           *
*  OUTPUT: CONDITION CODE REFLECTING THE FOLLOWING BRANCHES *
*          FOR THE RESULT OF COMPARING THE DESTINATION      *
*          MINUS THE SOURCE:                                *
*                                                           *
*                  GT - DESTINATION GREATER                 *
*                  GE - DESTINATION GREATER OR EQUAL TO     *
*                  EQ - DESTINATION EQUAL                   *
*                  NE - DESTINATION NOT EQUAL               *
*                  LT - DESTINATION LESS THAN               *
*                  LE - DESTINATION LESS THAN OR EQUAL TO   *
*                                                           *
*      CONDITION CODES:                                     *
*              N - CLEARED                                  *
*              Z - SET IF RESULT IS ZERO                    *
*              V - CLEARED                                  *
*              C - UNDEFINED                                *
*              X - UNDEFINED                                *
*                                                           *
*               ALL REGISTERS TRANSPARENT                   *
*                                                           *
*************************************************************
*         PAGE

***********************
* COMPARE ENTRY POINT *
***********************
FFPCMP    TST.B     D6                    ;? FIRST NEGATIVE
          BPL.S     FFPCP                 ;NO FIRST IS POSITIVE
          TST.B     D7                    ;? SECOND NEGATIVE
          BPL.S     FFPCP                 ;NO, ONE IS POSITIVE

* IF BOTH NEGATIVE THEN COMPARE MUST BE DONE BACKWARDS

          CMP.B     D7,D6                 ;COMPARE SIGN AND EXPONENT ONLY FIRST
          BNE.S     FFPCRTN               ;RETURN IF THAT IS SUFFICIENT
          CMP.L     D7,D6                 ;COMPARE REVERSE ORDER IF BOTH NEGATIVE
          RTS                             ;RETURN TO CALLER

FFPCP     CMP.B     D6,D7                 ;COMPARE SIGN AND EXPONENT ONLY FIRST
          BNE.S     FFPCRTN               ;RETURN IF THAT IS SUFFICIENT
          CMP.L     D6,D7                 ;NO, COMPARE FULL LONGWORDS THEN
FFPCRTN   RTS                             ;AND RETURN TO THE CALLER

*        PAGE
*************************************************************
*                     FFPTST                                *
*           FAST FLOATING POINT TEST                        *
*                                                           *
*  INPUT:  D7 - FAST FLOATING POINT ARGUMENT                *
*                                                           *
*  OUTPUT: CONDITION CODES SET FOR THE FOLLOWING BRANCHES:  *
*                                                           *
*                  EQ - ARGUMENT EQUALS ZERO                *
*                  NE - ARGUMENT NOT EQUAL ZERO             *
*                  PL - ARGUMENT IS POSITIVE (INCLUDES ZERO)*
*                  MI - ARGUMENT IS NEGATIVE                *
*                                                           *
*      CONDITION CODES:                                     *
*              N - SET IF RESULT IS NEGATIVE                *
*              Z - SET IF RESULT IS ZERO                    *
*              V - CLEARED                                  *
*              C - UNDEFINED                                *
*              X - UNDEFINED                                *
*                                                           *
*               ALL REGISTERS TRANSPARENT                   *
*                                                           *
*************************************************************
*         PAGE

********************
* TEST ENTRY POINT *
********************
FFPTST    TST.B     D7                    ;RETURN TESTED CONDITION CODE
          RTS                             ;TO CALLER

*         END

*         TTL       FAST FLOATING POINT DUAL-BINARY FLOAT (FFPDBF)
************************************
* (C) COPYRIGHT 1980 MOTORLA INC.  *
************************************

*FFPDBF   IDNT      1,1                   ;FFP DUAL-BINARY TO FLOAT
*         OPT       PCS
*         XDEF      FFPDBF                ;ENTRY POINT
*         XREF      9:FFP10TBL            ;POWER OF TEN TABLE
*         SECTION   9

***********************************************************
*                                                         *
*          FAST FLOATING POINT DUAL-BINARY TO FLOAT       *
*                                                         *
*      INPUT:  D6 BIT #16 - REPRESENTS SIGN (0=POSITIVE)  *
*                                           (1=NEGATIVE)  *
*              D6.W - REPRESENTS BASE TEN EXPONENT        *
*                     CONSIDERING D7 A BINARY INTEGER     *
*              D7 -   BINARY INTEGER MANTISSA             *
*                                                         *
*      OUTPUT: D7 - FAST FLOATING POINT EQUIVALENT        *
*                                                         *
*      CONDITION CODES:                                   *
*                N - SET IF RESULT IS NEGATIVE            *
*                Z - SET IF RESULT IS ZERO                *
*                V - SET IF RESULT OVERFLOWED             *
*                C - CLEARED                              *
*                X - UNDEFINED                            *
*                                                         *
*      REGISTERS D3 THRU D6 DESTROYED                     *
*                                                         *
*      CODE SIZE: 164 BYTES     STACK WORK AREA: 4 BYTES  *
*                                                         *
*                                                         *
*      FLOATING POINT RANGE:                              *
*                                                         *
*          FAST FLOATING POINT SUPPORTS THE VALUE ZERO    *
*          AND NON-ZERO VALUES WITHIN THE FOLLOWING       *
*          BOUNDS -                                       *
*                                                         *
* BASE 10                                                 *
*                  18                             -20     *
*   9.22337177 X 10   > +NUMBER >  5.42101070 X 10        *
*                                                         *
*                  18                             -20     *
*  -9.22337177 X 10   > -NUMBER > -2.71050535 X 10        *
*                                                         *
* BASE 2                                                  *
*                   63                            -63     *
*      .FFFFFF  X  2   > +NUMBER >  .FFFFFF  X  2         *
*                                                         *
*                   63                            -64     *
*     -.FFFFFF  X  2   > -NUMBER > -.FFFFFF  X  2         *
*                                                         *
*      PRECISION:                                         *
*                                                         *
*          THIS CONVERSION RESULTS IN A 24 BIT PRECISION  *
*          WITH GUARANTEED ERROR LESS THAN OR EQUAL TO    *
*          ONE-HALF LEAST SIGNIFICANT BIT.                *
*                                                         *
*                                                         *
*      NOTES:                                             *
*          1) THE INPUT FORMATS HAVE BEEN DESIGNED FOR    *
*             EASE OF PARSING TEXT FOR CONVERSION TO      *
*             FLOATING POINT.  SEE FFPASF FOR COMMENTS    *
*             DESCRIBING THE METHOD FOR SETUP TO THIS     *
*             ROUTINE.                                    *
*          2) UNDERFLOWS RETURN A ZERO WITHOUT ANY        *
*             INDICATORS SET.                             *
*          3) OVERFLOWS WILL RETURN THE MAXIMUM VALUE     *
*             POSSIBLE WITH PROPER SIGN AND THE 'V' BIT   *
*             SET IN THE CCR REGISTER.                    *
*                                                         *
***********************************************************
*         PAGE

* NORMALIZE THE INPUT BINARY MANTISSA
FFPDBF    MOVEQ     #32,D5                ;SETUP BASE 2 EXPONENT MAX
          TST.L     D7                    ;? TEST FOR ZERO
          BEQ       FPDRTN1               ;RETURN, NO CONVERSION NEEDED
          BMI.S     FPDINM                ;BRANCH INPUT ALREADY NORMALIZED
          MOVEQ     #31,D5                ;PREPARE FOR NORMALIZE LOOP
FPDNMI    ADD.L     D7,D7                 ;SHIFT UP BY ONE
          DBMI      D5,FPDNMI             ;DECREMENT AND LOOP IF NOT YET

* INSURE INPUT 10 POWER INDEX NOT WAY OFF BASE
FPDINM    CMP.W     #18,D6                ;? WAY TOO LARGE
          BGT.S     FPDOVF1               ;BRANCH OVERFLOW
          CMP.W     #-28,D6               ;? WAY TOO SMALL
          BLT.S     FPDRT0                ;RETURN ZERO IF UNDERFLOW
          MOVE.W    D6,D4                 ;COPY 10 POWER INDEX
          NEG.W     D4                    ;INVERT TO GO PROPER DIRECTION
          MULS.W    #6,D4                 ;TIMES FOUR FOR INDEX
          MOVE.L    A0,-(SP)              ;SAVE WORK ADDRESS REGISTER
          LEA       FFP10TBL,A0           ;LOAD TABLE ADDRESS
          ADD.W     0(A0,D4.W),D5         ;ADD EXPONENTS FOR MULTIPLY
          MOVE.W    D5,D6                 ;SAVE RESULT EXPONENT IN D6.W

* NOW PERFORM 32 BIT MULTIPLY OF INPUT WITH POWER OF TEN TABLE
          MOVE.L    2(A0,D4.W),D3         ;LOAD TABLE MANTISSA VALUE
          MOVE.L    (SP),A0               ;RESTORE WORK REGISTER
          MOVE.L    D3,(SP)               ;NOW SAVE TABLE MANTISSA ON STACK
          MOVE.W    D7,D5                 ;COPY INPUT VALUE
          MULU.W    D3,D5                 ;TABLELOW X INPUTLOW
          CLR.W     D5                    ;LOW END NO LONGER TAKES AFFECT
          SWAP      D5                    ;SAVE INTERMEDIATE SUM
          MOVEQ     #0,D4                 ;CREATE A ZERO FOR DOUBLE PRECISION
          SWAP      D3                    ;TO HIGH TABLE WORD
          MULU.W    D7,D3                 ;INPUTLOW X TABLEHIGH
          ADD.L     D3,D5                 ;ADD ANOTHER PARTIAL SUM
          ADDX.B    D4,D4                 ;CREATE CARRY IF ANY
          SWAP      D7                    ;NOW TO INPUT HIGH
          MOVE.W    D7,D3                 ;COPY TO WORK REGISTER
          MULU.W    2(SP),D3              ;TABLELOW X INPUTHIGH
          ADD.L     D3,D5                 ;ADD ANOTHER PARTIAL
          BCC.S     FPDNOC                ;BRANCH NO CARRY
          ADD.B     #1,D4                 ;ADD ANOTHER CARRY
FPDNOC    MOVE.W    D4,D5                 ;CONCAT HIGH WORK WITH LOW
          SWAP      D5                    ;AND CORRECT POSITIONS
          MULU.W    (SP),D7               ;TABLEHIGH X INPUTHIGH
          LEA       4(SP),SP              ;CLEAN UP STACK
          ADD.L     D5,D7                 ;FINAL PARTIAL PRODUCT
          BMI.S     FPDNON                ;BRANCH IF NO NEED TO NORMALIZE
          ADD.L     D7,D7                 ;NORMALIZE
          SUB.W     #1,D6                 ;ADJUST EXPONENT
FPDNON    ADD.L     #$80,D7               ;ROUND RESULT TO 24 BITS
          BCC.S     FPDROK                ;BRANCH ROUND DID NOT OVERFLOW
          ROXR.L    #1,D7                 ;ADJUST BACK
          ADD.W     #1,D6                 ;AND INCREMENT EXPONENT
FPDROK    MOVEQ     #9,D3                 ;PREPARE TO FINALIZE EXPONENT TO 7 BITS
          MOVE.W    D6,D4                 ;SAVE SIGN OF EXPONENT
          ASL.W     D3,D6                 ;FORCE 7 BIT PRECISION
          BVS.S     FPDXOV                ;BRANCH EXPONENT OVERFLOW
          EOR.W     #$8000,D6             ;EXPONENT BACK FROM 2'S-COMPLEMENT
          LSR.L     D3,D6                 ;PLACE INTO LOW BYTE WITH SIGN
          MOVE.B    D6,D7                 ;INSERT INTO RESULT
          BEQ.S     FPDRT0                ;RETURN ZERO IF EXPONENT ZERO
FPDRTN1   RTS                             ;RETURN TO CALLER

* RETURN ZERO FOR UNDERFLOW
FPDRT0    MOVEQ     #0,D7                 ;RETURN ZERO
          RTS                             ;RETURN TO CALLER

* EXPONENT OVERFLOW/UNDERFLOW
FPDXOV    TST.W     D4                    ;TEST ORIGINAL SIGN
          BMI.S     FPDRT0                ;BRANCH UNDERFLOW TO RETURN ZERO
FPDOVF1   MOVEQ     #-1,D7                ;CREATE ALL ONES
          SWAP      D6                    ;SIGN TO LOW BIT
          ROXR.B    #1,D6                 ;SIGN TO X BIT
          ROXR.B    #1,D7                 ;SIGN INTO HIGHEST POSSIBLE RESULT
          TST.B     D7                    ;CLEAR CARRY BIT
          ORI.B     #$02,CCR              ;SET OVERFLOW BIT
          RTS                             ;RETURN TO CALLER WITH OVERFLOW

*         END
*         TTL       FAST FLOATING POINT DIVIDE (FFPDIV)
*****************************************
*  (C) COPYRIGHT 1980 BY MOTOROLA INC.  *
*****************************************

*FFPDIV   IDNT      1,4                   ;FFP DIVIDE
*         XDEF      FFPDIV                ;ENTRY POINT
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*         SECTION   9

********************************************
*           FFPDIV SUBROUTINE              *
*                                          *
* INPUT:                                   *
*        D6 - FLOATING POINT DIVISOR       *
*        D7 - FLOATING POINT DIVIDEND      *
*                                          *
* OUTPUT:                                  *
*        D7 - FLOATING POINT QUOTIENT      *
*                                          *
* CONDITION CODES:                         *
*        N - SET IF RESULT NEGATIVE        *
*        Z - SET IF RESULT ZERO            *
*        V - SET IF RESULT OVERFLOWED      *
*        C - UNDEFINED                     *
*        X - UNDEFINED                     *
*                                          *
* REGISTERS D3 THRU D5 VOLATILE            *
*                                          *
* CODE: 150 BYTES     STACK WORK: 0 BYTES  *
*                                          *
* NOTES:                                   *
*   1) DIVISOR IS UNALTERED (D6).          *
*   2) UNDERFLOWS RETURN ZERO WITHOUT      *
*      ANY INDICATORS SET.                 *
*   3) OVERFLOWS RETURN THE HIGHEST VALUE  *
*      WITH THE PROPER SIGN AND THE 'V'    *
*      BIT SET IN THE CCR.                 *
*   4) IF A DIVIDE BY ZERO IS ATTEMPTED    *
*      THE DIVIDE BY ZERO EXCEPTION TRAP   *
*      IS FORCED BY THIS CODE WITH THE     *
*      ORIGINAL ARGUMENTS INTACT.  IF THE  *
*      EXCEPTION RETURNS WITH THE DENOM-   *
*      INATOR ALTERED THE DIVIDE OPERATION *
*      CONTINUES, OTHERWISE AN OVERFLOW    *
*      IS FORCED WITH THE PROPER SIGN.     *
*      THE FLOATING DIVIDE BY ZERO CAN BE  *
*      DISTINGUISHED FROM TRUE ZERO DIVIDE *
*      BY THE FACT THAT IT IS AN IMMEDIATE *
*      ZERO DIVIDING INTO REGISTER D7.     *
*                                          *
* TIME: (8 MHZ NO WAIT STATES ASSUMED)     *
* DIVIDEND ZERO         5.250 MICROSECONDS *
* MINIMUM TIME OTHERS  72.750 MICROSECONDS *
* MAXIMUM TIME OTHERS  85.000 MICROSECONDS *
* AVERAGE OTHERS       76.687 MICROSECONDS *
*                                          *
********************************************
*         PAGE

* DIVIDE BY ZERO EXIT
FPDDZR    DIVU.W    #0,D7                 ;**FORCE DIVIDE BY ZERO **

* IF THE EXCEPTION RETURNS WITH ALTERED DENOMINATOR - CONTINUE DIVIDE
          TST.L     D6                    ;? EXCEPTION ALTER THE ZERO
          BNE.S     FFPDIV                ;BRANCH IF SO TO CONTINUE
* SETUP MAXIMUM NUMBER FOR DIVIDE OVERFLOW
FPDOVF    OR.L      #$FFFFFF7F,D7         ;MAXIMIZE WITH PROPER SIGN
          TST.B     D7                    ;SET CONDITION CODE FOR SIGN
          OR.B      #$02,CCR              ;SET OVERFLOW BIT
FPDRTN    RTS                             ;RETURN TO CALLER

* OVER OR UNDERFLOW DETECTED
FPDOV2    SWAP      D6                    ;RESTORE ARG1
          SWAP      D7                    ;RESTORE ARG2 FOR SIGN
FPDOVFS   EOR.B     D6,D7                 ;SETUP CORRECT SIGN
          BRA.S     FPDOVF                ;AND ENTER OVERFLOW HANDLING
FPDOUF    BMI.S     FPDOVFS               ;BRANCH IF OVERFLOW
FPDUND    MOVEQ     #0,D7                 ;UNDERFLOW TO ZERO
          RTS                             ;AND RETURN TO CALLER

***************
* ENTRY POINT *
***************

* FIRST SUBTRACT EXPONENTS
FFPDIV    MOVE.B    D6,D5                 ;COPY ARG1 (DIVISOR)
          BEQ.S     FPDDZR                ;BRANCH IF DIVIDE BY ZERO
          MOVE.L    D7,D4                 ;COPY ARG2 (DIVIDEND)
          BEQ.S     FPDRTN                ;RETURN ZERO IF DIVIDEND ZERO
          MOVEQ     #-128,D3              ;SETUP SIGN MASK
          ADD.W     D5,D5                 ;ISOLATE ARG1 SIGN FROM EXPONENT
          ADD.W     D4,D4                 ;ISOLATE ARG2 SIGN FROM EXPONENT
          EOR.B     D3,D5                 ;ADJUST ARG1 EXPONENT TO BINARY
          EOR.B     D3,D4                 ;ADJUST ARG2 EXPONENT TO BINARY
          SUB.B     D5,D4                 ;SUBTRACT EXPONENTS
          BVS.S     FPDOUF                ;BRANCH IF OVERFLOW/UNDERFLOW
          CLR.B     D7                    ;CLEAR ARG2 S+EXP
          SWAP      D7                    ;PREPARE HIGH 16 BIT COMPARE
          SWAP      D6                    ;AGAINST ARG1 AND ARG2
          CMP.W     D6,D7                 ;? CHECK IF OVERFLOW WILL OCCUR
          BMI.S     FPDNOV                ;BRANCH IF NOT
* ADJUST FOR FIXED POINT DIVIDE OVERFLOW
          ADD.B     #2,D4                 ;ADJUST EXPONENT UP ONE
          BVS.S     FPDOV2                ;BRANCH OVERFLOW HERE
          ROR.L     #1,D7                 ;SHIFT DOWN BY POWER OF TWO
FPDNOV    SWAP      D7                    ;CORRECT ARG2
          MOVE.B    D3,D5                 ;MOVE $80 INTO D5.B
          EOR.W     D5,D4                 ;CREATE SIGN AND ABSOLUTIZE EXPONENT
          LSR.W     #1,D4                 ;D4.B NOW HAS SIGN+EXPONENT OF RESULT

* NOW DIVIDE JUST USING 16 BITS INTO 24
          MOVE.L    D7,D3                 ;COPY ARG1 FOR INITIAL DIVIDE
          DIVU.W    D6,D3                 ;OBTAIN TEST QUOTIENT
          MOVE.W    D3,D5                 ;SAVE TEST QUOTIENT

* NOW MULTIPLY 16-BIT DIVIDE RESULT TIMES FULL 24 BIT DIVISOR AND COMPARE
* WITH THE DIVIDEND.  MULTIPLYING BACK OUT WITH THE FULL 24-BITS ALLOWS
* US TO SEE IF THE RESULT WAS TOO LARGE DUE TO THE 8 MISSING DIVISOR BITS
* USED IN THE HARDWARE DIVIDE.  THE RESULT CAN ONLY BE TOO LARGE BY 1 UNIT.
          MULU.W    D6,D3                 ;HIGH DIVISOR X QUOTIENT
          SUB.L     D3,D7                 ;D7=PARTIAL SUBTRACTION
          SWAP      D7                    ;TO LOW DIVISOR
          SWAP      D6                    ;REBUILD ARG1 TO NORMAL
          MOVE.W    D6,D3                 ;SETUP ARG1 FOR PRODUCT
          CLR.B     D3                    ;ZERO LOW BYTE
          MULU.W    D5,D3                 ;FIND REMAINING PRODUCT
          SUB.L     D3,D7                 ;NOW HAVE FULL SUBTRACTION
          BCC.S     FPDQOK                ;BRANCH FIRST 16 BITS CORRECT

* ESTIMATE TOO HIGH, DECREMENT QUOTIENT BY ONE
FPDCRT    SUB.W     #1,D5                 ;DOWN ANOTHER DIVISOR                    V1,4
          ADD.L     D6,D7                 ;ADJUST UP BY DIVISOR                    V1,4
          BCC       FPDCRT                ;ADJUST MORE IF NOT BACK TO POSITIVE     V1,4

* COMPUTE LAST 8 BITS WITH ANOTHER DIVIDE.  THE EXACT REMAINDER FROM THE
* MULTIPLY AND COMPARE ABOVE IS DIVIDED AGAIN BY A 16-BIT ONLY DIVISOR.
* HOWEVER, THIS TIME WE REQUIRE ONLY 9 BITS OF ACCURACY IN THE RESULT
* (8 TO MAKE 24 BITS TOTAL AND 1 EXTRA BIT FOR ROUNDING PURPOSES) AND THIS
* DIVIDE ALWAYS RETURNS A PRECISION OF AT LEAST 9 BITS.
FPDQOK    MOVE.L    D6,D3                 ;COPY ARG1 AGAIN
          SWAP      D3                    ;FIRST 16 BITS DIVISOR IN D3.W
          CLR.W     D7                    ;INTO FIRST 16 BITS OF DIVIDEND
          DIVU.W    D3,D7                 ;OBTAIN FINAL 16 BIT RESULT
          SWAP      D5                    ;FIRST 16 QUOTIENT TO HIGH HALF
          BMI.S     FPDISN                ;BRANCH IF NORMALIZED
* RARE OCCURRANCE - UNNORMALIZED
* HAPPENDS WHEN MANTISSA ARG1 < ARG2 AND THEY DIFFER ONLY IN LAST 8 BITS
          MOVE.W    D7,D5                 ;INSERT LOW WORD OF QUOTIENT
          ADD.L     D5,D5                 ;SHIFT MANTISSA LEFT ONE
          SUB.B     #1,D4                 ;ADJUST EXPONENT DOWN (CANNOT ZERO)
          MOVE.W    D5,D7                 ;CANCEL NEXT INSTRUCTION

* REBUILD OUR FINAL RESULT AND RETURN
FPDISN    MOVE.W    D7,D5                 ;APPEND NEXT 16 BITS
          ADD.L     #$80,D5               ;ROUND TO 24 BITS (CANNOT OVERFLOW)
          MOVE.L    D5,D7                 ;RETURN IN D7
          MOVE.B    D4,D7                 ;FINISH RESULT WITH SIGN+EXPONENT
          BEQ.S     FPDUND                ;UNDERFLOW IF ZERO EXPONENT
          RTS                             ;RETURN RESULT TO CALLER

*         END
*         TTL       FAST FLOATING POINT EXPONENT (FFPEXP)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPEXP   IDNT      1,2                   ;FFP EXP
*         OPT       PCS
*         SECTION   9
*         XDEF      FFPEXP                ;ENTRY POINT
*         XREF      9:FFPHTHET            ;HYPERTANGENT TABLE
*         XREF      9:FFPMUL,9:FFPSUB     ;ARITHMETIC PRIMITIVES
*         XREF      9:FFPTNORM            ;TRANSCENDENTAL NORMALIZE ROUTINE
*         XREF      FFPCPYRT              ;COPYRIGHT STUB

*************************************************
*                  FFPEXP                       *
*       FAST FLOATING POINT EXPONENT            *
*                                               *
*  INPUT:   D7 - INPUT ARGUMENT                 *
*                                               *
*  OUTPUT:  D7 - EXPONENTIAL RESULT             *
*                                               *
*     ALL OTHER REGISTERS ARE TRANSPARENT       *
*                                               *
*  CODE SIZE: 256 BYTES   STACK WORK: 34 BYTES  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF RESULT IN D7 IS ZERO        *
*        N - CLEARED                            *
*        V - SET IF OVERLOW OCCURRED            *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*                                               *
*  NOTES:                                       *
*    1) AN OVERFLOW RETURNS THE LARGEST         *
*       MAGNITUDE NUMBER.                       *
*    2) SPOT CHECKS SHOW AT LEAST 6.8 DIGIT     *
*       ACCURACY FOR ALL ABS(ARG) < 30.         *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*              488 MICROSECONDS                 *
*                                               *
*  LOGIC:   1) FIND N = INT(ARG/LN 2).  THIS IS *
*              ADDED TO THE MANTISSA AT THE END.*
*           3) REDUCE ARGUMENT TO RANGE BY      *
*              FINDING ARG = MOD(ARG, LN 2).    *
*           4) DERIVE EXP(ARG) WITH CORDIC LOOP.*
*           5) ADD N TO EXPONENT GIVING RESULT. *
*                                               *
*************************************************
*         PAGE

LN2       EQU       $B1721840             ;LN 2 (BASE E)             .693147180
LN2INV    EQU       $B8AA3B41             ;INVERSE OF LN 2 (BASE E) 1.44269504
CNJKHINV  EQU       $9A8F4441             ;FLOATING CONJUGATE OF K INVERSE
*                                          CORRECTED FOR THE EXTRA CONVERGENCE
*                                          DURING SHIFTS FOR 4 AND 13
KFCTSEED  EQU       $26A3D100             ;K CORDIC SEED


* OVERFLOW - RETURN ZERO OR HIGHEST VALUE AND "V" BIT
FPEOVFLW  MOVE.W    (SP)+,D6              ;LOAD SIGN WORD AND WORK OFF STACK
          TST.B     D6                    ;? WAS ARGUMENT NEGATIVE
          BPL.S     FPOVNZRO              ;NO, CONTINUE
          MOVEQ     #0,D7                 ;RETURN A ZERO
          BRA.S     FPOVRTN               ;AS RESULT IS TOO SMALL
FPOVNZRO  MOVEQ     #-1,D7                ;SET ALL ZEROES
          LSR.B     #1,D7                 ;ZERO SIGN BIT
          OR.B      #$02,CCR              ;SET OVERFLOW BIT
FPOVRTN   MOVEM.L   (SP)+,D1-D6/A0        ;RESTORE REGISTERS
          RTS                             ;RETURN TO CALLER

* RETURN ONE FOR ZERO ARGUMENT
FFPE1     MOVE.L    #$80000041,D7         ;RETURN A TRUE ONE
          LEA       7*4+2(SP),SP          ;IGNORE STACK SAVES
          TST.B     D7                    ;SET CONDITION CODE PROPERLY
          RTS                             ;RETURN TO CALLER

**************
* EXP ENTRY  *
**************

* SAVE WORK REGISTERS AND INSURE POSITIVE ARGUMENT
FFPEXP    MOVEM.L   D1-D6/A0,-(SP)        ;SAVE ALL WORK REGISTERS
          MOVE.W    D7,-(SP)              ;SAVE SIGN IN LOW ORDER BYTE FOR LATER
          BEQ.S     FFPE1                 ;RETURN A TRUE ONE FOR ZERO EXPONENT
          AND.B     #$7F,D7               ;TAKE ABSOLUTE VALUE

* DIVIDE BY LOG 2 BASE E FOR PARTIAL RESULT
FPEPOS    MOVE.L    D7,D2                 ;SAVE ORIGINAL ARGUMENT
          MOVE.L    #LN2INV,D6            ;LOAD INVERSE TO MULTIPLY (FASTER)
          BSR       FFPMUL                ;OBTAIN DIVISION THRU MULTIPLY
          BVS       FPEOVFLW              ;BRANCH IF TOO LARGE
* CONVERT QUOTIENT TO BOTH FIXED AND FLOAT INTEGER
          MOVE.B    D7,D5                 ;COPY EXPONENT OVER
          MOVE.B    D7,D6                 ;COPY EXPONENT OVER
          SUB.B     #64+32,D5             ;FIND NON-FRACTIONAL PRECISION
          NEG.B     D5                    ;MAKE POSITIVE
          CMP.B     #24,D5                ;? INSURE NOT TOO LARGE
          BLE.S     FPEOVFLW              ;BRANCH TOO LARGE
          CMP.B     #32,D5                ;? TEST UPPER RANGE
          BGE.S     FPESML                ;BRANCH LESS THAN ONE
          LSR.L     D5,D7                 ;SHIFT TO INTEGER
          MOVE.B    D7,(SP)               ;PLACE ADJUSTED EXPONENT WITH SIGN BYTE
          LSL.L     D5,D7                 ;BACK TO NORMAL WITHOUT FRACTION
          MOVE.B    D6,D7                 ;RE-INSERT SIGN+EXPONENT
          MOVE.L    #LN2,D6               ;MULTIPLY BY LN2 TO FIND RESIDUE
          BSR       FFPMUL                ;MULTIPLY BACK OUT
          MOVE.L    D7,D6                 ;SETUP TO SUBTRACT MULTIPLE OF LN 2
          MOVE.L    D2,D7                 ;MOVE ARGUMENT IN
          BSR       FFPSUB                ;FIND REMAINDER OF LN 2 DIVIDE
          MOVE.L    D7,D2                 ;COPY FLOAT ARGUMENT
          BRA.S     FPEADJ                ;ADJUST TO FIXED

* MULTIPLE LESS THAN ONE
FPESML    CLR.B     (SP)                  ;DEFAULT INITIAL MULTIPLY TO ZERO
          MOVE.L    D2,D7                 ;BACK TO ORIGINAL ARGUMENT

* CONVERT ARGUMENT TO BINARY(31,29) PRECISION
FPEADJ    CLR.B     D7                    ;CLEAR SIGN AND EXPONENT
          SUB.B     #64+3,D2              ;OBTAIN SHIFT VALUE
          NEG.B     D2                    ;FOR 2 NON-FRACTION BITS
          CMP.B     #31,D2                ;INSURE NOT TOO SMALL
          BLS.S     FPESHF                ;BRANCH TO SHIFT IF OK
          MOVEQ     #0,D7                 ;FORCE TO ZERO
FPESHF    LSR.L     D2,D7                 ;CONVERT TO FIXED POINT

*****************************************
* CORDIC CALCULATION REGISTERS:         *
* D1 - LOOP COUNT   A0 - TABLE POINTER  *
* D2 - SHIFT COUNT                      *
* D3 - Y'   D5 - Y                      *
* D4 - X'   D6 - X                      *
* D7 - TEST ARGUMENT                    *
*****************************************

* INPUT WITHIN RANGE, NOW START CORDIC SETUP
FPECOM    MOVEQ     #0,D5                 ;Y=0
          MOVE.L    #KFCTSEED,D6          ;X=1 WITH JKHINVERSE FACTORED OUT
          LEA       FFPHTHET,A0           ;POINT TO HPERBOLIC TANGENT TABLE
          MOVEQ     #0,D2                 ;PRIME SHIFT COUNTER

* PERFORM CORDIC LOOP REPEATING SHIFTS 4 AND 13 TO GUARANTEE CONVERGENCE
* (REF. "A UNIFIED ALGORITHM FOR ELEMENTARY FUNCTIONS" J.S.WALTHER
*        PG. 380 SPRING JOINT COMPUTER CONFERENCE 1971)
          MOVEQ     #3,D1                 ;DO SHIFTS 1 THRU 4
          BSR.S     CORDIC                ;FIRST CORDIC LOOPS
          SUBQ.L    #4,A0                 ;REDO TABLE ENTRY
          SUB.W     #1,D2                 ;REDO SHIFT COUNT
          MOVEQ     #9,D1                 ;DO FOUR THROUGH 13
          BSR.S     CORDIC                ;SECOND CORDIC LOOPS
          SUBQ.L    #4,A0                 ;BACK TO ENTRY 13
          SUB.W     #1,D2                 ;REDO SHIFT FOR 13
          MOVEQ     #10,D1                ;NOW 13 THROUGH 23
          BSR.S     CORDIC                ;AND FINISH UP

* NOW FINALIZE THE RESULT
          TST.B     1(SP)                 ;TEST ORIGINAL SIGN
          BPL.S     FSEPOS                ;BRANCH POSITIVE ARGUMENT
          NEG.L     D5                    ;CHANGE Y FOR SUBTRACTION
          NEG.B     (SP)                  ;NEGATE ADJUSTED EXPONENT TO SUBTRACT
FSEPOS    ADD.L     D5,D6                 ;ADD OR SUBTRACT Y TO/FROM X
          BSR       FFPTNORM              ;FLOAT X
          MOVE.L    D6,D7                 ;SETUP RESULT
* ADD LN2 FACTOR INTEGER TO THE EXPONENT
          ADD.B     (SP),D7               ;ADD TO EXPONENT
          BMI       FPEOVFLW              ;BRANCH IF TOO LARGE
          BEQ       FPEOVFLW              ;BRANCH IF TOO SMALL
          ADDQ.L    #2,SP                 ;RID WORK DATA OFF STACK
          MOVEM.L   (SP)+,D1-D6/A0        ;RESTORE REGISTERS
          RTS                             ;RETURN TO CALLER

*************************
* CORDIC LOOP SUBROUTINE*
*************************
CORDIC    ADD.W     #1,D2                 ;INCREMENT SHIFT COUNT
          MOVE.L    D5,D3                 ;COPY Y
          MOVE.L    D6,D4                 ;COPY X
          ASR.L     D2,D3                 ;SHIFT FOR Y'
          ASR.L     D2,D4                 ;SHIFT FOR X'
          TST.L     D7                    ;TEST ARG VALUE
          BMI.S     FEBMI                 ;BRANCH MINUS TEST
          ADD.L     D4,D5                 ;Y=Y+X'
          ADD.L     D3,D6                 ;X=X+Y'
          SUB.L     (A0)+,D7              ;ARG=ARG-TABLE(N)
          DBRA      D1,CORDIC             ;LOOP UNTIL DONE
          RTS                             ;RETURN

FEBMI     SUB.L     D4,D5                 ;Y=Y-X'
          SUB.L     D3,D6                 ;X=X-Y'
          ADD.L     (A0)+,D7              ;ARG=ARG+TABLE(N)
          DBRA      D1,CORDIC             ;LOOP UNTIL DONE
          RTS                             ;RETURN

*         END
*         TTL       FAST FLOATING POINT FLOAT TO ASCII (FFPFPA)
***************************************
* (C) COPYRIGHT 1980 BY MOTOROLA INC. *
***************************************

*FFPFPA   IDNT      1,1                   ;FFP FLOAT TO ASCII
*         OPT       PCS,P=68010
*         SECTION   9
*         XDEF      FFPFPA                ;ENTRY POINT
*         XREF      9:FFP10TBL,FFPCPYRT   ;POWER OF TEN TABLE

*******************************************************
*                     FFPFPA                          *
*                 FLOAT TO ASCII                      *
*                                                     *
*    INPUT:  D7 - FLOATING POINT NUMBER               *
*                                                     *
*    OUTPUT: D7 - THE BASE TEN EXPONENT IN BINARY     *
*                 FOR THE RETURNED FORMAT             *
*            SP - DECREMENTED BY 14 AND               *
*                 POINTING TO THE CONVERTED           *
*                 NUMBER IN ASCII FORMAT              *
*                                                     *
*            ALL OTHER REGISTERS UNAFFECTED           *
*                                                     *
*    CONDITION CODES:                                 *
*            N - SET IF THE RESULT IS NEGATIVE        *
*            Z - SET IF THE RESULT IS ZERO            *
*            V - CLEARED                              *
*            C - CLEARED                              *
*            X - UNDEFINED                            *
*                                                     *
*   CODE SIZE: 192 BYTES   STACK WORK AREA: 42 BYTES  *
*                                                     *
*                                                     *
*            {S}{'.'}{DDDDDDDD}{'E'}{S}{DD}           *
*            <     FRACTION   >< EXPONENT >           *
*                                                     *
*        WHERE  S - SIGN OF MANTISSA OR EXPONENT      *
*                   ('+' OR '-')                      *
*               D - DECIMAL DIGIT                     *
*                                                     *
*        STACK OFFSET OF RESULT  S.DDDDDDDDESDD       *
*        AFTER RETURN            00000000001111       *
*                                01234567890123       *
*                                                     *
*                                                     *
*        EXAMPLES   +.12000000E+03  120               *
*                   +.31415927E+01  PI                *
*                   +.10000000E-01  ONE-HUNDREDTH     *
*                   -.12000000E+03  MINUS 120         *
*                                                     *
*     NOTES:                                          *
*       1) THE BINARY BASE 10 EXPONENT IS RETURNED    *
*          IN D7 TO FACILITATE CONVERSIONS TO         *
*          OTHER FORMATS.                             *
*       2) EVEN THOUGH EIGHT DIGITS ARE RETURNED, THE *
*          PRECISION AVAILABLE IS ONLY 7.167 DIGITS.  *
*          ROUNDING SHOULD BE PERFORMED WHEN LESS     *
*          THAN EIGHT DIGITS ARE ACTUALLY UTILIZED    *
*          IN THE MANTISSA.                           *
*       3) THE STACK IS LOWERED BY 14 BYTES BY THIS   *
*          ROUTINE.  THE RETURN ADDRESS TO THE CALLER *
*          IS REPLACED BY A PORTION OF THE RESULTS.   *
*                                                     *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)                *
*        330 MICROSECONDS CONVERTING THE SAMPLE FLOAT *
*        VALUE OF 55.55 TO ASCII.                     *
*                                                     *
*******************************************************
*         PAGE

* STACK DEFINITION
STKOLD    EQU       48                    ;PREVIOUS CALLERS STACK POINTER
STKEXP    EQU       46                    ;EXPONENT
STKEXPS   EQU       45                    ;EXPONENTS SIGN
STKLTRE   EQU       44                    ;'E'
STKMANT   EQU       36                    ;MANTISSA
STKPER    EQU       35                    ;'.'
STKMANS   EQU       34                    ;MANTISSA'S SIGN
STKNEWRT  EQU       30                    ;NEW RETURN POSITION
STKRTCC   EQU       28                    ;RETURN CONDITION CODE
STKSAVE   EQU       0                     ;REGISTER SAVE AREA


FFPFPA    LEA       -10(SP),SP            ;SET STACK TO NEW LOCATION
          MOVE.L    10(SP),-(SP)          ;SAVE RETURN
          TST.B     D7                    ;TEST VALUE
          MOVE.W    SR,-(SP)              ;SAVE FOR RETURN CODE
          MOVEM.L   D2-D6/A0/A1,-(SP)     ;SAVE WORK ADDRESS REGISTER

* ADJUST FOR ZERO VALUE
          BNE.S     FPFNOT0               ;BRANCH NO ZERO INPUT
          MOVEQ     #$41,D7               ;SETUP PSUEDO INTEGER EXPONENT

* SETUP MANTISSA'S SIGN
FPFNOT0   MOVE.W    #'+.',STKMANS(SP)     ;INSERT PLUS AND DECIMAL
          MOVE.B    D7,D6                 ;COPY SIGN+EXPONENT
          BPL.S     FPFPLS                ;BRANCH IF PLUS
          ADD.B     #2,STKMANS(SP)        ;CHANGE PLUS TO MINUS

* START SEARCH FOR MAGNITUDE IN BASE 10 POWER TABLE
FPFPLS    ADD.B     D6,D6                 ;SIGN OUT OF PICTURE
          MOVE.B    #$80,D7               ;SET ROUDING FACTOR FOR SEARCH
          EOR.B     D7,D6                 ;CONVERT EXPONENT TO BINARY
          EXT.W     D6                    ;EXPONENT TO WORD
          ASR.W     #1,D6                 ;BACK FROM SIGN EXTRACTMENT
          MOVEQ     #1,D3                 ;START BASE TEN COMPUTATION
          LEA       FFP10TBL,A0           ;START AT TEN TO THE ZERO
          CMP.W     (A0),D6               ;COMPARE TO TABLE
          BLT.S     FPFMIN                ;BRANCH MINUS EXPONENT
          BGT.S     FPFPLU                ;BRANCH PLUS EXPONENT
FPFEQE    CMP.L     2(A0),D7              ;EQUAL SO COMPARE MANTISSA'S
          BCC.S     FPFFND                ;BRANCH IF INPUT GREATER OR EQUAL THAN TABLE
FPFBCK    ADD.W     #6,A0                 ;TO NEXT LOWER ENTRY IN TABLE
          SUB.W     #1,D3                 ;DECREMENT BASE 10 EXPONENT
          BRA.S     FPFFND                ;BRANCH POWER OF TEN FOUND

* EXPONENT IS HIGHER THAN TABLE
FPFPLU    LEA       -6(A0),A0             ;TO NEXT HIGHER ENTRY
          ADD.W     #1,D3                 ;INCREMENT POWER OF TEN
          CMP.W     (A0),D6               ;TEST NEW MAGNITUDE
          BGT.S     FPFPLU                ;LOOP IF STILL GREATER
          BEQ.S     FPFEQE                ;BRANCH EQUAL EXPONENT
          BRA.S     FPFBCK                ;BACK TO LOWER AND FOUND

* EXPONENT IS LOWER THAN TABLE
FPFMIN    LEA       6(A0),A0              ;TO NEXT LOWER ENTRY
          SUB.W     #1,D3                 ;DECREMENT POWER OF TEN BY ONE
          CMP.W     (A0),D6               ;TEST NEW MAGNITUDE
          BLT.S     FPFMIN                ;LOOP IF STILL LESS THAN
          BEQ.S     FPFEQE                ;BRANCH EQUAL EXPONENT

* CONVERT THE EXPONENT TO ASCII
FPFFND    MOVE.L    #'E+00',STKLTRE(SP)   ;SETUP EXPONENT PATTERN
          MOVE.W    D3,D2                 ;? EXPONENT POSITIVE
          BPL.S     FPFPEX                ;BRANCH IF SO
          NEG.W     D2                    ;ABSOLUTIZE
          ADD.B     #2,STKEXPS(SP)        ;TURN TO MINUS SIGN
FPFPEX    CMP.W     #10,D2                ;? TEN OR GREATER
          BCS.S     FPFGEN                ;BRANCH IF NOT
          ADD.B     #1,STKEXP(SP)         ;CHANGE ZERO TO A ONE
          SUB.W     #10,D2                ;ADJUST TO DECIMAL
FPFGEN    OR.B      D2,STKEXP+1(SP)       ;FILL IN LOW DIGIT

* GENERATE THE MANTISSA IN ASCII A0->TABLE  D7=BINARY MANTISSA
* D5 - MANTISSA FROM TABLE       D6.W = BINARY EXPONENT
* D4 - SHIFT AND DIGIT BUILDER   D2 = DBRA MANTISSA DIGIT COUNT
* A1->MANTISSA STACK POSITION
          MOVEQ     #7,D2                 ;COUNT FOR EIGHT DIGITS
          LEA       STKMANT(SP),A1        ;POINT TO MANTISSA START
          TST.L     D7                    ;? ZERO TO CONVERT
          BPL.S     FPFZRO                ;BRANCH IF SO TO NOT ROUND
          TST.B     5(A0)                 ;? 24 BIT PRECISE IN TABLE
          BNE.S     FPFNXI                ;BRANCH IF NO TRAILING ZEROES
FPFZRO    CLR.B     D7                    ;CLEAR ADJUSTMENT FOR .5 LSB PRECISION
FPFNXI    MOVE.W    D6,D4                 ;COPY BINARY EXPONENT
          SUB.W     (A0)+,D4              ;FIND NORMALIZATION FACTOR
          MOVE.L    (A0)+,D5              ;LOAD MANTISSA FROM TABLE
          LSR.L     D4,D5                 ;ADJUST TO SAME EXPONENT
          MOVEQ     #9,D4                 ;START AT NINE AND COUNT DOWN
FPFINC    SUB.L     D5,D7                 ;SUBTRACT FOR ANOTHER COUNT
          DBCS      D4,FPFINC             ;DECREMENT AND BRANCH IF OVER
          BCS.S     FPFNIM                ;BRANCH NO IMPRECISION
          CLR.B     D4                    ;CORRECT RARE UNDERFLOW DUE TO TABLE IMPRECISION
FPFNIM    ADD.L     D5,D7                 ;MAKE UP FOR OVER SUBTRACTION
          SUB.B     #9,D4                 ;CORRECT VALUE
          NEG.B     D4                    ;TO BETWEEN 0 AND 9 BINARY
          OR.B      #'0',D4               ;CONVERT TO ASCII
          MOVE.B    D4,(A1)+              ;INSERT INTO ASCII MANTISSA PATTERN
          DBRA      D2,FPFNXI             ;BRANCH IF MORE DIGITS TO GO

* RETURN WITH BASE TEN EXPONENT BINARY IN D7
          MOVE.W    D3,D7                 ;TO D7
          EXT.L     D7                    ;TO FULL WORD
          MOVEM.L   (SP)+,D2-D6/A0/A1     ;RESTORE WORK REGISTERS
          RTR                             ;RETURN WITH PROPER CONDITION CODE

*         END
*         TTL       FAST FLOATING POINT FLOAT TO INTEGER (FFPFPI)
**************************************
* (C) COPYRIGHT 1980 BY MOTORLA INC. *
**************************************

*         XDEF      FFPFPI                ;ENTRY POINT
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*FFPFPI   IDNT      1,1                   ;FFP FLOAT TO INTEGER
*         SECTION   9

***********************************************************
*            FAST FLOATING POINT TO INTEGER               *
*                                                         *
*      INPUT:  D7 = FAST FLOATING POINT NUMBER            *
*      OUTPUT: D7 = FIXED POINT INTEGER (2'S COMPLEMENT)  *
*                                                         *
*  CONDITION CODES:                                       *
*             N - SET IF RESULT IS NEGATIVE               *
*             Z - SET IF RESULT IS ZERO                   *
*             V - SET IF OVERFLOW OCCURRED                *
*             C - UNDEFINED                               *
*             X - UNDEFINED                               *
*                                                         *
*  REGISTER D5 IS DESTROYED                               *
*                                                         *
*  INTEGERS OF OVER 24 BIT PRECISION WILL BE IMPRECISE    *
*                                                         *
*  NOTE: MAXIMUM SIZE INTEGER RETURNED IF OVERFLOW        *
*                                                         *
*   CODE SIZE: 78 BYTES        STACK WORK AREA: 0 BYTES   *
*                                                         *
*      TIMINGS:  (8 MHZ NO WAIT STATES ASSUMED)           *
*           COMPOSITE AVERAGE 15.00 MICROSECONDS          *
*            ARG = 0   4.75 MICROSECONDS                  *
*            ARG # 0   10.50 - 18.25 MICROSECONDS         *
*                                                         *
***********************************************************
*         PAGE

FFPFPI    MOVE.B    D7,D5                 ;SAVE SIGN/EXPONENT                4
          BMI.S     FPIMI                 ;BRANCH IF MINUS VALUE             8/10
          BEQ.S     FPIRTN                ;RETURN IF ZERO                    8/10
          CLR.B     D7                    ;CLEAR FOR SHIFT                   4
          SUB.B     #65,D5                ;EXPONENT-1 TO BINARY              8
          BMI.S     FPIRT0                ;RETURN ZERO FOR FRACTION          8/10
          SUB.B     #31,D5                ;? OVERFLOW                        8
          BPL.S     FPIOVP                ;BRANCH IF TOO LARGE               8/10
          NEG.B     D5                    ;ADJUST FOR SHIFT                  4
          LSR.L     D5,D7                 ;FINALIZE INTEGER                  8-70
FPIRTN    RTS                             ;RETURN TO CALLER                  16

* POSITIVE OVERFLOW
FPIOVP    MOVEQ     #-1,D7                ;LOAD ALL ONES
          LSR.L     #1,D7                 ;PUT ZERO IN AS SIGN
          OR.B      #$02,CCR              ;SET OVERFLOW BIT ON
          RTS                             ;RETURN TO CALLER

* FRACTION ONLY RETURNS ZERO
FPIRT0    MOVEQ     #0,D7                 ;RETURN ZERO
          RTS                             ;BACK TO CALLER

* INPUT IS A MINUS INTEGER
FPIMI     CLR.B     D7                    ;CLEAR FOR CLEAN SHIFT                 4
          SUB.B     #$80+65,D5            ;EXPONENT-1 TO BINARY AND STRIP SIGN   8
          BMI.S     FPIRT0                ;RETURN ZERO FOR FRACTION              8/10
          SUB.B     #31,D5                ;? OVERFLOW                            8
          BPL.S     FPICHM                ;BRANCH POSSIBLE MINUS OVERFLOW        8/10
          NEG.B     D5                    ;ADJUST FOR SHIFT COUNT                4
          LSR.L     D5,D7                 ;SHIFT TO PROPER MAGNITUDE             8-70
          NEG.L     D7                    ;TO MINUS NOW                          6
          RTS                             ;RETURN TO CALLER                      16

* CHECK FOR MAXIMUM MINUS NUMBER OR MINUS OVERFLOW
FPICHM    BNE.S     FPIOVM                ;BRANCH MINUS OVERFLOW
          NEG.L     D7                    ;ATTEMPT CONVERT TO NEGATIVE
          TST.L     D7                    ;CLEAR OVERFLOW BIT
          BMI.S     FPIRTN                ;RETURN IF MAXIMUM NEGATIVE INTEGER
FPIOVM    MOVEQ     #0,D7                 ;CLEAR D7
          BSET.L    #31,D7                ;SET HIGH BIT ON FOR MAXIMUM NEGATIVE
          OR.B      #$02,CCR              ;SET OVERFLOW BIT ON
          RTS                             ;AND RETURN TO CALLER

*         END
*         TTL       FAST FLOATING POINT CORDIC HYPERBOLIC TABLE (FFPHTHET)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPHTHET IDNT      1,1                   ;FFP INVERSE HYPERBOLIC TABLE
*         SECTION   9
*         XDEF      FFPHTHET              ;EXTERNAL DEFINITION

*********************************************************
*     INVERSE HYPERBOLIC TANGENT TABLE FOR CORDIC       *
*                                                       *
* THE FOLLOWING TABLE IS USED DURING CORDIC             *
* TRANSCENDENTAL EVALUATIONS FOR LOG AND EXP. IT HAS    *
* INVERSE HYPERBOLIC TANGENT FOR 2**-N WHERE N RANGES   *
* FROM 1 TO 24.  THE FORMAT IS BINARY(31,29)            *
* PRECISION (I.E. THE BINARY POINT IS ASSUMED BETWEEN   *
* BITS 27 AND 28 WITH THREE LEADING NON-FRACTION BITS.) *
*********************************************************

FFPHTHET  DC.L      $1193EA7A             ;HARCTAN(2**-1)   .549306144 !elenc vasm does signed shift so force value
          DC.L      $4162BBE8>>3          ;HARCTAN(2**-2)   .255412812
          DC.L      $202B1238>>3          ;HARCTAN(2**-3)
          DC.L      $10055888>>3          ;HARCTAN(2**-4)
          DC.L      $0800AAC0>>3          ;HARCTAN(2**-5)
          DC.L      $04001550>>3          ;HARCTAN(2**-6)
          DC.L      $020002A8>>3          ;HARCTAN(2**-7)
          DC.L      $01000050>>3          ;HARCTAN(2**-8)
          DC.L      $00800008>>3          ;HARCTAN(2**-9)
          DC.L      $00400000>>3          ;HARCTAN(2**-10)
          DC.L      $00200000>>3          ;HARCTAN(2**-11)
          DC.L      $00100000>>3          ;HARCTAN(2**-12)
          DC.L      $00080000>>3          ;HARCTAN(2**-13)
          DC.L      $00040000>>3          ;HARCTAN(2**-14)
          DC.L      $00020000>>3          ;HARCTAN(2**-15)
          DC.L      $00010000>>3          ;HARCTAN(2**-16)
          DC.L      $00008000>>3          ;HARCTAN(2**-17)
          DC.L      $00004000>>3          ;HARCTAN(2**-18)
          DC.L      $00002000>>3          ;HARCTAN(2**-19)
          DC.L      $00001000>>3          ;HARCTAN(2**-20)
          DC.L      $00000800>>3          ;HARCTAN(2**-21)
          DC.L      $00000400>>3          ;HARCTAN(2**-22)
          DC.L      $00000200>>3          ;HARCTAN(2**-23)
          DC.L      $00000100>>3          ;HARCTAN(2**-24)

*         END
*         TTL       FAST FLOATING POINT INTEGER TO FLOAT (FFPIFP)
************************************
* (C) COPYRIGHT 1980 MOTORLA INC.  *
************************************

*         XDEF      FFPIFP                ;EXTERNAL NAME
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*FFPIFP   IDNT      1,1                   ;FFP INTEGER TO FLOAT
*         SECTION   9

***********************************************************
*               INTEGER TO FLOATING POINT                 *
*                                                         *
*      INPUT: D7 = FIXED POINT INTEGER (2'S COMPLEMENT)   *
*      OUTPUT: D7 = FAST FLOATING POINT EQUIVALENT        *
*                                                         *
*      CONDITION CODES:                                   *
*                N - SET IF RESULT IS NEGATIVE            *
*                Z - SET IF RESULT IS ZERO                *
*                V - CLEARED                              *
*                C - UNDEFINED                            *
*                X - UNDEFINED                            *
*                                                         *
*      D5 IS DESTROYED                                    *
*                                                         *
*      INTEGERS OF GREATER THAN 24 BITS WILL BE ROUNDED   *
*      AND IMPRECISE.                                     *
*                                                         *
*      CODE SIZE: 56 BYTES      STACK WORK AREA: 0 BYTES  *
*                                                         *
*      TIMINGS: (8MHZ NO WAIT STATES ASSUMED)             *
*         COMPOSITE AVERATE 31.75 MICROSECONDS            *
*            ARG = 0   4.25          MICROSECONDS         *
*            ARG > 0   13.75 - 47.50 MICROSECONDS         *
*            ARG < 0   15.50 - 50.25 MICROSECONDS         *
*                                                         *
***********************************************************
*         PAGE

FFPIFP    MOVEQ     #64+31,D5             ;SETUP HIGH END EXPONENT
          TST.L     D7                    ;? INTEGER A ZERO
          BEQ.S     ITORTN                ;RETURN SAME RESULT IF SO
          BPL.S     ITOPLS                ;BRANCH IF POSITIVE INTEGER
          MOVEQ     #-32,D5               ;SETUP NEGATIVE HIGH EXPONENT -#80+64+32
          NEG.L     D7                    ;FIND POSITIVE VALUE
          BVS.S     ITORTI                ;BRANCH MAXIMUM NEGATIVE NUMBER
          SUB.B     #1,D5                 ;ADJUST FOR EXTRA ZERO BIT
ITOPLS    CMP.L     #$00007FFF,D7         ;? POSSIBLE 17 BITS ZERO
          BHI.S     ITOLP                 ;BRANCH IF NOT
          SWAP      D7                    ;QUICK SHIFT BY SWAP
          SUB.B     #16,D5                ;DEDUCT 16 SHIFTS FROM EXPONENT
ITOLP     ADD.L     D7,D7                 ;SHIFT MANTISSA UP
          DBMI      D5,ITOLP              ;LOOP UNTIL NORMALIZED
          TST.B     D7                    ;? TEST FOR ROUND UP
          BPL.S     ITORTI                ;BRANCH NO ROUNDING NEEDED
          ADD.L     #$100,D7              ;ROUND UP
          BCC.S     ITORTI                ;BRANCH NO OVERFLOW
          ROXR.L    #1,D7                 ;ADJUST DOWN ONE BIT
          ADD.B     #1,D5                 ;REFLECT RIGHT SHIFT IN EXPONENT BIAS
ITORTI    MOVE.B    D5,D7                 ;INSERT SIGN/EXPONENT
ITORTN    RTS                             ;RETURN TO CALLER

*         END
*         TTL       FAST FLOATING POINT LOG (FFPLOG)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPLOG   IDNT      1,2                   ;FFP LOG
*         OPT       PCS
*         SECTION   9
*         XDEF      FFPLOG                ;ENTRY POINT
*         XREF      9:FFPHTHET            ;HYPERTANGENT TABLE
*         XREF      9:FFPADD,9:FFPDIV,9:FFPSUB,9:FFPMUL  ;ARITHMETIC PRIMITIVES
*         XREF      9:FFPTNORM            ;TRANSCENDENTAL NORMALIZE ROUTINE
*         XREF      FFPCPYRT              ;COPYRIGHT STUB

*************************************************
*                  FFPLOG                       *
*       FAST FLOATING POINT LOGORITHM           *
*                                               *
*  INPUT:   D7 - INPUT ARGUMENT                 *
*                                               *
*  OUTPUT:  D7 - LOGORITHMIC RESULT TO BASE E   *
*                                               *
*     ALL OTHER REGISTERS TOTALLY TRANSPARENT   *
*                                               *
*  CODE SIZE: 184 BYTES   STACK WORK: 38 BYTES  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF THE RESULT IS ZERO          *
*        N - SET IF RESULT IN IS NEGATIVE       *
*        V - SET IF INVALID NEGATIVE ARGUMENT   *
*            OR ZERO ARGUMENT                   *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*                                               *
*  NOTES:                                       *
*    1) SPOT CHECKS SHOW ERRORS BOUNDED BY      *
*       5 X 10**-8.                             *
*    2) NEGATIVE ARGUMENTS ARE ILLEGAL AND CAUSE*
*       THE "V" BIT TO BE SET AND THE ABSOLUTE  *
*       VALUE USED INSTEAD.                     *
*    3) A ZERO ARGUMENT RETURNS THE LARGEST     *
*       NEGATIVE VALUE POSSIBLE WITH THE "V" BIT*
*       SET.                                    *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*        TIMES ARE VERY DATA SENSITIVE WITH     *
*        SAMPLES RANGING FROM 170 TO 556        *
*        MICROSECONDS                           *
*                                               *
*************************************************
*         PAGE

FPONEL    EQU       $80000041             ;FLOATING VALUE FOR ONE
LOG2      EQU       $B1721840             ;LOG(2) = .6931471805

**************
* LOG ENTRY  *
**************

* INSURE ARGUMENT POSITIVE
FFPLOG    TST.B     D7                    ;? TEST SIGN
          BEQ.S     FPLZRO                ;BRANCH ARGUMENT ZERO
          BPL.S     FPLOK                 ;BRANCH ALRIGHT

* ARGUMENT IS NEGATIVE - USE THE ABSOLUTE VALUE AND SET THE "V" BIT
          AND.B     #$7F,D7               ;TAKE ABSOLUTE VALUE
          BSR.S     FPLOK                 ;FIND LOG(ABS(X))
FPSETV    OR.B      #$02,CCR              ;SET OVERFLOW BIT
          RTS                             ;RETURN TO CALLER

* ARGUMENT IS ZERO - RETURN LARGEST NEGATIVE NUMBER WITH "V" BIT
FPLZRO    MOVEQ     #-1,D7                ;RETURN LARGEST NEGATIVE
          BRA       FPSETV                ;RETURN WITH "V" BIT SET

* SAVE WORK REGISTERS AND STRIP EXPONENT OFF
FPLOK     MOVEM.L   D1-D6/A0,-(SP)        ;SAVE ALL WORK REGISTERS
          MOVE.B    D7,-(SP)              ;SAVE ORIGINAL EXPONENT
          MOVE.B    #64+1,D7              ;FORCE BETWEEN 1 AND 2
          MOVE.L    #FPONEL,D6            ;LOAD UP A ONE
          MOVE.L    D7,D2                 ;COPY ARGUMENT
          BSR       FFPADD                ;CREATE ARG+1
          EXG       D7,D2                 ;SWAP RESULT WITH ARGUMENT
          BSR       FFPSUB                ;CREATE ARG-1
          MOVE.L    D2,D6                 ;PREPARE FOR DIVIDE
          BSR       FFPDIV                ;RESULT IS (ARG-1)/(ARG+1)
          BEQ.S     FPLNOCR               ;ZERO SO CORDIC NOT NEEDED
* CONVERT TO BIN(31,29) PRECISION
          SUB.B     #64+3,D7              ;ADJUST EXPONENT
          NEG.B     D7                    ;FOR SHIFT NECESSARY
          CMP.B     #31,D7                ;? INSURE NOT TOO SMALL
          BLS.S     FPLSHF                ;NO, GO SHIFT
          MOVEQ     #0,D7                 ;FORCE TO ZERO
FPLSHF    LSR.L     D7,D7                 ;SHIFT TO BIN(31,29) PRECISION

*****************************************
* CORDIC CALCULATION REGISTERS:         *
* D1 - LOOP COUNT   A0 - TABLE POINTER  *
* D2 - SHIFT COUNT                      *
* D3 - Y'   D5 - Y                      *
* D4 - X'   D6 - Z                      *
* D7 - X                                *
*****************************************

          MOVEQ     #0,D6                 ;Z=0
          MOVE.L    #1<<29,D5             ;Y=1
          LEA       FFPHTHET,A0           ;TO INVERSE HYPERBOLIC TANGENT TABLE
          MOVEQ     #22,D1                ;LOOP 23 TIMES
          MOVEQ     #1,D2                 ;PRIME SHIFT COUNTER
          BRA.S     CORDICL               ;ENTER CORDIC LOOP

* CORDIC LOOP
FPLPLSL   ASR.L     D2,D4                 ;SHIFT(X')
          SUB.L     D4,D5                 ;Y = Y - X'
          ADD.L     (A0),D6               ;Z = Z + HYPERTAN(I)
CORDICL   MOVE.L    D7,D4                 ;X' = X
          MOVE.L    D5,D3                 ;Y' = Y
          ASR.L     D2,D3                 ;SHIFT(Y')
FPLNLPL   SUB.L     D3,D7                 ;X = X - Y'
          BPL.S     FPLPLSL               ;BRANCH NEGATIVE
          MOVE.L    D4,D7                 ;RESTORE X
          ADDQ.L    #4,A0                 ;TO NEXT TABLE ENTRY
          ADD.B     #1,D2                 ;INCREMENT SHIFT COUNT
          LSR.L     #1,D3                 ;SHIFT(Y')
          DBRA      D1,FPLNLPL            ;AND LOOP UNTIL DONE

* NOW CONVERT TO FLOAT AND ADD EXPONENT*LOG(2) FOR FINAL RESULT
          MOVEQ     #0,D7                 ;DEFAULT ZERO IF TOO SMALL
          BSR       FFPTNORM              ;FLOAT Z
          BEQ.S     FPLNOCR               ;BRANCH IF TOO SMALL
          ADD.B     #1,D6                 ;TIMES TWO
          MOVE.L    D6,D7                 ;SETUP IN D7 IN CASE EXP=0
FPLNOCR   MOVE.L    D7,D2                 ;SAVE RESULT
          MOVEQ     #0,D6                 ;PREPARE ORIGINAL EXPONENT LOAD
          MOVE.B    (SP)+,D6              ;LOAD IT BACK
          SUB.B     #64+1,D6              ;CONVERT EXPONENT TO BINARY
          BEQ.S     FPLZPR                ;BRANCH ZERO PARTIAL HERE
          MOVE.B    D6,D1                 ;SAVE SIGN BYTE
          BPL.S     FPLPOS                ;BRANCH POSITIVE VALUE
          NEG.B     D6                    ;FORCE POSITIVE
FPLPOS    ROR.L     #8,D6                 ;PREPARE TO CONVERT TO INTEGER
          MOVEQ     #$47,D5               ;SETUP EXPONENT MASK
FPLNORM   ADD.L     D6,D6                 ;SHIFT TO LEFT
          DBMI      D5,FPLNORM            ;EXP-1 AND BRANCH IF NOT NORMALIZED
          MOVE.B    D5,D6                 ;FIX IN EXPONENT
          AND.B     #$80,D1               ;EXTRACT SIGN
          OR.B      D1,D6                 ;INSERT SIGN IN
          MOVE.L    #LOG2,D7              ;MULTIPLY EXPONENT BY LOG(2)
          BSR       FFPMUL                ;MULTIPLY D6 AND D7
          MOVE.L    D2,D6                 ;NOW ADD CORDIC RESULT
          BSR       FFPADD                ;FOR FINAL ANSWER

FPLZPR    MOVEM.L   (SP)+,D1-D6/A0        ;RESTORE REGISTERS
          RTS                             ;RETURN TO CALLER

*         END
*         TTL       FAST FLOATING POINT MULTIPLY (FFPMUL)
*******************************************
* (C)  COPYRIGHT 1980 BY MOTOROLA INC.    *
*******************************************

*FFPMUL   IDNT      1,1                   ;FFP MULTIPLY
*         XDEF      FFPMUL                ;ENTRY POINT
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE
*         SECTION   9

********************************************
*          FFPMUL  SUBROUTINE              *
*                                          *
* INPUT:                                   *
*          D6 - FLOATING POINT MULTIPLIER  *
*          D7 - FLOATING POINT MULTIPLICAN *
*                                          *
* OUTPUT:                                  *
*          D7 - FLOATING POINT RESULT      *
*                                          *
*                                          *
* CONDITION CODES:                         *
*          N - SET IF RESULT NEGATIVE      *
*          Z - SET IF RESULT IS ZERO       *
*          V - SET IF OVERFLOW OCCURRED    *
*          C - UNDEFINED                   *
*          X - UNDEFINED                   *
*                                          *
* REGISTERS D3 THRU D5 ARE VOLATILE        *
*                                          *
* SIZE: 122 BYTES    STACK WORK: 0 BYTES   *
*                                          *
* NOTES:                                   *
*   1) MULTIPIER UNALTERED (D6).           *
*   2) UNDERFLOWS RETURN ZERO WITH NO      *
*      INDICATOR SET.                      *
*   3) OVERFLOWS WILL RETURN THE MAXIMUM   *
*      VALUE WITH THE PROPER SIGN AND THE  *
*      'V' BIT SET IN THE CCR.             *
*   4) THIS VERSION OF THE MULTIPLY HAS A  *
*      SLIGHT ERROR DUE TO TRUNCATION      *
*      OF .00390625 IN THE LEAST SIGNIFIC- *
*      ANT BIT.  THIS AMOUNTS TO AN AVERAGE*
*      OF 1 INCORRECT LEAST  SIGNIFICANT   *
*      BIT RESULT FOR EVERY 512 MULTIPLIES.*
*                                          *
*  TIMES: (8MHZ NO WAIT STATES ASSUMED)    *
* ARG1 ZERO            5.750 MICROSECONDS  *
* ARG2 ZERO            3.750 MICROSECONDS  *
* MINIMUM TIME OTHERS 38.000 MICROSECONDS  *
* MAXIMUM TIME OTHERS 51.750 MICROSECONDS  *
* AVERAGE OTHERS      44.125 MICROSECONDS  *
*                                          *
********************************************
*         PAGE

* FFPMUL SUBROUTINE ENTRY POINT
FFPMUL    MOVE.B    D7,D5                 ;PREPARE SIGN/EXPONENT WORK       4
          BEQ.S     FFMRTN                ;RETURN IF RESULT ALREADY ZERO    8/10
          MOVE.B    D6,D4                 ;COPY ARG1 SIGN/EXPONENT          4
          BEQ.S     FFMRT0                ;RETURN ZERO IF ARG1=0            8/10
          ADD.W     D5,D5                 ;SHIFT LEFT BY ONE                4
          ADD.W     D4,D4                 ;SHIFT LEFT BY ONE                4
          MOVEQ     #-128,D3              ;PREPARE EXPONENT MODIFIER ($80)  4
          EOR.B     D3,D4                 ;ADJUST ARG1 EXPONENT TO BINARY   4
          EOR.B     D3,D5                 ;ADJUST ARG2 EXPONENT TO BINARY   4
          ADD.B     D4,D5                 ;ADD EXPONENTS                    4
          BVS.S     FFMOUF                ;BRANCH IF OVERFLOW/UNDERFLOW     8/10
          MOVE.B    D3,D4                 ;OVERLAY $80 CONSTANT INTO D4     4
          EOR.W     D4,D5                 ;D5 NOW HAS SIGN AND EXPONENT     4
          ROR.W     #1,D5                 ;MOVE TO LOW 8 BITS               8
          CLR.B     D7                    ;CLEAR S+EXP OUT OF ARG2          4
          MOVE.L    D7,D3                 ;PREPARE ARG2 FOR MULTIPLY        4
          SWAP      D3                    ;USE TOP TWO SIGNIFICANT BYTES    4
          MOVE.L    D6,D4                 ;COPY ARG1                        4
          CLR.B     D4                    ;CLEAR LOW BYTE (S+EXP)           4
          MULU.W    D4,D3                 ;A3 X B1B2                        38-54 (46)
          SWAP      D4                    ;TO ARG1 HIGH TWO BYTES           4
          MULU.W    D7,D4                 ;B3 X A1A2                        38-54 (46)
          ADD.L     D3,D4                 ;ADD PARTIAL PRODUCTS R3R4R5      8
          CLR.W     D4                    ;CLEAR LOW END RUNOFF             4
          ADDX.B    D4,D4                 ;SHIFT IN CARRY IF ANY            4
          SWAP      D4                    ;PUT CARRY INTO HIGH WORD         4
          SWAP      D7                    ;NOW TOP OF ARG2                  4
          SWAP      D6                    ;AND TOP OF ARG1                  4
          MULU.W    D6,D7                 ;A1A2 X B1B2                      40-70 (54)
          SWAP      D6                    ;RESTORE ARG1                     4
          ADD.L     D4,D7                 ;ADD PARTIAL PRODUCTS             8
          BPL.S     FFMNOR                ;BRANCH IF MUST NORMALIZE         8/10
FFMCON    ADD.L     #$80,D7               ;ROUND UP (CANNOT OVERFLOW)       16
          MOVE.B    D5,D7                 ;INSERT SIGN AND EXPONENT         4
          BEQ.S     FFMRT0                ;RETURN ZERO IF ZERO EXPONENT     8/10
FFMRTN    RTS                             ;RETURN TO CALLER                 16

* MUST NORMALIZE RESULT
FFMNOR    SUB.B     #1,D5                 ;BUMP EXPONENT DOWN BY ONE        4
          BVS.S     FFMRT0                ;RETURN ZERO IF UNDERFLOW         8/10
          BCS.S     FFMRT0                ;RETURN ZERO IF SIGN INVERTED     8/10
          MOVEQ     #$40,D4               ;ROUNDING FACTOR                  4
          ADD.L     D4,D7                 ;ADD IN ROUNDING FACTOR           8
          ADD.L     D7,D7                 ;SHIFT TO NORMALIZE               8
          BCC.S     FFMCLN                ;RETURN NORMALIZED NUMBER         8/10
          ROXR.L    #1,D7                 ;ROUNDING FORCED CARRY IN TOP BIT 10
          ADD.B     #1,D5                 ;UNDO NORMALIZE ATTEMPT           4
FFMCLN    MOVE.B    D5,D7                 ;INSERT SIGN AND EXPONENT         4
          BEQ.S     FFMRT0                ;RETURN ZERO IF EXPONENT ZERO     8/10
          RTS                             ;RETURN TO CALLER                 16

* ARG1 ZERO
FFMRT0    MOVEQ     #0,D7                 ;RETURN ZERO                      4
          RTS                             ;RETURN TO CALLER                 16

* OVERFLOW OR UNDERFLOW EXPONENT
FFMOUF    BPL.S     FFMRT0                ;BRANCH IF UNDERFLOW TO GIVE ZERO 8/10
          EOR.B     D6,D7                 ;CALCULATE PROPER SIGN            4
          OR.L      #$FFFFFF7F,D7         ;FORCE HIGHEST VALUE POSSIBLE     16
          TST.B     D7                    ;SET SIGN IN RETURN CODE
          ORI.B     #$02,CCR              ;SET OVERFLOW BIT                 20
          RTS                             ;RETURN TO CALLER                 16

*         END
*         TTL       FAST FLOATING POINT POWER (FFPPWR)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPPWR   IDNT      1,1                   ;FFP POWER
*         OPT       PCS
*         SECTION   9
*         XDEF      FFPPWR                ;ENTRY POINT
*         XREF      9:FFPLOG,9:FFPEXP     ;EXPONENT AND LOG FUNCTIONS
*         XREF      9:FFPMUL              ;MULTIPLY FUNCTION
*         XREF      FFPCPYRT              ;COPYRIGHT STUB

*************************************************
*                  FFPPWR                       *
*       FAST FLOATING POINT POWER FUNCTION      *
*                                               *
*  INPUT:   D6 - FLOATING POINT EXPONENT VALUE  *
*           D7 - FLOATING POINT ARGUMENT VALUE  *
*                                               *
*  OUTPUT:  D7 - RESULT OF THE VALUE TAKEN TO   *
*                THE POWER SPECIFIED            *
*                                               *
*     ALL REGISTERS BUT D7 ARE TRANSPARENT      *
*                                               *
*  CODE SIZE:  36 BYTES   STACK WORK: 42 BYTES  *
*                                               *
* CALLS SUBROUTINES: FFPLOG, FFPEXP AND FFPMUL  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF THE RESULT IS ZERO          *
*        N - CLEARED                            *
*        V - SET IF OVERFLOW OCCURRED OR BASE   *
*            VALUE ARGUMENT WAS NEGATIVE        *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*  NOTES:                                       *
*    1) A NEGATIVE BASE VALUE WILL FORCE THE USE*
*       IF ITS ABSOLUTE VALUE.  THE "V" BIT WILL*
*       BE SET UPON FUNCTION RETURN.            *
*    2) IF THE RESULT OVERFLOWS THEN THE        *
*       MAXIMUM SIZE VALUE IS RETURNED WITH THE *
*       "V" BIT SET IN THE CONDITION CODE.      *
*    3) SPOT CHECKS SHOW AT LEAST SIX DIGIT     *
*       PRECISION FOR 80 PERCENT OF THE CASES.  *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*        THE TIMING IS VERY DATA SENSITIVE WITH *
*        TEST SAMPLES RANGING FROM 720 TO       *
*        1206 MICROSECONDS                      *
*                                               *
*************************************************
*         PAGE

*****************
* POWER  ENTRY  *
*****************

* TAKE THE LOGORITHM OF THE BASE VALUE
FFPPWR    TST.B     D7                    ;? NEGATIVE BASE VALUE
          BPL.S     FPPPOS                ;BRANCH POSITIVE
          AND.B     #$7F,D7               ;TAKE ABSOLUTE VALUE
          BSR.S     FPPPOS                ;FIND RESULT USING THAT
          OR.B      #$02,CCR              ;FORCE "V" BIT ON FOR NEGATIVE ARGUMENT
          RTS                             ;RETURN TO CALLER

FPPPOS    BSR       FFPLOG                ;FIND LOG OF THE NUMBER TO BE USED
          MOVEM.L   D3-D5,-(SP)           ;SAVE MULTIPLY WORK REGISTERS
          BSR       FFPMUL                ;MULTIPLY BY THE EXPONENT
          MOVEM.L   (SP)+,D3-D5           ;RESTORE MULTIPLY WORK REGISTERS
* IF OVERFLOWED, FFPEXP WILL SET "V" BIT AND RETURN DESIRED RESULT ANYWAY
          BRA       FFPEXP                ;RESULT IS EXPONENT

*         END
*         TTL       FFP SINE COSINE TANGENT (FFPSIN/FFPCOS/FFPTAN/FFPSINCS)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPSIN   IDNT      1,2                   ;FFP SINE COSINE TANGENT
*         OPT       PCS
*         SECTION   9
*         XDEF      FFPSIN,FFPCOS,FFPTAN,FFPSINCS ;ENTRY POINTS
*         XREF      9:FFPTHETA            ;INVERSE TANGENT TABLE
*         XREF      9:FFPMUL,9:FFPDIV,9:FFPSUB ;MULTIPLY, DIVIDE AND SUBTRACT
*         XREF      9:FFPTNORM            ;TRANSCENDENTAL NORMALIZE ROUTINE
*         XREF      FFPCPYRT              ;COPYRIGHT STUB

*************************************************
*        FFPSIN FFPCOS FFPTAN FFPSINCS          *
*     FAST FLOATING POINT SINE/COSINE/TANGENT   *
*                                               *
*  INPUT:   D7 - INPUT ARGUMENT (RADIAN)        *
*                                               *
*  OUTPUT:  D7 - FUNCTION RESULT                *
*           (FFPSINCS ALSO RETURNS D6)          *
*                                               *
*     ALL OTHER REGISTERS TOTALLY TRANSPARENT   *
*                                               *
*  CODE SIZE: 334 BYTES   STACK WORK: 38 BYTES  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF RESULT IN D7 IS ZERO        *
*        N - SET IF RESULT IN D7 IS NEGATIVE    *
*        C - UNDEFINED                          *
*        V - SET IF RESULT IS MEANINGLESS       *
*            (INPUT MAGNITUDE TOO LARGE)        *
*        X - UNDEFINED                          *
*                                               *
*  FUNCTIONS:                                   *
*             FFPSIN   -  SINE RESULT           *
*             FFPCOS   -  COSINE RESULT         *
*             FFPTAN   -  TANGENT RESULT        *
*             FFPSINCS -  BOTH SINE AND COSINE  *
*                         D6 - SIN, D7 - COSINE *
*                                               *
*  NOTES:                                       *
*    1) INPUT VALUES ARE IN RADIANS.            *
*    2) FUNCTION FFPSINCS RETURNS BOTH SINE     *
*       AND COSINE TWICE AS FAST AS CALCULATING *
*       THE TWO FUNCTIONS INDEPENDENTLY FOR     *
*       THE SAME VALUE.  THIS IS HANDY FOR      *
*       GRAPHICS PROCESSING.                    *
*    2) INPUT ARGUMENTS LARGER THAN TWO PI      *
*       SUFFER REDUCED PRECISION.  THE LARGER   *
*       THE ARGUMENT, THE SMALLER THE PRECISION.*
*       EXCESSIVELY LARGE ARGUMENTS WHICH HAVE  *
*       LESS THAN 5 BITS OF PRECISION ARE       *
*       RETURNED UNCHANGED WITH THE "V" BIT SET.*
*    3) FOR TANGENT ANGLES OF INFINITE VALUE    *
*       THE LARGEST POSSIBLE POSITIVE NUMBER    *
*       IS RETURNED ($FFFFFF7F). THIS STILL     *
*       GIVES RESULTS WELL WITHIN SINGLE        *
*       PRECISION CALCULATION.                  *
*    4) SPOT CHECKS SHOW ERRORS BOUNDED BY      *
*       4 X 10**-7 BUT FOR ARGUMENTS CLOSE TO   *
*       PI/2 INTERVALS WHERE 10**-5 IS SEEN.    *
*                                               *
*  TIME: (8MHZ NO WAIT STATES AND ARGUMENT      *
*         ASSUMED WITHIN +-PI)                  *
*                                               *
*           FFPSIN       413 MICROSECONDS       *
*           FFPCOS       409 MICROSECONDS       *
*           FFPTAN       501 MICROSECONDS       *
*           FFPSINCS     420 MICROSECONDS       *
*************************************************
*         PAGE

PI        EQU       $C90FDB42             ;FLOATING CONSTANT PI
FIXEDPI   EQU       $C90FDAA2             ;PI SKELETON TO 32 BITS PRECISION
FIXEDPIs2 EQU       $3243f6a8             ;PI SKELETON TO 32 BITS PRECISION !elenc vasm does signed shift so force value
FIXEDPIs4 EQU       $0C90FDAA             ;PI SKELETON TO 32 BITS PRECISION !elenc vasm does signed shift so force value
INV2PI    EQU       $A2F9833E             ;INVERSE OF TWO-PI
KINV      EQU       $9B74EE40             ;FLOATING K INVERSE
NKFACT    EQU       $EC916240             ;NEGATIVE K INVERSE

********************************************
* ENTRY FOR RETURNING BOTH SINE AND COSINE *
********************************************
FFPSINCS  MOVE.W    #-2,-(SP)             ;FLAG BOTH SINE AND COSINE WANTED
          BRA.S     FPSCOM                ;ENTER COMMON CODE

**********************
* TANGENT ENTRY POINT*
**********************
FFPTAN    MOVE.W    #-1,-(SP)             ;FLAG TANGENT WITH MINUS VALUE
          BRA.S     FPSCHL                ;CHECK VERY SMALL VALUES

**************************
* COSINE ONLY ENTRY POINT*
**************************
FFPCOS    MOVE.W    #1,-(SP)              ;FLAG COSINE WITH POSITIVE VALUE
          BRA.S     FPSCOM                ;ENTER COMMON CODE

* NEGATIVE SINE/TANGENT SMALL VALUE CHECK
FPSCHM    CMP.B     #$80+$40-8,D7         ;? LESS OR SAME AS -2**-9
          BHI.S     FPSCOM                ;CONTINUE IF NOT TOO SMALL
* RETURN ARGUMENT
FPSRTI    ADDQ.L    #2,SP                 ;RID INTERNAL PARAMETER
          TST.B     D7                    ;SET CONDITION CODES
          RTS                             ;RETURN TO CALLER

************************
* SINE ONLY ENTRY POINT*
************************
FFPSIN    CLR.W     -(SP)                 ;FLAG SINE WITH ZERO
* SINE AND TANGENT VALUES < 2**-9 RETURN IDENTITIES
FPSCHL    TST.B     D7                    ;TEST SIGN
          BMI.S     FPSCHM                ;BRANCH MINUS
          CMP.B     #$40-8,D7             ;? LESS OR SAME THAN 2**-9
          BLS.S     FPSRTI                ;RETURN IDENTITY

* SAVE REGISTERS AND INSURE INPUT WITHIN + OR - PI RANGE
FPSCOM    MOVEM.L   D1-D6/A0,-(SP)        ;SAVE ALL WORK REGISTERS
          MOVE.L    D7,D2                 ;COPY INPUT OVER
          ADD.B     D7,D7                 ;RID SIGN BIT
          CMP.B     #(64+5)<<1,D7         ;? ABS(ARG) < 2**6 (32)
          BLS.S     FPSNLR                ;BRANCH YES, NOT TOO LARGE
* ARGUMENT IS TOO LARGE TO SUBTRACT TO WITHIN RANGE
          CMP.B     #(64+20)<<1,D7        ;? TEST EXCESSIVE SIZE (>2**20)
          BLS.S     FPSGPR                ;NO, GO AHEAD AND USE
* ERROR - ARGUMENT SO LARGE RESULT HAS NO PRECISION
          OR.B      #$02,CCR              ;FORCE V BIT ON
          MOVEM.L   (SP)+,D1-D6/A0        ;RESTORE REGISTERS
          ADDQ.L    #2,SP                 ;CLEAN INTERNAL ARGUMENT OFF STACK
          RTS                             ;RETURN TO CALLER

* WE MUST FIND MOD(ARG,TWOPI) SINCE ARGUMENT IS TOO LARGE FOR SUBTRACTIONS
FPSGPR    MOVE.L    #INV2PI,D6            ;LOAD UP 2*PI INVERSE CONSTANT
          MOVE.L    D2,D7                 ;COPY OVER INPUT ARGUMENT
          BSR       FFPMUL                ;DIVIDE BY TWOPI (VIA MULTIPLY INVERSE)
* CONVERT QUOTIENT TO FLOAT INTEGER
          MOVE.B    D7,D5                 ;COPY EXPONENT OVER
          AND.B     #$7F,D5               ;RID SIGN FROM EXPONENT
          SUB.B     #64+24,D5             ;FIND FRACTIONAL PRECISION
          NEG.B     D5                    ;MAKE POSITIVE
          MOVEQ     #-1,D4                ;SETUP MASK OF ALL ONES
          CLR.B     D4                    ;START ZEROES AT LOW BYTE
          LSL.L     D5,D4                 ;SHIFT ZEROES INTO FRACTIONAL PART
          OR.B      #$FF,D4               ;DO NOT REMOVE SIGN AND EXPONENT
          AND.L     D4,D7                 ;STRIP FRACTIONAL BITS ENTIRELY
          MOVE.L    #PI+1,D6              ;LOAD UP 2*PI CONSTANT
          BSR       FFPMUL                ;MULTIPLY BACK OUT
          MOVE.L    D7,D6                 ;SETUP TO SUBTRACT MULTIPLE OF TWOPI
          MOVE.L    D2,D7                 ;MOVE ARGUMENT IN
          BSR       FFPSUB                ;FIND REMAINDER OF TWOPI DIVIDE
          MOVE.L    D7,D2                 ;USE IT AS NEW INPUT ARGUMENT

* CONVERT ARGUMENT TO BINARY(31,26) PRECISION FOR REDUCTION WITHIN +-PI
FPSNLR    MOVE.L    #FIXEDPIs4,D4         ;LOAD PI    !elenc vasm does signed shift so force value
          MOVE.L    D2,D7                 ;COPY FLOAT ARGUMENT
          CLR.B     D7                    ;CLEAR SIGN AND EXPONENT
          TST.B     D2                    ;TEST SIGN
          BMI.S     FPSNMI                ;BRANCH NEGATIVE
          SUB.B     #64+6,D2              ;OBTAIN SHIFT VALUE
          NEG.B     D2                    ;FOR 5 BIT NON-FRACTION BITS
          CMP.B     #31,D2                ;? VERY SMALL NUMBER
          BLS.S     FPSSH1                ;NO, GO AHEAD AND SHIFT
          MOVEQ     #0,D7                 ;FORCE TO ZERO
FPSSH1    LSR.L     D2,D7                 ;CONVERT TO FIXED POINT
* FORCE TO +PI OR BELOW
FPSPCK    CMP.L     D4,D7                 ;? GREATER THAN PI
          BLE.S     FPSCKM                ;BRANCH NOT
          SUB.L     D4,D7                 ;SUBTRACT
          SUB.L     D4,D7                 ;.  TWOPI
          BRA.S     FPSPCK                ;AND CHECK AGAIN

FPSNMI    SUB.B     #$80+64+6,D2          ;RID SIGN AND GET SHIFT VALUE
          NEG.B     D2                    ;FOR 5 NON-FRACTIONAL BITS
          CMP.B     #31,D2                ;? VERY SMALL NUMBER
          BLS.S     FPSSH2                ;NO, GO AHEAD AND SHIFT
          MOVEQ     #0,D7                 ;FORCE TO ZERO
FPSSH2    LSR.L     D2,D7                 ;CONVERT TO FIXED POINT
          NEG.L     D7                    ;MAKE NEGATIVE
          NEG.L     D4                    ;MAKE -PI
* FORCE TO -PI OR ABOVE
FPSNCK    CMP.L     D4,D7                 ;? LESS THAN -PI
          BGE.S     FPSCKM                ;BRANCH NOT
          SUB.L     D4,D7                 ;ADD
          SUB.L     D4,D7                 ;.  TWOPI
          BRA.S     FPSNCK                ;AND CHECK AGAIN

*****************************************
* CORDIC CALCULATION REGISTERS:         *
* D1 - LOOP COUNT   A0 - TABLE POINTER  *
* D2 - SHIFT COUNT                      *
* D3 - X'   D5 - X                      *
* D4 - Y'   D6 - Y                      *
* D7 - TEST ARGUMENT                    *
*****************************************

* INPUT WITHIN RANGE, NOW START CORDIC SETUP
FPSCKM    MOVEQ     #0,D5                 ;X=0
          MOVE.L    #NKFACT,D6            ;Y=NEGATIVE INVERSE K FACTOR SEED
          MOVE.L    #FIXEDPIs2,D4         ;SETUP FIXED PI/2 CONSTANT     !elenc vasm does signed shift so force value
          ASL.L     #3,D7                 ;NOW TO BINARY(31,29) PRECISION
          BMI.S     FPSAP2                ;BRANCH IF MINUS TO ADD PI/2
          NEG.L     D6                    ;Y=POSITIVE INVERSE K FACTOR SEED
          NEG.L     D4                    ;SUBTRACT PI/2 FOR POSITIVE ARGUMENT
FPSAP2    ADD.L     D4,D7                 ;ADD CONSTANT
          LEA       FFPTHETA,A0           ;LOAD ARCTANGENT TABLE
          MOVEQ     #23,D1                ;LOOP 24 TIMES
          MOVEQ     #-1,D2                ;PRIME SHIFT COUNTER
* CORDIC LOOP
FSINLP    ADD.W     #1,D2                 ;INCREMENT SHIFT COUNT
          MOVE.L    D5,D3                 ;COPY X
          MOVE.L    D6,D4                 ;COPY Y
          ASR.L     D2,D3                 ;SHIFT FOR X'
          ASR.L     D2,D4                 ;SHIFT FOR Y'
          TST.L     D7                    ;TEST ARG VALUE
          BMI.S     FSBMI                 ;BRANCH MINUS TEST
          SUB.L     D4,D5                 ;X=X-Y'
          ADD.L     D3,D6                 ;Y=Y+X'
          SUB.L     (A0)+,D7              ;ARG=ARG-TABLE(N)
          DBRA      D1,FSINLP             ;LOOP UNTIL DONE
          BRA.S     FSCOM                 ;ENTER COMMON CODE
FSBMI     ADD.L     D4,D5                 ;X=X+Y'
          SUB.L     D3,D6                 ;Y=Y-X'
          ADD.L     (A0)+,D7              ;ARG=ARG+TABLE(N)
          DBRA      D1,FSINLP             ;LOOP UNTIL DONE

* NOW SPLIT UP TANGENT AND FFPSINCS FROM SINE AND COSINE
FSCOM     MOVE.W    7*4(SP),D1            ;RELOAD INTERNAL PARAMETER
          BPL.S     FSSINCOS              ;BRANCH FOR SINE OR COSINE

          ADD.B     #1,D1                 ;SEE IF WAS -1 FOR TANGENT
          BNE.S     FSDUAL                ;NO, MUST BE BOTH SIN AND COSINE
* TANGENT FINISH
          BSR.S     FSFLOAT               ;FLOAT Y (SIN)
          MOVE.L    D6,D7                 ;SETUP FOR DIVIDE INTO
          MOVE.L    D5,D6                 ;PREPARE X
          BSR.S     FSFLOAT               ;FLOAT X (COS)
          BEQ.S     FSTINF                ;BRANCH INFINITE RESULT
          BSR       FFPDIV                ;TANGENT = SIN/COS
FSINFRT   MOVEM.L   (SP)+,D1-D6/A0        ;RESTORE REGISTERS
          ADDQ.L    #2,SP                 ;DELETE INTERNAL PARAMETER
          RTS                             ;RETURN TO CALLER

* TANGENT IS INFINITE. RETURN MAXIMUM POSITIVE NUMBER.
FSTINF    MOVE.L    #$FFFFFF7F,D7         ;LARGEST FFP NUMBER
          BRA.S     FSINFRT               ;AND CLEAN UP

* SINE AND COSINE
FSSINCOS  BEQ.S     FSSINE                ;BRANCH IF SINE
          MOVE.L    D5,D6                 ;USE X FOR COSINE
FSSINE    BSR.S     FSFLOAT               ;CONVERT TO FLOAT
          MOVE.L    D6,D7                 ;RETURN RESULT
          TST.B     D7                    ;AND CONDITION CODE TEST
          MOVEM.L   (SP)+,D1-D6/A0        ;RESTORE REGISTERS
          ADDQ.L    #2,SP                 ;DELETE INTERNAL PARAMETER
          RTS                             ;RETURN TO CALLER

* BOTH SINE AND COSINE
FSDUAL    MOVE.L    D5,-(SP)              ;SAVE COSINE DERIVITIVE
          BSR.S     FSFLOAT               ;CONVERT SINE DERIVITIVE TO FLOAT
          MOVE.L    D6,6*4(SP)            ;PLACE SINE INTO SAVED D6
          MOVE.L    (SP)+,D6              ;RESTORE COSINE DERIVITIVE
          BRA.S     FSSINE                ;AND CONTINUE RESTORING SINE ON THE SLY

* FSFLOAT - FLOAT INTERNAL PRECISION BUT TRUNCATE TO ZERO IF < 2**-21
FSFLOAT   MOVE.L    D6,D4                 ;COPY INTERNAL PRECISION VALUE
          BMI.S     FSFNEG                ;BRANCH NEGATIVE
          CMP.L     #$000000FF,D6         ;? TEST MAGNITUDE
          BHI       FFPTNORM              ;NORMALIZE IF NOT TOO SMALL
FSFZRO    MOVEQ     #0,D6                 ;RETURN A ZERO
          RTS                             ;RETURN TO CALLER

FSFNEG    ASR.L     #8,D4                 ;SEE IF ALL ONES BITS 8-31
          ADD.L     #1,D4                 ;? GOES TO ZERO
          BNE       FFPTNORM              ;NORMALIZE IF NOT TOO SMALL
          BRA.S     FSFZRO                ;RETURN ZERO

*         END
*         TTL       FAST FLOATING POINT HYPERBOLICS (FFPSINH)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPSINH  IDNT      1,2                   ;FFP SINH COSH TANH
*         OPT       PCS
*         SECTION   9
*         XDEF      FFPSINH,FFPCOSH,FFPTANH  ;ENTRY POINTS
*         XREF      9:FFPEXP,9:FFPDIV,9:FFPADD,9:FFPSUB  ;FUNCTIONS CALLED
*         XREF      FFPCPYRT              ;COPYRIGHT STUB

*************************************************
*            FFPSINH/FFPCOSH/FFPTANH            *
*       FAST FLOATING POINT HYPERBOLICS         *
*                                               *
*  INPUT:   D7 - FLOATING POINT ARGUMENT        *
*                                               *
*  OUTPUT:  D7 - HYPERBOLIC RESULT              *
*                                               *
*     ALL OTHER REGISTERS ARE TRANSPARENT       *
*                                               *
*  CODE SIZE:  36 BYTES   STACK WORK: 50 BYTES  *
*                                               *
*  CALLS: FFPEXP, FFPDIV, FFPADD AND FFPSUB     *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF THE RESULT IS ZERO          *
*        N - SET IF THE RESULT IS NEGATIVE      *
*        V - SET IF OVERFLOW OCCURRED           *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*  NOTES:                                       *
*    1) AN OVERFLOW WILL PRODUCE THE MAXIMUM    *
*       SIGNED VALUE WITH THE "V" BIT SET.      *
*    2) SPOT CHECKS SHOW AT LEAST SEVEN DIGIT   *
*       PRECISION.                              *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*        SINH  623 MICROSECONDS                 *
*        COSH  601 MICROSECONDS                 *
*        TANH  623 MICROSECONDS                 *
*                                               *
*************************************************
*         PAGE

FPONES    EQU       $80000041             ;FLOATING ONE

**********************************
*            FFPCOSH             *
*  THIS FUNCTION IS DEFINED AS   *
*            X    -X             *
*           E  + E               *
*           --------             *
*              2                 *
* WE EVALUATE EXACTLY AS DEFINED *
**********************************

FFPCOSH   MOVE.L    D6,-(SP)              ;SAVE OUR ONE WORK REGISTER
          AND.B     #$7F,D7               ;FORCE POSITIVE (RESULTS SAME BUT EXP FASTER)
          BSR       FFPEXP                ;EVALUATE E TO THE X
          BVS.S     FHCRTN                ;RETURN IF OVERFLOW (RESULT IS HIGHEST NUMBER)
          MOVE.L    D7,-(SP)              ;SAVE RESULT
          MOVE.L    D7,D6                 ;SETUP FOR DIVIDE INTO ONE
          MOVE.L    #FPONES,D7            ;LOAD FLOATING POINT ONE
          BSR       FFPDIV                ;COMPUTE E TO -X AS THE INVERSE
          MOVE.L    (SP)+,D6              ;PREPARE TO ADD TOGETHER
          BSR       FFPADD                ;CREATE THE NUMERATOR
          BEQ.S     FHCRTN                ;RETURN IF ZERO RESULT
          SUB.B     #1,D7                 ;DIVIDE BY TWO
          BVC.S     FHCRTN                ;RETURN IF NO UNDERFLOW
          MOVEQ     #0,D7                 ;RETURN ZERO IF UNDERFLOW
FHCRTN    MOVEM.L   (SP)+,D6              ;RESTORE OUR WORK REGISTER
          RTS                             ;RETURN TO CALLER WITH ANSWER
*         PAGE
**********************************
*            FFPSINH             *
*  THIS FUNCTION IS DEFINED AS   *
*            X    -X             *
*           E  - E               *
*           --------             *
*              2                 *
* HOWEVER, WE EVALUATE IT VIA    *
* THE COSH FORMULA SINCE ITS     *
* ADDITION IN THE NUMERATOR      *
* IS SAFER THAN OUR SUBTRACTION  *
*                                *
* THUS THE FUNCTION BECOMES:     *
*            X                   *
*    SINH = E  - COSH            *
*                                *
**********************************

FFPSINH   MOVE.L    D6,-(SP)              ;SAVE OUR ONE WORK REGISTER
          BSR       FFPEXP                ;EVALUATE E TO THE X
          BVS.S     FHSRTN                ;RETURN IF OVERLOW FOR MAXIMUM VALUE
          MOVE.L    D7,-(SP)              ;SAVE RESULT
          MOVE.L    D7,D6                 ;SETUP FOR DIVIDE INTO ONE
          MOVE.L    #FPONES,D7            ;LOAD FLOATING POINT ONE
          BSR       FFPDIV                ;COMPUTE E TO -X AS THE INVERSE
          MOVE.L    (SP),D6               ;PREPARE TO ADD TOGETHER
          BSR       FFPADD                ;CREATE THE NUMERATOR
          BEQ.S     FHSZRO                ;BRANCH IF ZERO RESULT
          SUB.B     #1,D7                 ;DIVIDE BY TWO
          BVC.S     FHSZRO                ;BRANCH IF NO UNDERFLOW
          MOVEQ     #0,D7                 ;ZERO IF UNDERFLOW
FHSZRO    MOVE.L    D7,D6                 ;MOVE FOR FINAL SUBTRACT
          MOVE.L    (SP)+,D7              ;RELOAD E TO X AGAIN AND FREE
          BSR       FFPSUB                ;RESULT IS E TO X MINUS COSH
FHSRTN    MOVEM.L   (SP)+,D6              ;RESTORE OUR WORK REGISTER
          RTS                             ;RETURN TO CALLER WITH ANSWER
*         PAGE
**********************************
*            FFPTANH             *
*  THIS FUNCTION IS DEFINED AS   *
*  SINH/COSH WHICH REDUCES TO:   *
*            2X                  *
*           E  - 1               *
*           ------               *
*            2X                  *
*           E  + 1               *
*                                *
* WHICH WE EVALUATE.             *
**********************************

FFPTANH   MOVE.L    D6,-(SP)              ;SAVE OUR ONE WORK REGISTER
          TST.B     D7                    ;? ZERO
          BEQ.S     FFPTRTN               ;RETURN TRUE ZERO IF SO
          ADD.B     #1,D7                 ;X TIMES TWO
          BVS.S     FFPTOVF               ;BRANCH IF OVERFLOW/UNDERFLOW
          BSR       FFPEXP                ;EVALUATE E TO THE 2X
          BVS.S     FFPTOVF2              ;BRANCH IF TOO LARGE
          MOVE.L    D7,-(SP)              ;SAVE RESULT
          MOVE.L    #FPONES,D6            ;LOAD FLOATING POINT ONE
          BSR       FFPADD                ;ADD 1 TO E**2X
          MOVE.L    D7,-(SP)              ;SAVE DENOMINATOR
          MOVE.L    4(SP),D7              ;NOW PREPARE TO SUBTRACT
          BSR       FFPSUB                ;CREATE NUMERATOR
          MOVE.L    (SP)+,D6              ;RESTORE DENOMINATOR
          BSR       FFPDIV                ;CREATE RESULT
          ADDQ.L    #4,SP                 ;FREE E**2X OFF OF STACK
FFPTRTN   MOVE.L    (SP)+,D6              ;RESTORE OUR WORK REGISTER
          RTS                             ;RETURN TO CALLER WITH ANSWER

FFPTOVF   MOVE.L    #$80000082,D7         ;FLOAT ONE WITH EXPONENT OVER TO LEFT
          ROXR.B    #1,D7                 ;SHIFT IN CORRECT SIGN
          BRA.S     FFPTRTN               ;AND RETURN

FFPTOVF2  MOVE.L    #FPONES,D7            ;RETURN +1 AS RESULT
          BRA.S     FFPTRTN

*         END
*         TTL       FAST FLOATING POINT SQUARE ROOT (FFPSQRT)
*******************************************
* (C)  COPYRIGHT 1981 BY MOTOROLA INC.    *
*******************************************

*FFPSQRT  IDNT      1,4                   ;FFP SQUARE ROOT
*         SECTION   9
*         XDEF      FFPSQRT               ;ENTRY POINT
*         XREF      FFPCPYRT              ;COPYRIGHT NOTICE

********************************************
*           FFPSQRT SUBROUTINE             *
*                                          *
* INPUT:                                   *
*          D7 - FLOATING POINT ARGUMENT    *
*                                          *
* OUTPUT:                                  *
*          D7 - FLOATING POINT SQUARE ROOT *
*                                          *
* CONDITION CODES:                         *
*                                          *
*          N - CLEARED                     *
*          Z - SET IF RESULT IS ZERO       *
*          V - SET IF ARGUMENT WAS NEGATIVE*
*          C - CLEARED                     *
*          X - UNDEFINED                   *
*                                          *
*    REGISTERS D3 THRU D6 ARE VOLATILE     *
*                                          *
* CODE: 194 BYTES    STACK WORK: 4 BYTES   *
*                                          *
* NOTES:                                   *
*   1) NO OVERFLOWS OR UNDERFLOWS CAN      *
*      OCCUR.                              *
*   2) A NEGATIVE ARGUMENT CAUSES THE      *
*      ABSOLUTE VALUE TO BE USED AND THE   *
*      "V" BIT SET TO INDICATE THAT A      *
*      NEGATIVE SQUARE ROOT WAS ATTEMPTED. *
*                                          *
* TIMES:                                   *
* ARGUMENT ZERO         3.50 MICROSECONDS  *
* MINIMUM TIME > 0    187.50 MICROSECONDS  *
* AVERAGE TIME > 0    193.75 MICROSECONDS  *
* MAXIMUM TIME > 0    200.00 MICROSECONDS  *
********************************************
*         PAGE

* NEGATIVE ARGUMENT HANDLER
FPSINV    AND.B     #$7F,D7               ;TAKE ABSOLUTE VALUE
          BSR.S     FFPSQRT               ;FIND SQRT(ABS(X))
          ORI.B     #$02,CCR              ;SET "V" BIT
          RTS                             ;RETURN TO CALLER

*********************
* SQUARE ROOT ENTRY *
*********************
FFPSQRT   MOVE.B    D7,D3                 ;COPY S+EXPONENT OVER
          BEQ.S     FPSRTN                ;RETURN ZERO IF ZERO ARGUMENT
          BMI.S     FPSINV                ;NEGATIVE, REJECT WITH SPECIAL CONDITION CODES
          LSR.B     #1,D3                 ;DIVIDE EXPONENT BY TWO
          BCC.S     FPSEVEN               ;BRANCH EXPONENT WAS EVEN
          ADD.B     #1,D3                 ;ADJUST ODD VALUES UP BY ONE
          LSR.L     #1,D7                 ;OFFSET ODD EXPONENT'S MANTISSA ONE BIT
FPSEVEN   ADD.B     #$20,D3               ;RENORMALIZE EXPONENT
          SWAP      D3                    ;SAVE RESULT S+EXP FOR FINAL MOVE
          MOVE.W    #23,D3                ;SETUP LOOP FOR 24 BIT GENERATION
          LSR.L     #7,D7                 ;PREPARE FIRST TEST VALUE
          MOVE.L    D7,D4                 ;D4 - PREVIOUS VALUE DURING LOOP
          MOVE.L    D7,D5                 ;D5 - NEW TEST VALUE DURING LOOP
          MOVE.L    A0,D6                 ;SAVE ADDRESS REGISTER
          LEA       FPSTBL(PC),A0         ;LOAD TABLE ADDRESS
          MOVE.L    #$00800000,D7         ;D7 - INITIAL RESULT (MUST BE A ONE)
          SUB.L     D7,D4                 ;PRESET OLD VALUE IN CASE ZERO BIT NEXT
          SUB.L     #$01200000,D5         ;COMBINE FIRST LOOP CALCULATIONS
          BRA.S     FPSENT                ;GO ENTER LOOP CALCULATIONS

*                   SQUARE ROOT CALCULATION
* THIS IS AN OPTIMIZED SCHEME FOR THE RECURSIVE SQUARE ROOT ALGORITHM:
*
*  STEP N+1:
*     TEST VALUE <= .0  0  0  R  R  R  0 1  THEN GENERATE A ONE IN RESULT R
*                     N  2  1  N  2  1        ELSE A ZERO IN RESULT R      N+1
*                                                                    N+1
* PRECALCULATIONS ARE DONE SUCH THAT THE ENTRY IS MIDWAY INTO STEP 2

FPSONE    BSET      D3,D7                 ;INSERT A ONE INTO THIS POSITION
          MOVE.L    D5,D4                 ;UPDATE NEW TEST VALUE
FPSZERO   ADD.L     D4,D4                 ;MULTIPLY TEST RESULT BY TWO
          MOVE.L    D4,D5                 ;COPY IN CASE NEXT BIT ZERO
          SUB.L     (A0)+,D5              ;SUBTRACT THE '01' ENDING PATTERN
          SUB.L     D7,D5                 ;SUBTRACT RESULT BITS COLLECTED SO FAR
FPSENT    DBMI      D3,FPSONE             ;BRANCH IF A ONE GENERATED IN THE RESULT
          DBPL      D3,FPSZERO            ;BRANCH IF A ZERO GENERATED

* ALL 24 BITS CALCULATED. NOW TEST RESULT OF 25TH BIT
          BLS.S     FPSFIN                ;BRANCH NEXT BIT ZERO, NO ROUNDING
          CMP.L     #$00FFFFFF,D7         ;INSURE NO OVERFLOW    V1,4
          BEQ.S     FPSFIN                ;BR MANTISSA ALL ONES      V1,4
          ADD.L     #1,D7                 ;ROUND UP (CANNOT OVERFLOW)
FPSFIN    LSL.L     #8,D7                 ;NORMALIZE RESULT
          MOVE.L    D6,A0                 ;RESTORE ADDRESS REGISTER
          SWAP      D3                    ;RESTORE S+EXP SAVE
          MOVE.B    D3,D7                 ;MOVE IN FINAL SIGN+EXPONENT
FPSRTN    RTS                             ;RETURN TO CALLER

* TABLE TO FURNISH '01' SHIFTS DURING THE ALGORITHM LOOP
FPSTBL    DC.L      1<<20,1<<19,1<<18,1<<17,1<<16,1<<15
          DC.L      1<<14,1<<13,1<<12,1<<11,1<<10,1<<9,1<<8
          DC.L      1<<7,1<<6,1<<5,1<<4,1<<3,1<<2,1<<1,1<<0
          DC.L      0,0

*         END
*         TTL       ARCTANGENT CORDIC TABLE - FFPTHETA
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPTHETA IDNT      1,1                   ;FFP ARCTANGENT TABLE
*         SECTION   9
*         XDEF      FFPTHETA              ;EXTERNAL DEFINITION

*********************************************************
*             ARCTANGENT TABLE FOR CORDIC               *
*                                                       *
* THE FOLLOWING TABLE IS USED DURING CORDIC             *
* TRANSCENDENTAL EVALUATIONS FOR SINE, COSINE, AND      *
* TANGENT AND REPRESENTS ARCTANGENT VALUES 2**-N WHERE  *
* N RANGES FROM 0 TO 24.  THE FORMAT IS BINARY(31,29)   *
* PRECISION (I.E. THE BINARY POINT IS BETWEEN BITS      *
* 28 AND 27 GIVING TWO LEADING NON-FRACTION BITS.)      *
*********************************************************

FFPTHETA  DC.L      $1921FB54             ;ARCTAN(2**0)  !elenc vasm does signed shift so force value
          DC.L      $76B19C15>>3          ;ARCTAN(2**-1)
          DC.L      $3EB6EBF2>>3          ;ARCTAN(2**-2)
          DC.L      $1FD5BA9A>>3          ;ARCTAN(2**-3)
          DC.L      $0FFAADDB>>3          ;ARCTAN(2**-4)
          DC.L      $07FF556E>>3          ;ARCTAN(2**-5)
          DC.L      $03FFEAAB>>3          ;ARCTAN(2**-6)
          DC.L      $01FFFD55>>3          ;ARCTAN(2**-7)
          DC.L      $00FFFFAA>>3          ;ARCTAN(2**-8)
          DC.L      $007FFFF5>>3          ;ARCTAN(2**-9)
          DC.L      $003FFFFE>>3          ;ARCTAN(2**-10)
          DC.L      $001FFFFF>>3          ;ARCTAN(2**-11)
          DC.L      $000FFFFF>>3          ;ARCTAN(2**-12)
          DC.L      $0007FFFF>>3          ;ARCTAN(2**-13)
          DC.L      $0003FFFF>>3          ;ARCTAN(2**-14)
          DC.L      $0001FFFF>>3          ;ARCTAN(2**-15)
          DC.L      $0000FFFF>>3          ;ARCTAN(2**-16)
          DC.L      $00007FFF>>3          ;ARCTAN(2**-17)
          DC.L      $00003FFF>>3          ;ARCTAN(2**-18)
          DC.L      $00001FFF>>3          ;ARCTAN(2**-19)
          DC.L      $00000FFF>>3          ;ARCTAN(2**-20)
          DC.L      $000007FF>>3          ;ARCTAN(2**-21)
          DC.L      $000003FF>>3          ;ARCTAN(2**-22)
          DC.L      $000001FF>>3          ;ARCTAN(2**-23)
          DC.L      $000000FF>>3          ;ARCTAN(2**-24)
          DC.L      $0000007F>>3          ;ARCTAN(2**-25)
          DC.L      $0000003F>>3          ;ARCTAN(2**-26)

*         END
*         TTL       FFP TRANSCENDENTAL NORMALIZE INTERNAL ROUTINE (FFPTNORM)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*FFPTNORM IDNT      1,2                   ;FFP TRANSCENDENTAL INTERNAL NORMALIZE
*         XDEF      FFPTNORM
*         SECTION   9

******************************
*        FFPTNORM            *
* NORMALIZE BIN(29,31) VALUE *
*   AND CONVERT TO FLOAT     *
*                            *
* INPUT: D6 - INTERNAL FIXED *
* OUTPUT: D6 - FFP FLOAT     *
*         CC - REFLECT VALUE *
* NOTES:                     *
*  1) D4 IS DESTROYED.       *
*                            *
* TIME: (8MHZ NO WAIT STATE) *
*       ZERO  4.0 MICROSEC.  *
*   AVG ELSE 17.0 MICROSEC.  *
*                            *
******************************

FFPTNORM  MOVEQ     #$42,D4               ;SETUP INITIAL EXPONENT
          TST.L     D6                    ;TEST FOR NON-NEGATIVE
          BEQ.S     FSFRTN                ;RETURN IF ZERO
          BPL.S     FSFPLS                ;BRANCH IS >= 0
          NEG.L     D6                    ;ABSOLUTIZE INPUT
          MOVE.B    #$C2,D4               ;SETUP INITIAL NEGATIVE EXPONENT
FSFPLS    CMP.L     #$00007FFF,D6         ;TEST FOR A SMALL NUMBER
          BHI.S     FSFCONT               ;BRANCH IF NOT SMALL
          SWAP      D6                    ;SWAP HALVES
          SUB.B     #16,D4                ;OFFSET BY 16 SHIFTS
FSFCONT   ADD.L     D6,D6                 ;SHIFT ANOTHER BIT
          DBMI      D4,FSFCONT            ;SHIFT LEFT UNTIL NORMALIZED
          TST.B     D6                    ;? SHOULD WE ROUND UP
          BPL.S     FSFNRM                ;NO, BRANCH ROUNDED
          ADD.L     #$0100,D6             ;ROUND UP
          BCC.S     FSFNRM                ;BRANCH NO OVERFLOW
          ROXR.L    #1,D6                 ;ADJUST BACK FOR BIT IN 31
          ADD.B     #1,D4                 ;MAKE UP FOR LAST SHIFT RIGHT
FSFNRM    MOVE.B    D4,D6                 ;INSERT SIGN+EXPONENT
FSFRTN    RTS                             ;RETURN TO CALLER

*         END
