del drc-c.zip
del a86.zip
del *.bak
del *.sym
del *.obj
del tem*.*
pkzip drc-c *.c
pkzip drc-c *.h
pkzip drc-c drc.doc
pkzip drc-c *.bat
pkzip drc-c *.asc
pkzip a86 *.a86
copy a86.zip d:\drc
copy drc-c.zip d:\drc
pkunzip /t drc-c
pkunzip /t a86

