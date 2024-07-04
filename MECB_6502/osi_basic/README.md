# osi_basic

osi_basic is Microsoft BASIC for the OSI computer based on [Greg Searle's version](http://searle.x10host.com/6502/Simple6502.html) but adapted for [DigicoolThings MECB 6502](https://github.com/DigicoolThings/MECB) board.

## MECB

This version of osi basic has been modified to work with the [DigicoolThings MECB 6502](https://github.com/DigicoolThings/MECB) system:

The modified code assumes the following MECB set-up:

MECB Memory map (32 KB ROM)

    $0000-$BFFF RAM
    
       $0000-$00FF SMON use
       
    $C000-$C100 I/O
    
        $C000 PTM
        
        $C008 ACIA
        
    $8000-FFFF  ROM
    
        $E800-$FFFE SMON

MECB Memory map (16 KB ROM)

    $0000-$BFFF RAM
    
       $0000-$00FF SMON use
       
    $C000-$C100 I/O
    
        $C000 PTM
        
        $C008 ACIA
        
    $C100-FFFF  ROM
    
        $E800-$FFFE SMON

MECB Memory map (8 KB ROM)

    $0000-$CFFF RAM
    
       $0000-$00FF SMON use
       
    $D000-$D100 I/O
    
        $D000 PTM
        
        $D008 ACIA
        
    $D100-FFFF  ROM
    
        $E800-$FFFE SMON
