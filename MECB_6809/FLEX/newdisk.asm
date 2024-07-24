*=====================================================
* NEWDISK for the Corsham Tech SD card system.
*
* 07/12/2015 - Bob Applegate K2UT
*              bob@corshamtech.com
* 10/31/2015 - Bob Applegate
*              Added D command, bumped to version 1.
*
* This uses the SD card function calls to format disks
* to a number of different sizes.
*
*=====================================================
*
        LIB     FLEX.INC
        LIB     SDLIB.INC
*
* ASCII stuff
*
NULL    EQU     $00
EOT     EQU     $04
BS      EQU     $08
LF      EQU     $0A
CR      EQU     $0D
SPACE   EQU     $20
*
* Version number of this utility.  Must be a single byte
*
VERSION EQU     1
*
* Number of bytes per sector.  FLEX is always 256.
*
SECSIZE EQU     256
*
* Start of code
*
        ORG     $A100
NEWDISK BRA     NEWDSK
*
* Version number
*
        FCB     VERSION
*
* And back to real code
*
NEWDSK  LDX     #HELLO
        JSR     PSTRNG
*
* Load the binary files we'll need
*
        JSR     LOADFIL
*
* This is the loop that displays the menu, gets their
* select, and does it.
*
MLOOP   JSR     DOMENU
        CMPA    #'X
        BEQ     MEXIT
        CMPA    #'x
        BNE     MNEXIT
*
MEXIT   LDX     #BYEMSG
        JSR     PUTS
        JMP     WARMS
*
* They chose a drive format, the pointer to which is
* in X.
*
MNEXIT  STX     DSKPTR  *save pntr to disk params
        INX             *skip over tracks/sectors
        INX
        JSR     PUTS    *print the description
        JSR     PCRLF
*
* Go build the System Information Record (SIR)
* using the selected disk entry.
*
        JSR     BLDSIR
        BCS     MLOOP   *didn't want to format
*
        LDX     #TRKPROG *progress message
        JSR     PSTRNG
*
* Try opening the file.  If it fails, assume the
* function displays the error.  Just loop back
* and try again.
*
        JSR     RAWOPEN
        BCS     MLOOP
*
* Now write the first few sectors on track 0.
*
        LDX     #BOOTSEC
        JSR     RAWRITE *boot sector, T0 S0
        LDX     #BUT2SEC
        JSR     RAWRITE *"no boot" sector T0 S2
        LDX     #SIRSEC
        JSR     RAWRITE *SIR - T0 S3
        LDX     #SECTOR
        JSR     CLRBUF  *T0 S4 is unused
        LDX     #SECTOR
        JSR     RAWRITE *T0 S4
*
* Now comes the fun part.  Starting at sector 5,
* the rest of the track is the linked directory
* chain.
*
        CLR     DUNFLAG
        LDAA    #5      *this sector number
        STAA    SECTOR+1 *link in sector
WDL10   LDAA    SECTOR+1
        CMPA    MAXSEC  *at last sector?
        BNE     WDL11   *nope
        LDAA    #$FF    *-1; will inc to 0
        STAA    SECTOR+1
        INC     DUNFLAG *done with this loop
WDL11   INC     SECTOR+1 *next sector
        LDX     #SECTOR
        JSR     RAWRITE *and write the sector
        LDAA    DUNFLAG
        BEQ     WDL10   *loop if not done
*
        LDAA    #'.
        JSR     PUTCHR
*
* Now set up to write the rest of the disk starting
* at track 1.
*
        LDAA    #1      *track 1, sector 1
        STAA    SECTOR  *track
        STAA    SECTOR+1 *sector
        CLR     DUNFLAG
WDLP20  LDAA    SECTOR+1 *current sector number
        CMPA    MAXSEC  *end of track?
        BNE     WDLP22  *branch if not
*
* Reached end of track.  Bump to next track, if
* there is one.
*
        LDAA    #'.
        JSR     PUTCHR
*
        LDAA    SECTOR  *current track
        CMPA    MAXTRK  *at end?
        BNE     WDLP21
*
* About to write the last sector on the
* last track.  Forward pointer needs to be zero.
*
        CLRA
        STAA    SECTOR  *track 0
        DECA            *make -1
        STAA    SECTOR+1 *sector number
        STAA    DUNFLAG *indicate we're done
        BRA     WDLP22
*
WDLP21  INC     SECTOR  *next track
        CLR     SECTOR+1 *sector zero
*
WDLP22  INC     SECTOR+1 *inc sector number
        LDX     #SECTOR
        JSR     RAWRITE *and finally write the sector
*
        LDAA    DUNFLAG
        BEQ     WDLP20  *loop if not done
*
* Close the file
*
        JSR     RAWCLOS
*
* All done, back to menu
*
        JSR     PCRLF
        JMP     MLOOP
*
*=====================================================
* This presents the main menu.  Some of the items are
* fixed while the available disk formats are built
* dynamically.  The dynamic construction makes it
* easier to add/remove/modify entries without having
* to manually build new menu items.
*
DOMENU  LDX     #MENUMSG *the fixed portion of the menu
        JSR     PSTRNG
*
* Now scan through the list of disk entries and print
* each one.  This only allows for 10 entries!
*
        LDAA    #0      *initial option number
        STAA    MAXDRV  *save for highest drive
        LDX     #FORMATS *start of the table
DLOOP   LDAA    0,X     *if zero, end of list
        BEQ     DLEND
*
* Valid entry, so skip sectors and track, then display
* the number and text description.
*
        INX             *skip sectors-per-track
        INX             *skip tracks
        LDAA    #SPACE
        JSR     PUTCHR
        JSR     PUTCHR
        JSR     PUTCHR
        LDAA    MAXDRV  *selection number
        ORAA    #'0     *mask ASCII
        JSR     PUTCHR
        LDAA    #SPACE
        JSR     PUTCHR
        LDAA    #'=
        JSR     PUTCHR
        LDAA    #SPACE
        JSR     PUTCHR
        STX     TEMPX   *save for now
        LDX     #FMTMSG
        JSR     PUTS
        LDX     TEMPX   *restore pointer
        JSR     PUTS    *print the description
        JSR     PCRLF   *new line
*
        INX             *move to next entry
        INC     MAXDRV  *next drive number
        BRA     DLOOP   *and do it again
*
* All done displaying selections, so now prompt
* for what they want to do.
*
DLEND   DEC     MAXDRV
        LDX     #PROMPT
        JSR     PUTS
DLUP2   JSR     GETKEY  *get their selection
        CMPA    #'X     *exit?
        BEQ     DLGUD
        CMPA    #'x
        BEQ     DLGUD
        CMPA    #'0-1   *valid number choice?
        BLS     DLUP2   *nope
        SUBA    #'0     *make into a number
        CMPA    MAXDRV
        BHI     DLUP2
*
* A valid selection for a format option, so now
* find this entry in the table.
*
        CLRB            *which entry we're at
        LDX     #FORMATS
CLOOP   CBA             *at right entry?
        BEQ     CFND    *yes
        INCB
        PSHA            *save desired entry
        INX             *skip track & sector
CLP2    INX
        LDAA    0,X     *get description byte
        BNE     CLP2    *not at end yet
        INX             *move to next entry
        PULA            *restore desired entry
        BRA     CLOOP
*
* At the right entry, so clear A and return the
* pointer to this entry in X.
*
CFND    CLRA            *indicates found entry
*
* Exit with the code in A and maybe X.
*
DLGUD   RTS
*
*=====================================================
* This builds the System Information Record given a
* pointer to the disk information.  Also prompts the
* user for things they can set.
*
BLDSIR  LDX     #SIRSEC
        JSR     CLRBUF  *make sure it's all zeroes
        LDX     DSKPTR  *pointer to the drive info
        LDAA    0,X     *sectors per track
        LDAB    1,X     *tracks on disk
        DECB            *track numbers are zero based
*
* This is done out of order.  Since we've got the
* tracks/sectors, put them where needed in the SIR.
*
        STAB    LUTRK
        STAA    LUSEC
        STAB    MAXTRK
        STAA    MAXSEC
*
        LDAA    #1
        STAA    FUTRK   *track 1 is always first
        STAA    FUSEC   *sector 1 is always first
*
* Now compute the number of usable sectors.
* This is the number of tracks minus one, times
* the number of sectors per track.  Track 0 is
* not available for user data, so that's why it
* isn't counted.
*
* Fortunately this is an 8 bit number multiplied
* by another 8 bit number, so I just borrowed
* code from the web:
*
*    http://cse.yeditepe.edu.tr/~esin/Courses/ics232/FULLshort.pdf
*
        STAB    TEMPX   *just use 8 bits of it
        CLRA            *MSB of result
        CLRB            *LSB of result
        LDX     #8      *multiply 8 bits
BLSFT   ASLB            *shift product left one bit
        ROLA
        ASL     TEMPX   *shift to get next bit
        BCC     BLDEC   *branch if a zero bit
        ADDB    MAXSEC  *else add in sectors
        ADCA    #0
BLDEC   DEX
        BNE     BLSFT   *branch if another bit
        STAA    TOTSECS *MSB of total sectors
        STAB    TOTSECS+1 *LSB
*
* Now move the date over from FLEX.
*
        LDAA    DATE
        STAA    CREDATE
        LDAA    DATE+1
        STAA    CREDATE+1
        LDAA    DATE+2
        STAA    CREDATE+2
*
* All the easy stuff is done, so now we've got
* to prompt the user for three things:
*
*   Name of the file
*   Volume name
*   Volume number
*
        LDX     #VLABMSG *prompt for volume name
        JSR     PUTS
        JSR     INBUFF
        LDX     #LINEBUF
        STX     SPTR
        LDX     #VLABEL
        STX     DPTR
        LDAB    #11
        JSR     MOVSTR
*
        LDX     #VNUMMSG
        JSR     PUTS
        JSR     INBUFF
        JSR     INDEC
        STX     VNUMBER
*
* Get the filename.  If they press ENTER without a
* filename, then indicate not to format.
*
        LDX     #FNMSG
        JSR     PUTS
        JSR     INBUFF
        LDX     #LINEBUF
        LDAA    0,X     *first char
        CMPA    #CR     *empty line?
        BEQ     BLDBAD  *yes
        STX     SPTR
        LDX     #FILNAM
        STX     DPTR
        LDAB    #8
        JSR     MOVSTR
*
        CLC
        RTS
*
BLDBAD  SEC
        RTS
*
*=====================================================
* This loads the boot sector and the "not bootable"
* sector into memory from two files.  If either file
* is not present, this gives an error message and
* returns C set.  If both loaded, they are copied to
* their appropriate buffer and quietly returns C clear.
*
LOADFIL LDX     #BOOTSEC
        JSR     CLRBUF  *clear the buffer
        LDX     #BUT2SEC
        JSR     CLRBUF
*
* The file is a binary file on disk, including the
* segment headers, transfer address, etc, but we 
* need a raw binary format for the booter to load,
* so read the binary file into a different buffer
* for now.
*
        LDX     #SECTOR *temporary buffer
        STX     DPTR    *set up pointer to buffer
        LDX     #BTNAME *boot sector file
        JSR     RDFILE  *read it in
        BCC     LD2     *loaded successfully
*
* Missing the boot sector file, give an error
*
        LDX     #MFILE1
        JSR     PSTRNG
*
* Now transfer the raw image into the real buffer
*
LD2     LDX     #BOOTSEC
        STX     DPTR
        LDX     #SECTOR
LD22    LDAA    0,X     *segment type
        CMPA    #2      *code?
        BEQ     LD2C    *yes
        CMPA    #$16    *transfer address?
        BEQ     LD2T
        INX
        BNE     LD22
*
* It's a code segment.  Next two bytes are the
* address, followed by a one byte length.
*
LD2C    INX             *skip to MSB of address
        INX             *skip to LSB of address
        LDAA    0,X     *get LSB
        STAA    DPTR+1  *where to copy to
        INX             *move to length
        LDAB    0,X     *length of block
        INX             *first byte of data
        STX     SPTR    *source
        JSR     MOVBLK
        LDX     SPTR
        BRA     LD22    *go do next segment
*
* Now try to load the "not bootable" file.
*
LD2T    LDX     #BUT2SEC
*
* Dummy up the link bytes so this is the last sector
* and sector 1 in sequence.
*
        CLR     0,X     *no next track
        INX
        CLR     0,X     *no next sector
        INX
        CLR     0,X     *high byte of sequence number
        LDAA    #1
        INX
        STAA    0,X     *low byte of sequence number
        INX
        STX     DPTR
*
        LDX     #NBNAME *not bootable file
        JSR     RDFILE  *go read it
        BCS     LDER2   *branch if not found
        RTS
*
* Missing the not-bootable file, show error
*
LDER2   LDX     #MFILE2
        JMP     PSTRNG
*
*=====================================================
* Given a pointer to a filename in X, this loads one
* sector of that file into the buffer pointed to by
* DPTR, closes the file, and returns C clear if all
* all went well.  Returns C set on error.
*
RDFILE  LDAB    #NBNAME-BTNAME *size of filename
        STX     SPTR    *save source pointer
        LDX     DPTR    *need to save this pointer
        STX     TEMPX
        LDX     #FCB+4  *where to copy to
        STX     DPTR
        JSR     MOVBLK
        LDX     TEMPX
        STX     DPTR
*
* FCB is set up, so do the open
*
        LDX     #FCB
        LDAA    #1      *OPEN function
        STAA    0,X
        JSR     FMS     *do the open
        BEQ     RDOK    *no error
*
* Got an error.  No need to close the file.
*
        SEC             *indicates an error
        RTS
*
* File opened successfully
*
RDOK    LDX     #FCB
        LDAA    #$FF    *no compression flag
        STAA    59,X
*
* Now read in the file until EOF.  We're
* counting on the fact that the file is not
* too large to fit into a buffer.
*
        LDX     #FCB
        LDAA    #0      *read next byte function code
        STAA    0,X
RDLUP   LDX     #FCB
        JSR     FMS
        BNE     RDER3   *assume end of file
        LDX     DPTR
        STAA    0,X
        INX
        STX     DPTR
        BRA     RDLUP   *do next byte
*
RDER3   LDAA    #4      *CLOSE function
        STAA    0,X
        JSR     FMS
*
        CLC             *indicate no error
        RTS
*
*=====================================================
* This opens a raw file on the SD drive.  On entry,
* the filename is in FILNAM.  This appends a ".DSK"
* and then attempts to open the file for writing.
* Returns C clear if file is open, C set if not.
*
* Note that this does no checking to make sure the
* file doesn't already exist.  Ie, you could call
* this with the name of a mounted drive and this will
* still attempt to open it.  Ouch!
*
RAWOPEN JSR     PSETWRI *make sure we're in write mode
        LDAA    #CWRIFIL *command to write a file
        JSR     PWRITE  *send command
*
* Now send the filename.  The name ends with a 
* null but does not have a .DSK added, so we'll
* do that manually.
*
        LDX     #FILNAM
        JSR     SNDTXT  *let another function do it
        LDX     #DSKEXT
        JSR     SNDTXT  *send extension
        CLRA
        JSR     PWRITE  *send terminating null
*
* Now get the response
*
RAWGR   JSR     PSETREA *go back to receive mode
        JSR     PREAD   *get response
        CMPA    #RACK   *hopefully an ACK?
        BEQ     SNDG    *yes!
*
* Assume this is a NAK.  Get the error code.
*
        JSR     PREAD   *get error code
        LDX     #OPNERR *error message
        JSR     PSTRNG
        JSR     PSETWRI
        SEC
        RTS
*
SNDG    JSR     PSETWRI
        CLC
        RTS
*
*=====================================================
* Given a pointer to a 256 byte block of data, write
* the data to the currently open file.  Returns C
* clear if success, C set if not.
*
RAWRITE JSR     PSETWRI *be paranoid; set write
        LDAA    #CWRIBYT *command to write a block
        JSR     PWRITE
*
        CLRA            *byte count 0 (256 bytes)
        JSR     PWRITE
*
* Now write 256 bytes
*
        CLRB            *byte counter
RWRL1   LDAA    0,X
        JSR     PWRITE
        INX
        DECB
        BNE     RWRL1
        BRA     RAWGR   *common handler
*
*=====================================================
* This closes the open file.  This does not check to
* see if a file is open or not.
*
RAWCLOS JSR     PSETWRI
        LDAA    #CDONE
        JSR     PWRITE
        RTS
*
*=====================================================
* Given a pointer to a null-terminated string in X,
* send it to the Arduino.
*
SNDTXT  LDAA    0,X     *next character
        BEQ     SNDX
        JSR     PWRITE  *send it
        INX
        BRA     SNDTXT
SNDX    RTS
*
        LIB     NEWDISK2.TXT
        LIB     NEWDISK3.TXT
*

        END     NEWDISK
