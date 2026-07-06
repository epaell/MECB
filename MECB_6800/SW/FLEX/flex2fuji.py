#!/usr/bin/env python

# Convert a FLEX disk for use with FujiNet

import numpy as np
import sys

media = []
media.append(["MEDIATYPE_IMG_FD360", 40 * 2 * 9 * 512])
media.append(["MEDIATYPE_IMG_FD720", 80 * 2 * 9 * 512])
media.append(["MEDIATYPE_IMG_FD120", 80 * 2 * 15 * 512])
media.append(["MEDIATYPE_IMG_FD144", 80 * 2 * 18 * 512])
media.append(["MEDIATYPE_IMG_HD", 8 * 1024 * 1024])

sec_size = 256
path = sys.argv[1]
dest = f"FujiNet/{sys.argv[1].replace('.DSK', '.IMG')}"
print(f"Reading {path}")
fin = open(path, "rb")
flex_data = fin.read()
fin.close()

nFlex = len(flex_data)
print(f"{nFlex} bytes read")
nsectors = (nFlex >> 8)
print(f"nsectors={nsectors} x {sec_size} bytes = {nsectors*sec_size} bytes")

nFuji = 0
for m in media:
    if nFlex <= m[1]:
        print(f"Using {m[0]}")
        nFuji = m[1]
        break
if nFuji == 0:
    sys.exit("FujiNet doesn't support the disk size")

fuji_data = bytearray(np.full((nFuji), 0x00, np.ubyte))

print(f"FujiNet disk size: {nFuji} bytes")

fuji_data[:len(flex_data)] = flex_data

print(f"Writing {len(fuji_data)} bytes")
fout = open(dest, "wb")
fout.write(fuji_data)
fout.close()
