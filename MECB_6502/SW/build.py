#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
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
    os.system(f"vasm6502_mot  -L {source}.lst -wdc02 -Fihex src/{source}.asm")
    os.system(f"mv a.out {source}.hex")
#    os.system(f"vasmm68k_mot -Fbin -L {source}.lst src/{source}.asm")
#    os.system(f"mv a.out {source}.bin")
