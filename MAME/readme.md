# MECB on MAME

Preparations for including MECB 6502 and 6809 boards into MAME

git clone https://github.com/mamedev/mame.git mymame

export MAMESRC=/path/to/MECB/MAME/

export MAMEDST=/path/to/mymame/

cp $MAMESRC/mecb6502.cpp $MAMEDST/src/mame/homebrew/.

cp $MAMESRC/mecb6502b.cpp $MAMEDST/src/mame/homebrew/.

cp $MAMESRC/mecb6809.cpp $MAMEDST/src/mame/homebrew/.

cp -R $MAMESRC/mecb6502 $MAMEDST/roms/.

cp -R $MAMESRC/mecb6502b $MAMEDST/roms/.

cp -R $MAMESRC/mecb6809 $MAMEDST/roms/.

cp $MAMESRC/mame.lst $MAMEDST/src/mame/.

cd $MAMEDST

if you have 4 cores use "-j5", otherwise adjust to number of cores + 1.

make SUBTARGET=mecb SOURCES=src/mame/homebrew/mecb6502.cpp,src/mame/homebrew/mecb6502b.cpp,src/mame/homebrew/mecb6809.cpp,src/mame/homebrew/mecb68008.cpp,src/mame/homebrew/mecb68008t.cpp TOOLS=1 REGENIE=1 -j5

This will create the executable "mecb" which can then be run to load up mame.
# mecb_6502
This emulates the MECB 6502 board with memory from 0x0000-0xBFFF; ROM from 0xE100-0xFFFF; ACIA at 0xE008. The ROM contains SMON.

# mecb_6502
This emulates the MECB 6502 board with memory from 0x0000-0xBFFF; ROM from 0xE100-0xFFFF; ACIA at 0xE008. The ROM contains OSI BASIC.

# mecb_6809
This emulates the MECB 6809 board with memory from 0x0000-0xBFFF; ROM from 0xC100-0xFFFF; ACIA at 0xC008. The ROM contains the combination ROM with ASSIST09 and Extended BASIC.

# mecb_68008
This emulates a hypothetical MECB 68008 board with ROM from 0x0000-0x2FFF; Memory from 0x3000-0x1FFFF and ACIA at 0x20000. The ROM contains a modified version of zBug. In the preparation steps listed above, also include the following:

cp $MAMESRC/mecb68008.cpp $MAMEDST/src/mame/homebrew/.

cp -R $MAMESRC/mecb68008 $MAMEDST/roms/.

make SUBTARGET=mecb SOURCES=src/mame/homebrew/mecb6502.cpp,src/mame/homebrew/mecb6502b.cpp,src/mame/homebrew/mecb6809.cpp,src/mame/homebrew/mecb68008.cpp,src/mame/homebrew/mecb68008t.cpp,src/mame/homebrew/mecb68008b.cpp TOOLS=1 REGENIE=1 -j5

# mecb_68008t
This emulates a hypothetical MECB 68008 board with ROM from 0x0000-0x3FFF; Memory from 0x4000-0x1FFFF and ACIA at 0x20000. The ROM contains a modified version of Tutor. In the preparation steps listed above, also include the following:

cp $MAMESRC/mecb68008t.cpp $MAMEDST/src/mame/homebrew/.

cp -R $MAMESRC/mecb68008t $MAMEDST/roms/.

To include this in the mecb MAME build use the following command:

make SUBTARGET=mecb SOURCES=src/mame/homebrew/mecb6502.cpp,src/mame/homebrew/mecb6502b.cpp,src/mame/homebrew/mecb6809.cpp,src/mame/homebrew/mecb68008.cpp,src/mame/homebrew/mecb68008t.cpp,src/mame/homebrew/mecb68008b.cpp TOOLS=1 REGENIE=1 -j5

# mecb_68008b
This emulates a hypothetical MECB 68008 board with ROM from 0x0000-0x3FFF; Memory from 0x4000-0x1FFFF and ACIA at 0x20000. The ROM contains a modified version of BASIC. In the preparation steps listed above, also include the following:

cp $MAMESRC/mecb68008b.cpp $MAMEDST/src/mame/homebrew/.

cp -R $MAMESRC/mecb68008b $MAMEDST/roms/.

To include this in the mecb MAME build use the following command:

make SUBTARGET=mecb SOURCES=src/mame/homebrew/mecb6502.cpp,src/mame/homebrew/mecb6502b.cpp,src/mame/homebrew/mecb6809.cpp,src/mame/homebrew/mecb68008.cpp,src/mame/homebrew/mecb68008t.cpp,src/mame/homebrew/mecb68008b.cpp TOOLS=1 REGENIE=1 -j5

# Compile with your own software
You can update the ROMS with your own version. The supplied bin2rom.py script modifies the current ROMS for the MECB system to work with MAME. It does so by removing the parts of the ROM that are not visible to the system. Note that you will need to re-calculate the CRC and SHA1 codes and add them to the appropriate source code file for the system otherwise MAME will complain that the checksums do not match.

# Limitations

Currently only the 6850, RAM and ROM are included as part of the emulation. It should be possible to add the 6840 timer, 6821, and possibly the VDP board but this hasn't been done yet.