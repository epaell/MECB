#!/usr/bin/env python
hex = {}
for i in range(10):
    hex["%d" %(i)] = i
hex["A"] = 10
hex["B"] = 11
hex["C"] = 12
hex["D"] = 13
hex["E"] = 14
hex["F"] = 15

for line in open("sprite.txt"):
    if line.find("const") != -1:
        print(";")
        continue
    ldata = line.split(",")
    for item in ldata:
        pos = item.find("x")
        if pos == -1:
            continue
        val = hex[item[pos+1]]*16 + hex[item[pos+2]]
        print("               fcb     0b{:08b}".format(val))