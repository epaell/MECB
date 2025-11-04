               include 'mecb.asm'
               include 'tutor.asm'
;
               org      $4000
;
sector_buffer  equ      $8000                ; location for FLASH write buffer
;
start          move.l   #RAM_END+1,a7        ; Set up stack
               bsr      intro
               bsr      dump_flash_info      ; Summary information relating to FLASH
               move.l   a0,flash_attr        ; Check if info is valid
               cmp.l    #0,a0
               beq      exit                 ; No, exit
               bsr      sector_erase
               bsr      chip_erase
               bsr      chip_write
;
exit           move.b   #TUTOR,d7
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
; Write data back to FLASH ROM
;
chip_write     movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
               move.b   #OUT1CR,d7           ; Write message
               move.l   #MSG_WRITE,a5
               move.l   #MSG_WRITEE,a6
               trap     #14
               
               move.l   #EX_ROM1_BASE,a0     ; destination for FLASH ROM write
               move.l   #EX_ROM1_END+1,a2    ; end address
               move.l   #0,d3                ; value to store
chip_write1    move.l   #sector_buffer,a1    ; destination address for buffer
               move.l   #4096,d1             ; number of dwords to store
chip_write2    move.l   d3,(a1)+             ; store value
               add.l    #1,d3                ; increment the value
               sub.l    #1,d1                ; decrement the counter
               bne      chip_write2
; Sector buffer has data, write to ROM
               move.l   a0,a4                ; temporarily keep this value for printing
               movem.l  d0-d3/a0,-(a7)
               move.b   #OUTPUT,d7
               move.l   #MSG_WR_ADDR,a5
               move.l   #MSG_WR_ADDRE,a6
               trap     #14
;
               move.b   #PNT6HX,d7
               move.l   #buffer,a6
               move.l   a4,d0
               trap     #14
;
               move.b   #OUT1CR,d7
               move.l   #buffer,a5
               trap     #14
               movem.l  (a7)+,d0-d3/a0
;
               move.l   #EX_ROM1_BASE,d0
               move.l   #sector_buffer,a1
               move.l   #16384,d2            ; number of bytes to transfer (4096 * 4)
               bsr      flash_wbytes         ; a0 should have next location to write to
               bne      chip_write3
               cmp.l    a2,a0                ; check if end of ROM reached
               bne      chip_write1          ; if not, continue
;
; continue with second rom
;
               move.l   #EX_ROM2_BASE,a0     ; destination for FLASH ROM write
               move.l   #EX_ROM2_END+1,a2    ; end address
chip_write4    move.l   #sector_buffer,a1    ; destination address for buffer
               move.l   #4096,d1             ; number of dwords to store
chip_write5    move.l   d3,(a1)+             ; store value
               add.l    #1,d3                ; increment the value
               sub.l    #1,d1                ; decrement the counter
               bne      chip_write5
; Sector buffer has data, write to ROM
               move.l   a0,a4                ; temporarily keep this value for printing
               movem.l  d0-d3/a0,-(a7)
               move.b   #OUTPUT,d7
               move.l   #MSG_WR_ADDR,a5
               move.l   #MSG_WR_ADDRE,a6
               trap     #14
;
               move.b   #PNT6HX,d7
               move.l   #buffer,a6
               move.l   a4,d0
               trap     #14
;
               move.b   #OUT1CR,d7
               move.l   #buffer,a5
               trap     #14
               movem.l  (a7)+,d0-d3/a0
;
               move.l   #EX_ROM2_BASE,d0
               move.l   #sector_buffer,a1
               move.l   #16384,d2            ; number of bytes to transfer (4096 * 4)
               bsr      flash_wbytes         ; a0 should have next location to write to
               bne      chip_write3
               cmp.l    a2,a0                ; check if end of ROM reached
               bne      chip_write4          ; if not, continue
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
; Erase Lower FLASH ROM sector by sector
;
sector_erase   movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
;
               move.b   #OUT1CR,d7           ; Sector erase
               move.l   #MSG_SEC_ERASE,a5
               move.l   #MSG_SEC_ERASEE,a6
               trap     #14
;
               move.l   #EX_ROM1_BASE,d0     ; Point to the expansion FLASH ROM
               move.l   #EX_ROM1_BASE,a1     ; sector to erase
               move.l   #EX_ROM1_END,a2      ; end of expansion FLASH ROM
sector_erase1  bsr      flash_erase          ; if successful a1 is bumped to next sector
               bne      sector_erase2
               cmp.l    a2,a1                ; check if reached end of ROM
               blo      sector_erase1        ; if not, continue erasing
;
               move.b   #OUT1CR,d7           ; Sector erase succeeded
               move.l   #MSG_ERASE_OK,a5
               move.l   #MSG_ERASE_OKE,a6
               trap     #14
               
               bra      sector_erase3
;
sector_erase2  move.b   #OUT1CR,d7           ; Sector erase failed
               move.l   #MSG_ERASE_NOK,a5
               move.l   #MSG_ERASE_NOKE,a6
               trap     #14
;
sector_erase3  movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
;
; Erase Upper FLASH ROM using chip erase
;
chip_erase   movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
;
               move.b   #OUT1CR,d7           ; Chip erase
               move.l   #MSG_CH_ERASE,a5
               move.l   #MSG_CH_ERASEE,a6
               trap     #14
;
               move.l   #EX_ROM2_BASE,d0     ; Point to the expansion FLASH ROM
               move.l   #EX_ROM2_BASE,a1     ; sector to erase
               move.l   #EX_ROM2_END,a2      ; end of expansion FLASH ROM
chip_erase1    bsr      flash_chip_erase     ; if successful a1 is bumped to next sector
               bne      chip_erase2
;
               move.b   #OUT1CR,d7           ; Chip erase succeeded
               move.l   #MSG_CH_ERASE_OK,a5
               move.l   #MSG_CH_ERASE_OKE,a6
               trap     #14
               
               bra      chip_erase3
;
chip_erase2    move.b   #OUT1CR,d7           ; Chip erase failed
               move.l   #MSG_CH_ERASE_NOK,a5
               move.l   #MSG_CH_ERASE_NOKE,a6
               trap     #14
;
chip_erase3    movem.l  (a7)+,d0-d7/a0-a6    ; Restore registers
               rts
;
dump_flash_info
               movem.l  d0-d7/a0-a6,-(a7)    ; Save registers
               move.l   #EX_ROM1_BASE,d0     ; Point to the eROM
               bsr      flash_swid           ; Get the FLASH swid->d1, attribute pointer->a0
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
               move.l   #buffer,a6
               move.b   flash_mfr_id,d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #buffer,a5
               trap     #14
               
               move.b   #OUTPUT,d7           ; Write the chip ID to the terminal
               move.l   #MSG_CHIP_ID,a5
               move.l   #MSG_CHIP_IDE,a6
               trap     #14

               move.b   #PNT2HX,d7
               move.l   #buffer,a6
               move.b   flash_mfr_id+1,d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #buffer,a5
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
               move.l   #buffer,a6
               move.l   flash_attr,a0
               move.l   12(a0),d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #buffer,a5
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
               align    2                    ; Make sure everything is aligned to long boundary
;
flash_attr     ds.l     1
flash_mfr_id   ds.w     1
buffer         ds.b     64
;
MSG_INTRO      dc.b     'Program to test FLASH ROM subroutines'
MSG_INTROE     equ      *
MSG_WRITE      dc.b     'Writing to FLASH ROMs'
MSG_WRITEE     equ     *
MSG_WRITE_OK   dc.b     'Writing to FLASH ROMs succeeded'
MSG_WRITE_OKE  equ     *
MSG_WRITE_NOK  dc.b     'Writing to FLASH ROMs failed'
MSG_WRITE_NOKE equ     *
MSG_WR_ADDR    dc.b     'Writing to address: $'
MSG_WR_ADDRE   equ      *
MSG_SEC_ERASE  dc.b     'Erasing lower FLASH ROM sector by sector'
MSG_SEC_ERASEE equ     *
MSG_CH_ERASE   dc.b     'Erasing upper FLASH ROM using chip erase'
MSG_CH_ERASEE  equ     *
MSG_ERASE_OK   dc.b     'Sector erase of lower FLASH ROM succeeded'
MSG_ERASE_OKE  equ     *
MSG_ERASE_NOK  dc.b     'Sector erase of lower FLASH ROM failed'
MSG_ERASE_NOKE equ     *
MSG_CH_ERASE_OK dc.b    'Chip erase of upper FLASH ROM succeeded'
MSG_CH_ERASE_OKE equ     *
MSG_CH_ERASE_NOK dc.b   'Chip erase of upper FLASH ROM failed'
MSG_CH_ERASE_NOKE equ   *
MSG_PROT       dc.b     'Unknown Device or write-protected'
MSG_PROTE      equ      *
MSG_DEVICE     dc.b     'Device: '
MSG_DEVICEE    equ      *
MSG_CAPACITY   dc.b     'Capacity (bytes): $'
MSG_CAPACITYE  equ      *
MSG_MFR_ID     dc.b     'Manufacturer ID: $'
MSG_MFR_IDE    equ      *
MSG_CHIP_ID    dc.b     'Chip ID: $'
MSG_CHIP_IDE   equ      *
;MSG_READING    dc.b     'Reading FLASH'
;MSG_READINGE   equ      *
;MSG_MISMATCH   dc.b     'Mismatch at: $'
;MSG_MISMATCHE  equ      *
;
               include  'flash.asm'
;
