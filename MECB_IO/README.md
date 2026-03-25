# MECB_IO
An implementation of a basic I/O board for the MECB system. The hardware is based on a I/O and front panel design available
for the RC2014 system (https://rc2014.co.uk/backplanes/front-panel-kit/) and should be compatible with the Front Panel available for that.

The board also adds a Real-time clock and 31 bytes of non-volatile memory, again based on an RC2014 design (https://github.com/electrified/rc2014-ds1302-rtc/tree/main).

The current I/O board, front panel and RTC should all be compatible with RomWBW. At the moment I've confirmed that the I/O board works fine (although I had to reverse the LEDs to make them work with the PCB-mount LEDs that I had - my prototype has them mounted on the back of the board to overcome this). I'm currently having trouble getting RomWBW to recognise the RTC (although it seems to work if I access it via my own test program). If it requires a hardware change I'll release a v1.0 board.
