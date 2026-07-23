#!/usr/bin/env python
#
# ***** library_rom.py *****
# Compiles various software routines into a library.
# Two versions are created:
#   1. for loading onto the onboard FLASH ROM (library_rom_loader.s19), 
#   2. for loading onto the FLASH expansion ROM (library_exrom_loader.s19)
# Compiles a FLASH writing routine
# Combines the library with the FLASH writing routine so that it can be loaded and run
# Creates a library include file to all calling of library functions

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
    rom[:len(bin_contents[0x00:])] = bin_contents[0x00:]
    
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

def bin2srec(f_bin, f_srec, start = 0x4800, slen = 0x20):
    # Read the binary
    fin = open(f_bin, "rb")
    raw = fin.read()
    fin.close()
    
    # Add the length to the start of the binary array
    bin_contents = bytearray(np.full((len(raw)+2), 0x00, np.ubyte))
    bin_contents[0] = ((len(raw) >> 8) & 0xFF)
    bin_contents[1] = (len(raw) & 0xFF)
    bin_contents[2:] = raw

    fout = open(f_srec, "wt")
    srecord = bytearray(np.full((1 + 3 + slen + 1), 0x00, np.ubyte))
    fout.write("S0030000FC\n")
    for addr in range(0,len(bin_contents), slen):
        if addr + slen > len(bin_contents):
            ndata = len(bin_contents)-addr
        else:
            ndata = slen
        srecord[0] = ndata+4
        srecord[1] = ((addr + start) >> 16) & 0xFF
        srecord[2] = (((addr + start) >> 8) & 0xFF)
        srecord[3] = ((addr + start) & 0xFF)
        srecord[4:4+ndata] = bin_contents[addr:addr+ndata]
        srecord[4+ndata] = 0xFF - (np.sum(srecord[:4+ndata]) & 0xFF)
        s = 0x00
        str = "S2"
        for index in range(ndata+4+1):
            str += "%02X" %(srecord[index])
        str += "\n"
        fout.write(str)
    fout.write("S9030000FC\n")
    fout.close()

def link_loader(loader, library, outsrec):
    fout = open(outsrec, "wt")
    for line in open(loader):
        if len(line)>2:
            if line[1] == '9':
                print ("**",line)
                continue
        fout.write(line)
    for line in open(library):
        if len(line)>2:
            if line[1] == '0':
                print ("**",line)
                continue
        fout.write(line)
    fout.close()

#def read_symbols(fin):
#    state = "none"
#    sym2addr = {}
#    for line in open(fin, "rt"):
#        if state != "start":
#            if line.find("Symbols by value:") != -1:
#                state = "start"
#            continue
#        ldata = line.split()
#        sym2addr[ldata[1]] = ldata[0]
#    return sym2addr

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
        if line.find(" bra ") == -1:
            continue
        ldata = line.split()
        label = ldata[1].upper()
        addr = sym2addr[label]
        if len(ldata) > 2:
            comment = " ".join(ldata[2:])
        fout.write(f"{label:22s}   equ ${addr}  {comment}\n")
    fout.close()

# Build the code to transfer library in memory to FLASH
build_list = [
    "flash_rom",        # Write library to FLASH ROM
    "flash_exrom",      # Write library to FLASH expansion ROM
]
for source in build_list:
    os.system(f"rm {source}.lst {source}.hex")
#    os.system(f"vasmm68k_mot -Fsrec -s19 -L {source}.lst src/{source}.asm")
#    os.system(f"mv a.out {source}.s19")
    os.system(f"asl  -L -olist ./{source}.lst -o ./{source}.p src/{source}.asm")
    os.system(f"p2hex {source}.p -M 2 -l 32 -F Moto")

# Build the library mapped for on-board rom $210000
source="library_rom"    
os.system(f"rm {source}.lst {source}.bin")
os.system(f"asl  -L -olist ./{source}.lst -o ./{source}.p src/{source}.asm")
os.system(f"p2bin {source}.p")

#os.system(f"vasmm68k_mot -Fbin -L {source}.lst src/{source}.asm")
#os.system(f"mv a.out {source}.bin")
bin2rom(f"{source}.bin",f"ROMLIB.BIN")
bin2srec(f"{source}.bin", f"{source}.hex")
# Combine the loader with the library so it can be self-contained
link_loader("flash_rom.hex", f"{source}.hex", f"{source}_loader.hex")
sym2addr = read_symbols('library_rom.lst')
lst2asm('src/library_rom.asm', 'src/library_rom.inc', sym2addr)

# Build the library mapped for expansion rom $100000
source="library_exrom"    
os.system(f"rm {source}.lst {source}.bin")
os.system(f"asl  -L -olist ./{source}.lst -o ./{source}.p src/{source}.asm")
os.system(f"p2bin {source}.p")
#os.system(f"vasmm68k_mot -Fbin -L {source}.lst src/{source}.asm")
#os.system(f"mv a.out {source}.bin")
bin2rom(f"{source}.bin",f"EXROMLIB.BIN")
bin2srec(f"{source}.bin", f"{source}.hex")
# Combine the loader with the library so it can be self-contained
link_loader("flash_exrom.hex", f"{source}.hex", f"{source}_loader.hex")
sym2addr = read_symbols('library_exrom.lst')
lst2asm('src/library_exrom.asm', 'src/library_exrom.inc', sym2addr)
