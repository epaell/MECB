#!/usr/bin/env python
import sys
import numpy as np

max_buff = 65536*2
fin = sys.argv[1]
fout = fin.replace('.SR', ".bin")
buff = bytearray(np.full((max_buff), 0xff, np.ubyte))

first = max_buff
last = 0
for line in open(fin):
    if len(line) < 3:
        continue
    stype = line[:2]
    if stype in ["S1", "S2"]:
        nbytes = int(line[2:4], 16)
        ldata = []
        for i in range(nbytes):
            offset = 4+2*i
            ldata.append(int(line[offset:offset+2],16))
        checksum = ldata[-1]
    if stype == "S1":
        addr = ldata[0] * 256 + ldata[1]
        print(f"S1 ${addr:04X} : {nbytes} bytes cs=${checksum:02X}")
        for i in range(2,nbytes-1):
            print(f"{addr:08X} = {ldata[i]:02X}")
            buff[addr] = ldata[i]
            if addr < first:
                first = addr
            if addr > last:
                last = addr
            addr += 1
    elif stype == "S2":
        addr = ldata[0] * 256 * 256 + ldata[1] * 256 + ldata[2]
        print(f"S2 ${addr:08X} : {nbytes} bytes cs=${checksum:02X}")
        for i in range(3,nbytes-1):
            print(f"{addr:08X} = {ldata[i]:02X}")
            buff[addr] = ldata[i]
            if addr < first:
                first = addr
            if addr > last:
                last = addr
            addr += 1
    elif stype == "S9":
        break
print(f"Data range ${first:08X}-${last:08X}")
fout = open(fout, "wb")
fout.write(buff[first:last+1])
fout.close()
