# TUTOR
The modified version of the Motorola MC68000 Educational Computer Board Tutor monitor based on the [Teeside adaptation](http://www.easy68k.com/paulrsm/mecb/mecb.htm) of the software but adapted for a hypothetical [DigiCoolThings MECB 68008](https://github.com/DigicoolThings/MECB). It also builds a version of Tutor with a modified version of the Motorola MC68000 Enhanced Basic based on the [Jeff Tranter's version](https://github.com/jefftranter/68000/tree/master). Enhanced BASIC can be started from Tutor using the "BA" command.


The modified code assumes the following MECB set-up:

MECB Memory map

    $00000-$07FFF ROM
    
    $08000-$1FFFF RAM
    $20000-$20100 I/O
    
        $20000-$20001 ACIA (Note that the ACIA on the 68000 was original set up on even bytes only).
        
The current set-up is somewhat arbitrary and is what it used for emulation in MAME.

The code has been adapted to work with vasmm68k_mot:

   http://sun.hasenbraten.de/vasm/

To compile the tutor-only and combined version simply run "build.sh".

TODO: Note that the vector table needs work as the Motorola system had a different set up in the lower part of memory space. Currently only the reset and some trap vectors are set up.
