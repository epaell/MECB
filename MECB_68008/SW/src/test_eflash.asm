               include 'mecb.asm'
               include 'tutor.asm'
;
               org      $4000
;
CR             equ      $0d
LF             equ      $0a
;
start          move.l   #EX_ROM2_BASE,d0      ; Point to the eROM
               bsr      flash_swid           ; Get the FLASH swid->d1
               move.w   d1,flash_mfr_id
               move.l   a0,flash_attr
               cmp.l    #0,a0
               beq      mem_prot_err
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

               move.b   #OUTPUT,d7           ; Write the chip ID to the terminal
               move.l   #MSG_DEVICE,a5
               move.l   #MSG_DEVICEE,a6
               trap     #14

               move.b   #OUT1CR,d7           ; Write the device name to the terminal
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
;
               bra      exit
;
mem_prot_err   move.l   #MSG_PROT,a5         ; Device/Manufacturer unknown or write protected
               move.l   #MSG_PROTE,a6
               move.b   #OUTPUT,d7
               trap     #14
;
               bra      exit
;
               move.l   #MSG_READING,a5
               move.l   #MSG_READINGE,a6
               move.b   #OUTPUT,d7
               trap     #14
;
               move.l   #EX_ROM2_BASE,a0       ; Start of expansion ROM
               move.l   #0,d0
loop           move.l   (a0),d1
               cmp.l    d0,d1
               bne      end
               lea      4(a0),a0
               add.l    #1,d0
               bra      loop
;
end            move.l   a0,-(a7)
               move.b   #OUTPUT,d7
               move.l   #MSG_MISMATCH,a5
               move.l   #MSG_MISMATCHE,a6
               trap     #14
;
               move.l   (a7)+,d0
               move.l   #buffer,a6
               move.b   #PNT8HX,d7        ; Add d0 to buffer
               trap     #14
;
               move.b   #CR,(a6)+
               move.b   #LF,(a6)+
               move.b   #OUTPUT,d7
               move.l   #buffer,a5
               trap     #14
;
exit           move.b   #TUTOR,d7
               trap     #14
;
               align    2              ; Make sure everything is aligned to long boundary
;
flash_attr     ds.l     1
flash_mfr_id   ds.w     1
buffer         ds.b     32
;
MSG_PROT       dc.b     'Unknown Device or write-protected',CR,LF
MSG_PROTE      equ      *
MSG_DEVICE     dc.b     'Device: '
MSG_DEVICEE    equ      *
MSG_CAPACITY   dc.b     'Capacity (bytes): $'
MSG_CAPACITYE  equ      *
MSG_MFR_ID     dc.b     'Manufacturer ID: $'
MSG_MFR_IDE    equ      *
MSG_CHIP_ID    dc.b     'Chip ID: $'
MSG_CHIP_IDE   equ      *
MSG_READING    dc.b     'Reading FLASH'
MSG_READINGE   equ      *
MSG_MISMATCH   dc.b     'Mismatch at: $'
MSG_MISMATCHE  equ      *
;
               include  'flash.asm'
;
