echo off
cls
if not exist %1.c goto err
copy/b %1.c+cpmeof.asc srcfile.c 
if "%3"=="/d" goto debug
:standard
cpm86 drc srcfile -b
cpm86 rasm86 %2 $nc
cpm86 link86 %1=srcfile
goto done
:debug
cpm86 drc srcfile -b     > log.txt
cpm86 rasm86 %2 $nc     >> log.txt
cpm86 link86 %1=srcfile >> log.txt
rem
rem cpm86 link86 %1=srcfile [extra[max[7000]]], %2
rem cpm86 link86 %1=srcfile, %2 [extra[max[3000]]]
:done
del srcfile.obj
del %1.sym
rem
del %2.lst
del %2.obj
del %2.sym
goto exit
:err
echo Source file: (%1.c) - was not found.
:exit
