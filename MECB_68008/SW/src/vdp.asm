; Low-level functions for reading and writing to the VDP registers and memory
;
;
               align    2              ; Make sure everything is aligned to long boundary
               
; Function:	Setup VRAM Address for subsequent VRAM read
; Parameters:  d0 - VRAM address (17 bits) - top word has A16, lower word A15-A0
; Returns:     -
; Destroys:    d0,d1,d2
vdp_vram_raddr move.b   #$00,d1        ; Set VRAM bank (VRAM, not Expansion RAM)
               move.b   #45,d2         ; Register #45
               bsr      vdp_write_reg
               move.l   d0,d1          ; Set VRAM Access Bank (VRAM high address A16-A14)
               lsl.l    #2,d1          ; Shift A15 and A14 into upper word
               swap     d1             ; Move A16-A14 to lower word
               and.b    #7,d1          ; Mask off other bits
               move.b   #14,d2         ; Register #14
               bsr      vdp_write_reg
;
               and.w    #$3FFF,d0      ; Mask off A16-A14
               move.b   d0,VDP_REG     ; Store A7-A0 of address
               lsr.w    #8,d0          ; Shift A13-A8 to lower byte
               move.b   d0,VDP_REG     ; Store masked high byte of address
               rts

; Function:	Setup VRAM Address for subsequent VRAM write
; Parameters:  d0 - VRAM address (17 bits) - top word has A16, lower word A15-A0
; Returns:     -
; Destroys:    d0,d1,d2
vdp_vram_waddr move.b   #$00,d1        ; Set VRAM bank (VRAM, not Expansion RAM)
               move.b   #45,d2         ; Register #45
               bsr      vdp_write_reg
               move.l   d0,d1          ; Set VRAM Access Bank (VRAM high address A16-A14)
               lsl.l    #2,d1          ; Shift A16-A14 into three lower bits of upper word
               swap     d1             ; Move A16-A14 to lower word
               and.b    #7,d1          ; Mask off other bits
               move.b   #14,d2         ; Register #14
               bsr      vdp_write_reg
;
               and.w    #$3fff,d0      ; Mask off A16-A14
               move.b   d0,VDP_REG     ; Store A7-A0 of address
               lsr.w    #8,d0          ; Shift A13-A8 to lower byte
               or.b     #$40,d0
               move.b   d0,VDP_REG     ; Store A13-A8 of address
               rts

; Function:	Write a data byte into a specified VDP register
; Parameters:  d1 - Data Byte
;              d2 - Register number
; Returns:     -
; Destroys:    d2
vdp_write_reg  move.b   d1,VDP_REG     ; Store data byte
               and.b    #$3F,d2
               or.b     #$80,d2
               move.b   d2,VDP_REG     ; Store masked register number
               rts

; Function:	Read the VDP status byte
; Note:		Routine intended for functional documentation only
;		i.e. Just directly inline implement: move.b VDP_REG,d0
; Parameters:	-
; Returns:	d0 = Status Byte
; Destroys:	-
vdp_read_stat  move.b   VDP_REG,d0
               rts

; Function:	Read the VDP status register N
; Note:		Routine intended for functional documentation only
;		i.e. Just directly inline implement: move.b VDP_REG,d0
; Parameters:  d0 = status register number
; Returns:	d0 = Status Byte
; Destroys:	d1,d2
vdp_read_nstat move.b   d0,d1          ; Set the status register number
               move.b   #15,d2
               bsr      vdp_write_reg
               move.b   VDP_REG,d0     ; Read the status
               rts


; Function:	Read byte from current VRAM read address
; Note:		Routine intended for functional documentaion only
;		i.e. Just directly inline implement: move.b VDP_VRAM,d0
; Parameters:	-
; Returns:	d0 = VRAM Byte read
; Destroys:	d0
vdp_read_vram  move.b   VDP_VRAM,d0
               rts

; Function:	Write byte to current VRAM write address
; Note:		Routine intended for functional documentaion only
;		i.e. Just directly inline implement: STA VDP_VRAM
; Parameters:	A - VRAM Byte to write
; Returns:	-
; Destroys:	-
vdp_write_vram move.b   d0,VDP_VRAM
               rts

;
;
; Function:	Write block of 24 bytes to the VDP registers
; Parameters:	a0 - Points to address of 24 byte register set
; Returns:	-
; Destroys:	a0, d0, d1
vdp_init_regs  move.b   #$80,d0           ; Initialise to register zero
vdp_init_regs2 move.b   (a0)+,d1          ; Load register data pointed to by a0 and increment a0
               move.b   d1,VDP_REG        ; Store data byte
               move.b   d0,VDP_REG        ; Store register number
               add.b    #1,d0
               cmp.b    #$98,d0           ; Have we done all 24 registers?
               bne      vdp_init_regs2    ; No, do next register
               rts

; Function:	Write a specified byte to a block of VRAM bytes
; Parameters:  d0 - Byte to write
;              d1 - Count of bytes to write
; Returns:     -
; Destroys:    d0,d1
vdp_set_vram   move.b   d0,VDP_VRAM
               sub.l    #1,d1
               bne      vdp_set_vram
               rts

; Function:	Write an incrementing byte to a block of VRAM bytes
; Parameters:  d0 - Initial Byte to write
;              d1 - Count of incrementing bytes to write
; Returns:     -
; Destroys:    d0, d1
vdp_inc_vram   move.b   d0,VDP_VRAM
               add.b    #1,d0
               sub.l    #1,d1
               bne      vdp_inc_vram
               rts

; Function:	Write block of bytes to VRAM
; Parameters:  a0 - Points to address of bytes to write to VRAM
;              d0 - Count of bytes to write
; Returns:     a0 points to end of written block
; Destroys:    -
vdp_xfr_vram   move.l   d0,-(a7)
vdp_xfr_vram1  move.b	(a0)+,VDP_VRAM		; Load VRAM data pointed to by A0 and increment A0
               sub.l    #1,d0
               bne      vdp_xfr_vram1
               move.l   (a7)+,d0
               rts

; Function:	Clear VDP VRAM
; Parameters:	-
; Returns:	-
; Destroys:	-
vdp_clr_vram   movem.l  d0/d1,-(a7)          ; Save d0 and d1
               move.l   #$00000,d0        ; Start clearing from the start of VRAM
               bsr      vdp_vram_waddr
               move.b   #$00,d0
               move.l   #$20000,d1        ; Clear $20000 bytes (128 KB)
               bsr      vdp_set_vram
               movem.l   (a7)+,d0/d1          ; restore d0 and d1
               rts

; Function: Wait until VDP function has completed
; Parameters:  -
; Returns:     -
; Destroys:    -
vdp_wait       movem.l  d0-d2,-(a7)          ; Save d0-d2
vdp_wait1      move.b   #2,d0                ; Read status register 2
               bsr      vdp_read_nstat
               btst     #0,d0                ; Check CE bit
               bne      vdp_wait1            ; If command is still running then wait
               movem.l  (a7)+,d0-d2          ; restore d0-d2
               rts
