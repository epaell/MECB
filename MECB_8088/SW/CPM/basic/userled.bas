10    REM ****************************************
20    REM
30    REM Z80-MBC2 (HW ref. A040618)
33    REM V20-MBC  (HW ref. A250220)
40    REM
50    REM Blink the USER led until the USER key is pressed
60    REM
70    REM ****************************************
80    REM
90    PRINT "Press USER key to exit"
100   LEDUSER = 0 : REM USER LED write Opcode (0x00)
110   KEYUSER = 128 : REM USER KEY read Opcode (0x80)
120   PRINT "Now blinking..."
130   OUT 1,LEDUSER : REM Write the USER LED write Opcode
140   OUT 0,1 : REM Turn USER LED on
150   GOSUB 230 : REM Delay sub
160   OUT 1,LEDUSER : REM Write the USER LED write Opcode
170   OUT 0,0 : REM Turn USER LED off
180   GOSUB 230 : REM Delay
190   GOTO 130
200   REM
210   REM * * * * * DELAY SUB
220   REM
230   FOR J=0 TO 150
240   OUT 1,KEYUSER : REM Write the USER KEY read Opcode
250   IF INP(0)=1 THEN GOTO 310 : REM Exit if USER key is pressed
260   NEXT J
270   RETURN
280   REM
290   REM * * * * * PROGRAM END
300   REM
310   OUT 1,LEDUSER : REM Write the USER LED write Opcode
320   OUT 0,0 : REM Turn USER LED off
330   PRINT "Terminated by USER Key"
