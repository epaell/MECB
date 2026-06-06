#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
    "badapple",
    "bohemian",
    "downunder",
    "electricdreams",
    "oxygene",
    "popcorn",
    "rasputin",
    "timer",
    "drw2",
    "drwv",
            ]
    
for source in build_list:
    print(f"*** Compiling {source}.asm ***")
    os.system(f"rm {source}.lst {source}.hex")
    os.system(f"asl  -L -olist ./{source}.lst -cpu W65C02S -o ./{source}.p src/{source}.asm")
    os.system(f"p2hex {source}.p -F Intel")
#    os.system(f"vasmm68k_mot -Fbin -L {source}.lst src/{source}.asm")
#    os.system(f"mv a.out {source}.bin")
