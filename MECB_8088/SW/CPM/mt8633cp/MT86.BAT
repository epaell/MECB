REM Runs the Pascal/MT+ Compiler to produce the program/module  %1

ERA %1.err
ERA %1.r86

MT-86 %1 $tfepcq%2
