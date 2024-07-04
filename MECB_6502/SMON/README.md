# SMON

SMON is a machine language monitor and direct assembler for the Commodore 64,
published in 1984 in "64'er" magazine (for more info see the [credit section](https://github.com/dhansel/smon6502#credits) below).

In a nutshell, SMON provides the following functionality:
  - View and edit data in memory
  - Disassemble machine code
  - Write assembly code directly into memory (direkt assembler with support for labels)
  - Powerful search features
  - Moving memory, optionally with translation of absolute addresses
  - Trace (single-step) through code
  - Set breakpoint or run to a specific address and continue in single-step mode

The best description of SMON's commands and capabilities is the article in the
64'er magazine (in German) [available here](https://archive.org/details/64er_sonderheft_1985_08/page/n121/mode/2up).
For English speakers, C64Wiki has a brief [overview of SMON commands](https://www.c64-wiki.com/wiki/SMON).

The version adapted here is based on a version by [David Hansel](https://github.com/dhansel/smon6502) but modified for use with the [DigiCoolThings MECB 6502 board](https://github.com/DigicoolThings/MECB).

## Basic usage

At startup, SMON shows the current 6502 processor status, followed by a "." command prompt
```
  PC  SR AC XR YR SP  NV-BDIZC
;E00B B4 E7 00 FF FF  10110100
.                             
```
Where "PC" is the program counter, "SR" is the status register, "AC" is the accumulator, "XR" and "YR" are
the X and Y registers and "SP" is the stack pointer. the "NV-BDIZC" column shows the individual bits
in the status register.

At the command prompt you can enter commands. For example, entering "m 1000 1020" will show the memory
content from $1000-$1020:
```
.m 1000 1030                                                                    
:1000 00 01 02 03 04 05 06 07  08 09 0A 0B 0C 0D 0E 0F         ........ ........
:1010 10 11 12 13 14 15 16 17  18 19 1A 1B 1C 1D 1E 1F         ........ ........
:1020 20 21 22 23 24 25 26 27  28 29 2A 2B 2C 2D 2E 2F          !"#$%&' ()*+,-./
```
The column on the right shows the (printable) ASCII characters corresponding to the data bytes.

If your terminal supports the VT100 cursor movement sequences, you can **modify** the memory
content by just moving the cursor into the displayed lines, editing data and pressing ENTER
on each line where data was modified. If your terminal does not support cursor keys you can
modify memory by typing (for example) `:1015 AA BB` and pressing ENTER. The example here will 
set $1015 to AA and $1016 to BB.

If you supply only one argument to the "m" command, SMON will show the memory content line-by-line,
stopping after each line. Press SPACE to advance to the next line, ESC to go back to the command prompt
or any other key to keep displaying memory without pausing (press SPACE to pause the scrolling display).

The "d" (disassemble) command will disassemble code in memory, for example:
```
.d f000
,F009  A9 FF     LDA #FF
,F00B  A2 04     LDX #04
,F00D  95 FA     STA   FA,X
,F00F  CA        DEX
,F010  D0 FB     BNE F00D
```
You can use the cursor keys to move over the displayed assembly statements and their arguments and modify 
them (assuming the code is in RAM).

You can use the "a" (assemble) command to assemble code directly into memory. SMON will show the current
address as a prompt and you can enter an assembly statement (e.g. `LDX #12`). Press ENTER and SMON will
assemble it, place it directly in memory, and advance the address to the next location according to the
previous opcode's size. To exit assembly mode, type "f" as the opcode. SMON will then show you the full
disassembly of the code you entered, in which you can edit again. For example:
```
.a 2000                  
 2000  ldx #00 
 2002  inx     
 2003  bne 2002
 2005  brk     
 2006 f                  
,2000  A2 00     LDX #00 
,2002  E8        INX     
,2003  D0 FD     BNE 2002
,2005  00        BRK     
```

To run your code just enter `g 2000`. Note that to jump back into SMON after your code
finishes, it should end with a `BRK` instruction.

SMON also allows you to single-step through code using the `tw` (trace walk) command. For example:

```
  PC  SR AC XR YR SP  NV-BDIZC
;2002 23 E7 00 FF FF  00100011
.tw 2000                      
 2002 23 E7 00 FF FF  INX     
 2003 21 E7 01 FF FF  BNE 2002
 2002 21 E7 01 FF FF  INX     
 2003 21 E7 02 FF FF  BNE 2002
 2002 21 E7 02 FF FF  INX     
 2003 21 E7 03 FF FF  BNE 2002
```

After entering the `tw` command, SMON executes the first opcode and stops after
finishing it and displays the next opcode (the first opcode is not shown).
It also shows you the processor registers in the same order as they appear in the
register display line. Press any key to advance one step or ESC to stop.
If the next command is a `JSR`, press 'j' to "jump" over the subroutine and
continue after it finishes (this only works if the `JSR` command is located in RAM).

SMON has a number of other "trace" related commands, a range of "find"
commands to examine memory and several other commands. To get a quick overview
of commands type "h" at the command line. For a bit more information on each command,
refer to the [C64Wiki](https://www.c64-wiki.com/wiki/SMON) page or for the full description 
read the [64er article](https://archive.org/details/64er_sonderheft_1985_08/page/n121/mode/2up) 
(in German).

## New commands

### Intel HEX load

This version of SMON provides the "l" (load [Intel HEX](https://en.wikipedia.org/wiki/Intel_HEX)) command to 
help test 6502 programs written on your PC and compiled there using a compiler such as VASM:
  1. Tell your compiler to produce Intel HEX output (in VASM, use the "-Fihex" command line parameter).
  2. In SMON, type "l" followed by ENTER on the command line
  3. Copy-and-paste the content of the (plain text ASCII) .hex file produced by your compiler into the terminal.

SMON will show a "+" for each HEX record processed. If a transmission error occurs, SMON shows
a one-character error code followed by "?". Possible error codes are:
  - I?: Input character error - an unexpected character was received in the input
  - C?: Checksum error - the checksum at the end of a record did not match the expected value
  - M?: Memory error - After writing a byte to memory it did not read back properly (most likely attempting to write to ROM)
  - B?: Break - Either ESC or CTRL-C was received before the end of the transmission

If no "?" is shown and SMON goes back to the command prompt then the transmission succeeded.

### Memory size and test

The new "MS" (memory size) command checks memory starting at address $0100 and upwards until it finds
and address where a read after write does not result in the same data. It then shows that address as
the memory size.

The "MT xxxx yyyy [nn]" command tests memory between $xxxx and $yyyy by writing different patterns
of data to it and checking whether the data reads back the same. Each time a difference is found
the corresponding address is printed. The optional "nn" parameter specifies a repetition count
(defaults to 1). At the end of each test, a "+" is printed.

## Credits

The SMON machine language monitor was originally published in three parts in the 
[November](https://archive.org/details/64er_1984_11/page/n59/mode/2up)
/ [December](https://archive.org/details/64er_1984_12/page/n59/mode/2up)
/ [January](https://archive.org/details/64er_1985_01/page/n68/mode/2up)
1984/85 issues of German magazine "[64er](https://www.c64-wiki.com/wiki/64%27er)".

SMON was written for the Commodore 64 by Norfried Mann and Dietrich Weineck.

The [code](https://github.com/dhansel/smon6502/blob/main/smon.asm) here is based 
on a (partially) commented [disassembly of SMON](https://github.com/cbmuser/smon-reassembly/blob/master/smon_acme.asm)
by GitHub user Michael ([cbmuser](https://github.com/cbmuser)).

The [code](https://github.com/dhansel/smon6502/blob/main/uart_6522.asm) for handling RS232 communication via the 6522 VIA chip was taken
and (heavily) adapted from the VIC-20 kernal, using Lee Davidson's 
[commented disassembly](https://www.mdawson.net/vic20chrome/vic20/docs/kernel_disassembly.txt).

The [code](https://github.com/dhansel/smon6502/blob/main/uart_6551.asm) for handling RS232 communication via the 
65C51N ACIA chip was put together and tested by Chris McBrien, based on the ACIA code from 
[Adrien Kohlbecker](https://github.com/adrienkohlbecker/65C816/blob/ep.30/software/lib/acia.a).

This version is based on an adaptation by [David Hansel](https://github.com/dhansel/smon6502).

Special thanks to DigicoolThings for providing adaptations to allow the code to compile with ca65/ld65.

## MECB

This version of SMON has been modified to work with the [DigicoolThings MECB 6502](https://github.com/DigicoolThings/MECB) system:

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
