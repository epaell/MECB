#!/usr/bin/env python

import numpy as np

lnum = 0
rtypes = []
dseg = bytearray(np.full((0x10000), 0x00, np.ubyte))
cseg = bytearray(np.full((0x10000), 0x00, np.ubyte))
seg = bytearray(np.full((0x10000), 0x00, np.ubyte))
for line in open("CPM/cpm86_1.1/ALL/CPM.H86", "rt"):
    lnum += 1
    if len(line)<7:
        continue
    if line[0] != ":":
        continue
    length = int(line[1:3],16)
    addr = int(line[3:7],16)
    addrh = int(line[3:5],16)
    addrl = int(line[5:7],16)
    rtype = int(line[7:9],16)
    if (rtype in rtypes) == False:
        rtypes.append(rtype)
    if rtype in [0x85, 0x86, 0x03]:
        print(line)
    data = []
#    print(f"{length:02X} {addrh:02X}{addrl:02X} {rtype:02X}")
    sum = length + rtype + addrh + addrl
    for x in range(length):
        byte = int(line[9+x*2:11+x*2], 16)
        data.append(byte)
        sum += data[-1]
        if rtype == 0x81:
            cseg[addr+x] = 0xff
        if rtype == 0x82:
            dseg[addr+x] = 0xff
        seg[addr+x] = byte
    csum = int(line[9+length*2:11+length*2],16)
    sum &= 0xFF
    sum = (-sum & 0xFF)
    if sum != csum:
        print(f"line {lnum} failed to pass checksum test")
for t in rtypes:
    print(f"{t:02X} ", end="")
print("")
# 0x00 data record, loaded starting at offset from current base paragraph
# 0x01 end of file
# 0x02 extended address, paragraph base for subsequent data records
# 0x03 start address (ignored, IP set according to memory model in use)
# 0x81 same as 00, data belongs to code segment
# 0x82 same as 00, data belongs to data segment
# 0x83 same as 00, data belongs to stack segment
# 0x84 same as 00, data belongs to extra segment
# 0x85 paragraph address for absolute code segment
# 0x86 paragraph address for absolute data segment
# 0x87 paragraph address for absolute stack segment
# 0x88 paragraph address for absolute extra segment
st = -1
last = -1
first = 0x10000
print("Code segment usage:")
for i in range(0x10000):
    if st<0:
        if cseg[i] == 0xff:
            st = i
            if st < first:
                first = st
            continue
    else:
        if cseg[i] == 0x00:
            en = i-1
            if en > last:
                last = en
            print(f"0x{st:04X}-{en:04X}")
            st = -1
            continue

st = -1
print("Data segment usage:")
for i in range(0x10000):
    if st<0:
        if dseg[i] == 0xff:
            st = i
            if st < first:
                first = st
            continue
    else:
        if dseg[i] == 0x00:
            en = i-1
            if en > last:
                last = en
            print(f"0x{st:04X}-{en:04X}")
            st = -1
            continue

print(f"full binary range: {first:04X}-{last:04X}")
fout = open("cpm.bin", "wb")
fout.write(seg[first:last+1])
fout.close()
