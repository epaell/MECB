*================================================
* MOUNT is a program used with the Corsham Tech SD
* card to mount, unmount, and list mounted drives
* from a FLEX program.
*
* You'll no doubt notice a lot of subroutines
* rather than in-line code.  30+ years of high
* level programming has greatly influenced how
* my assembly code is structured.
*
* 06/15/2015 - Bob Applegate, K2UT
*              bob@corshamtech.com
*
* 10/31/2015 - Bob Applegate, version 1
*              Added the D command and also added
*              command line argument processing.
*
* Version of the MOUNT utility
*
VERSION EQU     1
*
* ASCII constants
*
NUL     EQU     $00
EOT     EQU     $04
BS      EQU     $08
LF      EQU     $0A
CR      EQU     $0D
SPACE   EQU     $20
*
        LIB     SDLIB.INC
        LIB     FLEX.INC
*================================================
        ORG     $A100
MOUNT0  BRA     MOUNT1   *skip over version
*
        FCB     VERSION
*
MOUNT1  LDAA    LSTTRM   *get next char on command line
        CMPA    #CR
        BEQ     VDOMENU
        CMPA    #LF
        BEQ     VDOMENU
*
* They supplied parameters on the command line.
*
CMDLIN  JSR     NXTCH   ;get next character
        CMPA    #CR
        BEQ     EXIT2   ;end of command line
        PSHA
        LDX     #CRMSG
        JSR     PUTS
        PULA
*
* Valid commands:
*    D          - directory of DSK files
*    L          - list mounted drives
*    Ux         - unmount drive x
*    MxFFFFFFFF - mount file FFFFFFFF to drive x
*
        CMPA    #'D
        BEQ     CLDIR
        CMPA    #'L
        BEQ     CLLIST
        CMPA    #'M
        BEQ     CLMOUNT
        CMPA    #'U
        BEQ     CLUNMNT
*
* Bad command.  Issue an error and exit.
*
        LDX     #ERRMSG
        JSR     PUTS
        BRA     EXIT2
*
* All done, so exit back to FLEX
*
EXIT1   LDX     #EXITMSG
        JSR     PUTS
EXIT2   JMP     WARMS
*
VDOMENU BRA     DOMENU
*
* Command handlers
*
CLLIST  JSR     LDRIVES
        BRA     EXIT2
*
CLDIR   JSR     DIRECT
        BRA     EXIT2
*
CLMOUNT JSR     NXTCH
        JSR     CHKDRV
        BCS     BADCD   ;branch if drive not valid
        PSHA            ;save drive number
        JSR     DUNMNT  ;unmount existing drive
        PULA            ;get back drive number
        LDX     LBPTR   ;get pointer to command line
        JSR     MNTDRV  ;go mount the drive
        BRA     EXIT2
*
CLUNMNT JSR     NXTCH
        JSR     CHKDRV
        BCS     BADCD   *branch if drive not valid
        JSR     DUNMNT  ;unmount it
        BRA     EXIT2
*
BADCD   LDX     #BADDMSG
        JSR     PUTS
        BRA     EXIT2
*
* Do the interactive version.  Present a menu,
* get requests, do actions, etc.
*
DOMENU  LDX     #WELMSG
        JSR     PSTRNG
PRMENU  LDX     #MENUMSG
        JSR     PSTRNG
GETCMD  JSR     GETKEY
        CMPA    #'X     *exit
        BEQ     EXIT1
        CMPA    #'D     *disk directory
        BEQ     DODIR
        CMPA    #'L     *list mounted files
        BEQ     DOLIST
        CMPA    #'U     *unmount a drive
        BEQ     DOUNMNT
        CMPA    #'M     *mount a drive
        BEQ     DOMOUNT
        BRA     GETCMD
*
*================================================
* Handles the D command.
*
DODIR   LDX     #DIRMSG
        JSR     PUTS
        JSR     DIRECT
        BRA     PRMENU
*
*================================================
* Handles the L command from the user interface.
*
DOLIST  LDX     #LISTMSG
        JSR     PUTS
        JSR     LDRIVES *do the actual work
        BRA     PRMENU
*
*================================================
* Handles the U command to unmount a drive.  The
* initial prompt asks for a drive number.
*
DOUNMNT LDX     #UNMSG
        JSR     PUTS
        JSR     GETDRV  *get drive number
        CMPA    #CR     *abort?
        BEQ     DOUN2   *yeah, do nothing.
        JSR     DUNMNT  *unmount it
DOUN2   JSR     PCRLF
        JMP     PRMENU
DOUN3   PULA
        BRA     DOUN2
*
*================================================
* Mount a drive.  Query the user for the drive
* number and filename.
*
DOMOUNT LDX     #MNTMSG
        JSR     PUTS
        JSR     GETDRV  *get drive to mount
        CMPA    #CR     *they want to abort?
        BEQ     DOUN2   *yes, get out
        PSHA
        LDX     #FNAMMSG
        JSR     PUTS    *ask for filename to mount
        JSR     INBUFF  *get line
*
* See if they entered anything.  If not, just
* exit.
*
        LDAA    LINEBUF *not the right way to do this
        CMPA    #CR
        BEQ     DOUN3
*
* Start by unmounting the drive just to be sure.
*
        PULA
        PSHA
        JSR     DUNMNT
        PULA            ;restore drive number
        LDX     #LINEBUF ;pointer to filename
        JSR     MNTDRV
        JMP     DOUN2
*
*================================================
* Get and display the list of mounted drives.
*
LDRIVES JSR     GETMDRV *get list of drives
        LDX     #DINFO0
        JSR     DISPDRV
        LDX     #DINFO1
        JSR     DISPDRV
        LDX     #DINFO2
        JSR     DISPDRV
        LDX     #DINFO3
        JSR     DISPDRV
        RTS
*
*================================================
* Display a list of DSK files on the drive.
*
DIRECT  JSR     DDIR
DIR2    LDX     #DUMMY
        JSR     DDIRNXT
        BCS     DDIREND ;branch if end reached
*
* Have an entry, see if it ends with .DSK
* Future consideration: should we also not report
* filenames with "~" in them?  Those are mangled
* names so they fit in 8.3 format.
*
        LDX     #DUMMY
DIR3    LDAA    0,X
        BEQ     DIR2    ;end of string
        INX
        CMPA    #'.     ;start of extension?
        BNE     DIR3
        LDAA    0,X
        CMPA    #'D
        BNE     DIR2
        LDAA    1,X
        CMPA    #'S
        BNE     DIR2
        LDAA    2,X
        CMPA    #'K
        BNE     DIR2
*
* Display the filename
*
        LDAA    #SPACE
        JSR     PUTCHR
        JSR     PUTCHR
        LDX     #DUMMY
        JSR     PUTS
        LDX     #CRMSG
        JSR     PUTS
        BRA     DIR2    ;get next entry
DDIREND RTS
*
*================================================
* This mounts a drive.  On entry, A contains a
* drive number from 0 to 3, and X points to the
* full filename to mount, including the
* DSK extension.
*
MNTDRV  PSHA            *save drive
        STX     TEMPX   *save pointer to filename
MNTD1   LDAA    0,X     *get next character of filename
        CMPA    #CR
        BEQ     MNTD2
        INX
        BRA     MNTD1
*
MNTD2   CLR     0,X     *terminate the name
        CLRB            *assume it is not read-only
        PULA            *restore drive number
        LDX     TEMPX   *get back filename ptr
        JSR     DMOUNT  *do the mount
        BCC     MNTD3   *branch if no error
*
* Failed to mount.  Error code is in A.  Need
* to add text showing the error code.
*
        LDX     #FAILMSG
        JSR     PUTS
*
MNTD3   RTS
*
*================================================
* This gets a drive number OR a carriage return.
* The number must be from 0 to 3.  This echoes
* a valid drive number.  Returns 0 to 3 (binary)
* in A or a CR ($0d).
*
GETDRV  JSR     GETKEY  *get their selection
        CMPA    #CR     *carriage return?
        BEQ     GETDR2
        CMPA    #'0-1
        BLS     GETDRV  *loop if a bad drive number
        CMPA    #'3
        BHI     GETDRV
*
* A valid drive number, in ASCII, is in A.
*
        PSHA
        JSR     PUTCHR
        PULA
        SUBA    #'0     *convert to binary
GETDR2  RTS
*
*================================================
* Given an ASCII character in A, determine if it
* is a valid drive number ('0' to '3').  If so,
* return a value from 0 to 3 in A and clear
* carry.  Else, A remains as-is and carry is set.
*
CHKDRV  CMPA    #'0-1   *lower bound
        BLS     CHKBAD
        CMPA    #'3
        BHI     CHKBAD
        SUBA    #'0     *convert to number
        CLC
        RTS
CHKBAD  SEC
        RTS
*
*================================================
* This gets one key from the user, erases it so
* it doesn't appear, and then returns it in A.
*
GETKEY  JSR     GETCHR  *get the character
        PSHA
        LDAA    #BS     *and now erase it
        JSR     PUTCHR
        LDAA    #SPACE
        JSR     PUTCHR
        LDAA    #BS
        JSR     PUTCHR
        PULA
        RTS
*
*================================================
* Given a pointer to a string in X, print the
* string until either an EOT ($04) or NULL ($00).
*
PUTS    LDAA    0,X
        BEQ     PUTSDUN
        CMPA    #EOT
        BEQ     PUTSDUN
        JSR     PUTCHR
        INX
        BRA     PUTS
PUTSDUN RTS
*
*================================================
* This asks the Arduino for a list of mounted
* drives and populates a table with the data.
* This always gets data for exactly four drives.
* Technically, this should wait until the
* Arduino indicates the end of the list, but
* this works for now.
*
* Assume all registers are destroyed.
*
GETMDRV JSR     DGETMNT *ask for mounted drive list
        LDX     #DINFO0 *where to place drive 0
        JSR     DNXTMNT *get info
        LDX     #DINFO1 *drive 1
        JSR     DNXTMNT
        LDX     #DINFO2 *drive 2
        JSR     DNXTMNT
        LDX     #DINFO3 *drive 3
        JSR     DNXTMNT
*
* Ask for one more, but this will be the end
* of the list.
*
        LDX     #DUMMY
        JSR     DNXTMNT
        RTS
*
*================================================
* Given a pointer to drive information in X,
* print out the information in a pretty format.
*
DISPDRV STX     TEMPX   ;save X for now
        LDAA    #SPACE
        JSR     PUTCHR
        JSR     PUTCHR
        LDX     TEMPX   *restore pointer to data
*
        LDAA    0,X     *the drive number
        ORAA    #'0     *make ASCII digit
        JSR     PUTCHR
*
        LDAA    #SPACE
        JSR     PUTCHR
        LDAA    #'=
        JSR     PUTCHR
        LDAA    #SPACE
        JSR     PUTCHR
*
* Skip over the read-only flag, then print the
* filename.
*
        INX             *skip drive number
        INX             *skip read-only flag
DDLOOP  LDAA    0,X     *char of filename
        BEQ     DDDONE  *branch if end
        JSR     PUTCHR
        INX
        BRA     DDLOOP
*
DDDONE  JSR     PCRLF
        RTS
*
*================================================
* Text strings
*
WELMSG  FCB     CR,LF,CR,LF
        FCC     'MOUNT version '
        FCB     VERSION+'0
        FCB     CR,LF,EOT
*
MENUMSG FCB     CR,LF
        FCC     'Options:'
        FCB     CR,LF,CR,LF
        FCC     '   D = Directory of DSK files'
        FCB     CR,LF
        FCC     '   L = List mounted drives'
        FCB     CR,LF
        FCC     '   M = Mount drive'
        FCB     CR,LF
        FCC     '   U = Unmount drive'
        FCB     CR,LF
        FCC     '   X = Exit back to FLEX'
        FCB     CR,LF,CR,LF
        FCC     'Enter your command: '
        FCB     EOT
*
DIRMSG  FCC     "Directory"
        FCB     CR,LF,CR,LF,EOT
*
LISTMSG FCC     "List"
        FCB     CR,LF,CR,LF,EOT
*
UNMSG   FCC     "Unmount"
        FCB     CR,LF,CR,LF
        FCC     "Enter drive number to unmount "
        FCC     "(0-3) or Enter to cancel: "
        FCB     EOT
*
EXITMSG FCC     "Exit"
        FCB     CR,LF,CR,LF,EOT
*
MNTMSG  FCC     "Mount"
        FCB     CR,LF,CR,LF
        FCC     "Enter drive number to mount "
        FCC     "(0-3) or Enter to cancel: "
        FCB     EOT
*
FNAMMSG FCB     CR,LF
        FCC     "Enter filename to mount: "
        FCB     EOT
*
FAILMSG FCB     CR,LF,CR,LF
        FCC     "Failed to mount the drive.  "
        FCB     CR,LF,EOT
*
ERRMSG  FCB     CR,LF,CR,LF
        FCC     "Unknown command.  "
        FCC     "D, L, M and U are valid."
CRMSG   FCB     CR,LF,EOT
*
BADDMSG FCC     "Illegal drive number"
        FCB     CR,LF,EOT
*
*================================================
* This is where the data about the four mounted
* drives is stored.  The first byte is the drive
* number (zero based).  Next is the read-only
* flag (zero or not).  Next are up to 12 ASCII
* characters of the filename, then terminated
* with a NULL.
*
DINFO0  RMB     16
DINFO1  RMB     16
DINFO2  RMB     16
DINFO3  RMB     16
DUMMY   RMB     16      ;not used
*
* Misc storage
*
TEMPX   RMB     2

        END     MOUNT0
