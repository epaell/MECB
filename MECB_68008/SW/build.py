#!/usr/bin/env python
import numpy as np
import sys
import os

# OK marks those files that have been updated to work with updated library ROM which now uses TRAP #8 calls

build_list = [
#    "trap",                    # OK
#    "test_lib",                # OK
#    "fntime",                  # OK
#    "asciiart",                # OK
#    "test_aciaio",             # OK
#    "firmware_update",         # OK
    "cpm400_bios",             # OK
    "cpm15k_bios",             # OK
#    "test_fn",
#    "test_delay",
#    "test_sid",
#    "test_ppide",
#    "music",
#    "ram_test",
#    "test_psg",
#    "xmas",
#    "test_oled2",
#    "surface",                  # Draw a 3d surface using FFP math routines on OLED
#    "flash_rom",                # Write library to onboard FLASH ROM
#    "flash_exrom",              # Write library to expansion FLASH ROM
#    "FFPCALC",                     # FPP CALC
#    "test_math",                # Test Math routines
#    "FFPDEMO",                     # FFP Math demo
#    "test_oled",                # Test OLED functionality
#    "test_sd",                  # Test SD card access
#    "test_eflash",              # Test FLASH functionality in ROM expansion card
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
    print(f"*** Compiling {source}.asm ***")
    os.system(f"rm {source}.lst {source}.hex")
    os.system(f"asl  -L -olist ./{source}.lst -cpu 68008 -o ./{source}.p src/{source}.asm")
    os.system(f"p2hex {source}.p -l 32 -F Moto")
