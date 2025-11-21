               include  'mecb.inc'
               include  'tutor.inc'
               include  'library_rom.inc'
;
               org      $4000
;
CR             equ      $0d
LF             equ      $0a
EOT            equ      $04
RESET          equ      $03               ; Master reset for ACIA
CONTROL        equ      $51               ; Control settings for ACIA
;
BUFFER_SIZE equ      255
;
start       move.l   #RAM_END+1,a7        ; Set up stack
;
            bsr      intro
            bsr      dump_flash_info      ; Summary information relating to FLASH
            move.l   a0,flash_attr        ; Check if info is valid
            cmp.l    #0,a0
            beq      main_end             ; No, exit

            jsr      SDParInit            ; Set up SD card interface
            jsr      SDDiskPing
;
            lea.l    FLIBNAME(pc),a0      ; Point to the library binary
            move.l   #16384/128,d3        ; Number of 128-byte chunks to read
            bsr      read_file
;
            bsr      sector_erase
            bsr      chip_write
;
main_end    move.b   #TUTOR,d7
            trap     #14
;
; Intro
;
intro          movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
               move.b   #OUT1CR,d7           ; Sector erase
               move.l   #MSG_INTRO,a5
               move.l   #MSG_INTROE,a6
               trap     #14
intro_exit     movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
;
dump_flash_info
               movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
               move.l   #EX_ROM1_BASE,d0     ; Point to the eROM
               jsr      flash_swid           ; Get the FLASH swid->d1, attribute pointer->a0
               move.w   d1,flash_mfr_id
               move.l   a0,flash_attr
               cmp.l    #0,a0
               beq      dump_flash_info1
;
               move.b   #OUTPUT,d7           ; Write the manufacturer ID to the terminal
               move.l   #MSG_MFR_ID,a5
               move.l   #MSG_MFR_IDE,a6
               trap     #14

               move.b   #PNT2HX,d7
               move.l   #text_buffer,a6
               move.b   flash_mfr_id,d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #text_buffer,a5
               trap     #14
               
               move.b   #OUTPUT,d7           ; Write the chip ID to the terminal
               move.l   #MSG_CHIP_ID,a5
               move.l   #MSG_CHIP_IDE,a6
               trap     #14

               move.b   #PNT2HX,d7
               move.l   #text_buffer,a6
               move.b   flash_mfr_id+1,d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #text_buffer,a5
               trap     #14

               move.b   #OUTPUT,d7           ; Write the device name to the terminal
               move.l   #MSG_DEVICE,a5
               move.l   #MSG_DEVICEE,a6
               trap     #14

               move.b   #OUT1CR,d7
               move.l   flash_attr,a0
               lea      1(a0),a5             ; Start of device name
               lea      12(a0),a6            ; End of device name
               trap     #14

               move.b   #OUTPUT,d7           ; Write the chip capacity to the terminal
               move.l   #MSG_CAPACITY,a5
               move.l   #MSG_CAPACITYE,a6
               trap     #14
;
               move.b   #PNT8HX,d7
               move.l   #text_buffer,a6
               move.l   flash_attr,a0
               move.l   12(a0),d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #text_buffer,a5
               trap     #14
               bra      dump_flash_info2     ; return
;
dump_flash_info1
               move.l   #MSG_PROT,a5         ; Device/Manufacturer unknown or write protected
               move.l   #MSG_PROTE,a6
               move.b   #OUT1CR,d7
               trap     #14
;
dump_flash_info2
               movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
read_file   jsr      SDDiskOpenRead       ; Open for read
            bcs      ropen_fail           ; Check for error
;
read_loop   move.l   #buffer,a0           ; Read bytes into buffer
read_loop1  move.l   #128,d0              ; Number of bytes to read
            jsr      SDDiskRead           ; Do the read
            bcs      read_done            ; Check for EoF
            sub.l    #1,d3                ; decrement the number of 128 byte chunks remaining
            beq      read_done            ; if no more left then return
            move.b   #'.',d0              ; write a progress dot
            move.l   a0,-(a7)
            move.b   #OUTCH,d7            ; output byte to terminal
            trap     #14
            move.l   (a7)+,a0
            bra      read_loop1

ropen_fail  move.l   d0,-(a7)
            move.b   #OUTPUT,d7           ; Display an error
            move.l   #MS_OPENERR,a5
            move.l   #MS_OPENERRE,a6
            trap     #14
            move.l   (a7)+,d0
            
            move.b   #PNT2HX,d7           ; Add the error code
            move.l   #text_buffer,a6
            trap     #14
;
            move.b   #OUT1CR,d7           ; Output
            move.l   #text_buffer,a5
            trap     #14
;
read_done   move.b   #$0d,d0
            move.b   #OUTCH,d7            ; output byte to terminal
            trap     #14
            move.b   #$0a,d0
            move.b   #OUTCH,d7            ; output byte to terminal
            trap     #14
            jsr      SDDiskClose          ; Close the file
            rts
;
;
; Erase Lower FLASH ROM sector by sector
;
sector_erase   movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
;
               move.b   #OUT1CR,d7           ; Sector erase
               move.l   #MSG_SEC_ERASE,a5
               move.l   #MSG_SEC_ERASEE,a6
               trap     #14
;
               move.l   #EX_ROM1_BASE,d0           ; Point to the expansion FLASH ROM
               move.l   #EX_ROM1_BASE,a1           ; sector to erase
               move.l   #EX_ROM1_BASE+$4000,a2     ; end of expansion FLASH ROM
sector_erase1  jsr      flash_erase                ; if successful a1 is bumped to next sector
               bne      sector_erase2
               cmp.l    a2,a1                      ; check if reached end
               blo      sector_erase1              ; if not, continue erasing
;
               move.b   #OUT1CR,d7                 ; Sector erase succeeded
               move.l   #MSG_ERASE_OK,a5
               move.l   #MSG_ERASE_OKE,a6
               trap     #14
               
               bra      sector_erase3
;
sector_erase2  move.b   #OUT1CR,d7                 ; Sector erase failed
               move.l   #MSG_ERASE_NOK,a5
               move.l   #MSG_ERASE_NOKE,a6
               trap     #14
;
sector_erase3  movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
; Write data back to FLASH ROM
;
chip_write     movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
               move.b   #OUT1CR,d7           ; Write message
               move.l   #MSG_WRITE,a5
               move.l   #MSG_WRITEE,a6
               trap     #14
               
               move.l   #EX_ROM1_BASE,a0     ; destination for FLASH ROM write
               move.l   #EX_ROM1_BASE+$4000,a2    ; end address
; Sector buffer has data, write to ROM
               move.l   a0,a4                ; temporarily keep this value for printing
               movem.l  d0-d3/a0,-(a7)
               move.b   #OUTPUT,d7
               move.l   #MSG_WR_ADDR,a5
               move.l   #MSG_WR_ADDRE,a6
               trap     #14
;
               move.b   #PNT6HX,d7
               move.l   #text_buffer,a6
               move.l   a4,d0
               trap     #14
;
               move.b   #OUT1CR,d7
               move.l   #text_buffer,a5
               trap     #14
               movem.l  (a7)+,d0-d3/a0
;
               move.l   #EX_ROM1_BASE,d0
               move.l   #buffer,a1
               move.l   #16384,d2            ; number of bytes to transfer (4096 * 4)
               jsr      flash_wbytes         ; a0 should have next location to write to
               bne      chip_write3
;
               move.b   #OUT1CR,d7           ; Chip write succeeded
               move.l   #MSG_WRITE_OK,a5
               move.l   #MSG_WRITE_OKE,a6
               trap     #14
               bra      write_exit
;
chip_write3    move.b   #OUT1CR,d7           ; Chip write failed
               move.l   #MSG_WRITE_NOK,a5
               move.l   #MSG_WRITE_NOKE,a6
               trap     #14
               
write_exit     movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts


;
; dir - display directory of SD card contents
;
dir         move.b   #OUT1CR,d7           ; Write message
            move.l   #MS_DIR,a5
            move.l   #MS_DIRE,a6
            trap     #14
;
            jsr      SDDiskDir            ; Initiate directory function
            bcs      dir_error
dir_loop    move.l   #text_buffer,a0           ; Point to buffer
            jsr      SDDiskDirNext        ; Get next entry
            bcs      dir_done             ; If it was the last entry then exit
;
            move.b   #OUT1CR,D7           ; Write the file name
            move.l   #text_buffer,a5
            move.l   a0,a6
            trap     #14
;
            bra      dir_loop             ; Loop back for more
;
dir_error   move.b   #OUT1CR,d7
            move.l   #MS_ERROR1,a5
            move.l   #MS_ERROR1E,a6
            trap     #14
;
dir_done    rts

;
; File to test open on non-existant file (read)
;
FLIBNAME    dc.b     'EXROMLIB.BIN',$00
;
MSG_INTRO   dc.b     'Checking for FLASH ROM'
MSG_INTROE  equ      *
;
MS_RTCERR   dc.b     "RTC Error Code: $"
MS_RTCERRE
;
MS_OPENERR  dc.b     "File Open Error Code: "
MS_OPENERRE
;
MS_DIR      dc.b     "SD Card directory:"
MS_DIRE
;
MS_ERROR1   dc.b     "Failed  directory."
MS_ERROR1E
;
MS_ERROR2   dc.b     "Failed to mount."
MS_ERROR2E
;
MSG_SEND       dc.b     'Sending codes',CR,LF
MSG_SENDE
MSG_MFR_ID     dc.b     'Manufacturer ID: $'
MSG_MFR_IDE
MSG_CHIP_ID    dc.b     'Chip ID: $'
MSG_CHIP_IDE
MSG_PROT       dc.b     'Unknown Device or write-protected'
MSG_PROTE      equ      *
MSG_DEVICE     dc.b     'Device: '
MSG_DEVICEE    equ      *
MSG_CAPACITY   dc.b     'Capacity (bytes): $'
MSG_CAPACITYE  equ      *
;
MSG_SEC_ERASE  dc.b     'Erasing lower FLASH ROM sectors'
MSG_SEC_ERASEE equ     *
MSG_ERASE_OK   dc.b     'Sector erase of lower FLASH ROM succeeded'
MSG_ERASE_OKE  equ     *
MSG_ERASE_NOK  dc.b     'Sector erase of lower FLASH ROM failed'
MSG_ERASE_NOKE equ     *
MSG_WRITE      dc.b     'Writing to FLASH ROM'
MSG_WRITEE     equ     *
MSG_WRITE_OK   dc.b     'Writing to FLASH ROM succeeded'
MSG_WRITE_OKE  equ     *
MSG_WRITE_NOK  dc.b     'Writing to FLASH ROM failed'
MSG_WRITE_NOKE equ     *
MSG_WR_ADDR    dc.b     'Writing to address: $'
MSG_WR_ADDRE   equ      *

;
; Buffer for directory and file load
;
               align    2
flash_attr     ds.l     1
flash_mfr_id   ds.w     1
               align    2
text_buffer    ds.b     128
buffer         equ      *
;
