# MECB_IO
An implementation of a basic I/O board for the MECB system. The hardware is based on a I/O and front panel design available
for the RC2014 system (https://rc2014.co.uk/backplanes/front-panel-kit/) and should be compatible with the Front Panel available for that. If using an external front panel do not install the on-board switches and LEDs.

The board also adds a Real-time clock and 31 bytes of non-volatile memory, again based on an RC2014 design (https://github.com/electrified/rc2014-ds1302-rtc/tree/main).

I have confirmed that the V1.0 version of the FP I/O board and RTC appear to be fully operational with MECB and RomWBW (though I haven't actually tested the front panel via an external cable). Note that the PLD places the RTC at $C0 (or $XXC0 for memory mapped CPUs) - this is the default location for RomWBW. The front panel I/O, however, is at $C1 (or $XXC1 for memory mapped CPUs) as opposed to the standard port of $00 (which conflicts with the MECB I/O board).

![MECB FPIO Board](https://github.com/epaell/MECB/blob/main/MECB_IO/MECB_FPIO.jpg)

