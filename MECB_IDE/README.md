# MECB_IDE_Board
An implementation of a parallel IDE board for the MECB system. The hardware is based on the PPIDE available for the RC2014 system (https://rc2014.co.uk/modules/ide-hard-drive-module/) and should be compatible with that and with RomWBW. The PLD is set to select the PPIDE device at ports $20-$23 (or $XX20-$XX23 on the MECB memory map if used with CPUs without a separate I/O map) - this is also the default port setting used by RomWBW.

I have confirmed that v1.0 of the board works without any modification. Note that Pin 20 of the 44 pin IDE header should be removed as it acts as a guide for devices that plug directly into it.
