#!/usr/bin/env python
import numpy as np

# Read the monitor part of the ROM
fin = open("monitor.bin", "rb")
bin_contents = fin.read()
fin.close()

# Initialise the unused part of the ROM to 0xFF
rom = bytearray(np.full((0x8000), 0xFF, np.ubyte))
print(f"ROM size {len(rom)} bytes")

nbin = len(bin_contents)
print(f"Adding monitor: size 0x{nbin:04x} bytes")
#if nbin > 0x4000:
#    nbin = 0x4000
rom[0x4000:nbin+0x4000] = bin_contents[:nbin]
print(f"ROM size {len(rom)} bytes")

# Read the CCP/BDOS part of binary
fin = open("cpm.bin", "rb")
bin_contents = fin.read()
fin.close()
bin_contents = bin_contents[:0x2500]
nbin = len(bin_contents)
#if nbin > 0x4000:
#    nbin = 0x4000
print(f"Adding CPM: size 0x{nbin:04x} bytes")
rom[:nbin] = bin_contents[:nbin]

print(f"ROM size {len(rom)} bytes")

# Read the BIOS part of binary
fin = open("load_cpm.bin", "rb")
bin_contents = fin.read()
fin.close()
nbin = len(bin_contents)
print(f"Adding BIOS: size 0x{nbin:04x} bytes")
rom[0x2500:0x2500+nbin] = bin_contents[:nbin]

print(rom[0x7ff0:])
print(f"ROM size {len(rom)} bytes")
#    
# Write the combined binary to a 32 KB ROM image
fout = open("monitor.rom", "wb")
fout.write(rom)
fout.close()
