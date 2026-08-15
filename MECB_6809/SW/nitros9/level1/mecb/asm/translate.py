#!/usr/bin/env python

for line in open("sprites.asm"):
    if line.find("0b") == -1:
        print(line)
        continue
    ldata = line.split("0b")
    x = int("%s" %(ldata[1]),2)
    print("%s $%02X * 0b%s" %(ldata[0], x, ldata[1]), end="")