#!/usr/bin/env python
import numpy as np
import sys
import os

def extract_crc(fname):
    os.system("rm -f log.txt")
    os.system("crc32 %s >log.txt" %(fname))
    for line in open("log.txt"):
        crc32 = line.split()[0]
        break
    return crc32

def extract_sha1(fname):
    os.system("rm -f log.txt")
    os.system("sha1sum %s >log.txt" %(fname))
    for line in open("log.txt"):
        sha1 = line.split()[0]
        break
    return sha1

def update_checksums(fname, f_rom, new_crc32, new_sha1):
    fout = ""
    updated = False
    for line in open(fname):
        # Search for the ROM_LOAD tag
        p1 = line.find("ROM_LOAD")
        if p1 == -1:
            fout += line
            continue    # Not found, search next line
        p1 = line.find(f_rom)
        if p1 == -1:    # Not for this rom
            fout += line
            continue
        p1 = line.find("CRC(")
        if p1 == -1:    # Shouldn't get to this point
            fout += line
            continue
        line_part = line[p1+4:]
        p1 = line_part.find(")")
        if p1 == -1:
            fout += line
            continue
        crc32 = line_part[:p1]
        line_part = line_part[p1+1:]
        p1 = line_part.find("SHA1(")
        if p1 == -1:    # Shouldn't get to this point
            fout += line
            continue
        line_part = line_part[p1+5:]
        p1 = line_part.find(")")
        if p1 == -1:    # Shouldn't get to this point
            fout += line
            continue
        sha1 = line_part[:p1]
        if (sha1 != new_sha1) or (crc32 != new_crc32):
            line = line.replace(sha1, new_sha1)
            line = line.replace(crc32, new_crc32)
            updated = True
        fout += line

    if updated:
        fo = open(fname, "wt")
        fo.write(fout)
        fo.close()

def bin2rom(f_bin, f_rom):
    # f_bin - original combined binary produced by the build
    # f_rom - 32 KB binary matched to the ROM size (for an AT28C256)

    # Read the combined binary
    fin = open(f_bin, "rb")
    bin_contents = fin.read()
    fin.close()

    # Initialise the lower (unused) part of the ROM to 0xFF
    rom = bytearray(np.full((0x4000), 0xFF, np.ubyte))
    nbin = len(bin_contents)
    if nbin > 0x4000:
        nbin = 0x4000
    rom[:nbin] = bin_contents[:nbin]
    
#    upper_rom = bin_contents[-0x3F00:]
    # Write the 512 KB binary that is more easily burned to FLASH ROM
    fout = open(f_rom, "wb")
    fout.write(rom)
    fout.close()

build_list = [
    "test_int",
    "monitor",
    "test_load",
    "mandel",
]
for source in build_list:
 #   f_rom = f"SST39SF040_{source}.bin"
    cwd = os.getcwd()
    os.system(f"rm {source}.bin {source}.lst")
#    os.system(f"rm {f_rom}")
    os.system(f"nasm src/{source}.asm -l {source}.lst -o {source}.bin")
    os.system(f"nasm -f ith src/{source}.asm -l {source}.lst -o {source}.hex")
sys.exit(0)
bin2rom(f"{source}.bin", f_rom)
os.chdir(cwd)

# This is file that will produce a 512 KB ROM for use with MAME
f_mamerom= "mecb8088.bin"

# Read the combined binary
fin = open(f"work/{f_rom}", "rb")
bin_contents = fin.read()
fin.close()
print(len(bin_contents))
# Read the actual code part of the ROM that is contained within the combined.bin binary
lower_rom = bytearray(np.full((0x4000), 0xFF, np.ubyte))
lower_rom[:len(bin_contents)] = bin_contents

# Write the 4 KB binary that is more easily burned to FLASH ROM
fout = open(f"roms/mecb8088/{f_mamerom}", "wb")
fout.write(lower_rom)
fout.close()

crc32 = extract_crc(f"roms/mecb8088/{f_mamerom}")
sha1 = extract_sha1(f"roms/mecb8088/{f_mamerom}")
update_checksums("src/mame/homebrew/mecb8088.cpp", f_mamerom, crc32, sha1)
os.system("make SUBTARGET=mecb8088 SOURCES=src/mame/homebrew/mecb8088.cpp TOOLS=1 REGENIE=1 -j5")
#os.system("./mecb8088 -debug mecb8088")
os.system("./mecb8088 mecb8088")