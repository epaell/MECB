# MECB FLASH Test
Simple routines to write data to the MECB 1 MB FLASH ROM card
(https://digicoolthings.com/minimalist-europe-card-bus-mecb-1mb-rom-expansion-card-part-2/)
Assumptions:
   MECB RAM: $0000-$7FFF
   MECB ROM: $8000-$FFFF (ASSIST09 is in upper part of ROM, mine was at $F000)
   MECB I/O: $C000

These routines will only allow access to the 32KB bank of ROM that is enabled.
Care must be taken not to inadvertently erase/over-write the ASSIST09 part of the ROM.
