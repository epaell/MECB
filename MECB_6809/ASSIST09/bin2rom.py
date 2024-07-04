#!/usr/bin/env python
import numpy as np

# Simple Python script to convert the compiled binary output for the combined ROM into
# something that can be more easily loaded into a ROM programmer.

# This is the original combined binary produced by the build
f_bin = "combined.bin"
# This is file that will produce a 32 KB binary matched to the ROM size (for an AT28C256)
f_rom= "AT28C256_combo.bin"

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Initialise the lower (unused) part of the ROM to 0xFF
lower_rom = bytearray(np.full((0x4100), 0xFF, np.ubyte))
# Read the actual code part of the ROM that is contained within the combined.bin binary
upper_rom = bin_contents[-0x3F00:]
# Write the 32 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom)
fout.write(upper_rom)
fout.close()