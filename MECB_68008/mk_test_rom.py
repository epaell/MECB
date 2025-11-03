#!/usr/bin/env python

# Simple script to generate binary files to program into the expansion ROM to test that they
# are fully functional in the 68008 address space.

import numpy as np
import sys
import os

def bin2rom(f_rom, offset):
    # Initialise the lower (unused) part of the ROM to 0xFF
    rom = bytearray(np.full((0x80000), 0xFF, np.ubyte))
    for index in range(int(len(rom)/4)):
        val = index + offset
        dig0 = (val >> 24) & 0xFF;
        dig1 = (val >> 16) & 0xFF;
        dig2 = (val >> 8) & 0xFF;
        dig3 = (val & 0xFF);
        rom[index*4] = dig0 
        rom[index*4+1] = dig1 
        rom[index*4+2] = dig2 
        rom[index*4+3] = dig3 
    
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

f_rom = f"SST39SF040_A.bin"
os.system(f"rm {f_rom}")
bin2rom(f_rom, 0)
f_rom = f"SST39SF040_B.bin"
os.system(f"rm {f_rom}")
bin2rom(f_rom, 0x20000)
