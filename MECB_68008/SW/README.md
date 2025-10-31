# SW
Useful software routines for MECB 68008.

mecb.asm - MECB-specific definitions for the MECB 68008 e.g. RAM, ROM, I/O ports

random.asm - a simple 16-bit signed random number generator

vdp.asm - low level routines to communicate with the 9958 VDP

vdp_gfx.asm - routines to set graphics mode, draw pixels and draw lines.

vdp_text.asm - routines to load font and enable text mode.

test_vdp_gfx - test program for line drawing routine.

test_vdp_text.asm - test program to check VDP text mode and font loading.

read_rom.asm - low level routine that accesses all bytes in the ROM

test_timer.asm - test program to test timer interrupt.

test_trap.asm - test program to see if Tutor TRAP #14 routines work.
