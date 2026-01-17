#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
#    "mikbug",
    "beep",
#    "DREAM_invaders6800",
#    "mikbug2",
    "CHIPOS",
#    "trek"
            ]

def clean_s19(f_in):
    with open(f_in) as file:
        lines = [line for line in file]
    fout = open(f_in, "wt")
    for line in lines:
        if line[:2] == "S9":
            fout.write("%s\n" %(line[:2]))
        else:
            fout.write(line)
    fout.close()

def bin2rom(f_bin, f_rom):
    # f_bin - original combined binary produced by the build
    # f_rom - 32 KB binary matched to the ROM size (for an AT28C256)

    # Read the combined binary
    fin = open(f_bin, "rb")
    bin_contents = fin.read()
    fin.close()

    # Initialise the lower (unused) part of the ROM to 0xFF
    rom = bytearray(np.full((0x8000), 0xFF, np.ubyte))
    rom[0x7000:] = bin_contents[-0x1000:]
    
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

for source in build_list:
    print(f"*** Compiling {source}.asm ***")
    os.system(f"rm {source}.lst {source}.s19")
    os.system(f"vasm6800_mot -Fsrec -s19 -L {source}.lst src/{source}.asm")
    os.system(f"mv a.out {source}.s19")
    clean_s19(f"{source}.s19")
    if source in ["mikbug2"]:
        os.system(f"vasm6800_mot -Fbin -L {source}.lst src/{source}.asm")
        os.system(f"mv a.out {source}.bin")
        bin2rom(f"{source}.bin", f"rom_mikbug2.bin")
#    os.system(f"vasmm68k_mot -Fbin -L {source}.lst src/{source}.asm")
#    os.system(f"mv a.out {source}.bin")
