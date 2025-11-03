# MECB_68008
Development of a MECB 68008 system. Currently this board is under test so use schematics with caution (PCB layout has not been updated with fixes yet). ROM, RAM and IO access have been tested.

TODO:
- test ability to load software via Tutor - OK!
- test board with 9958 VDP card - OK!
- test interrupt functionality - Seems to work with timer.
- test ability to write to FLASH ROM and check write-protect - seems OK.
- test expansion capability - Seems to function OK with ROM expansion card.
- rework the PLD to concentrate addressing in one PLD and remaining GLUE in the other. Currently it is quite messy.
- rework the PCB layout to be incorporate the bodge fixes needed for v0.1.

The GAL directory contains the definition files for the GALs used on the board.

The Tutor directory contains the monitor and enhanced BASIC (modified slightly for use with this system).

The test directory contains a number of very basic test programs to check the ROM, RAM and IO.

The SW directory contains useful 68008-related assembly routines (work in progress). Some of these may ultimately be shifted into ROM.