               align    2              ; Make sure everything is aligned to long boundary
;
; Write bytes to FLASH ROM
; Routine assumes that the sector to which is being written has already been erased.
; On Entry:
;        d0 = base address of ROM
;        d2 = number of bytes to transfer
;        a0 = location to write to
;        a1 = source location
; On Exit:
;       if write succeeded, Z is set
;       if write failed, Z is clear
;       a0 = final location written to + 1 (on failure points to failed location of write)
;       a1 = final location read from + 1
;       All other register contents conserved
flash_wbytes  movem.l  d0-d2,-(a7)     ; Save registers
flash_wbytes1 move.b  (a1)+,d1         ; Read a byte
              bsr     flash_wbyte      ; Write to FLASH
              bne     flash_wbytes3    ; If it failed then exit
              sub.l   #1,d2            ; Decrement byte counter
              bne     flash_wbytes1    ; More to do, loop back
;
              movem.l  (a7)+,d0-d2     ; Restore registers
              ori.w    #$04,sr         ; set zero flag
              rts
;
flash_wbytes3 movem.l  (a7)+,d0-d2     ; Restore registers
              andi.w   #$FB,sr         ; Clear zero flag
              rts                      ; Done

;
; Write byte to ROM
; On Entry:
;        d0 = base address of ROM
;        d1 = Byte to write
;        a0 = location to write to
; On Exit:
;       if write succeeded, Z is set
;       if write failed, Z is clear
;       a0 = location that was written + 1
;       Register contents are conserved.
flash_wbyte move.l   a0,-(a7)          ; save pointer
            move.l   #FLASH_BYTE_PROG,a0
            bsr      flash_cmd
            move.l   (a7)+,a0          ; restore pointer
            move.b   d1,(a0)
            bsr      flash_wait
            cmp.b    (a0)+,d1          ; check what was written
            rts                        ; Return

;
; Erase entire ROM
; On Entry:
;        d0 = base address of ROM
;        a1 = sector to erase
; On Exit:
;       if erase succeeded, Z is set, a1 points to last location erased + 1
;       if erase failed, Z is clear, a1 points to location where erase failed
;       All other registers are conserved.
;
flash_chip_erase
            movem.l  d1/a0,-(a7)       ; save registers
            move.l   #FLASH_CHIP_ERASE,a0
            bsr      flash_cmd
            move.b   #$FF,d1
            move.l   d0,a0             ; a0 points to start of ROM
            bsr      flash_wait
            move.l   #$80000,d1
            move.l   d0,a1             ; a1 points to start of ROM
flash_chip_erase1
            cmp.b    #$ff,(a1)+        ; check that erasure worked
            bne      flash_chip_erase2
            sub.l    #1,d1
            bne      flash_chip_erase1
            movem.l  (a7)+,d1/a0       ; restore registers
            ori.w    #$04,sr           ; Set zero flag
            rts
;
flash_chip_erase2
            lea      -1(a1),a1         ; Restore X to point to failed location
            movem.l  (a7)+,d1/a0       ; restore registers
            andi.w   #$FB,sr           ; Clear zero flag
            rts
;
; Erase a 4KB sector in ROM
; On Entry:
;        d0 = base address of ROM
;        a1 = location of sector to erase
; On Exit:
;       if erase succeeded, Z is set, a1 points to last location erased + 1
;       if erase failed, Z is clear, a1 points to location where erase failed
;       All other registers are conserved.
;
flash_erase movem.l  d1/a0,-(a7)    ; save registers
            move.l   #FLASH_SEC_ERASE,a0
            bsr      flash_cmd
            move.b   #$30,(a1)      ; Initiate erasure of the sector by writing $30 to the sector
            move.b   #$FF,d1
            move.l   a1,a0
            bsr      flash_wait
            move.l   #$1000,d1
flash_erase1
            cmp.b    #$ff,(a1)+
            bne      flash_erase2
            sub.l    #1,d1
            bne      flash_erase1
            movem.l  (a7)+,d1/a0    ; restore registers
            ori.w    #$04,sr        ; Set zero flag
            rts
;
flash_erase2
            lea      -1(a1),a1      ; Restore X to point to failed location
            movem.l  (a7)+,d1/a0    ; restore registers
            andi.w   #$FB,sr        ; Clear zero flag
            rts

;
; Wait for FLASH operation to complete
; On Entry:
;       d1 = Data that was written
;       a0 = Location that was written
; On Exit:
;       All registers are conserved
;
flash_wait  move.l  d1,-(a7)        ; Save data that was written
            btst    #7,d1           ; Check for Bit 7 value
            bne     flash_wait1     ; Waiting for Bit 7 = 1
;
flash_wait0 move.b  (a0),d1         ; Get FLASH status
            btst    #7,d1           ; Check for completion, Bit 7 = 0
            bne     flash_wait0     ; Bit 7 = 1, not ready yet
            bra     flash_wait2     ; Bit 7 = 0, operation complete
;
flash_wait1 move.b  (a0),d1         ; Get FLASH status
            btst    #7,d1           ; Check for completion, Bit 7 = 1
            beq     flash_wait1     ; Bit 7 = 0, not ready yet
flash_wait2 move.l  (a7)+,d1        ; Restore register
            rts                     ; Return

;
; Get the software ID for the ROM
; On Entry:
;        d0 = base address of ROM to check
; On Exit:
;        d1 = Manufacturer ID (D15-D8) + Chip ID (D7-D0)
;        a0 = pointer to device attribute
;        All other registers are conserved
;
flash_swid  move.l   d2,-(a7)                ; save registers
            move.l   #FLASH_SW_ID_ENTER,a0   ; send command to retrieve ID
            bsr      flash_cmd
            move.l   d0,a0
            move.w   (a0),d1                 ; get the IDs
            move.l   #FLASH_SW_ID_EXIT,a0    ; send command to exit mode
            bsr      flash_cmd
            move.w   d1,d2
            lsr      #8,d2                   ; get the manufacturer ID
            cmp.b    #$BF,d2                 ; Only know about Microchip (=$BF)
            bne      flash_swid2
            move.l   #FLASH_ATTR,a0          ; Point to the device attribute table
flash_swid1 move.b   (a0),d2                 ; Get current device ID
            beq      flash_swid2             ; If end of table reached then device not found, exit
            cmp.b    d1,d2                   ; Does it match
            beq      flash_swid3             ; If so, found device attributes so return.
            lea      16(a0),a0               ; Skip to next table entry
            bra      flash_swid1
flash_swid2 move.l   #0,a0                   ; Device/Manufacturer not found
flash_swid3 move.l   (a7)+,d2                ; restore registers
            rts

;
; Send a command to the FLASH ROM
;
; On entry:
;       d0 = base address of ROM to check
;       a0 = Points to command sequence to send (SW_ID_ENTER, SW_ID_EXIT, BYTE_PROG, SEC_ERASE)
; On exit:
;       All registers are conserved
;
flash_cmd   movem.l  d0-d2/a2,-(a7) ; save registers
flash_cmd1  move.l   (a0)+,d1       ; fetch a command
            beq      flash_cmd2     ; if end of command sequence reached then return
            move.l   (a0)+,d2       ; fetch an offset
            add.l    d0,d2          ; add base address to offset
            move.l   d2,a2          ; move to an address register
            move.b   d1,(a2)        ; write the command to the offset in ROM
            bra      flash_cmd1     ; loop back
flash_cmd2  movem.l  (a7)+,d0-d2/a2 ; restore registers
            rts                     ; return
;
;
; FLASH Commands
;
FLASH_SW_ID_ENTER 
            dc.l     $AA
            dc.l     $5555
            dc.l     $55
            dc.l     $2AAA
            dc.l     $90
            dc.l     $5555
            dc.l     $00
;
FLASH_SW_ID_EXIT
            dc.l     $AA
            dc.l     $5555
            dc.l     $55
            dc.l     $2AAA
            dc.l     $F0
            dc.l     $5555
            dc.l     $00
;
FLASH_BYTE_PROG
            dc.l     $AA
            dc.l     $5555
            dc.l     $55
            dc.l     $2AAA
            dc.l     $A0
            dc.l     $5555
            dc.l     $00
;
FLASH_SEC_ERASE
            dc.l     $AA
            dc.l     $5555
            dc.l     $55
            dc.l     $2AAA
            dc.l     $80
            dc.l     $5555
            dc.l     $AA
            dc.l     $5555
            dc.l     $55
            dc.l     $2AAA
            dc.l     $00
;
FLASH_CHIP_ERASE
            dc.l     $AA
            dc.l     $5555
            dc.l     $55
            dc.l     $2AAA
            dc.l     $80
            dc.l     $5555
            dc.l     $AA
            dc.l     $5555
            dc.l     $55
            dc.l     $2AAA
            dc.l     $10
            dc.l     $5555
            dc.l     $00
;
; FLASH device attribute table:
;     byte8  device_id (terminated with $00)
;     char   device_name[11]
;     int32  size
FLASH_ATTR  dc.b     $B5
            dc.b     'SST39SF010A'
            dc.l     $20000
            dc.b     $B6
            dc.b     'SST39SF020A'
            dc.l     $40000
            dc.b     $B7
            dc.b     'SST39SF040',$00
            dc.l     $80000
            dc.b     $00
