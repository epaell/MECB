#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
    "test_oled",
#    "test_SD",
#    "test_mini",
#    "test_eflash",    # Test FLASH functionality in ROM expansion card
#    "test_vdp_gfx",             # Test VDP graphics functionality
#    "test_erom",                # Test reading of ROM expansion card
#    "test_flash",               # Test FLASH functionality in onboard ROM
#    "test_vdp_text",            # Test VDP text functionality
#    "test_timer",               # Test timer and interrupts
#    "test_timer1",              # Test timer and interrupts (reports vector used)
#    "test_vdp_ram",             # Test VDP video memory
#    "test_trap",                # Test trap functionality in Tutor
#    "read_rom"                  # Test reading onboard ROM
            ]
    
for source in build_list:
    os.system(f"rm {source}.lst {source}.s19")
    os.system(f"vasmm68k_mot -Fsrec -s19 -L {source}.lst src/{source}.asm")
    os.system(f"mv a.out {source}.s19")
