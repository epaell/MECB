* Drive, name, and extension of the boot record and
* the not-bootable record.
*
BTNAME  FCC     "BOOTSEC"
        FCB     0       *pad out name to 8 bytes
        FCC     "BIN"   *must be three bytes
*
NBNAME  FCC     "NOBOOT"
        FCB     0,0
        FCC     "BIN"
*
DSKEXT  FCC     ".DSK"
        FCB     0
*
*=====================================================
* Disk format tables.  Each entry has the following:
* 
*    Number of sectors per track (1 byte)
*    Number of tracks (1 byte)
*    Description of the format (variable sized)
*
* If you want to add your own format, you need to
* add THREE things:
*
*   Disk parameters (sectors, track)
*   Description (ASCII text)
*   A zero to terminate the description.
*
* I spent a fair amount of time writing fancy logic
* to dynamically print the options so it would be
* easy to add/remove/modify entries.  Please don't
* hack up the main code when it's so much easier to
* just tweak antries here.
*
* Oh, there can be NO MORE THAN 10 ENTRIES!!!
*
FORMATS
        FCB     10,34
        FCC     "88K"
        FCB     0
*
        FCB     32,32
        FCC     "256K"
        FCB     0
*
        FCB     26,76
        FCC     "500k"
        FCB     0
*
        FCB     72,79
        FCC     "1.4 MB"
        FCB     0
*
* This marks the end of the table.
*
        FCB     0
*
*=====================================================
* Strings
*
HELLO   FCB     CR,LF
        FCC     "NEWDISK for SD card system, version "
        FCB     VERSION+'0
        FCB     CR,LF,EOT
*
BYEMSG  FCC     "Exit"
        FCB     CR,LF,CR,LF,EOT
*
MENUMSG FCB     CR,LF
        FCC     "Your options:"
        FCB     CR,LF,CR,LF
        FCC     "   X = Exit"
        FCB     CR,LF,EOT
*
PROMPT  FCB     CR,LF
        FCC     "Your choice: "
        FCB     EOT
*
VLABMSG FCB     CR,LF
        FCC     "Enter the label for the disk (11 chars max): "
        FCB     EOT
*
VNUMMSG FCB     CR,LF
        FCC     "Enter the volume number (0-65535): "
        FCB     EOT
*
FMTMSG  FCC     "Format a disk: "
        FCB     EOT
*
FNMSG   FCB     CR,LF
        FCC     "Enter filename, no extension, "
        FCC     "8 chars max: "
        FCB     EOT
*
MFILE1  FCC     "Missing file: BOOTSEC.BIN"
        FCB     CR,LF,EOT
*
MFILE2  FCC     "Missing file: NOBOOT.BIN"
        FCB     CR,LF,EOT
*
OPNERR  FCC     "Error opening output file"
        FCB     CR,LF,EOT
*
TRKPROG FCB     CR,LF
        FCC     "Formatting tracks"
        FCB     EOT
*
*=====================================================
* Data storage
*
* I moved the data down low in RAM so as not to tie
* up limited space in the transient program area.
*
* The code assumes some of the buffers are at a
* page boundary (ie, address xx00) so I've done
* that here.  All of the sector buffers are first
* since they are all exactly 256 bytes long.
*
        ORG     $1000
*
* This is the track 0, sector 0 (boot sector) buffer.
* It gets loaded with the boot sector data.
*
BOOTSEC RMB     SECSIZE
*
* This is the secondary boot sector (track 0, sector
* 2).
*
BUT2SEC RMB     SECSIZE
*
* This is the System Information Record (SIR) record.
* It contains useful data, so give it a buffer.
*
SIRSEC  RMB     16      *unused
VLABEL  RMB     11
VNUMBER RMB     2
FUTRK   RMB     1       *first user track
FUSEC   RMB     1       *first user sector
LUTRK   RMB     1       *last user track
LUSEC   RMB     1       *last user sector
TOTSECS RMB     2       *total sectors
CREDATE RMB     3       *creation date (m, d, y)
MAXTRK  RMB     1       *highest track number
MAXSEC  RMB     1       *number of sectors per track
ENDSIR  EQU     *
SIRSIZE EQU     ENDSIR-SIRSEC
        RMB     256-SIRSIZE
*
* The general sector used for everything else.
*
SECTOR  RMB     SECSIZE
*
* The number of drives in drive table
*
MAXDRV  RMB     1
*
* Temp storage of X
*
TEMPX   RMB     2
*
* Source and desination pointers for block moves
*
SPTR    RMB     2
DPTR    RMB     2
*
* Pointer to the disk entry the user chose.
*
DSKPTR  RMB     2
*
* Holds filename
*
FILNAM  RMB     20
*
* Used to indicate completion of an operation
*
DUNFLAG RMB     1
*
