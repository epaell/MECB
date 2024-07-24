*================================================
* SDLIB.INC
*
* Corsham Technologies SD Drive Library interface
* data.  This is meant to make it a bit easier
* to write software for the SD card library by
* providing common names for functions and
* constants.
*
* Just include this file into any program that
* will be interfacing with the low-level
* 07/18/2015 - Made compliant with spec v0.1.
* subroutines.
*
* The original libraries were written using a
* 6800 cross assembler with long symbols, so
* converting to the very short ASMB symbols means
* the descriptive names are compressed to a
* bunch of meaningless strings of characters,
* but I'll try to explain the logic a bit.
*
* This file is based on "The Remote Disk Protocol
* Guide" which is available on the Corsham Tech
* web page.
*
* UPDATES
* 07/18/2015 Made compliant with spec v0.1.
*
*================================================
*
* These are low level commands sent to the
* remote disk controller.
*
CGETVER EQU     $01     *Get version of code
CPING   EQU     $05     *send a PING request
CLEDCON EQU     $06     *control the LEDs
CGETCLK EQU     $07     *get the real time clock
CSETCLK EQU     $08     *set the real time clock
CGETDIR EQU     $10     *request directory of disk
CGETMNT EQU     $11     *request list of mounted drives
CMOUNT  EQU     $12     *mount a drive
CUNMNT  EQU     $13     *unmount a drive
CGETSTA EQU     $14     *get status of drive
CDONE   EQU     $15     *end current operation
CABORT  EQU     CDONE
CREAFIL EQU     $16     *read regular file
CREABYT EQU     $17     *read more bytes
CREASEC EQU     $18     *read FLEX sector
CWRSEC  EQU     $19     *write FLEX sector
CGETMAX EQU     $1A     *get max drive number
CWRIFIL EQU     $1B     *open file for writing
CWRIBYT EQU     $1C     *data to be written to file
*
*================================================
*
* These are responses from the remote disk
* system.  Again, very cryptic names.
*
RVERSIO EQU     $81     *version information
RACK    EQU     $82     *ACK
RNAK    EQU     $83     *NAK - followed by error code
RPONG   EQU     $85     *response to PING
RCLKDAT EQU     $87     *contains clock data
RDIRDAT EQU     $90     *a directory entry
RDIREND EQU     $91     *end of directory
RFILDAT EQU     $92     *file data
RSTATUS EQU     $93     *drive status
RSECDAT EQU     $94     *sector data
RMNTINF EQU     $95     *mount entry
RMAXDRV EQU     $96     *max number of drives
*
*================================================
*
* Error codes.  These are returned after a NAK.
*
ENONE   EQU     $00     *no error
ENOTMNT EQU     $10     *not mounted
EMOUNTD EQU     $11     *mounted
ENOTFND EQU     $12     *not found
EREADO  EQU     $13     *read only
EBADDRV EQU     $14     *bad drive
EBADTRK EQU     $15     *bad track
EBADSEC EQU     $16     *bad sector
EREADER EQU     $17     *read error
ENODEV  EQU     $18     *no device
*
*================================================
*
* These are the low-level subroutines that
* directly touch hardware.
*
* IF YOU ARE NOT USING A CORSHAM TECH CPU BOARD
* THEN THESE MIGHT BE AT DIFFERENT ADDRESSES!
*
* Also note that the base address of this vector
* table depends on the CPU board.
*
* For 6800, it is at E40A.
* For 6809, it is at F000.
*
        ORG     $F000   *location of jump table - 6809
BOOTOS  RMB     3       *loads FLEX from SD card
PINIT   RMB     3       *Initialize parallel interface
PSETWRI RMB     3       *set for write to Arduino
PSETREA RMB     3       *set for read from Arduino
PWRITE  RMB     3       *write byte to Arduino
PREAD   RMB     3       *read byte from Arduino
*
*================================================
*
* These are the higher level functions.  Using
* these will save you from the trouble of sending
* and receiving individual bytes to/from the
* Arduino.
*
DSECRD  RMB     3       *read a disk sector
DSECWR  RMB     3       *write a disk sector
DSTATUS RMB     3       *get disk status
DGETDRV RMB     3       *get number of supported drives
DGETMNT RMB     3       *ask for mounted drive list
DNXTMNT RMB     3       *get next mounted drive info
DUNMNT  RMB     3       *unmount a drive
DMOUNT  RMB     3       *mount a drive
DDIR    RMB     3       *start a directory of disk
DDIRNXT RMB     3       *get next directory entry
*
