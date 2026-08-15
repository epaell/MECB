10    REM ************************************************
20    REM
30    REM Z80-MBC2 (HW ref. A040618)
33    REM V20-MBC  (HW ref. A250220)
34    REM
35    REM RTC demo demo
37    REM
40    REM ************************************************
100   OUT 1,132 : REM Write the DATETIME read Opcode
110   SEC = INP(0) : REM Read a RTC parameter
120   MINUTES = INP(0) : REM Read a RTC parameter
130   HOURS = INP(0) : REM Read a RTC parameter
140   DAY = INP(0) : REM Read a RTC parameter
150   MNTH = INP(0) : REM Read a RTC parameter
160   YEAR = INP(0) : REM Read a RTC parameter
170   TEMP = INP(0) : REM Read a RTC parameter
180   IF TEMP < 128 THEN 200 : REM Two complement correction
190   TEMP = TEMP - 256
200   PRINT
210   PRINT "THE TIME IS: ";
220   PRINT HOURS; : PRINT ":"; : PRINT MINUTES; : PRINT ":"; : PRINT SEC
230   PRINT "THE DATE IS: ";
240   YEAR= YEAR+ 2000
250   PRINT DAY; : PRINT "/"; : PRINT MNTH; : PRINT "/"; : PRINT YEAR
260   PRINT "THE TEMPERATURE IS: ";
270   PRINT TEMP; : PRINT "C"
280   PRINT
