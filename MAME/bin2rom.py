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



# This is the original combined binary produced by the build
f_bin = "MECB68008_zbug_12KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecb68008.bin"
os.system("cp ../MECB_68008/ZBUG/zbug.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
lower_rom = bin_contents
print("%d bytes" %(len(lower_rom)))
# Initialise the lower (unused) part of the ROM to 0xFF
upper_rom = bytearray(np.full(0x3000-len(lower_rom), 0xFF, np.ubyte))
# Write the 16 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom)
#fout.write(upper_rom)
fout.close()

print("mecb68008 checksums")
os.system("crc32 mecb68008.bin")
os.system("sha1sum mecb68008.bin")
os.system("cp mecb68008.bin mecb68008/.")

# This is the original combined binary produced by the build
f_bin = "MECB68008_tutor_32KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecb68008t.bin"
os.system("cp ../MECB_68008/Tutor/tutor.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
lower_rom = bin_contents
print("%d bytes" %(len(lower_rom)))
#upper_rom = bytearray(np.full(0x8000-len(lower_rom), 0xFF, np.ubyte))
# Write the 16 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom[:0x8000])
#fout.write(upper_rom)
fout.close()

print("mecb68008t checksums")
os.system("crc32 mecb68008t.bin")
os.system("sha1sum mecb68008t.bin")
os.system("cp mecb68008t.bin mecb68008t/.")


# This is the original combined binary produced by the build
f_bin = "MECB68008_basic_32KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecb68008b.bin"
os.system("cp ../MECB_68008/BASIC/basic68k.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
lower_rom = bin_contents
print("%d bytes" %(len(lower_rom)))
upper_rom = bytearray(np.full(0x8000-len(lower_rom), 0xFF, np.ubyte))
# Write the 16 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom[:0x8000])
fout.write(upper_rom)
fout.close()

print("mecb68008b checksums")
os.system("crc32 mecb68008b.bin")
os.system("sha1sum mecb68008b.bin")
os.system("cp mecb68008b.bin mecb68008b/.")

