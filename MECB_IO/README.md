# MECB_IO
An implementation of a basic I/O board for the MECB system. The hardware is based on a I/O and front panel design available
for the RC2014 system (https://rc2014.co.uk/backplanes/front-panel-kit/) and should be compatible with the Front Panel available for that.

The board also adds a Real-time clock and 31 bytes of non-volatile memory, again based on an RC2014 design (https://github.com/electrified/rc2014-ds1302-rtc/tree/main).

The current I/O board, front panel and RTC should all be compatible with RomWBW. At the moment I've confirmed that the I/O board works fine with MECB and RomWBW. Note that the PLD places the RTC at $C0 (or $XXC0 for memory mapped CPUs) - this is the default location for RomWBW. The front panel I/O, however, is at $C1 (or $XXC1 for memory mapped CPUs) as opposed to the standard port of $00 (which conflicts with the MECB I/O board).

![MECB FPIO Board](https://github.com/epaell/MECB/blob/main/MECB_IO/MECB_FPIO.jpg)

