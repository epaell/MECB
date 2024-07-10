# EH BASIC
The modified version of the Motorola MC68000 EHBasic based on the [Jeff Tranter's version](https://github.com/jefftranter/68000/tree/master) of the software but adapted for a hypothetical [DigiCoolThings MECB 68008](https://github.com/DigicoolThings/MECB). 

The modified code assumes the following MECB set-up:

MECB Memory map

    $00000-$03FFF ROM
    
    $04000-$1FFFF RAM
    $20000-$20100 I/O
    
        $20000-$20001 ACIA (Note that the ACIA on the 68000 was original set up on even bytes only).
        
The current set-up is somewhat arbitrary and is what it used for emulation in MAME.

The code has been adapted to work with vasmm68k_mot:

   http://sun.hasenbraten.de/vasm/

To compile the combined version simply run "build.sh".
