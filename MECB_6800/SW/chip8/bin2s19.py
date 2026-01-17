#!/usr/bin/env python
import numpy as np
import sys
import os

def bin2srec(f_bin, f_srec, start = 0x0200, slen = 0x20):
    # Read the binary
    fin = open(f_bin, "rb")
    raw = fin.read()
    fin.close()
    
    # Add the length to the start of the binary array
    bin_contents = bytearray(np.full((len(raw)), 0x00, np.ubyte))
    bin_contents = raw

    fout = open(f_srec, "wt")
    srecord = bytearray(np.full((1 + 2 + slen + 1), 0x00, np.ubyte))
    fout.write("S0030000FC\n")
    for addr in range(0,len(bin_contents), slen):
        if addr + slen > len(bin_contents):
            ndata = len(bin_contents)-addr
        else:
            ndata = slen
        srecord[0] = ndata+3
        srecord[1] = ((addr + start) >> 8)
        srecord[2] = ((addr + start) & 0xFF)
        srecord[3:3+ndata] = bin_contents[addr:addr+ndata]
        srecord[3+ndata] = 0xFF - (np.sum(srecord[:3+ndata]) & 0xFF)
        s = 0x00
        str = "S1"
        for index in range(ndata+3+1):
            str += "%02X" %(srecord[index])
        str += "\n"
        fout.write(str)
    fout.write("S9\n")
    fout.close()

source = sys.argv[1]
source = source.split(".")[0]
bin2srec(f"{source}.bin", f"{source}.s19")
