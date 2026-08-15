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
    nbin = len(bin_contents)
#    print(nbin)
    rom = bytearray(np.full((0x8000), 0xFF, np.ubyte))
    rom[0x8000-nbin:] = bin_contents[-nbin:]
    
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

fin = sys.argv[1]
bin2rom(fin, f"{fin}.rom")