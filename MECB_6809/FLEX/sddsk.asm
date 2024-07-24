*=====================================================
* Disk drivers for the Corsham Technologies SD card
* system.
* 
* Written fall of 2014 and spring/summer of 2015 by
* Bob Applegate K2UT, bob@corshamtech.com
*
* Converted to 6809 FLEX 11/27/2015
*
* The 6809 version also contains console drivers.
*====================================================
*
* ASCII constants
*
EOT             EQU     $04
LF              EQU     $0A
CR              EQU     $0D
*
        LIB     FLEX.INC
        LIB     SDLIB.INC
*
MONITOR EQU     $F800   *SBUG cold entry point
*
*=====================================================
* This is the start of the actual driver.
*
* Vectors first.  "What's our vector, Victor?"
*
        ORG     $D3E5   *start of console vectors
        FDB     INNECH  *input without echo
        FDB     IHND    *IRQ handler
        FDB     $F800   *SWI3 vector - read-only location
        FDB     $F800   *IRQ vector - read only
        FDB     TOFF    *timer off
        FDB     TON     *timer on
        FDB     TINT    *timer init
        FDB     MONITOR *monitor entry point
        FDB     TINIT   *console init
        FDB     STATUS  *console status
        FDB     OUTPUT  *output character
        FDB     INPUT   *input char with echo
*
* Console definitions.  This should eventualy be
* removed once the STATUS function is moved to the
* SBUG version.
*
ACIA    EQU     $E010   *slot 1
*
*=====================================================
* Console driver functions.  Most of them just call
* SBUG functions.
*
        ORG     $D370
TINIT   RTS             *SBUG already initialized it
INNECH  JMP     [$F804]
INPUT   BSR     INNECH
OUTPUT  JMP     [$F80A]
STATUS  PSHS    A
        LDA     ACIA
        ANDA    #1
        PULS    A
        RTS
*
* No timer for now
*
TINT
TON
TOFF    RTS
IHND    RTI
*
*=====================================================
* Disk function vectors
*
        ORG     $DE00
        JMP     READ    * Read sector
        JMP     WRITE   * Write sector
        JMP     VERIFY  * Verify last write
        JMP     RESTOR  * Seek to track 0
        JMP     DRVSEL  * Select drive to use
        JMP     CHECK   * Check if drive is ready
        JMP     CHECK   * Quick check
        JMP     INIT    *cold start
        JMP     WARM    *warm start
        JMP     SEEK    *seek to track
*       ORG     $BEB3
*
* The FCB for accessing the low level disk functions.
*
LFCB    EQU     *
FCBDRV  FCB     0       ;Drive 0
FCBTRK  FCB     0       ;Track 0
FCBSEC  FCB     0       * Sector 0
FCBSPT  FCB     0       * Sectors per track
FCBPTR  FDB     0       * Buffer address
*
*=====================================================
* Cold start
*
INIT    RTS
*
*=====================================================
* Warm start
*
WARM    RTS
*
*====================================================
* READ
* Entry: (X)  Address where data is to be placed
*        (A) = Track umber
*        (B) = Sector Number
* The sector referencedby the track and sector
* number is to be read into the Sector Buffer
* area of the idicated FCB.
*
READ    STAA    FCBTRK
        STAB    FCBSEC
        STX     FCBPTR
        LDX     #LFCB
        JSR     DSECRD
        BCS     DISKERR * Handle errors
*
* See if we just read the SIR, and grab the
* sectors-per-track value if so.
*
        LDAA    FCBTRK
        BNE     RETGOOD * Not track zero
        LDAA    FCBSEC
        CMPA    #3      * SIR sector?
        BNE     RETGOOD * branch if not
*
* We just read the SIR so grab the sectors
* per track from offset $27.
*
        LDX     FCBPTR  * pointer to buffer
        LDAA    $27,X
        STAA    FCBSPT  * Update FCB
*
* Now update the table for this drive for
* future reference
*
        LDAA    FCBDRV
        BSR     GETSECT
        LDAA    FCBSPT
        STAA    0,X
*
* Common return point when there are no errors.
* C clear, Z set, and B contains 0 indicating no
* 1771 FDC errors.
*
RETGOOD CLRB
        RTS
*
* This is a common error return point.  C set,
* Z clear, and B will contain a "record not
* found" error code.
*
DISKERR LDAB    #$08
        SEC
        RTS
*
*=====================================================
* WRITE
* Entry: (X) = Address of data o be written
*        (A) = Track Number
*        (B) = Sector Number
*
* Exit:  (B) = Error condition(1771 status register)
*        (Z) = set if no error, clear on error
*        (C) = clear if no eror, set if error
*
WRITE   STAA    FCBTRK
        STAB    FCBSEC
        STX     FCBPTR
        LDX     #LFCB
        JSR     DSECWR
        BCS     DISKERR
*
* See if this is the SIR and update the
* sectors-per-track value if it is.
*
        LDAA    FCBTRK
        BNE     RETGOOD  * Not track zero
        LDAA    FCBSEC
        CMPA    #3       * SIR sector?
        BNE     RETGOOD  * no
*
* Update table with the number of sectors
* per track
*
        LDAA    FCBDRV
        BSR     GETSECT
        LDAA    FCBSPT
        STAA    0,X      * update table
        BRA     RETGOOD
*
*=====================================================
* VERIFY
* Entry - (No parameters)
* The sector just written isto be verified to
* determine if there are CRC errors.
*
* There are no error that weren't reported
* already, so just return a good value.
*
VERIFY  CLRB
        RTS
*
*=====================================================
* RESTORE
* Entry - (X) = FCB Addess
* Exit -  CC, NE, &B=$B if write protected
*         CS, NE, &B=$F if no drive
* A Restore Operation (also known as a Seek
* to Track 00) is o be performed on the
* drive whose number is in the FCB.
*
* Given that the SD card has no heads to move, this
* this always returns immediately without errors.
*
RESTOR  CLRB
        RTS
*
*=====================================================
* DRIVE SELECT
* Entry - (X) = FCB Address
* The drive whose number is in the FCB is
* to be selected
*
* This also updates the FCB with the number of
* sectors per track.
*
DRVSEL  LDAA    3,X     * get the drive
        STAA    FCBDRV
        BSR     GETSECT
        LDAA    0,X
        STAA    FCBSPT
        CLRB
        RTS
*
*=====================================================
* CHECK DRIVE READY
* Entry - (X) = CB Address
* Exit -  NE & CS if drive no ready
*         EQ & CS if drive ready
*
CHECK   LDAA    3,X     * get the drive
        CMPA    #3      * There are only four drives
        BLS     RETGOOD
        LDAB    $80     * "drive notready"
        SEC
        RTS
*
*=====================================================
* SEEK
*
SEEK    CLRB
        RTS
*
*=====================================================
* The driver needs to keep track of how many sectors
* per track on a per-drive basis.  This codeis called
* with a drive (0-3) in A and will return X pointing
* to the memory location containing the sectors per
* track for that drive.
*
* The values here are updaed whenever the SIR is read
* in the read sector routine or written in the sector
* write routine.  Values are taken from here
* whenever a new drive is selected.
*
GETSECT LDX     #SECTRK-1
GETSE2  INX
        DECA
        BPL     GETSE2
        RTS
*
* These are the entries for the number of sectors
* per track.  The drive number is the index.
*
SECTRK  FCB     0,0,0,0
*
* Set the transfer address to the start of FLEX.
*
        END     $CD00

