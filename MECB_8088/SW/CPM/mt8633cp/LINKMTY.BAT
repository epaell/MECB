REM Runs the Pascal/MT+ Linker to produce  %1.CMD and %1.Y00

ERA %1.cmd
ERA %1.y00

LINKMT %1/f
REN %1.MAP %1.Y00
