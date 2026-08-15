echo off
if not exist %1.c goto err
copy/b %1.c+cpmeof.asc srcfile.c 
cls
cpm86 drc srcfile -a
del srcfile.obj
del %1.cmd
ren srcfile.cmd %1.cmd
goto exit
:err
echo Source file: (%1.c) - was not found.
:exit
