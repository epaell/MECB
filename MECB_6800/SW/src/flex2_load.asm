; The SIR needs to be read in order for the tracks/sector information to work.
; startup.txt calls date - I think this expects the RTC hardware.


         include  "mecb.inc"
         include  "libfujinet.inc"
         include  "DigiBug.inc"
         include  "aciaio.inc"
;
DEBUG    equ   1                 ; 0 for no debug, 1 for I/O debug, 2 for detailed load debugging
;
STACK    equ   $a07f
READ     equ   $be80
DRIVE    equ   $be8c
INIT     equ   $be95
SCTBUF   equ   $a300             ; Data sector buffer
; SCTBUF + 0 = trk
; SCTBUF + 1 = dct
; SCTBUF + 2 = ?
; SCTBUF + 3 = drive

;
; Start of utility

         org   $a100
;
qload    lds   #STACK          ; Set up the stack
         bra   load0
;
         fcb   $00,$00,$00
trk      fcb   $00             ; track
sct      fcb   $00             ; sector
dns      fcb   $00             ; Density flag
tadr     fdb   $ad00           ; Transfer address
ladr     fdb   $0000           ; Load address
sbfptr   fdb   $0000           ; Sector buffer pointer
;
load0    
         jsr   finit           ; Initialise Fujinet

         ldx   #stmount
         jsr   print
         
         ldb   #0
         jsr   fujinet_mount_all    ; Mount the host slot
         cmpa  #FUJINET_RC_OK       ; Check if OK
         beq   load0a
         jmp   load_err             ; if not, report error
load0a:
         ldx   #stboot
         jsr   print
         bra   load0b
;
stmount: fcb   CR,LF,"Mounting disks",CR,LF,EOT
stboot:  fcb   "Booting FLEX 6800 ",EOT
sterr:   fcb   CR,LF,"Error encountered",CR,LF,EOT
;
load0b:
         ldx   #SCTBUF         ; Point to FCB
         clr   3,X             ; Set for drive 0
         jsr   DRIVE           ; Select drive 0
         ldx   #SCTBUF         ; Point to FCB
         lda   #$00            ; Read the SIR (track 0, sector 3 = logical sector 3)
         ldb   #$03
         jsr   READ            ; This will update the sectors/track for the drive
         ldx   #SCTBUF         ; Point to buffer in which to read data
         lda   #$00            ; Read the boot sector (track 0, sector 0 = logical sector 0)
         ldb   #$00
         jsr   READ
         ldx   #SCTBUF         ; Point to buffer in which to read data
         lda   5,x             ; get the track/sector from which to start loading
         ldb   6,x
;         lda   #$02            ; Force load starting from this track and sector if needed
;         ldb   #36
         sta   SCTBUF
         stb   SCTBUF+1
         ldx   #SCTBUF+256     ; Force a read of the sector
         stx   sbfptr
;
; Perform actual file load
;
load1    jsr   getch           ; Get a character
         cmpa  #$02            ; Data record header?
         beq   load2           ; Skip if so
         cmpa  #$16            ; XFR address header?
         bne   load1           ; Loop if neither
         jsr   getch           ; Get transfer address
         sta   tadr
         jsr   getch
         sta   tadr+1
         bra   load1           ; Continue load
load2    jsr   getch           ; Get load address
         sta   ladr
         jsr   getch
         sta   ladr+1
         jsr   getch           ; Get byte count
         tab                   ; Put in B
         beq   load1           ; Loop if count=0
;
load3    pshb
         jsr   getch           ; Get a data character
         pulb
         ldx   ladr            ; Get load address in X
; This bit checks to see if overwriting the driver
         sta   ltempa
         stb   ltempb
         lda   ladr
         ldb   ladr+1
         cmpa  #$be
         blo   store           ; OK to store in <$be00
         bne   skip            ; if it's >$bf00 then skip
         cmpb  #$80
         blo   store           ; OK to store in <$be80
         bra   skip            ; otherwise skip
store:   lda   ltempa
         ldb   ltempb
         
         sta   ,x              ; Put character

         if DEBUG>3            ; Dump each byte read from disk and where it goes
         pshb
         psha
         stx   ltempx
         ldx   #read1
         jsr   print
         lda   ltempx
         ldb   ltempx+1
         jsr   out4h
         lda   #' '
         jsr   foutch
         pula
         jsr   out2h
         jsr   pcrlf
         pulb
         ldx   ltempx
         endif

skip:    lda   ltempa
         ldb   ltempb
         inx
         stx   ladr
         decb                  ; End of data in record?
         bne   load3           ; Loop if not
         jmp   load1           ; Get another record
;
; Get character routine - reads a sector if necessary
;
getch2   ldx   #SCTBUF         ; point to buffer
         lda   ,x              ; get forward link (track)
         beq   go              ; if zero, file is loaded
         ldb   1,x             ; else, get the sector
;
         psha
         lda   #'.'
         jsr   foutch
         pula
;
         jsr   READ            ; read next sector
         bne   load_err        ; exit if error
         ldx   #SCTBUF+4       ; point past link
         bra   getch1          ; got get a character
getch    ldx   sbfptr
         cmpx  #SCTBUF+256     ; Out of data?
         beq   getch2          ; Go read character if not
getch1   lda   0,x             ; Else, get a character
         inx
         stx   sbfptr          ; update pointer
         rts
;
load_err:
         ldx   #sterr
         jsr   print
         jmp   CONTRL

; At this point the loader is done
go:
         if DEBUG>3
         jmp   CONTRL          ; Jump to monitor if debugging
         endif
         ldx   #finch          ; Set up initial I/O routines
         stx   $ad0a
         stx   $ad0d
         ldx   #foutch
         stx   $ad10
         stx   $ad13
         jmp   $ad00           ; Start up FLEX
         jmp   CONTRL
         ldx   tadr            ; Jump to transfer address
         jmp   ,x
;
         if DEBUG>3
read1    fcb   "Set transfer address to: $",EOT
         endif
ltempx   rmb   2
ltempa   rmb   1
ltempb   rmb   1
;
         org   $be80
;
; Disk driver jump table for FLEX 6800
; Must be in area from $be80 to $be9d for FLEX 6800
;
         jmp   fread    ; read a single sector
         jmp   fwrite   ; write a single sector
         jmp   fverify  ; verify last sector written
         jmp   frestore ; restore head to track #0
         jmp   fdrive   ; select the specified drive
         jmp   fchkrdy  ; check for drive ready
         jmp   fchkrdy  ; quick check for drive ready
;
curdrv   rmb   1        ; Last drive
         rmb   1
xtemp    rmb   2
lsttrk   rmb   1        ; Last track
;
         org   $bea3
;
; Console I/O driver vector table for FLEX 6800
;
         fdb   finch    ; input character with echo
         fdb   foutch   ; output character
         fdb   ACIA     ; base of ACIA
         fdb   PTM      ; timer board base
         fdb   $F800    ; IRQ vector location
         fdb   $F800    ; SWI3 vector location
         fdb   CONTRL   ; monitor entry address
         fdb   $F800    ; Monitor PC location
;
;
; Can use memory above $c000-$ceff

         org   $c000

; Read a character from the terminal, no echo
; Entry: -
; Exit: A - character read from terminal
; 
finche:  lda    ACIA             ; get port status
         bita   #1               ; test ready bit, rdrf?
         beq    finche           ; if not ready, try again
         lda    ACIA+1           ; read the character
         rts
; Read a character from the terminal, echo
finch:
         bsr   finche            ; Fall through to output

; Output character to terminal
; entry: a - character to be transmitted
; exit: -
foutch:  psha
fetsta:  lda   ACIA              ; fetch port status
         bita  #2                ; test tdre, OK to transmit?
         beq   fetsta            ; if not look until ready
         pula                    ; restore character for transmit
         sta   ACIA+1            ; transmit character
         rts
;
fstat:   psha
         lda   ACIA
         anda  #1
         pula
         rts

ftmint:
ftmon:
ftmoff:
ftinit:
         rts
fihndlr:
         rts

;====================================================
; READ
; Entry: x - address where data is to be placed
;        a - track number
;        b - sector number
; The sector referenced by the track and sector
; number is to be read into the sector buffer
; area of the indicated FCB.
;
fread:
         sta   fcbtrk            ; Store values in FCB
         stb   fcbsec
         stx   fcbptr

         ;  The following is additional outputs for troubleshooting and is not needed
         if DEBUG>3
         psha
         pshb
         stx   debugx
         ldx   #read2a
         jsr   print
         lda   fcbtrk
         jsr   out2h
         ldx   #read2b
         jsr   print
         lda   fcbsec
         jsr   out2h
         jsr   pcrlf
         ldx   debugx
         pulb
         pula
         endif

         jsr   getlsec           ; Convert to logical sector
         sta   fcblsec           ; save the logical sector
         stb   fcblsec+1 
         ldx   #fujinet_dcb
         sta   DCB_AUX2,x        ; Store the logical sector MSB
         stb   DCB_AUX1,x        ; Store the logical sector LSB
         ldb   fcbdrv
         incb
         jsr   fujinet_disk_read
         cmpa  #FUJINET_RC_OK    ; Check if OK
         beq   fread1
         jmp   diskerr           ; if not, report error

; Copy data read to destination
fread1:
         ldx   fcbptr            ; set up destination pointer
         stx   destptr
         ldx   #rxdata           ; assume copying first half of sector to destination
         tst   fcbfirsthalf      ; check if working on first half of sector
         beq   fread2            ; if so, copy to destination
         ldx   #rxdata+256       ; otherwise, copying second half of sector to destination
fread2:
         clrb                    ; copy 256-byte sector to destination
rcopy:   lda   ,x                ; read a value
         inx                     ; update and store source pointer
         stx   srcptr
         ldx   destptr           ; get the destination pointer
         sta   ,x                ; write the value
         inx                     ; update and store destination pointer
         stx   destptr
         ldx   srcptr            ; restore source pointer
         decb
         bne   rcopy
;
; See if we just read the SIR, and grab the
; sectors-per-track value if so.
;
         lda   fcbtrk
         bne   retgood ; Not track zero
         lda   fcbsec
         cmpa  #2      ; SIR sector (256-byte logical sector 2)?
         bne   retgood ; branch if not
;
; We just read the SIR so grab the sectors
; per track from offset 39.
;
         ldx   fcbptr  ; pointer to buffer
         lda   39,x
         sta   fcbspt  ; update FCB
;
; Now update the table for this drive for
; future reference
;
         lda   fcbdrv
         jsr   getsect
         lda   fcbspt
         sta   ,x
;
; Common return point when there are no errors.
; C clear, Z set, and B contains 0 indicating no
; 1771 FDC errors.
;
retgood  clrb
         rts
;
destptr  rmb   2
srcptr   rmb   2
;
         if DEBUG>3
read2a   fcb   "Reading track: 0x",EOT
read2b   fcb   " sector: 0x",EOT
         endif

;
; This is a common error return point.  C set,
; Z clear, and B will contain a "record not
; found" error code.
;
diskerr: ldb   #$08
         sec
         rts

         
;
;=====================================================
; WRITE
; Entry: x - address of data of be written
;        a - track number
;        b - sector number
;
; Exit:  b = Error condition (1771 status register)
;        z = set if no error, clear on error
;        c = clear if no eror, set if error
;
fwrite:  sta   fcbtrk
         stb   fcbsec
         stx   fcbptr

         if DEBUG>0
         psha
         pshb
         stx   debugx
         ldx   #write2a
         jsr   print
         lda   fcbtrk
         jsr   out2h
         ldx   #write2b
         jsr   print
         lda   fcbsec
         jsr   out2h
         jsr   pcrlf
         ldx   debugx
         pulb
         pula
         endif

         jsr   getlsec           ; Convert to logical sector
         sta   fcblsec           ; save the logical sector
         stb   fcblsec+1
         ldx   #fujinet_dcb
         sta   DCB_AUX2,x        ; Set the logical sector (MSB)
         stb   DCB_AUX1,x        ; Set the logical sector (LSB)
         
         ; Read the full 512-byte sector into the transmit buffer first
         lda   #txdata>>8
         sta   DCB_RX_BUFFER,x   ; read into the transmit buffer
         lda   #txdata&$ff
         sta   DCB_RX_BUFFER+1,x ;
         ldb   fcbdrv            ; get the drive to read
         incb                    ; convert to device slot (start from 1)
         jsr   fujinet_disk_read
         cmpa  #FUJINET_RC_OK    ; Check if OK
         beq   fwrite1
         jmp   diskerr           ; if not, report error
;
fwrite1:
         ldx   #txdata           ; assume working on the first half of the sector
         tst   fcbfirsthalf      ; check if we are working on the first half
         beq   fwrite2
         ldx   #txdata+256       ; working on the second half of the sector
fwrite2:
         stx   destptr           ; save the destination pointer
         ldx   fcbptr            ; get the source pointer
         ldb   #0                ; Copy 256-byte sector
tcopy:   lda   ,x                ; Copy data to DCB
         inx
         stx   srcptr
         ldx   destptr
         sta   ,x
         inx
         stx   destptr
         ldx   srcptr
         decb
         bne   tcopy
;
         ldx   #fujinet_dcb
         lda   #rxdata>>8
         sta   DCB_RX_BUFFER,x   ; restore the receive buffer
         lda   #rxdata&$ff
         sta   DCB_RX_BUFFER+1,x ;
         
         ldb   fcbdrv
         incb                    ; Adjust the drive to align so device=drive+1
         lda   fcblsec
         sta   DCB_AUX2,x
         lda   fcblsec+1
         sta   DCB_AUX1,x
         jsr   fujinet_disk_write
         cmpa  #FUJINET_RC_OK    ; Check if OK
         beq   fwrite3
         jmp   diskerr           ; if not, report error
;
; See if this is the SIR and update the
; sectors-per-track value if it is.
;
fwrite3:
         lda   fcbtrk
         bne   fwgood            ; Not track zero
         lda   fcbsec
         cmpa  #2                ; SIR sector (256-byte logical sector 2)?
         bne   fwgood            ; no
;
; Update table with the number of sectors
; per track
;
         lda   fcbdrv
         jsr   getsect
         lda   fcbspt
         sta   ,x       ; update table
fwgood   jmp   retgood

         if DEBUG>0
write2a  fcb   "Writing track: 0x",EOT
write2b  fcb   " sector: 0x",EOT
         endif

;=====================================================
; VERIFY
; Entry - (No parameters)
; The sector just written isto be verified to
; determine if there are CRC errors.
;
; There are no error that weren't reported
; already, so just return a good value.
;

fverify:
         clrb
         rts

;=====================================================
; RESTORE
; Entry: x - FCB Addess
; Exit -  CC, NE, &B=$B if write protected
;         CS, NE, &B=$F if no drive
; A Restore Operation (also known as a Seek
; to Track 00) is to be performed on the
; drive whose number is in the FCB.
;
; Given that the SD card has no heads to move, this
; this always returns immediately without errors.
;
frestore:
         clrb
         rts

;
;=====================================================
; DRIVE SELECT
; Entry: x - FCB Address
; The drive whose number is in the FCB is
; to be selected
;
; This also updates the FCB with the number of
; sectors per track.
;
fdrive:  lda   3,x      ; get the drive
         sta   fcbdrv
         jsr   getsect
         lda   ,x       ; get the number of sectors per track
         sta   fcbspt
         clrb
         rts

;
;=====================================================
; CHECK DRIVE READY
; Entry: x - FCB Address
; Exit -  NE & CS if drive no ready
;         EQ & CS if drive ready
;
fchkrdy:
         lda   3,x                     ; get the drive
         cmpa  #3                      ; There are only four drives
         bls   fchkretgood
         ldb   $80                     ; "drive not ready"
         sec
         rts
fchkretgood:
         jmp   retgood
         
finit:
         ldx   #fujinet_dcb            ; Set up the receive and transmit buffer in the DCB
         lda   #rxdata>>8
         sta   DCB_RX_BUFFER,x
         lda   #rxdata&$ff
         sta   DCB_RX_BUFFER+1,x
         lda   #txdata>>8
         sta   DCB_TX_BUFFER,x
         lda   #txdata&$ff
         sta   DCB_TX_BUFFER+1,x
         jsr   fujinet_init            ; Initialise the fujinet device
         rts

ierror:
         ldx   #sterror
         jsr   print
         rts

fwarm:
         rts

fseek:
         clrb
         rts
;
;=====================================================
; The driver needs to keep track of how many sectors
; per track on a per-drive basis.  This code is called
; with a drive (0-3) in A and will return X pointing
; to the memory location containing the sectors per
; track for that drive.
;
; The values here are updaed whenever the SIR is read
; in the read sector routine or written in the sector
; write routine.  Values are taken from here
; whenever a new drive is selected.
;
getsect  ldx     #sectrk-1
getse2   inx
         deca
         bpl     getse2
         rts

;
; return logical 512-byte sector based on 256-byte sector, track and sectors per track
; Entry: a = track
;        b = sector
;
; Exit:  d (a+b) = logical sector
getlsec:
         tsta                 ; is it track 0
         bne   getlsec2
         tstb                 ; is it sector 0
         beq   getlsec3
getlsec2:
         decb                 ; make 0-based
getlsec3:
         stb   fcbsec         ; save the sector number
         ldb   fcbspt         ; get the sectors per track
         bsr   mpy16          ; multiply by the track number
         addb  fcbsec         ; add the sector number
         adca  #0
         clr   fcbfirsthalf   ; assume it is the first half sector
         bitb  #$01           ; check which half of the 512-sector to work on
         beq   getlsec4
         inc   fcbfirsthalf   ; actually working on the upper half of the sector
getlsec4:
         lsra                 ; divide the logical number by 2 since there are 2 x 256-byte sectors in each 512-byte sector
         rorb
         rts
;
; 8 x 8-bit multiply
;
; Entry: a - mutiplier
;        b - multiplicand
; Exit:  a (MSB),b (LSB) - resfult
mpy16:   stx   mpyx
         sta   mpya
         stb   mpyb
         clra                 ; product MSB = Zero
         clrb                 ; product LSB = Zero
         ldx   #8             ; load number of bits of the multiplier to index register
mpy16b:  aslb                 ; shift product left 1 bit
         rola
         asl   mpya           ; shift multiplier left to examine next bit
         bcc   mpy16c         ;
         addb  mpyb           ; add multiplicand to the product if carry is 1
         adca  #0             ;
mpy16c:  dex
         bne   mpy16b         ; repeat until index register is 0
         ldx   mpyx
         rts
;
sterror: fcb   "Failed to mount drives",CR,LF,EOT
;
         include "aciaio.asm"
         include  "libfujicmdbase.asm"
         include  "libfujicmddisk.asm"
         include  "libfujinet.asm"
;
mpyx:    rmb   2
mpya:    rmb   1
mpyb:    rmb   1
fltempx: rmb   2
debugx:  rmb   3
;
;
; The FCB for accessing the low level disk functions.
;
lfcb            equ     *
fcbdrv          fcb     0       ; drive 0
fcbtrk          fcb     0       ; track 0
fcbsec          fcb     0       ; sector 0
fcblsec         fdb     0       ; logical sector
fcbspt          fcb     0       ; sectors per track
fcbptr          fdb     0       ; buffer address
fcbfirsthalf    fcb     0       ; zero if 256-byte sector in first half of 512-byte sector
;
sectrk:  fcb   0,0,0,0        ; Sectors per track on per-drive basis (filled when SIR read)
;
fujinet_dcb:
         rmb   1              ; FujiNet device
         rmb   1              ; FujiNet command
         rmb   1              ; Aux1
         rmb   1              ; Aux2
         fdb   txdata         ; pointer to transmit buffer
         rmb   2              ; length of data in bytes
         fdb   rxdata         ; pointer to receive buffer
         rmb   2              ; length of response buffer in bytes
         rmb   2              ; timeout in milliseconds
;
txdata   rmb   512
rxdata   rmb   512
;
