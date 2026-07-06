#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
#    "DigiBug",
    "test_fn",
#    "flex2_load",
#    "flex3_load",
#    "flex2",
            ]

def clean_hex(fin):
    fout = open("temp.hex", "wt")
    for line in open(fin, "rt"):
        if line.find("S9") !=-1:
            fout.write("S9")
            continue
        fout.write(line)
    fout.close()
    os.system(f"mv temp.hex {fin}")

def bin2rom(f_bin, f_rom):
    # f_bin - original combined binary produced by the build
    # f_rom - 32 KB binary matched to the ROM size (for an AT28C256)

    # Read the combined binary
    fin = open(f_bin, "rb")
    bin_contents = fin.read()
    fin.close()

    # Initialise the lower (unused) part of the ROM to 0xFF
    nbin = len(bin_contents)
    print(nbin)
    rom = bytearray(np.full((0x8000), 0xFF, np.ubyte))
    rom[0x8000-nbin:] = bin_contents[-nbin:]
    
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

for source in build_list:
    print(f"*** Compiling {source}.asm ***")
    os.system(f"rm {source}.lst {source}.hex")
    if source in ["DigiBug", "mikbug", "mikbug2"]:
        os.system(f"asl  -L -olist ./{source}.lst -cpu 6800 -o ./{source}.p src/{source}.asm")
        os.system(f"p2bin {source}.p")
        bin2rom(f"{source}.bin", f"rom_{source}.bin")
    else:
        os.system(f"asl  -L -olist ./{source}.lst -cpu 6800 -o ./{source}.p src/{source}.asm")
        os.system(f"p2hex {source}.p -l 64 -F Moto")
#    clean_hex(f"{source}.hex")
        
        