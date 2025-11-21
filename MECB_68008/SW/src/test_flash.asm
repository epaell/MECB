               include  'mecb.inc'
               include  'tutor.inc'
               include  'library_rom.inc'
;
               org      $4000
;
CR             equ      $0d
LF             equ      $0a
;
start          move.b   #OUTPUT,d7        ; Write the sending codes
               move.l   #MSG_SEND,a5
               move.l   #MSG_MFR_ID,a6
               trap     #14
;
               move.l   #ROM_BASE,d0      ; Start of ROM
               jsr      flash_swid        ; Get the FLASH swid
               move.w   d1,flash_mfr_id
;
               move.b   #OUTPUT,d7        ; Write the manufacturer ID to the terminal
               move.l   #MSG_MFR_ID,a5
               move.l   #MSG_CHIP_ID,a6
               trap     #14
               
               move.b   #PNT2HX,d7
               move.l   #buffer,a6
               move.b   flash_mfr_id,d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #buffer,a5
               trap     #14
               
               move.b   #OUTPUT,d7        ; Write the chip ID to the terminal
               move.l   #MSG_CHIP_ID,a5
               move.l   #MSG_END,a6
               trap     #14

               move.b   #PNT2HX,d7
               move.l   #buffer,a6
               move.b   flash_mfr_id+1,d0
               trap     #14

               move.b   #OUT1CR,d7
               move.l   #buffer,a5
               trap     #14

exit           move.b   #TUTOR,d7
               trap     #14
;
;
flash_mfr_id   ds.w     1
buffer         ds.b     32
;
MSG_SEND       dc.b     'Sending codes',CR,LF
MSG_MFR_ID     dc.b     'Manufacturer ID: $'
MSG_CHIP_ID    dc.b     'Chip ID: $'
MSG_END        equ      *
;
               end