10    REM asciiart.bas benchmark for Rienk's sbc-2g-512 7.3728Mhz Z80 board running NASCOM ROM BASIC Ver 4.7
20    REM https://www.retrobrewcomputers.org/forum/index.php?t=msg&th=201&goto=4704&#msg_4704
30    REM 2m43s
40    REM
45    width 80
50    FOR Y=-12 TO 12
60    FOR X=-39 TO 39
70    CA=X*0.0458
80    CB= Y*0.08333
90    A=CA
100   B=CB
110   FOR I=0 TO 15
120   T=A*A-B*B+CA
130   B=2*A*B+CB
140   A=T
150   IF (A*A+B*B)>4 THEN GOTO 190
160   NEXT I
170   PRINT " ";
180   GOTO 210
190   IF I>9 THEN I=I+7
200   PRINT CHR$(48+I);
210   NEXT X
220   PRINT
230   NEXT Y
