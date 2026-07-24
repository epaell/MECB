               cpu      68008
;
               include  "mecb.inc"
               include  "tutor.inc"
               include  "libfujinet.inc"
;
               org      $4000
;
; *** BUFFER_LEN must be an integer multiple of 4096 (the smallest FLASH ROM section that can be erased) ***
; *** To ensure this, BUFFER_SECTORS must be some multiple of 32 (32 * SECTOR_SIZE = 4096)
FLASH_SECTOR_SIZE          equ   4096                          ; Size of FLASH ROM sector size
BUFFER_LEN                 equ   16*FLASH_SECTOR_SIZE
BUFFER_SECTORS             equ   BUFFER_LEN/DISK_SECTOR_SIZE   ; Number of disk sectors within a buffer
ROM_SIZE                   equ   512*1024                      ; Size of FLASH ROM
BUFFERS_PER_ROM            equ   ROM_SIZE/BUFFER_LEN           ; Number of buffer chunks needed to process entire FLASH ROM
;
; ==================================================
; Firmware update utility
;
; Mounts 'firmware.rom' - 512 KB binary containing new ROM contents
; Reads 64 KB chunks into memory
; Flashes each chunk into the system ROM
; Returns to tutor monitor
;
start          move.l   #RAM_END+1,a7        ; Set up stack
;
               bsr      intro
               bsr      dump_flash_info      ; Summary information relating to FLASH
               move.l   flash_attr,a0        ; Check if info is valid
               cmp.l    #0,a0
               beq      main_end             ; No, exit
;
               move.l   #fujinet_dcb,a0
               jsr      fujinet_mount_all    ; Mount the host slot
               cmp.b    #FUJINET_RC_OK,d0    ; Check if OK
               bne      mount_fail           ; if not, report error

               move.l   #0,d1                ; d0 - contains current buffer chunk to read/erase/write
               move.l   #ROM_BASE,a0         ; Start at the beginning of the ROM
; ********* COMMENT THESE TWO LINES IF AN UPDATE OF TUTOR/ENHANCED BASIC IS REQUIRED ********
               add.l    #1,d1                ; Avoid over-writing Tutor
               add.l    #BUFFER_LEN,a0       ; Shift the ROM position accordingly
; ******* COMMENT THE ABOVE TWO LINES IF AN UPDATE OF TUTOR/ENHANCED BASIC IS REQUIRED ******
; WARNING : If the tutor section of ROM fails to updated correctly then the system will become unusable
;           and a manual reprogramming of the ROM will be needed.
write_loop:
               bsr      read_buffer          ; read a buffer load from disk
               cmp.b    #FUJINET_RC_OK,d0    ; check for an error
               bne      read_error           ; abort if can't read data
               bsr      erase_flash_section  ; Erase the current section of ROM being processed
               bsr      chip_write_buffer
               add.l    #BUFFER_LEN,a0       ; Work on next section
               add.w    #1,d1
               cmp.w    #BUFFERS_PER_ROM,d1  ; have all chunks been processed?
               blo      write_loop           ; if not, loop until done
;
main_end       move.b   #TUTOR,d7
               trap     #14
;
read_error:    move.l   #MSG_READ_ERROR,a0   ; Report that a read error occurred
               jsr      print
               bra      main_end             ; exit
;
mount_fail:    move.l   #MSG_MOUNT_FAIL,a0   ; Report that mount failed
               jsr      print
               bra      main_end
;
; read_buffer
; d1 is the current buffer chunk to read - with 128 byte sectors = 512 reads, start LSN = d0*512
;
read_buffer    movem.l  d1-d3/a0-a2,-(a7)    ; save registers

               movem.l  a0,-(a7)
               move.l   #MSG_READ,a0         ; Read
               jsr      print
               movem.l  (a7)+,a0

               move.l   #buffer,a2           ; a2 points to the current buffer read location
               move.l   #fujinet_dcb,a0      ; a0 points to the DCB
               mulu     #BUFFER_SECTORS,d1   ; determine the start LSN based on the current buffer section being processed
               move.l   d1,d3                ; d3 contains the current LSN to read
               move.l   #BUFFER_SECTORS-1,d2 ; the number of sectors to read in order to fill the buffer (=512-1)
read_buffer1:
               move.b   #0,d1                ; Set up the drive
               move.l   a2,DCB_RX_BUFFER(a0) ; set up where to store the sector
               move.l   #0,DCB_TX_BUFFER(a0) ; Set up receive and transmit buffers
               move.l   d3,d0
               jsr      fujinet_disk_read    ; Read the disk
               cmp.b    #FUJINET_RC_OK,d0
               bne      read_buffer_exit
               add.l    #DISK_SECTOR_SIZE,a2 ; point to next location to read
               add.l    #1,d3                ; move to next sector
               dbra     d2,read_buffer1      ; keep reading until buffer is full
read_buffer_exit:               
               movem.l  (a7)+,d1-d3/a0-a2    ; restore registers
               rts
;
;
; Intro
;
intro          movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
               move.b   #OUT1CR,d7           ; Sector erase
               move.l   #MSG_INTRO,a0
               jsr      print
intro_exit     movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
;
dump_flash_info
               movem.l  d0-d7/a1-a6,-(a7)    ; Save registers
               move.l   #ROM_BASE,d0         ; Point to the main ROM
               jsr      flash_swid           ; Get the FLASH swid->d1, attribute pointer->a0
               move.w   d1,flash_mfr_id
               move.l   a0,flash_attr
               cmp.l    #0,a0
               beq      dump_flash_info1
;
               move.l   #MSG_MFR_ID,a0       ; Write the manufacturer ID to the terminal
               jsr      print

               move.b   flash_mfr_id,d0
               jsr      out2h
               jsr      pcrlf

               move.l   #MSG_CHIP_ID,a0      ; Write the chip ID to the terminal
               jsr      print

               move.b   flash_mfr_id+1,d0
               jsr      out2h
               jsr      pcrlf

               move.l   #MSG_DEVICE,a0       ; Write the device name to the terminal
               jsr      print

               move.l   flash_attr,a0
               add.l    #1,a0
               move.l   #text_buffer,a1
               move.l   #12,d0
               jsr      strncpy
               move.b   #EOT,(a1)+
               move.l   #text_buffer,a0
               jsr      print
               jsr      pcrlf

               move.l   #MSG_CAPACITY,a0     ; Write the chip capacity to the terminal
               jsr      print
;
               move.l   flash_attr,a0
               move.l   12(a0),d0            ; Get the chip capacity
               jsr      out8h
               jsr      pcrlf
               bra      dump_flash_info2     ; return
;
dump_flash_info1
               move.l   #MSG_PROT,a0         ; Device/Manufacturer unknown or write protected
               jsr      print
;
dump_flash_info2
               movem.l  (a7)+,d0-d7/a1-a6    ; Restore registers
               rts
;
; Library part of FLASH ROM sector by sector
; a0 - is the address of the buffer chunk of the FLASH ROM being processed
;
erase_flash_section:
               movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
;
               movem.l  a0,-(a7)
               move.l   #MSG_SEC_ERASE,a0    ; Sector erase
               jsr      print
               movem.l  (a7)+,a0
;
               move.l   #ROM_BASE,d0         ; Point to the FLASH ROM
               move.l   a0,a1                ; a1 points to the current FLASH ROM sector to be erased
               move.l   a1,a2
               add.l    #BUFFER_LEN,a2       ; End is the start location + buffer length
erase_flash_rom1:
               jsr      flash_erase          ; if successful a1 is bumped to next sector
               bne      erase_flash_rom_error
               cmp.l    a2,a1                ; check if reached end
               blo      erase_flash_rom1     ; if not, continue erasing
;
               move.l   #MSG_ERASE_OK,a0
               jsr      print
               
               bra      erase_flash_rom_exit
;
erase_flash_rom_error:
               move.l   #MSG_ERASE_NOK,a0
               jsr      print
;
erase_flash_rom_exit:
               movem.l  (a7)+,d0-d7/a0-a6          ; Restore registers
               rts
;
; Write current data buffer contents to FLASH ROM
; a0 - is the address of the buffer chunk of the FLASH ROM being processed
;
chip_write_buffer:
               movem.l  d0-d7/a0-a6,-(a7)          ; Save registers

               movem.l  a0,-(a7)
               move.l   #MSG_WRITE,a0
               jsr      print
               movem.l  (a7)+,a0
               
; Sector buffer has data, write to ROM
               move.l   a0,a4                      ; temporarily keep this value for printing
               movem.l  d0/a0/a4,-(a7)
               move.l   #MSG_WR_ADDR,a0
               jsr      print
;
               move.l   a4,d0
               jsr      out6h
               jsr      pcrlf
;
               movem.l  (a7)+,d0/a0/a4
;
               move.l   #ROM_BASE,d0         ; base address of the ROM to update
               move.l   #BUFFER_LEN,d2       ; number of bytes to transfer
               move.l   #buffer,a1           ; location to transfer from
               jsr      flash_wbytes         ; a0 should have next location to write to
               bne      chip_write_buffer1
;
               move.l   #MSG_WRITE_OK,a0     ; Chip write succeeded
               jsr      print
               bra      chip_write_buffer_exit
;
chip_write_buffer1:
               move.l   #MSG_WRITE_NOK,a0    ; Chip write failed
               jsr      print
               
chip_write_buffer_exit:
               movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
               include  "flash.asm"
               include  "aciaio.asm"
               include  "libfujinet.asm"
               include  "libfujicmd.asm"
;
MSG_INTRO      dc.b     'Checking for FLASH ROM',CR,LF,EOT
MSG_MFR_ID     dc.b     'Manufacturer ID: $',EOT
MSG_CHIP_ID    dc.b     'Chip ID: $',EOT
MSG_PROT       dc.b     'Unknown Device or write-protected',CR,LF,EOT
MSG_DEVICE     dc.b     'Device: ',EOT
MSG_CAPACITY   dc.b     'Capacity (bytes): $',EOT
MSG_READ_ERROR dc.b     'Error reading FIRMWARE.ROM',CR,LF,EOT
MSG_MOUNT_FAIL dc.b     'Failed to mount disks',CR,LF,EOT
;
MSG_READ       dc.b     'Reading part of FIRMWARE.ROM into buffer',CR,LF,EOT
MSG_SEC_ERASE  dc.b     'Erasing FLASH ROM sectors',CR,LF,EOT
MSG_ERASE_OK   dc.b     'Sector erase of FLASH ROM succeeded',CR,LF,EOT
MSG_ERASE_NOK  dc.b     'Sector erase of FLASH ROM failed',CR,LF,EOT
MSG_WRITE      dc.b     'Writing to FLASH ROM',CR,LF,EOT
MSG_WRITE_OK   dc.b     'Writing to FLASH ROM succeeded',CR,LF,EOT
MSG_WRITE_NOK  dc.b     'Writing to FLASH ROM failed',CR,LF,EOT
MSG_WR_ADDR    dc.b     'Writing to address: $',EOT
;
; Storage for FLASH information
;
               align    2
flash_attr     ds.l     1
flash_mfr_id   ds.w     1
               align    2
;
; Text buffer for formatting outputs
text_buffer    ds.b     128
;
; location where ROM update is stored
;
buffer         ds.b     BUFFER_LEN          ; Space for a 64KB chunk
;
fujinet_dcb    ds.b     DCB_SIZE
;
               end