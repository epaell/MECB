         include  'parproto.asm'
;
; Low-level routines to communicate with SD-card interface
;         jmp   SDParInit           ; init parallel interface
;         jmp   SDParSetWrite       ; set for writing
;         jmp   SDParSetRead        ; set for reading
;         jmp   SDParWriteByte      ; write one byte
;         jmp   SDParReadByte       ; read one byte
; Routines to access SD Card files
;         jmp   SDDiskPing          ; exercises the interface
;         jmp   SDDiskOpenRead      ; open file for read
;         jmp   SDDiskOpenWrite     ; open file for write
;         jmp   SDDiskClose         ; close file
;         jmp   SDDiskRead          ; read from file
;         jmp   SDDiskWrite         ; write to file
;         jmp   SDDiskDir           ; start directory query
;         jmp   SDDiskDirNext       ; get next directory entry
; Routines to mount and low-level access to a file system within a SD-card disk image. (Not yet implemented)
;         jmp   SDDiskReadSector    ; read a sector
;         jmp   SDDiskWriteSector   ; write a sector
;         jmp   SDDiskStatus        ; get status
;         jmp   SDDiskGetDrives     ; get the number of drives
;         jmp   SDDiskGetMounted    ; get the mounted drive
;         jmp   SDDiskNextMountedDrv; Get the next mounted drive
;         jmp   SDDiskUnmount       ; Unmount the file system
;         jmp   SDDiskMount         ; Mount a file system
;

;*****************************************************
; These are the low-level I/O routines to talk to the
; Arduino processor connected to a 6821 PIA.
;
; August 2014, Bob Applegate K2UT, bob@corshamtech.com
;
; Modified 08/08/2015 to build for 6809
;
; Which port bits are used for what:
;
; A0 = Data 0, alternates input/output
; A1 = Data 1, alternates input/output
; A2 = Data 2, alternates input/output
; A3 = Data 3, alternates input/output
; A4 = Data 4, alternates input/output
; A5 = Data 5, alternates input/output
; A6 = Data 6, alternates input/output
; A7 = Data 7, alternates input/output
;
; B0 = Direction bit, always output
; B1 = Write strobe or ACK, always output
; B2 = Read stroke or ACK, always input
;
;----------------------------------------------------
; Bits in the B register
;
DIRECTION      equ      0
PSTROBE        equ      1
ACK            equ      2
;
; Number of drives emulated.
;
SDDRIVES       equ     4
;
; This is the address where the first bootloader from
; the SD card is supposed to be loaded.
;
SDBOOT_ADDR    equ     $8000

;----------------------------------------------------
;
;*****************************************************
; This is the initialization function.  Call before
; doing anything else with the parallel port.
;
;
; Set up the data direction register for port B so that
; the DIRECTION and PSTROBE bits are output.
;
SDParInit
                move.b   #$00,PIACTLB         ; select DDR for port B
                move.b   #$03,PIADDRB         ; DIRECTION + PSTROBE bits
                move.b   #$04,PIACTLB         ; select data reg
;
; Fall through to set up for writes...
;
;*****************************************************
; This sets up for writing to the Arduino.  Sets up
; direction registers, drives the direction bit, etc.
;
SDParSetWrite   move.b  #$00,PIACTLA          ; select DDR...for port A
                move.b  #$ff,PIADDRA          ; set bits for output
                move.b  #$04,PIACTLA          ; select data reg
;
; Set direction flag to output, clear ACK bit
;
                move.b  #$01,PIAREGB          ; DIRECTION bit
                rts

;*****************************************************
; This sets up for reading from the Arduino.  Sets up
; direction registers, clears the direction bit, etc.
;
SDParSetRead    move.b  #$00,PIACTLA         ; select DDR for port A
                move.b  #$00,PIADDRA         ; set bits for input
                move.b  #$04,PIACTLA         ; select data reg
;
; Set direction flag to input, clear ACK bit
;
                move.b  #$00,PIAREGB
                rts
;*****************************************************
; This writes a single byte to the Arduino.  On entry,
; the byte to write is in d0.  This assumes ParSetWrite
; was already called.
;
; All registers preserved.
;
; Write cycle:
;
;    1. Wait for other side to lower ACK.
;    2. Put data onto the bus.
;    3. Set DIRECTION and PSTROBE to indicate data
;       is valid and ready to read.
;    4. Wait for ACK line to go high, indicating the
;       other side has read the data.
;    5. Lower PSTROBE.
;    6. Wait for ACK to go low, indicating end of
;       transfer.
;
SDParWriteByte    btst.b   #ACK,PIAREGB      ; check status
                  bne      SDParWriteByte
;
; Now put the data onto the bus
;
                  move.b   d0,PIAREGA
;
; Raise the strobe so the Arduino knows there is
; new data.
;
                  bset.b   #PSTROBE,PIAREGB
;
; Wait for ACK to go high, indicating the Arduino has
; pulled the data and is ready for more.
;
SDParwl33         btst.b   #ACK,PIAREGB      ; check status
                  beq      SDParwl33
;
; Now lower the strobe, then wait for the Arduino to
; lower ACK.
;
                  bclr.b   #PSTROBE,PIAREGB
SDParwl44         btst.b   #ACK,PIAREGB      ; check status
                  bne      SDParwl44
                  rts

;*****************************************************
; This reads a byte from the Arduino and returns it in
; d0.  Assumes ParSetRead was called before.
;
; This does not have a time-out.
;
; Preserves all other registers.
;
; Read cycle:
;
;    1. Wait for other side to raise ACK, indicating
;       data is ready.
;    2. Read data.
;    3. Raise PSTROBE indicating data was read.
;    4. Wait for ACK to go low.
;    5. Lower PSTROBE.
;
SDParReadByte  btst.b   #ACK,PIAREGB      ; is the strobe high?
               beq      SDParReadByte     ; nope, no data
;
; Data is available, so grab and save it.
;
               move.b   PIAREGA,d0
;
; Now raise our strobe (their ACK), then wait for
; them to lower their strobe.
;
               bset.b   #PSTROBE,PIAREGB
SDParrlp1      btst.b   #ACK,PIAREGB
               bne      SDParrlp1         ; still active
;
; Lower our ack, then we're done.
;
               bclr.b   #PSTROBE,PIAREGB
               rts
;
SDBoot
               rts
;
SDDiskReadSector
               rts
SDDiskWriteSector
               rts
SDDiskStatus
               rts
;
;=====================================================
; Get the maximum number of drives supported.  This
; takes no input parameters.  Returns a value in d0
; that is the number of drives supported.  This is a
; one based value, so a return of 4 indicates that four
; drives are supported, 0 to 3.
SDDiskGetDrives
               move.b   #SDDRIVES,d0
               rts
SDDiskGetMounted
               rts
SDDiskNextMountedDrv
               rts

;=====================================================
; Unmount a filesystem.  On entry, d0 contains the
; zero-based drive number.
;
; Returns with C clear on success.  If error, C is set
; and d0 contains the error code.
;
SDDiskUnmount     move.l   d0,-(a7)                ; save drive
                  move.b   #PC_UNMOUNT,d0
                  bsr      SDParWriteByte
                  move.l   (a7)+,d0                ; restore drive
                  bsr      SDParWriteByte
;
; Handy entry point.  This sets the mode to read, gets
; an ACK or NAK, and if a NAK, gets the error code
; and returns it in A.
;
SDComExit         bsr      SDParSetRead            ; get ready for response
                  bsr      SDParReadByte
                  cmp.b    #PR_ACK,d0
                  beq      SDDiskRetGood
;
; Assume it's a NAK.
;
SDDiskRetErrCode  bsr      SDParReadByte           ; get error code
SDDiskRetBad      bsr      SDParSetWrite
                  ori.b    #$01,ccr
                  rts

;=====================================================
; Mount a filesystem.  On entry, d0 contains a zero
; based drive number, d1 is the read-only flag (0 or
; non-zero), and a0 points to a filename to mount on
; that drive.  
;
; Returns with C clear on success.  If error, C is set
; and A contains the error code.
;
SDDiskMount     move.l  d1,-(a7)                ; save read-only flag
                move.l  d0,-(a7)                ; save drive
                move.b  #PC_MOUNT,d0
                bsr     SDParWriteByte          ; send the command
                move.l  (a7)+,d0
                bsr     SDParWriteByte          ; send drive number
                move.l  (a7)+,d0
                bsr     SDParWriteByte          ; send read-only flag
;
; Now send each byte of the filename until the end,
; which is a 0 byte.
;
SDdmnt1         move.b  (a0)+,d0
                beq     SDdmnt2
                bsr     SDParWriteByte
                bra     SDdmnt1
SDdmnt2         bsr     SDParWriteByte          ; send trailing null
                bra     SDComExit

;=====================================================
; This starts a directory read of the raw drive, not
; the mounted drive.  No input parameters.  This simply
; sets up for reading the entries, then the user must
; read each entry.
;
; Returns with C clear on success.  If error, C is set
; and d0 contains the error code.
;
SDDiskDir      move.b  #PC_GET_DIR,d0           ; send command
               bsr     SDParWriteByte
               andi.b  #$fe,ccr                 ; assume it works
               rts

;=====================================================
; Read the next directory entry.  On input, a0 points
; to a XXX byte area to receive the drive data.
; Returns C set if end of directory (ie, attempt to
; read and there are none left).  Else, C is clear
; and a0 points to the null at end of filename.
;
SDDiskDirNext  bsr     SDParSetRead             ; read results
               bsr     SDParReadByte            ; get response code
               cmp.b   #PR_NAK,d0               ; error?
               beq     SDDDNErr
               cmp.b   #PR_DIR_END,d0           ; end?
               beq     SDDDNErr
;
; This contains a directory entry.
;
SDDDNloop      bsr      SDParReadByte
               move.b   d0,(a0)+
               cmp.b    #0,d0	                  ; end of file name?
               bne      SDDDNloop
SDDDNEnd       bsr      SDParSetWrite
               andi.b    #$fe,ccr                 ; not end of files
               rts
;
; Error.  Set C and return.  This is not really
; proper, since this implies a simple end of the
; directory rather than an error.
;
SDDDNErr       bsr      SDParSetWrite
               ori.b     #$01,ccr
               rts

;=====================================================
; This is a sanity check to verify connectivity to the
; Arduino code is working.  Returns C clear if all is
; good, or C set if not.
;
SDDiskPing     move.b   #PC_PING,d0             ; command
               bsr      SDParWriteByte          ; send to Arduino
               bsr      SDParSetRead
               bsr      SDParReadByte           ; read their reply
SDDiskRetGood  bsr      SDParSetWrite
               andi.b   #$fe,ccr                ; assume it's good
               rts

;=====================================================
; This opens a file on the SD for writing.  On entry,
; a0 points to a null-terminated filename to open.
; On return, C is clear if the file is open, or C set
; if an error.
;
; Assumes write mode has been set.  Returns with it set.
;
SDDiskOpenWrite
               move.b   #PC_WRITE_FILE,d0
               bsr      SDParWriteByte
               bra      SDDiskOpen              ; jump into common code

;=====================================================
; This opens a file on the SD for reading.  On entry,
; a0 points to a null-terminated filename to open.  On
; return, C is clear if the file is open, or C set if
; an error (usually means the file does not exist.
;
; Assumes write mode has been set.  Returns with it set.
;
SDDiskOpenRead move.b   #PC_READ_FILE,d0
               bsr      SDParWriteByte
SDDiskOpen     move.b   (a0)+,d0                ; Send file name
               bsr      SDParWriteByte
               tst.b    d0
               bne      SDDiskOpen
               bsr      SDParSetRead            ; get response
               bsr      SDParReadByte
               cmp.b    #PR_ACK,d0
               bne      SDDiskOpenErr
               bsr      SDParSetWrite           ; back to write mode
               andi.b   #$fe,ccr                ; clear carry
               rts
; Handle error
SDDiskOpenErr  bsr      SDParReadByte           ; get error code
               bsr      SDParSetWrite           ; back to write mode
               ori.b    #$01,ccr                ; set carry
               rts

;
;=====================================================
; On entry, d0 contains the number of bytes to read from the file,
; a0 points to the buffer in which to transfer the data.  On return,
; C will be set if EOF was reached (and no data read), or
; C will be clear and d0 contains the number of bytes
; actually read into the buffer.
;
; Modifies A, X and Y.  Also modifies INL and INH
; (00F8 and 00F9).
;
SDDiskRead     move.l   d0,-(a7)                ; Save register
               move.b   #PC_READ_BYTES,d0       ; Command
               bsr      SDParWriteByte
               move.l   (a7)+,d0                ; Restore register
               bsr      SDParWriteByte          ; Number of bytes to read
               bsr      SDParSetRead            ; Get ready for response
               bsr      SDParReadByte           ; Assume PR_FILE_DATA
               bsr      SDParReadByte           ; length
               tst.b    d0
               beq      SDDiskReadEoF           ; zero = EoF
               move.b   d0,d1                   ; d1=length
               move.l   d0,-(a7)                ; save on stack
SDDiskRead1    bsr      SDParReadByte
               move.b   d0,(a0)+
               sub.b    #1,d1
               bne      SDDiskRead1             ; loop back if more to read
               bsr      SDParSetWrite
               move.l   (a7)+,d0                ; Restore count
               andi.b   #$fe,ccr                ; Clear carry
               rts
;
SDDiskReadEoF  bsr      SDParSetWrite
               move.b   #0,d0
               ori.b    #$01,ccr                ; Set carry
               rts
;
;
;=====================================================
; On entry, d0 contains the number of bytes to write
; to the file, a0 points to the buffer where data is
; written from.  On return, C will be set if an error
; was detected, or C will be clear
; if no error.  Note that if d0 contains 0 on entry,
; no bytes are written.
;
SDDiskWrite    tst.b    d0
               beq      SDDiskOk1
               move.b   d0,-(a7)
               move.b   #PC_WRITE_BYTES,d0   ; Command
               bsr      SDParWriteByte
               move.b   (a7)+,d0
               bsr      SDParWriteByte       ; Number of bytes to write
               move.b   d0,d1                ; count
SDDiskWriteLoop
               move.b   (a0)+,d0             ; get a byte
               bsr      SDParWriteByte
               sub.b    #1,d1                ; decrement counter
               bne      SDDiskWriteLoop      ; keep writing until end reached
               bsr      SDParSetRead         ; read the status
               bsr      SDParReadByte
               cmp.b    #PR_ACK,d0
               beq      SDDiskOk1            ; all good
               bsr      SDParReadByte        ; Otherwise read error code
               bsr      SDParSetWrite
               ori.b    #$01,ccr             ; Set carry
               rts
;
SDDiskOk1      bsr      SDParSetWrite
               andi.b   #$fe,ccr             ; Clear carry
               rts
;
;=====================================================
; Call this to close any open file.  No parameters
; and no return status.
;
SDDiskClose    move.b      #PC_DONE,d0
               bsr         SDParWriteByte
               rts
