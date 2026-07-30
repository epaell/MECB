# TUTOR
The modified version of the Motorola MC68000 Educational Computer Board Tutor monitor based on the [Teeside adaptation](http://www.easy68k.com/paulrsm/mecb/mecb.htm) of the software but adapted for a hypothetical [DigiCoolThings MECB 68008](https://github.com/DigicoolThings/MECB). It also builds a version of Tutor with a modified version of the Motorola MC68000 Enhanced Basic based on the [Jeff Tranter's version](https://github.com/jefftranter/68000/tree/master). Enhanced BASIC can be started from Tutor using the "BA" command. In addition, firmware updates of the FLASH ROM can be made via a Fujinet card using the "FU" command (assuming the firmware is in /CPM68K/FIRMWARE.ROM). Furthermore, "BO" can be used to boot CP/M via the Fujinet card - it is assumed that /CPM68K/CPM13.CPM is available in the first device slot and mounted as drive A: (slots 2-8 are mounted as drives B: through to H:)


The modified code assumes the following MECB set-up:

MECB Memory map

    $000000-$07FFFF RAM
    
    $200000-$27FFFF ROM
    $3C0000-$3C00FF I/O
    
        $3C0008-$3C0009 ACIA (Note that the ACIA on the 68000 was original set up on even bytes only).
        
The code has been adapted to work with vasmm68k_mot:

   http://sun.hasenbraten.de/vasm/

To compile the tutor-only and combined version simply run "build.sh".
