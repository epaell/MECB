01 REM ********************************************************************
02 REM
03 REM V20-MBC SPP activation utility (MBASIC)
04 REM
05 REM Enable the SPP (Standard Parallel Port) Adapter board
06 REM as CP/M "list" device.
07 REM The GPE option and the SPP Adapter board must be installed.
08 REM
09 REM NOTE: Required IOS S260320-R241023 and 
10 REM       CBIOS S140520-R281023 (and following revisions 
11 REM       unless stated otherwise)
12 REM
13 REM ********************************************************************
14 REM
15 REM SETSPP write Opcode 17 (0x11)
16 REM GETSPP read Opcode 131 (0x83)
17 REM
18 OUT 1,131 : SPPFLG1 = INP(0) : REM read the GETSPP Opcode
20 OUT 1,17 : OUT 0,0 : REM enable the SPP with AUTOFD = 0 and initialize the printer (SETSPP Opcode)
30 OUT 1,131 : SPPFLG2 = INP(0) : REM read the GETSPP Opcode again
40 IF SPPFLG2 = 0 THEN GOTO 150 : REM exit with error
50 IF SPPFLG1 > 0 THEN GOTO 100 : REM SPP was alredy active
70 PRINT : PRINT "SPP enabled using the GPIO port."
71 PRINT : PRINT "NOTES:"
73 PRINT "* GPIO port is now reserved exclusively for SPP emulation"
76 PRINT "* The SPP emulation is active until next system reset/reboot"
77 PRINT "* When SPP is active a permanent not ready printer (e.g. printer off or"
78 PRINT "  not connected) can hang CP/M"
90 GOTO 200
100 PRINT : PRINT "SPP already active - Printer re-initialized"
110 GOTO 200
150 PRINT : PRINT "SPP activation failed!"
200 SYSTEM
