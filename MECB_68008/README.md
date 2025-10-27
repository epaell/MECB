# MECB_68008
Development of a MECB 68008 system. Currently this board is under test so use schematics with caution (PCB layout has not been updated with fixes yet). ROM, RAM and IO access have been tested.

TODO:
- test ability to load software via Tutor
- test board with 9958 card
- test interrupt functionality
- test expansion capability? This may not work at full processor speed because system clock is not passed through (clock needs to be E for IO functionality)

The MAME directory contains files for simulating a simular system in MAME.

The GAL directory contains the definition files for the GALs used on the board.

The Tutor directory contains the monitor and enhanced BASIC.

The test directory contains a number of very basic test programs to check the ROM, RAM and IO.
