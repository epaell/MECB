# MECB_KB
An implementation of a PS/2 Keyboard/Mouse interface for the MECB system. The hardware is based on a similar design available for the RC2014 system (https://hackaday.io/project/184729-smart-ps2-keyboardmouse-for-rc2014).

I have confirmed that the V1.0 version of the KB board appears to be fully operational with MECB and RomWBW. By default, the PLD sets the address of the board registers to $60 and $64 (to maintain compatibility with RomWBW).

Note that this board requires the VIA VT82C64 - I have tried with other versions of the 8264 an the board does not work with those (I'm not 100% certain why but it seems like the firmware might be incompatible).

![MECB KB Board](https://github.com/epaell/MECB/blob/main/MECB_KB/MECB_KB.jpg)

