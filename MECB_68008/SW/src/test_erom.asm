            include 'mecb.asm'
            include 'tutor.asm'
;
               org      $4000
;
CR             equ      $0d
LF             equ      $0a
EOT            equ      $04
RESET          equ      $03               ; Master reset for ACIA
CONTROL        equ      $51               ; Control settings for ACIA
;
start          move.l   #MSG_READING,a5
               move.l   #MSG_MISMATCH,a6
               move.b   #OUTPUT,d7
               trap     #14
;
               move.l   #EX_ROM_BASE,a0       ; Start of expansion ROM
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
               move.l   #MSG_MFR_ID,a6
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
               move.b   #OUTPUT,d7        ; Write the sending codes
               move.l   #MSG_SEND,a5
               move.l   #MSG_READING,a6
               trap     #14

               move.l   #EX_ROM_BASE,d0   ; Point to the eROM
               bsr      flash_swid        ; Get the FLASH swid->d1
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
;
init_acia
               lea     ACIA,a0
               move.b  #RESET,(a0)        ; Reset the ACIA
               move.b  #CONTROL,(a0)      ; Set up the ACIA
               rts
;
;
; outstr
;
outstr         lea     ACIA,a0
outstr0        move.b  (a1)+,d0           ; Get a character
               cmp.b   #EOT,d0            ; Check for EOT
               beq     outstr2            ; If done, exit
outstr1        move.b  (a0),d1            ; Read the ACIA status
               andi.b  #$2,d1             ; Check for ready to send
               beq.s   outstr1            ; Wait until ready
               move.b  d0,1(a0)           ; Send a character
               bra     outstr0
outstr2        rts
;
MSG_SEND       dc.b     'Sending codes',CR,LF
MSG_READING    dc.b     'Reading expansion ROM ...',CR,LF
MSG_MISMATCH   dc.b     'Mismatch at: $'
MSG_MFR_ID     dc.b     'Manufacturer ID: $'
MSG_CHIP_ID    dc.b     'Chip ID: $'
MSG_END        equ      *
;
flash_mfr_id   ds.w     1
buffer         ds.b     32
;
               include  'flash.asm'
