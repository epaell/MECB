make clean
make
make dsk
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/cc1 NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/cc1
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/c.asm NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.asm
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/c.link NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.link
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/c.opt NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.opt
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/c.pass1 NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.pass1
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/c.pass2 NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.pass2
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/c.prep NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.prep
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/make NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/make
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/pacos9/pacos9 NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/pacos9
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/cc1
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.asm
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.link
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.opt
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.pass1
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.pass2
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/c.prep
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/make
os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/pacos9

os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,LIB
os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,BASIC09
os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,C
os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,ASM
os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,PASCAL

os9 copy -o=0 -l pascal/* NOS9_6809_L1_v3.3.0_mecb.dsk,PASCAL
os9 copy -o=0 -l basic09/* NOS9_6809_L1_v3.3.0_mecb.dsk,BASIC09
os9 copy -o=0 -l c/*.c NOS9_6809_L1_v3.3.0_mecb.dsk,C
os9 copy -o=0 -l c/*.com NOS9_6809_L1_v3.3.0_mecb.dsk,C
os9 copy -o=0 -l asm/*.asm NOS9_6809_L1_v3.3.0_mecb.dsk,ASM
#os9 copy -o=0 asm/nopsg NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/nopsg
#os9 attr -q -pe -npw -pr -e -w -r NOS9_6809_L1_v3.3.0_mecb.dsk,cmds/nopsg

os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/lib/*.l NOS9_6809_L1_v3.3.0_mecb.dsk,LIB
os9 copy -o=0 $NITROS9DIR/3rdparty/packages/ccompiler/lib/*.r NOS9_6809_L1_v3.3.0_mecb.dsk,LIB

os9 copy -o=0 -l $NITROS9DIR/3rdparty/packages/ccompiler/defs/*.h NOS9_6809_L1_v3.3.0_mecb.dsk,DEFS

os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,SOURCES
os9 copy -o=0 -l $NITROS9DIR/3rdparty/packages/ccompiler/sources/*.c NOS9_6809_L1_v3.3.0_mecb.dsk,SOURCES

os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,SOURCES/SYS
os9 copy -o=0 -l $NITROS9DIR/3rdparty/packages/ccompiler/sources/*.a NOS9_6809_L1_v3.3.0_mecb.dsk,SOURCES/SYS

os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,SRC
os9 copy -o=0 -l $NITROS9DIR/src/*.asm NOS9_6809_L1_v3.3.0_mecb.dsk,SRC

os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,LEN067
os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,ELENC
os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,EMIL
os9 makdir NOS9_6809_L1_v3.3.0_mecb.dsk,EPAELL

cp NOS9_6809_L1_v3.3.0_mecb.dsk /Volumes/FUJINET/NITROS9/FNOS9.DSK 
diskutil eject /Volumes/FUJINET
