#!/usr/bin/env python
import numpy as np
import sys
import os

for source in ["test_vdp_gfx"]:#["test_vdp_ram", "test_trap", "test_timer", "read_rom"]:
    os.system(f"rm {source}.bin {source}.lst {source}.s19")
    os.system(f"vasmm68k_mot -Fsrec -s19 -L {source}.lst src/{source}.asm")
    os.system(f"mv a.out {source}.s19")
#    os.system(f"cat a.out s19term.txt >{source}.s19")
