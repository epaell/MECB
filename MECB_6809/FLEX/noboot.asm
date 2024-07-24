*================================================
* This is the default second-stage boot for the
* Corsham Technologies SD card system.  This is
* loaded onto track 0, sector 1 (offsets $0100 to
* $01FF on a DSK file) and basically does nothing
* more than tell the user that this disk is not
* bootable.  The boot code in sector 0 will point
* to this by default.  If the user links a real
* OS then this code is never called.
*
* 07/03/2015 by Bob Applegate K2UT
*            bob@corshamtech.com
*
* ASCII constants
*
EOT     EQU     $04
LF      EQU     $0A
CR      EQU     $0D
*
* Functions in SBUG
*
PDATA   EQU     $F80C
MONITOR EQU     $F800
*
* Address where this gets loaded.  It must be
* the same location that FLEX cold-starts at
* since the loader will jump to that location
* once this file is loaded into memory.
*
LOADDR  EQU     $CD00
*
* ORG low so that there is room for the header
*
        ORG     LOADDR
*
* This is the actual program
*
NOBOOT  LDX     #MSG
        JSR     [PDATA] *display the message
*
* I don't know which is best... do an SWI or
* just jump back into SBUG's cold start.  Both
* seem to work, but SWI seems more proper.
*
        SWI
*
*       JMP     [MONITOR] *jump back to SBUG
*
MSG     FCB     CR,LF
        FCC     "Sorry, but this disk is not bootable."
        FCB     CR,LF,CR,LF
        FCB     0,EOT
*
        END     NOBOOT

