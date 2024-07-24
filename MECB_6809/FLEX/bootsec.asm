*=====================================================
* 6809 Boot Sector for the Corsham Tech SD card
* systen.  www.corshamtech.com
*
* Modified from the 6800 version.
*
* 11/27/2015 - Bob Applegate, K2UT, bob@corshamtech.com
*
* This is loaded onto the very first "sector" of a
* bootable DSK image, which is track zero, sector zero.
* The code is read into memory at $C100 by the monitor
* boot command.
*=====================================================
*
* ASCII constants
*
EOT     EQU     $04
LF      EQU     $0A
CR      EQU     $0D
*
        LIB     SDLIB.INC
*
* SBUG functions
*
MONITOR EQU     $F800
OUTCH   EQU     $F80A
PDATA   EQU     $F80C
*
* These are the standard record types in FLEX binary
* files.
*
RECBIN  EQU     $02
RECTADR EQU     $16
*
* This is the default start address of the OS, just
* in case the binary file doesn't specify one.
*
DEFRUN  EQU     $CD00
*
        ORG     $C100
*
LOAD    JSR     PINIT   *not really needed but not bad
        BRA     LOAD0   *skip to next section
*
* The next bytes must be at offset 5 and 6.  They
* contain the track and sector number of where to
* find the actually OS to load.
*
* By default, point to the next sector which is a
* very short program telling them this disk is
* not bootable.
*
FLXTRK  FCB     0
FLXSEC  FCB     2
*
LOAD0   LDX     #DEFRUN
        STX     TRADDR  *clear the transfer address
        LDS     #$C07F
        LDX     #BOOTMSG
        JSR     [PDATA] *print hello
*
* Read in the System Information Record (SIR) next.
* We'll need to know how many sectors per track
* for future disk operations.  The FCB is already
* set up for this read.  Track 0, sector 3.
*
        JSR     READSEC
*
* Now move the sectors-per-track into the FCB.
*
        LDAA    BUFFER+$27
        STAA    LFCB+3
*
* Now start loading the OS into memory, starting
* with the track/sector at offset 5/6.
*
        LDX     FLXTRK  *get both track and sector
        STX     LFCB+1
        JSR     READSEC *go get the first sector
        LDX     #BUFFER+4 *start of data
        STX     BUFPTR
*
* This loop processes the next record type in the
* boot sequence.
*
PROCBUF JSR     GETBYTE *get next record type
        CMPA    #RECBIN *binary record?
        BEQ     BINREC
        CMPA    #RECTADR *transfer address?
        BNE     PROCBUF *nope, ignore it
*
* It's a transfer record.  This is followed
* by a two byte address.  Save the address and
* then continue.  If more than one transfer
* address is seen, only the last is kept.
*
        JSR     GETBYTE
        STA     TRADDR  *MSB
        JSR     GETBYTE
        STA     TRADDR+1 *LSB
        BRA     PROCBUF
*
* It's a binary record.  This is followed
* by a two-byte address and then a one-byte
* byte count.  After that are the bytes.
*
BINREC  JSR     GETBYTE
        STA     ADDRESS
        JSR     GETBYTE
        STA     ADDRESS+1
        JSR     GETBYTE *get the byte count
        TFR     A,B     *put length in B
BINLOOP JSR     GETBYTE *next byte of data
        LDY     ADDRESS *restore pointer
        STA     ,Y+     *put into memory
        STY     ADDRESS
        DECB
        BNE     BINLOOP *do all the bytes
        BRA     PROCBUF *all done
*
*=====================================================
* This function reads a sector.  The FCB is already
* set up, so this takes no parameters.  Prints a dot
* so the user sees progress.
*
READSEC LDA     #'.
        JSR     [OUTCH]
*
        LDX     #LFCB
        JSR     DSECRD  *get SD sector
        BCS     BOOTERR
        RTS
*
BOOTERR LDX     #ERRMSG
        JSR     [PDATA]
        JMP     [MONITOR]
*
*=====================================================
* This gets the next byte from the disk buffer and
* returns it in A.  If the end of the buffer is
* reached, this will get the next buffer in the chain
* and return the first byte from it.  If the end of
* the chain is reached, this will not return.
*
GETBYTE LDX     BUFPTR  *current pointer
        CPX     #BUFFEND
        BNE     GETNEN  *branch if not at end
*
* There is no more data in this sector, so see if there
* is another sector after it.
*
        LDA     BUFFER  *track of next buffer
        BEQ     GETEND  *branch if end of chain
*
* There is another sector in chain, so get it.
*
        LDX     BUFFER  *do track and sector at once
        STX     LFCB+1  *save into FCB
        STB     SAVEB
        JSR     READSEC *get next sector
        LDB     SAVEB
        LDX     #BUFFER+4 *start of data
GETNEN  LDA     ,X+     *get next byte
        STX     BUFPTR
        RTS
*
* End of the chain.
*
GETEND  LDX     #CRMSG2
        JSR     [PDATA]
*       JMP     [MONITOR]   *DEBUG
        JMP     [TRADDR]
*
*=====================================================
* Text messages
*
BOOTMSG FCB     CR,LF
        FCC     "Loading 6809 FLEX"
        FCB     EOT
*
ERRMSG  FCC     "FAILURE"
CRMSG2  FCB     CR,LF
CRMSG   FCB     CR,LF,0,EOT
*
*=====================================================
* The FCB
*
LFCB    FCB     0       *drive
        FCB     0       *track
        FCB     3       *sector
        FCB     0       *sectors per track
        FDB     BUFFER  *buffer pointer
*
*=====================================================
* Uninitialized data follows.
*
ADDRESS RMB     2
TRADDR  RMB     2
BUFPTR  RMB     2
SAVEB   RMB     1
BUFFER  RMB     256
BUFFEND EQU     *
*
        END     LOAD
