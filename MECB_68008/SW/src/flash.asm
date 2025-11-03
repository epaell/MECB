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
flash_wbytes  movem.l  d0-d2,-(a7)    ; Save registers
flash_wbytes1 move.b  (a1)+,d1        ; Read a byte
              bsr     flash_wbyte     ; Write to FLASH
              bne     flash_wbytes3   ; If it failed then exit
              sub     #1,d2           ; Decrement byte counter
              bne     flash_wbytes1   ; More to do, loop back
;
              movem.l  (a7)+,d0-d2    ; Restore registers
              ori.w    #$0004,sr      ; set zero flag
              rts
;
flash_wbytes3 movem.l  (a7)+,d0-d2     ; Restore registers
              andi.w   #$FFFB,sr      ; Clear zero flag
              rts                     ; Done

;
; Write byte to ROM
; On Entry:
;        d0 = base address of ROM
;        d1 = Byte to write
;        a0 = location to write to
; On Exit:
;       if write succeeded, Z is set
;       if write failed, Z is clear
;       X = location that was written + 1
;       Register contents are conserved.
flash_wbyte move.l   a0,-(a7)       ; save pointer
            move.l   #FLASH_BYTE_PROG,a0
            bsr      flash_cmd
            move.l   (a7)+,a0       ; restore pointer
            move.b   d1,(a0)
            bsr      flash_wait
            cmp.b    (a0)+,d1       ; check what was written
            rts                     ; Return

;
; Erase a 4KB sector in ROM
; On Entry:
;        d0 = base address of ROM
;        a1 = location of sector to erase
; On Exit:
;       if erase succeeded, Z is set, X points to last location erased + 1
;       if erase failed, Z is clear, X points to location where erase failed
;       All other registers are conserved.
;
flash_erase movem.l  d1/a0,-(a7)    ; save registers
            move.l   #FLASH_SEC_ERASE,a0
            bsr      flash_cmd
            move.b   #$30,(a1)      ; Initiate erasure of the sector by writing $30 to the sector
            move.b   #$FF,d1
            bsr      flash_wait
            move.l   #$1000,d1
flash_erase1
            cmp.b    #$ff,(a1)+
            bne      flash_erase2
            sub      #1,d1
            bne      flash_erase1
            movem.l  (a7)+,d1/a0    ; restore registers
            rts
;
flash_erase2
            lea      -1(a0),a0      ; Restore X to point to failed location
            move.l   (a7)+,d1       ; restore registers
            andi.w   #$FFFB,sr      ; Clear zero flag
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
            bra     flash_wait2     ; Bit 7 = 0, pperation complete
;
flash_wait1 move.b  (a0),d1         ; Get FLASH status
            btst    #7,d1           ; Check for completion, Bit 7 = 1
            beq     flash_wait1     ; Bit 7 = 0, not ready yet
flash_wait2 move.l  (a7)+,d1        ; Restore register
            rts                     ; Return

;
; Get the software ID for the ROM
; On Entry:
;       d0 = base address of ROM to check
; On Exit:
;       d1 = Manufacturer ID (D15-D8) + Chip ID (D7-D0)
;       All other registers are conserved
;
flash_swid  move.l   a0,-(a7)          ; save a0
            move.l   #FLASH_SW_ID_ENTER,a0   ; send command to retrieve ID
            bsr      flash_cmd
            move.l   d0,a0
            move.w   (a0),d1           ; get the IDs
            move.l   #FLASH_SW_ID_EXIT,a0    ; send command to exit mode
            bsr      flash_cmd
            move.l   (a7)+,a0          ; restore a0
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