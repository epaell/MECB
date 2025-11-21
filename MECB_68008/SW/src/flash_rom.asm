               include  'mecb.inc'
               include  'tutor.inc'
;
               org      $4000
;
start          move.l   #RAM_END+1,a7        ; Set up stack
;
               bsr      intro
               bsr      dump_flash_info      ; Summary information relating to FLASH
               move.l   a0,flash_attr        ; Check if info is valid
               cmp.l    #0,a0
               beq      main_end             ; No, exit
;
               bsr      sector_erase
               bsr      chip_write
;
main_end       move.b   #TUTOR,d7
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
               move.l   #ROM_BASE,d0         ; Point to the main ROM
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
; Library part of FLASH ROM sector by sector
;
sector_erase   movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
;
               move.b   #OUT1CR,d7           ; Sector erase
               move.l   #MSG_SEC_ERASE,a5
               move.l   #MSG_SEC_ERASEE,a6
               trap     #14
;
               move.l   #ROM_BASE,d0               ; Point to the expansion FLASH ROM
               move.l   #ROM_BASE+$10000,a1        ; sector to erase
               move.l   #ROM_BASE+$14000,a2        ; end of expansion FLASH ROM
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
               
               move.l   #ROM_BASE+$10000,a0     ; destination for FLASH ROM write
               move.l   #ROM_BASE+$14000,a2     ; end address
; Sector buffer has data, write to ROM
               move.l   a0,a4                   ; temporarily keep this value for printing
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
               move.l   #ROM_BASE,d0
               move.l   #0,d2
               move.w   buffer_len,d2        ; number of bytes to transfer
               move.l   #buffer,a1           ; location to transfer from
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
MSG_INTRO      dc.b     'Checking for FLASH ROM'
MSG_INTROE
MSG_MFR_ID     dc.b     'Manufacturer ID: $'
MSG_MFR_IDE
MSG_CHIP_ID    dc.b     'Chip ID: $'
MSG_CHIP_IDE
MSG_PROT       dc.b     'Unknown Device or write-protected'
MSG_PROTE
MSG_DEVICE     dc.b     'Device: '
MSG_DEVICEE
MSG_CAPACITY   dc.b     'Capacity (bytes): $'
MSG_CAPACITYE
;
MSG_SEC_ERASE  dc.b     'Erasing FLASH ROM sectors'
MSG_SEC_ERASEE
MSG_ERASE_OK   dc.b     'Sector erase of FLASH ROM succeeded'
MSG_ERASE_OKE
MSG_ERASE_NOK  dc.b     'Sector erase of FLASH ROM failed'
MSG_ERASE_NOKE
MSG_WRITE      dc.b     'Writing to FLASH ROM'
MSG_WRITEE
MSG_WRITE_OK   dc.b     'Writing to FLASH ROM succeeded'
MSG_WRITE_OKE
MSG_WRITE_NOK  dc.b     'Writing to FLASH ROM failed'
MSG_WRITE_NOKE
MSG_WR_ADDR    dc.b     'Writing to address: $'
MSG_WR_ADDRE
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
buffer_len     equ      $4800
buffer         equ      $4802
;
               include  'flash.asm'