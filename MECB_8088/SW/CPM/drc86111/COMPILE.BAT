echo off
cls
if not exist %1.c goto err
copy/b %1.c+cpmeof.asc srcfile.c 
cpm86 drc srcfile.c -b  >> log.txt
ren srcfile.obj %1.obj
rem del %1.sym
rem
goto exit
:err
echo Source file: (%1.c) - was not found.
:exit
