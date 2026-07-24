#!/usr/bin/env python
#
# ***** firmware.py *****
# Start with SST39SF040_68k_combo_68k.bin as the default monitor/basic firmware
# Compiles various software routines into a library that goes above the monitor/basic $210000.
# Combines the initial firmware ROM binary (SST39SF040_68k_combo_68k.bin) with the libary binary into firmware.bin
# Creates a library include file to all calling of library functions

import numpy as np
import sys
import os

def bin2rom(f_bin, offset, f_rom):
    # f_bin - original combined binary produced by the build
    # f_rom - 32 KB binary matched to the ROM size (for an AT28C256)

    # Read the base monitor/basic ROM to start with (should be 512 KB)
    fin = open("SST39SF040_68k_combo_68k.bin", "rb")
    rom_contents = fin.read()
    fin.close()

    # Read the base monitor/basic ROM to start with (should be 512 KB)
    fin = open(f_bin, "rb")
    lib = fin.read()
    fin.close()

    # Initialise the lower (unused) part of the ROM to 0xFF
    rom = bytearray(np.full((len(rom_contents)), 0xFF, np.ubyte))
    rom[0:] = rom_contents[0:]
    rom[offset:offset+len(lib)] = lib
    
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

def read_symbols(fin):
    state = "none"
    sym2addr = {}
    for line in open(fin, "rt"):
        if state != "start":
            if line.find("Symbol Table (* = unused):") != -1:
                state = "start"
            continue
        ldata = line.split()
        if len(ldata) < 2:
            continue
        if ldata[1] != ":":
            continue
        sym = ldata[0].strip()
        if sym[0] == "*":
            sym = sym[1:]
        addr = ldata[2]
        sym2addr[sym] = f"{addr}"
        if ldata[4] == "|":
            if len(ldata) < 8:
                continue
        if ldata[6] != ":":
            continue
        sym = ldata[5].strip()
        if sym[0] == "*":
            sym = sym[1:]
        addr = ldata[7]
        sym2addr[sym] = f"{addr}"
    return sym2addr

def lst2asm(fnin, fnout, sym2addr):
    state = "find_start"
    fout = open(fnout, "wt")
    for line in open(fnin):
        if state == "find_start":
            if line.find("vector_tbl:"):
                state = "read_vectors"
                continue
        if state != "read_vectors":
            continue
        if len(line)<1:
            continue
        # Pass through comments
        if line[0]==";":
            fout.write(line)
        if line.find("'include'") != -1:
            state = 'done'
            break
        #00:00210000 600004E6        	     7:                bra      FFPABS                  ; d7=abs(d7)
        if line.find(" jmp ") == -1:
            continue
        ldata = line.split()
        label = ldata[1].upper()
        addr = sym2addr[label]
        if len(ldata) > 2:
            comment = " ".join(ldata[2:])
        fout.write(f"{label:22s}   equ ${addr}  {comment}\n")
    fout.close()

# Build the library mapped for on-board rom $210000
source="library_rom"    
os.system(f"rm {source}.lst {source}.bin")
os.system(f"asl  -L -olist ./{source}.lst -o ./{source}.p src/{source}.asm")
os.system(f"p2bin {source}.p")

bin2rom(f"{source}.bin", 0x10000, f"FIRMWARE.ROM")
# Combine the loader with the library so it can be self-contained
sym2addr = read_symbols('library_rom.lst')
lst2asm('src/library_rom.asm', 'src/library_rom.inc', sym2addr)
