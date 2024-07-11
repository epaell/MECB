# zBug
The modified version of zBug based on the [kanpapa version](https://github.com/kanpapa/mic68k/tree/master) of the software but adapted for a hypothetical [DigiCoolThings MECB 68008](https://github.com/DigicoolThings/MECB). 

The modified code assumes the following MECB set-up:

MECB Memory map

    $00000-$07FFF ROM
    
    $08000-$1FFFF RAM
    $20000-$20100 I/O
    
        $20000 ACIA
        
The current set-up is somewhat arbitrary and is what it used for emulation in MAME.

The code has been adapted to work with vasmm68k_mot:

   http://sun.hasenbraten.de/vasm/

To compile the combined version simply run "build.sh".
