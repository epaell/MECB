#!/usr/bin/env python
import numpy as np
import os

# Simple Python script to convert the compiled binary output for the combined ROM into
# something that can be more easily loaded into a ROM programmer.

# This is the original combined binary produced by the build
f_bin = "AT28C256_MECB6809_combo.bin"
# This is file that will produce a 16 KB ROM for use with MAME
f_rom= "mecb6809.bin"
# Copy the original ROM from the compilation directory
os.system("cp ../MECB_6809/ASSIST09/AT28C256_combo.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
upper_rom = bin_contents[-0x3F00:]
# Write the 32 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(upper_rom)
fout.close()

print("mecb6809 checksums")
os.system("cp mecb6809.bin mecb6809/.")
os.system("crc32 mecb6809.bin")
os.system("sha1sum mecb6809.bin")

# This is the original combined binary produced by the build
f_bin = "AT28C256_MECB6502_SMON_8KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecb6502.bin"

# Copy the original ROM from the compilation directory
os.system("cp ../MECB_6502/SMON/AT28C256_SMON_8KB.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
upper_rom = bin_contents[-0x1F00:]
# Write the 32 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(upper_rom)
fout.close()

print("mecb6502 checksums")
os.system("cp mecb6502.bin mecb6502/.")
os.system("crc32 mecb6502.bin")
os.system("sha1sum mecb6502.bin")

# This is the original combined binary produced by the build
f_bin = "AT28C256_MECB6502_basic_8KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecb6502b.bin"
os.system("cp ../MECB_6502/osi_basic/AT28C256_basic_8KB.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
upper_rom = bin_contents[-0x2000:]
# Write the 32 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(upper_rom)
fout.close()
print("mecb6502b checksums")
os.system("cp mecb6502b.bin mecb6502b/.")
os.system("crc32 mecb6502b.bin")
os.system("sha1sum mecb6502b.bin")
