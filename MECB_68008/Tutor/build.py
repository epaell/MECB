#!/usr/bin/env python
import numpy as np
import sys
import os

def bin2rom(f_bin, f_rom):
    # f_bin - original combined binary produced by the build
    # f_rom - 32 KB binary matched to the ROM size (for an AT28C256)

    # Read the combined binary
    fin = open(f_bin, "rb")
    bin_contents = fin.read()
    fin.close()

    # Initialise the lower (unused) part of the ROM to 0xFF
    rom = bytearray(np.full((0x80000), 0xFF, np.ubyte))
    rom[:len(bin_contents[0x200000:])] = bin_contents[0x200000:]
    
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

for source in ["tutor13", "combo_68k"]:
    f_rom = f"SST39SF040_68k_{source}.bin"
    os.system(f"rm {source}.bin {source}.lst {f_rom}")
    os.system(f"vasmm68k_mot -Fbin -L {source}.lst src/{source}.asm")
    os.system(f"mv a.out {source}.bin")
    bin2rom(f"{source}.bin", f_rom)
