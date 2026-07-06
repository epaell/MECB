# SW

Various software for the 6800/6802 board.

build.py can be used to build the boot loaders for FLEX 2 and FLEX 3 (using asl) - these make use of FujiNet to read/write disk images.

- flex2_load.asm - boot loader for FLEX 2.0
- flex3_load.asm - boot loader for FLEX 3.0
- test_fn.asm - some basic command tests the FujiNet library (libfujinet.asm) against the FujiNet card (it currently only implements just enough to boot FLEX)
- DigiBug.asm - DigiBug monitor
- flex2.asm - FLEX 2.0 source code adapted for use with asl.
- digibug_othello.asm - game of Othello adapated for DigiBug/asl
- digibug_trek.asm - Star Trek game adapted for DigiBug/asl

old.build.py is an old build script that used vasm for compilation.