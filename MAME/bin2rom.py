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
os.system("cp %s mecb6809/." %(f_rom))
crc32 = extract_crc(f_rom)
sha1 = extract_sha1(f_rom)
update_checksums("mecb6809.cpp", f_rom, crc32, sha1)


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
os.system("cp %s mecb6502/." %(f_rom))
os.system("crc32 mecb6502.bin")
os.system("sha1sum mecb6502.bin")
crc32 = extract_crc(f_rom)
sha1 = extract_sha1(f_rom)
update_checksums("mecb6502.cpp", f_rom, crc32, sha1)

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
os.system("cp %s mecb6502b/." %(f_rom))
crc32 = extract_crc(f_rom)
sha1 = extract_sha1(f_rom)
update_checksums("mecb6502b.cpp", f_rom, crc32, sha1)

# This is the original combined binary produced by the build
f_bin = "AT28C256_MECBZ80_basic_8KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecbz80.bin"
os.system("cp ../MECB_Z80/BASIC/basic.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
lower_rom = bin_contents
print("%d bytes" %(len(lower_rom)))
# Initialise the lower (unused) part of the ROM to 0xFF
upper_rom = bytearray(np.full(0x2000-len(lower_rom), 0xFF, np.ubyte))
# Write the 8 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom)
fout.write(upper_rom)
fout.close()

print("mecbz80 checksums")
os.system("cp %s mecbz80/." %(f_rom))
crc32 = extract_crc(f_rom)
sha1 = extract_sha1(f_rom)
update_checksums("mecbz80.cpp", f_rom, crc32, sha1)

# This is the original combined binary produced by the build
f_bin = "MECB68008_combo_32KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecb68008.bin"
os.system("cp ../MECB_68008/Tutor/combo_68k.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
lower_rom = bin_contents
print("%d bytes" %(len(lower_rom)))
#upper_rom = bytearray(np.full(0x8000-len(lower_rom), 0xFF, np.ubyte))
# Write the 32 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom[:0x8000])
#fout.write(upper_rom)
fout.close()

print("mecb68008 checksums")
os.system("cp %s mecb68008/." %(f_rom))
crc32 = extract_crc(f_rom)
sha1 = extract_sha1(f_rom)
update_checksums("mecb68008.cpp", f_rom, crc32, sha1)



# This is the original combined binary produced by the build
f_bin = "MECB68008_zbug_12KB.bin"
# This is file that will produce a 8 KB binary ROM for use with MAME
f_rom= "mecb68008z.bin"
os.system("cp ../MECB_68008/ZBUG/zbug.bin %s" %(f_bin))

# Read the combined binary
fin = open(f_bin, "rb")
bin_contents = fin.read()
fin.close()

# Read the actual code part of the ROM that is contained within the combined.bin binary
lower_rom = bin_contents
print("%d bytes" %(len(lower_rom)))
# Initialise the lower (unused) part of the ROM to 0xFF
upper_rom = bytearray(np.full(0x8000-len(lower_rom), 0xFF, np.ubyte))
# Write the 32 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom)
fout.write(upper_rom)
fout.close()

print("mecb68008z checksums")
os.system("cp %s mecb68008z/." %(f_rom))
crc32 = extract_crc(f_rom)
sha1 = extract_sha1(f_rom)
update_checksums("mecb68008z.cpp", f_rom, crc32, sha1)


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
# Write the 32 KB binary that is more easily burned to FLASH ROM
fout = open(f_rom, "wb")
fout.write(lower_rom[:0x8000])
#fout.write(upper_rom)
fout.close()

print("mecb68008t checksums")
os.system("cp %s mecb68008t/." %(f_rom))
crc32 = extract_crc(f_rom)
sha1 = extract_sha1(f_rom)
update_checksums("mecb68008t.cpp", f_rom, crc32, sha1)



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
print("")

