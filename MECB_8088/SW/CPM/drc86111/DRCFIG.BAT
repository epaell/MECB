echo build %1 pcbios  %%3 > m.bat
echo ed %1.c > e.bat
echo cpm86 %1 %%1 %%2 %%3 > p.bat
echo dcopy %1.cmd b: > dc.bat

