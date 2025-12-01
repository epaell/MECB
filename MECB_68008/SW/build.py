#!/usr/bin/env python
import numpy as np
import sys
import os

build_list = [
    "music",
    "test_psg",
    "xmas",
    "test_oled2",
#    "surface",                  # Draw a 3d surface using FFP math routines on OLED
#    "flash_rom",                # Write library to onboard FLASH ROM
#    "flash_exrom",              # Write library to expansion FLASH ROM
#    "FFPCALC",                     # FPP CALC
#    "test_math",                # Test Math routines
#    "FFPDEMO",                     # FFP Math demo
#    "test_oled",                # Test OLED functionality
#    "test_sd",                  # Test SD card access
#    "test_eflash",              # Test FLASH functionality in ROM expansion card
    "test_vdp_gfx",             # Test VDP graphics functionality
#    "test_erom",                # Test reading of ROM expansion card
#    "test_flash",               # Test FLASH functionality in onboard ROM
    "test_vdp_text",            # Test VDP text functionality
#    "test_timer",               # Test timer and interrupts
#    "test_timer1",              # Test timer and interrupts (reports vector used)
    "test_vdp_ram",             # Test VDP video memory
#    "test_trap",                # Test trap functionality in Tutor
#    "read_rom"                  # Test reading onboard ROM
            ]
    
for source in build_list:
    os.system(f"rm {source}.lst {source}.s19")
    os.system(f"vasmm68k_mot -Fsrec -s19 -L {source}.lst src/{source}.asm")
    os.system(f"mv a.out {source}.s19")
#    os.system(f"vasmm68k_mot -Fbin -L {source}.lst src/{source}.asm")
#    os.system(f"mv a.out {source}.bin")
