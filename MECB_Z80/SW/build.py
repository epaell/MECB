#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
    "memtest",
]

for source in build_list:
    cwd = os.getcwd()
    os.system(f"rm {source}.hex {source}.lst")
    os.system(f"vasmz80_mot -Fihex src/{source}.asm -o {source}.hex -L {source}.lst ")
