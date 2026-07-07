#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
    "test_fn",
    "flex_load",
    "date",
            ]

def clean_hex(fin):
    fout = open("temp.hex", "wt")
    for line in open(fin, "rt"):
        if line.find("S9") !=-1:
            fout.write("S9")
            continue
        fout.write(line)
    fout.close()
    os.system(f"mv temp.hex {fin}")

for source in build_list:
    print(f"*** Compiling {source}.asm ***")
    os.system(f"rm {source}.lst {source}.hex")
    os.system(f"asl  -L -olist ./{source}.lst -cpu 6809 -o ./{source}.p src/{source}.asm")
    os.system(f"p2hex {source}.p -l 64 -F Moto")
    clean_hex(f"{source}.hex")
