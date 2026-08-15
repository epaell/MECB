10    REM ************************************************
20    REM
30    REM Z80-MBC2 (HW ref. A040618)
33    REM V20-MBC  (HW ref. A250220)
34    REM
35    REM GPE led blink demo:
40    REM
50    REM Blink a led attached to PIN 8 (GPA5) of the GPIO
60    REM connector (J7 for both the boards) until USER key 
63    REM is pressed (see A040618 or A250220 schematic).
66    REM
80    REM The GPE option must be installed.
90    REM
100   REM ************************************************
110   REM
120   REM Demo HW wiring:
130   REM
140   REM    GPIO
150   REM    (J7)
160   REM  +-----+
170   REM  | 1 2 |
180   REM  | 3 4 |   LED         RESISTOR
190   REM  | 5 6 |                 680
200   REM  | 7 8-+--->|-----------/\/\/--+
210   REM  | 9 10|                       |
220   REM  |11 12|                       |
230   REM  |13 14|                       |
240   REM  |15 16|                       |
250   REM  |17 18|                       |
260   REM  |19 20+-----------------------+ GND
270   REM  +-----+
280   REM
290   REM ************************************************
300   REM
310   PRINT "Press USER key to exit"
320   REM
330   REM * * * * SET USED OPCODES FOR I/O
340   REM
350   KEYUSER = 128 : REM USER KEY read Opcode (0x80)
360   IODIRA = 5 : REM IODIRA write Opcode (0x05)
370   GPIOA = 3 : REM GPIOA write Opcode (0x03)
380   REM
390   OUT 1,IODIRA : OUT 0,0 : REM Set all GPAx as output (IODIRA=0x00)
400   PRINT "Now blinking GPA5 (GPIO port pin 8)..."
410   REM
420   REM * * * * * BLINK LOOP
430   REM
440   OUT 1,GPIOA : OUT 0,32 : REM Set GPA5=1, GPAx=0 (GPIOA=B00100000=32)
450   GOSUB 520 : REM Delay sub
460   OUT 1,GPIOA : OUT 0,0 : REM Clear all pins GPAx (MCP23017)
470   GOSUB 520 : REM Delay sub
480   GOTO 440
490   REM
500   REM * * * * * DELAY SUB
510   REM
520   FOR J=0 TO 150
530   OUT 1,KEYUSER : REM Write the USER KEY read Opcode
540   IF INP(0)=1 THEN GOTO 600 : REM Exit if USER key is pressed
550   NEXT J
560   RETURN
570   REM
580   REM * * * * * PROGRAM END
590   REM
600   OUT 1,GPIOA : OUT 0,0 : REM Clear all pins GPAx (MCP23017)
610   PRINT "Terminated by USER Key"
