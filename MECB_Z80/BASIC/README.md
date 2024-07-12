# Microsoft Z80 BASIC
The modified version of the Microsoft Z80 Basic based on the [Greg Searle's version](http://searle.x10host.com/z80/SimpleZ80.html) of the software but adapted for a hypothetical [DigiCoolThings MECB Z80](https://github.com/DigicoolThings/MECB). 

The modified code assumes the following MECB set-up:

MECB Memory map

    $0000-$1FFF ROM
    
    $8000-$FFFF RAM

MECB I/O map

    $80-$81 ACIA
        
The current set-up is somewhat arbitrary and is what it used for emulation in MAME.

The code has been adapted to work with vasmz80_oldstyle:

   http://sun.hasenbraten.de/vasm/

To compile basic simply run "build.sh".
