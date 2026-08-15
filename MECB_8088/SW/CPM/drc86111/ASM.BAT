echo off
cls
call asm86 fn
call gencmd fn
echo ÿCopy to cp/m-86 drive [b0:]  ?
echo ÿ
echo ÿctrl-brk to stop or..
pause
dcopy fn.cmd b:
