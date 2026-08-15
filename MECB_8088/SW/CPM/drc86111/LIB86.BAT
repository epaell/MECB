echo off
cls
rem cpm86 lib86 %1.l86 [xref,noalpha]
rem cpm86 lib86 %1.l86 [map,noalpha]
rem cpm86 lib86 %1.l86 [modules,noalpha]
cpm86 lib86 %1 [publics,externals,noalpha]
rem cpm86 lib86 %1.l86 [externals,noalpha]
