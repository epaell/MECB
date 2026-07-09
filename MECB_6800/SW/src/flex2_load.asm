; The SIR needs to be read in order for the tracks/sector information to work.
; startup.txt calls date - I think this expects the RTC hardware.


         include  "mecb.inc"
         include  "libfujinet.inc"
         include  "DigiBug.inc"
         include  "aciaio.inc"
;
DEBUG    equ   0                 ; 0 for no debug, 1 for I/O debug, 2 for detailed load debugging
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
;
; Jump table for FujiNet library
;
lfujinet_reset                            jmp   fujinet_reset
lfujinet_dcb_exec                         jmp   fujinet_dcb_exec
lfn_perror                                jmp   fn_perror
lfujinet_mount_all                        jmp   fujinet_mount_all
lfujinet_mount_host                       jmp   fujinet_mount_host
lfujinet_read_host_slots                  jmp   fujinet_read_host_slots
lfujinet_read_device_slots                jmp   fujinet_read_device_slots
lfujinet_random_number                    jmp   fujinet_random_number
lfujinet_get_time                         jmp   fujinet_get_time
lfujinet_open_directory                   jmp   fujinet_open_directory
lfujinet_read_dir_entry                   jmp   fujinet_read_dir_entry
lfujinet_close_directory                  jmp   fujinet_close_directory
lfujinet_set_directory_position           jmp   fujinet_set_directory_position
lfujinet_get_directory_position           jmp   fujinet_get_directory_position
lfujinet_write_appkey                     jmp   fujinet_write_appkey
lfujinet_read_appkey                      jmp   fujinet_read_appkey
lfujinet_open_appkey                      jmp   fujinet_open_appkey
lfujinet_close_appkey                     jmp   fujinet_close_appkey

lfujinet_device_create_new                jmp   fujinet_device_create_new
lfujinet_device_disable_device            jmp   fujinet_device_disable_device
lfujinet_device_enable_device             jmp   fujinet_device_enable_device
lfujinet_device_get_adapter_config        jmp   fujinet_device_get_adapter_config
lfujinet_device_get_device_enabled_status jmp   fujinet_device_get_device_enabled_status
lfujinet_device_get_device_filename       jmp   fujinet_device_get_device_filename
lfujinet_write_device_slots               jmp   fujinet_write_device_slots
lfujinet_write_host_slots                 jmp   fujinet_write_host_slots
lfujinet_device_set_boot_config           jmp   fujinet_device_set_boot_config
lfujinet_device_set_device_filename       jmp   fujinet_device_set_device_filename
lfujinet_logical_device_type              jmp   fujinet_logical_device_type
lfujinet_logical_device_unit              jmp   fujinet_logical_device_unit
lfujinet_logical_device_url               jmp   fujinet_logical_device_url
lfujinet_mount_image                      jmp   fujinet_mount_image
lfujinet_disk_read                        jmp   fujinet_disk_read
lfujinet_unmount_image                    jmp   fujinet_unmount_image
lfujinet_disk_get_sector_size             jmp   fujinet_disk_get_sector_size
lfujinet_disk_write                       jmp   fujinet_disk_write

lfujinet_file_open                        jmp   fujinet_file_open
lfujinet_file_read                        jmp   fujinet_file_read
lfujinet_file_status                      jmp   fujinet_file_status
lfujinet_file_write                       jmp   fujinet_file_write
lfujinet_file_close                       jmp   fujinet_file_close

lfujinet_network_open                     jmp   fujinet_network_open
lfujinet_network_read                     jmp   fujinet_network_read
lfujinet_network_status                   jmp   fujinet_network_status
lfujinet_network_write                    jmp   fujinet_network_write
lfujinet_network_close                    jmp   fujinet_network_close
lfujinet_network_channel_mode             jmp   fujinet_network_channel_mode
lfujinet_network_json_parse               jmp   fujinet_network_json_parse
lfujinet_network_json_query               jmp   fujinet_network_json_query
lfujinet_network_login                    jmp   fujinet_network_login

lfujinet_modem_read                       jmp   fujinet_modem_read
lfujinet_modem_status                     jmp   fujinet_modem_status
lfujinet_modem_stream                     jmp   fujinet_modem_stream
lfujinet_modem_write                      jmp   fujinet_modem_write

lfujinet_printer_stream                   jmp   fujinet_printer_stream
lfujinet_printer_write                    jmp   fujinet_printer_write

lfujinet_scan_for_networks                jmp   fujinet_scan_for_networks
lfujinet_get_scan_result                  jmp   fujinet_get_scan_result
lfujinet_get_ssid                         jmp   fujinet_get_ssid
lfujinet_get_wifi_status                  jmp   fujinet_get_wifi_status
lfujinet_set_ssid                         jmp   fujinet_set_ssid
lfujinet_get_wifi_enabled                 jmp   fujinet_get_wifi_enabled

lfujinet_new_disk                         jmp   fujinet_new_disk
lfujinet_set_host_prefix                  jmp   fujinet_set_host_prefix
lfujinet_get_host_prefix                  jmp   fujinet_get_host_prefix
lfujinet_copy_file                        jmp   fujinet_copy_file
lfujinet_set_boot_mode                    jmp   fujinet_set_boot_mode
lfujinet_status                           jmp   fujinet_status
lfujinet_get_adapterconfig_extended       jmp   fujinet_get_adapterconfig_extended
lfujinet_generate_guid                    jmp   fujinet_generate_guid
lfujinet_set_status                       jmp   fujinet_set_status
lfujinet_unmount_host                     jmp   fujinet_unmount_host

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
         lda   fcbptr            ; Point the receive buffer to where the data will go
         sta   DCB_RX_BUFFER,x
         lda   fcbptr+1
         sta   DCB_RX_BUFFER+1,x
         ldb   fcbdrv
         incb
         jsr   fujinet_disk_read
         cmpa  #FUJINET_RC_OK    ; Check if OK
         beq   fread1
         jmp   diskerr           ; if not, report error

;
; See if we just read the SIR, and grab the
; sectors-per-track value if so.
;
fread1:
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
         lda   fcbptr
         sta   DCB_TX_BUFFER,x   ; Point the transmit buffer to the source
         lda   fcbptr+1
         sta   DCB_TX_BUFFER+1,x
         ldb   fcbdrv
         incb                    ; Adjust the drive to align so device=drive+1
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
         clra
         sta   DCB_RX_BUFFER,x
         sta   DCB_RX_BUFFER+1,x
         sta   DCB_TX_BUFFER,x
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
; return logical sector based on 256-byte sector, track and sectors per track
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
         include  "libfujicmd.asm"
         include  "libfujierr.asm"
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
;
sectrk:  fcb   0,0,0,0        ; Sectors per track on per-drive basis (filled when SIR read)
;
fujinet_dcb:
         rmb   1              ; FujiNet device
         rmb   1              ; FujiNet command
         rmb   1              ; Aux1
         rmb   1              ; Aux2
         fdb   0              ; pointer to transmit buffer
         rmb   2              ; length of data in bytes
         fdb   0              ; pointer to receive buffer
         rmb   2              ; length of response buffer in bytes
         rmb   2              ; timeout in milliseconds
;
