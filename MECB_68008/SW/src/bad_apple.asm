               org      $4000
;
               include  'mecb.inc'
               include  'tutor.inc'
               include  'library_rom.inc'
               include  'oled.inc'
;
CR             equ      $0d
LF             equ      $0a
RING_SIZE      equ      100               ; ring buffer has space for 128 x 4096-byte frames = 512 KB
LAST_FRAME     equ      6573+RING_SIZE*6              ; need to update with last frame number
;
TIMER_VAL      equ      $9B02      ; timer 1 count setting for 30 fps
DELAY          equ      $06        ; number of timer ticks before frame is played (1= 15fps)
TIMER_SETH     equ      $01        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
TIMER_SETL     equ      $42        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
;
start          move.l   #RAM_END+1,a7     ; Set up stack
               move.l   #OUT1CR,d7        ; Write message to indicate test starting
               move.l   #M_TSTART,a5
               move.l   #M_TEND,a6
               trap     #14
;
               move.l   #timer_isr,a0    ; For now, point all vectors to ISR
               move.l   a0,VEC_IRQ0
               move.l   a0,VEC_IRQ1
               move.l   a0,VEC_IRQ2
               move.l   a0,VEC_IRQ3
               move.l   a0,VEC_IRQ4
               move.l   a0,VEC_IRQ5
               move.l   a0,VEC_IRQ6
               move.l   a0,VEC_IRQ7
;
               jsr      oled_init
;
               move.b   #$00,d0           ; d0 = fill value
               move.b   #$00,d1           ; d1 = start row
               move.b   #$3f,d2           ; d2 = end row
               jsr      oled_fill
               jsr      oled_on
;
               move.w   #0,fr_load        ; First frame to load
               move.w   #$ff,fr_play      ; Set frame to start playing at end of buffer just to enable initial fill
               move.w   #0,fr_end         ; Current ring buffer index for loading
               
               move.l   #RING_SIZE-1,d5   ; fill buffer with frames
rloop          bsr      load_frame
               dbra     d5,rloop
;
               move.l   #OUT1CR,d7        ; Write message to indicate test starting
               move.l   #M_TPSTART,a5
               move.l   #M_TPEND,a6
               trap     #14
;
               bsr      ptm_init          ; initialize the timer
               move.w   #$2000,sr         ; enable interrupts
;
ploop          bsr      load_frame
               move.w   fr_load,d0
               cmp.w    #LAST_FRAME,d0
               blo      ploop             ; keep loading while there are frames to load
;
ploop2         move.w   fr_play,d0        ; check if all frames have been played
               cmp.w    fr_end,d0
               bne      ploop2            ; if not, loop back
;
; return to tutor monitor
;
               move.b   #TUTOR,d7
               trap     #14
;
ptm_init:      move.w   #TIMER_VAL,d0
               move.w   d0,PTM1_T1MSB
               move.b   #TIMER_SETH,d0    ; Preset all timers : CRX6=1 (interrupt); CRX1=1 (enable clock)
               move.b   d0,PTM1_CR2       ; Write to CR2
               move.b   #TIMER_SETL,d0
               move.b   d0,PTM1_CR13 
               move.l   #0,d0
               move.b   d0,PTM1_CR2 
               move.w   d0,fr_play        ; reset the play frame
               move.w   #DELAY,fr_delay   ; initialise the tick counter
               move.b   PTM1_SR,d0        ; Read the interrupt flag from the status register
               move.b   #$40,d0
               move.b   d0,PTM1_CR13      ; enable interrupt and start timer
               rts 
;
timer_isr:     movem.l  a0/d0-d1,-(a7)    ; Save registers
               move.b   PTM1_SR,d0        ; Read the interrupt flag from the status register
               move.w   PTM1_T1MSB,d0     ; clear timer interrupt flag
               move.b   PTM1_SR,d0        ; Read the interrupt flag from the status register
               move.w   PTM1_T2MSB,d0
               move.b   PTM1_SR,d0        ; Read the interrupt flag from the status register
               move.w   PTM1_T3MSB,d0
               move.w   fr_delay,d0
               sub.w    #1,d0             ; bump timer clicks before frame play
               beq      timer_isr1        ; ready to play a frame
               move.w   d0,fr_delay       ; save updated tick counter
               bra      timer_isr3        ; return without playing
                                          ; Send the current play frame to the OLED display
timer_isr1     move.w   #DELAY,fr_delay   ; reset tick counter
               move.l   #0,d0             ; Get the current play position
               move.w   fr_play,d0
               move.b   d0,MECB_LED       ; LED shows current frame to play
               lsl.l    #7,d0             ; Convert to buffer address = fbuffer + 4096 * fr_play
               lsl.l    #5,d0
               add.l    #fbuffer,d0
               move.l   d0,a0
                                          ; Fill OLED display VRAM data pointed to by a0
               move.b   #0,d0             ; start row
               move.b   #$3f,d1           ; end row
               jsr      oled_set_row      ; set the row range
               move.b   #0,d0             ; start column = 0
               move.b   #$7f,d1           ; end column = 127
               jsr      oled_set_col      ; set the column range
               move.w   #64*64-1,d0       ; number of bytes to transfer 128 x 64 / 2 (pixels per byte)
;
timer_isr4     move.b   (a0)+,OLED_DTA    ; Move byte to current VRAM location
               dbra     d0,timer_isr4     ; Dec byte counter

               move.w   fr_play,d0        ; bump the play position within the ring buffer
               add.w    #1,d0
               cmp.w    #RING_SIZE,d0     ; reached end of ring buffer?
               bne      timer_isr2        ; no, save current position and return
               move.w   #0,d0             ; yes, go back to start of the ring buffer
;
timer_isr2     cmp.w    fr_end,d0         ; have we reached the load location?
               beq      timer_isr3        ; if so, don't update the play frame (effectively a lost frame)
               move.w   d0,fr_play        ; update play frame
;
timer_isr3     movem.l  (a7)+,a0/d0-d1    ; restore registers
               rte

;
; Loads a frame into the ring buffer
; Each frame is 4096 bytes
; fr_play is the ring buffer index in the ring buffer to the current frame to play
; fr_end is the ring buffer index to where the next frame will be loaded
; if fr_play==fr_end then the buffer is full
; if fr_play!=fr_end then the next frame can be read into fr_end
; fr_load is the next frame that needs to be read off disk
load_frame     move.l   #0,d0
               move.w   fr_end,d0
;               move.b   d0,MECB_LED       ; LED shows current frame to load
               cmp.w    fr_play,d0
               bne      load_frame2
load_frame5    rts                        ; buffer is full, return
;
load_frame2    move.l   #0,d2
               move.w   fr_load,d2
               cmp.w    #LAST_FRAME,d2    ; have last frames been read?
               beq      load_frame5       ; if so, return
               lsl.l    #7,d0             ; calculate offset in ring buffer to load next frame = fbuffer + d0 * 4096
               lsl.l    #5,d0
               add.l    #fbuffer,d0
               move.l   d0,a0             ; a0 points to destination
               lsl.l    #3,d2             ; work out sector offset on the disk LBA = d0 * 8 (since 4096 = 8 * sectors)
               move.l   #7,d4             ; total number of 512 sectors to read (8 x 512 = 4096)
               
               move.l   #dtable,a1        ; Pointer to the table
               move.b   #MASTER,d0        ; use master
               move.b   d0,(disk_slave_o,a1)
               move.l   #MECB_PPI,a5      ; Set up pointer to ppide device
               move.l   #1,d3             ; Read 1 sector

load_frame3    movem.l  a0-a1/d2-d4,-(a7) ; save registers
               move.l   a0,-(a7)          ; push the buffer location
               move.l   #0,-(a7)          ; push the drive number
               jsr      ppide_read        ; do the read
               lea.l    8(a7),a7          ; remove arguments from stack
               movem.l  (a7)+,a0-a1/d2-d4 ; restore registers
               lea.l    512(a0),a0        ; point to next sector location
               add.l    #1,d2
               dbra     d4,load_frame3    ; loop until frame is read
;
               move.w   fr_load,d0        ; increment the frame to load next
               add.w    #6,d0             ; skip alternate frames (5 fps)
               move.w   d0,fr_load
               move.w   fr_end,d0
               add.w    #1,d0
               cmp.w    #RING_SIZE,d0     ; reached end of ring buffer?
               beq      load_frame4
               move.w   d0,fr_end         ; no, save updated position
               rts
;
load_frame4    move.w   #0,fr_end         ; end of ring buffer, wrap around
               rts
;
dtable:        ds.l     1                 ; pointer to operation
               dc.l     $1F400            ; LBA number of cylinders
               dc.b     D_PPIDE           ; disk type
               dc.b     1                 ; port
               dc.b     MASTER            ; master/slave
               dc.b     0                 ; last status
               dc.w     0                 ; cylinders
               dc.b     0                 ; heads/tracks
               dc.b     0                 ; sectors/track
;
tbuffer        ds.b     32
fr_load        ds.w     1                 ; next frame number to load from disk
fr_play        ds.w     1                 ; ring buffer index where next frame will be send to the OLD display
fr_end         ds.w     1                 ; ring buffer index where next frame will be loaded from disk
fr_delay       ds.w     1
;
M_TSTART       dc.b     "Starting Bad Apple test",CR,LF
M_TEND
M_TPSTART      dc.b     "Starting play timer",CR,LF
M_TPEND
;
;-----------------------------------------------------------------------------
; offsets from the base port address
portA_o        equ   0
portB_o        equ   1
portC_o        equ   2
portCTRL_o     equ   3

; absolute port addresses
portA          equ   MECB_PPI+portA_o
portB          equ   MECB_PPI+portB_o
portC          equ   MECB_PPI+portC_o
portCTRL       equ   MECB_PPI+portCTRL_o
;-----------------------------------------------------------------------------

; use optimised block data transfer loops?
;FASTXFER      equ   0        ; Disable fast transfer option
;FASTXFER      equ   1        ; Fast transfer of long aligned data
;FASTXFER      equ   2        ; Fast transfer ignoring alignment


; PPI control bytes for read and write to IDE drive

rd_ide_8255    equ   $92      ; ide_8255_ctl out, ide_8255_lsb/msb input
wr_ide_8255    equ   $80      ; all three ports output

max_disk       equ   8
max_floppy     equ   2

;	.comm	disk_table,max_disk*4

; Disk type
D_NONE         equ   0
D_FLOPPY_1200  equ   2
D_FLOPPY_720   equ   3
D_FLOPPY_1440  equ   4
D_PPIDE        equ   8
D_DISKIO       equ   9
D_DUALSD       equ   10
D_DIDE         equ   11
D_DIDE_8       equ   12

; Master/slave
MASTER         equ   0
SLAVE          equ   $10
 
; DISK structure offsets
disk_ops_o     equ   0     ; operations dispatch ptr
disk_lba_o     equ   4     ; LBA number of cylinders
disk_type_o    equ   8     ; byte: disk type
disk_port_o    equ   9     ; byte: I/O port
disk_slave_o   equ   10    ; byte: MASTER=0, SLAVE=$10 (IDE)
                           ; SLAVE=$01 (SD)
disk_status_o  equ   11    ; byte: last h/w status
disk_geom_o    equ   12    ; geometry longword (0-cylinders.w-1, 0-heads.b-1, 1-sectors_per_track.b)

; ide control lines for use with ide_8255_ctl.  Change these 8
; constants to reflect where each signal of the 8255 each of the
; ide control signals is connected.  All the control signals must
; be on the same port, but these 8 lines let you connect them to
; whichever pins on that port.

ide_a0_line    equ   $01      ; direct from 8255 to ide interface
ide_a1_line    equ   $02      ; direct from 8255 to ide interface
ide_a2_line    equ   $04      ; direct from 8255 to ide interface
; for the PPIDE driver
ide_cs0_line   equ   $08      ; inverter between 8255 and ide interface
ide_cs1_line   equ   $10      ; inverter between 8255 and ide interface
ide_wr_line    equ   $20      ; inverter between 8255 and ide interface
ide_rd_line    equ   $40      ; inverter between 8255 and ide interface
ide_rst_line   equ   $80      ; inverter between 8255 and ide interface

;------------------------------------------------------------------
; More symbolic constants... these should not be changed, unless of
; course the IDE drive interface changes, perhaps when drives get
; to 128G and the PC industry will do yet another kludge.

;some symbolic constants for the ide registers, which makes the
;code more readable than always specifying the address pins

ide_data       equ   ide_cs0_line
ide_err        equ   ide_cs0_line+ide_a0_line
ide_sec_cnt    equ   ide_cs0_line+ide_a1_line
ide_sector     equ   ide_cs0_line+ide_a1_line+ide_a0_line
ide_cyl_lsb    equ   ide_cs0_line+ide_a2_line
ide_cyl_msb    equ   ide_cs0_line+ide_a2_line+ide_a0_line
ide_head       equ   ide_cs0_line+ide_a2_line+ide_a1_line
ide_command    equ   ide_cs0_line+ide_a2_line+ide_a1_line+ide_a0_line
ide_status     equ   ide_cs0_line+ide_a2_line+ide_a1_line+ide_a0_line

ide_control    equ   ide_cs1_line+ide_a2_line+ide_a1_line
ide_astatus    equ   ide_cs1_line+ide_a2_line+ide_a1_line
ide_address    equ   ide_cs1_line+ide_a2_line+ide_a1_line+ide_a0_line

;IDE Command Constants.  These should never change.
ide_cmd_recal        equ   $10
ide_cmd_read         equ   $20
ide_cmd_write        equ   $30
ide_cmd_init         equ   $91
ide_cmd_id           equ   $EC
ide_cmd_set_feature  equ   $EF
ide_cmd_spindown     equ   $E0
ide_cmd_spinup       equ   $E1

;Feature r=ests
ide_fea_8bit         equ   $01
ide_fea_16bit        equ   $81


; FDC error codes (returned in D0)

ERR_no_error                  equ   0       ; no error (return Carry clear)
;   everything below returns with the Carry set to indicate an error
ERR_invalid_command           equ   1
ERR_address_mark_not_found    equ   2
ERR_write_protect             equ   3
ERR_sector_not_found          equ   4
ERR_disk_removed              equ   6
ERR_dma_overrun               equ   8
ERR_dma_crossed_64k           equ   9
ERR_media_type_not_found      equ   12
ERR_uncorrectable_CRC_error   equ   $10
ERR_controller_failure        equ   $20
ERR_seek_failed               equ   $40
ERR_disk_timeout              equ   $80
;
arg1        equ   4
arg2        equ   arg1+4
arg3        equ   arg2+4
arg4        equ   arg3+4
;
buffer      equ   arg2
            align    2
;
;------------------------------------------------------------------------------------
; Parallel port IDE driver
;
;
;

; -----------------------------------------------------------------------------	
;  ppide_read_id
;  ppide_info   equivalent
; -----------------------------------------------------------------------------	
; Read the 512 byte ID information from the attached drive
;
;  arg1  disk number  (D1)
;  arg2  buffer or NULL	(A0)
;  A1    disk table pointer
;  A5    principal M68k I/O address of device
;
;-----------------------------------------------------------------------------

ppide_read_id:
ppide_info:
            move.l   (buffer,sp),a0          ; get buffer address

            move     a0,d0                   ; test for NULL
            tst.l    d0
            beq      short_info              ; LBA & GEOM info only

            bsr      ide_wait_not_busy       ; make sure drive is ready
            bne      error_return

            move.b   (disk_slave_o,a1),d1    ; get slave byte
            and.b    #$10,d1                 ; for safety
            or.b     #$E0,d1                 ; select LBA mode
            move.b   #ide_head,d0            ; write to head register
            bsr      ide_write

            move.b   #ide_command,d0
            move.w   #ide_cmd_id,d1
            bsr      ide_write               ; ask the drive to read the ID

            bsr      ide_wait_drq            ; wait until it's got the data
            bne      error_return

            bsr      read_data               ; get the data

short_info:
            move.l   disk_lba_o(a1),d2       ; LBA info return
            move.l   d2,arg1(sp)
            move.l   disk_geom_o(a1),d2      ; geometry return

            bra      get_error_status

; -----------------------------------------------------------------------------	
;  ppide_read
; -----------------------------------------------------------------------------	
;  read a 512 byte sector, specified by the 4 bytes in "lba",
;  Return, acc is zero on success, non-zero for an error
;
;  arg1  disk number  (D1)
;  arg2  buffer	(A0)
;  A1    disk table pointer
;  D2    LBA address
;  D3    sector count (assumed to be 1)
;  A5    principal M68k I/O address of device
;
;
;-----------------------------------------------------------------------------

ppide_read:
            move.l   (buffer,sp),a0          ; get buffer address
            move.l   #5,d0                   ; error code
            cmp.l    (disk_lba_o,a1),d2      ; check lba address
            bcc.s    read_error

            move.l   #4,d0                   ; error code
            cmp.l    #1,d3
            bne.s    read_error              ; for now

            bsr      ide_wait_not_busy       ; make sure drive is ready
            bne.s    read_error              ; d0 == -1

            bsr      wr_lba                  ; select device

            move.b   #ide_command,d0
            move.w   #ide_cmd_read,d1
            bsr      ide_write

            bsr      ide_wait_drq            ; wait until it's got the data
            bne.s    read_error              ; d0 == -1

            bsr      read_data               ; get the data

get_error_status:
            bsr      ide_wait_not_busy       ; make sure drive is ready;
            bne.s    read_error              ; d0 == -1;

            move.b   #ide_status,d0
            bsr      ide_read

            and.l    #1,d1                   ; check error bit;
            beq.s    exg_return

            move.b   #ide_err,d0
            bsr      ide_read

            and.l    #$FF,d1                ; mask to byte;
            or.w     #$800,d1

exg_return:
            exg      d1,d0
error_return:
read_error:
            rts

good_return:
            clr.l	d0
            rts


; -----------------------------------------------------------------------------	
;  ppide_verify
; -----------------------------------------------------------------------------	
;  read a sector, specified by the 4 bytes in "lba",
;  Return, acc is zero on success, non-zero for an error
;
;  arg1  disk number  (D1)
;  A1    disk table pointer
;  D2    LBA address
;  D3    sector count (assumed to be 1)
;  A5    principal M68k I/O address of device
;

;-----------------------------------------------------------------------------
ppide_verify:
            bsr      ide_wait_not_busy    ; make sure drive is ready
            bne      error_return

            move.l   8(a6),d3             ; logical block number
            move.l   12(a6),d2            ; master/slave
            bsr      wr_lba               ; select device

            move.b   #ide_command,d0
            move.w   #ide_cmd_read,d1
            bsr      ide_write

            bsr      ide_wait_drq         ; wait until it's got the data
            bne      error_return

            bsr      verify_data          ; get the data

            bra      get_error_status


;-----------------------------------------------------------------------------
;  ppide_write
; -----------------------------------------------------------------------------
;  write a sector, specified by the 4 bytes in "lba",
;  Return, acc is zero on success, non-zero for an error
;
;  arg1  disk number (D1)
;  arg2  buffer (A0)
;  A1    disk table pointer
;  D2    LBA address
;  D3    sector count (assumed to be 1)
;  A5    principal M68k I/O address of device


;-----------------------------------------------------------------------------
ppide_write:
            move.l   (buffer,sp),a0          ; get buffer address
            move.l   #5,d0                   ; error code
            cmp.l    (disk_lba_o,a1),d2      ; check lba address
            bcc      read_error

            move.l   #4,d0                   ; error code
            cmp.l    #1,d3
            bne      read_error              ; for now

            bsr      ide_wait_not_busy       ; make sure drive is ready
            bne      read_error              ; d0 == -1

            bsr      wr_lba                  ; select device

            move.b   #ide_command,d0
            move.w   #ide_cmd_write,d1
            bsr      ide_write

            bsr      ide_wait_drq            ; wait until it's got the data
            bne      error_return

            bsr      write_data              ; put the data

            bra      get_error_status


RECAL       equ      1

;-----------------------------------------------------------------------------
;--------ppide_reset-------------------------------------------------------
;
;  arg1  disk number  (D1)
;  A1    disk table pointer
;  A5    principal M68k I/O address of device
;
;   Returns D1 (in stack) mask of devices present (D0 == 0)
;   Error return if no devices on unit.
; -----------------------------------------------------------------------------	

ppide_reset:
            move.l   #0,a0                         ; accumulate D1 mask here

            move.b   #rd_ide_8255,portCTRL_o(a5)   ; bsr set_ppi_rd
;           bsr.s    set_ppi_rd                    ; setup for a read cycle

            nop
            nop
            move.b   #ide_rst_line,portC_o(a5)     ; assert the RST line on the interface

            move.l   #10000,d0                     ; half a second
            jsr      usec_delay                    ; wait 10ms

            clr.b    portC_o(a5)

            move.l   #10000,d0                     ; half a second
            jsr      usec_delay                    ; wait 10ms

            move.l   d2,-(sp)                      ; save D2
            move.b   #4,d2                         ; some drives take a while to reset
resetwait:
            bsr      ide_wait_not_busy
            dbra     d2,resetwait
            move.l   (sp)+,d2                      ; restore D2

            move.b   #ide_status,d0
            bsr      ide_read                      ; read status of drive 0
            cmp.b    #$50,d1                      ; check exact status bits
            bne.s    reset1

;.if RECAL
            btst     #4,(disk_slave_o,a1)          ; test SLAVE bit
            bne      reset10                       ; branch if SLAVE
            move.b   #ide_command,d0               ; do a recalibrate of drive 0
            move.b   #ide_cmd_recal,d1             ; do a recalibrate of the drive
            bsr      ide_write

            bsr      ide_wait_not_busy
            bne      reset1
reset10:
;.endif
            add.l    #1,a0                         ; mark drive 0 present
reset1:
            move.b   #$C0,d1
            move.b   #ide_head,d0                  ; select drive 1
            bsr      ide_write

            move.l   #1000,d0                      ; delay 10 ms = 10,000 usec
            jsr      usec_delay

            move.b   #ide_status,d0
            bsr      ide_read                      ; read status of drive 0
            cmp.b    #$50,d1                      ; check exact status bits
            bne      reset2
;.if RECAL
            btst     #4,(disk_slave_o,a1)          ; test SLAVE bit
            beq      reset20                       ; branch if SLAVE
            move.b   #ide_command,d0               ; do a recalibrate of drive 0
            move.b   #ide_cmd_recal,d1             ; do a recalibrate of the drive
            bsr      ide_write

            bsr      ide_wait_not_busy
            bne      reset2
reset20:
;.endif
            add.l    #2,a0                         ; mark drive 1 present
reset2:
            move.b   #$E0,d1
            move.b   #ide_head,d0                  ; select drive 0
            bsr      ide_write

            move.l   a0,d1                         ; move to D1
            move.l   d1,arg1(sp)                   ; save in stack
            clr.l    d0
            tst.b    d1
            bne.s    reset3
            move.l   #1,d0                         ; error return
reset3:
            rts




;------------------------------------------------------------------------------
; IDE INTERNAL SUBROUTINES 
;------------------------------------------------------------------------------


;	
;----------------------------------------------------------------------------
;  Get Error code
;
;  when an error occurs, we get bit 0 of A set from a call to ide_drq
;  or ide_wait_not_busy (which read the drive's status register).  If
;  that error bit is set, we should jump here to read the drive's
;  explaination of the error, to be returned to the user.  If for
;  some reason the error code is zero (shouldn't happen), we'll
;  return 255, so that the main program can always depend on a
;  return of zero to indicate success.
;
;  Exit with:
;  D0 contains exact status byte as read
;  D1 destroyed
;----------------------------------------------------------------------------
;.if 0
;get_err:
;            move.b   #ide_err,d0
;            bsr      ide_read

;            clr.l    d0
;            or.b     d1,d0
;            bne      gerr2
;            sub.b    #1,d0
;gerr2:
;            rts
;.endif


;-----------------------------------------------------------------------------
;  Wait for BUSY to be reset
;
;  Exit with:
;	D0 contains exact status byte as read
;	D1 destroyed
;
;------------------------------------------------------------------------------
ide_wait_not_busy:
            move.l   d4,-(sp)

            move.l   #-1,d4
wnb1:
            move.b   #ide_status,d0
            bsr      ide_read

            move.b   d1,d0
            eor.b    #$40,d0       ; want busy==0, rdy==1
            and.b    #$C0,d0       ; mask off Busy(7) & Drdy(6)
            dbeq.w   d4,wnb1        ; loop
            bne.s    wnb2

            clr.l    d0             ; zero extend D0, set EQ (Z-bit)
wnb2:
            ; return EQ if no timeout, NE if timeout
            move.l   (sp)+,d4
            tst.l    d0
            rts

;------------------------------------------------------------------------------
;  Wait for the drive to be ready to transfer data (DRQ = data request)
;  Returns the drive's status in Acc
;
;  Exit with:
;  D0 contains exact status byte as read
;  D1 destroyed
;
;------------------------------------------------------------------------------
ide_wait_drq:
            move.l   d4,-(sp)

            move.l   #-1,d4
wdrq1:
            move.b   #ide_status,d0
            bsr      ide_read

            move.b   d1,d0
            eor.b    #$08,d0       ; want busy==0, drq==1
            and.b    #$88,d0       ; mask off Busy(7) and DRQ(3)
            dbeq.w   d4,wdrq1
            bne.s    wdrq2

            clr.l    d0             ; zero extend D0
wdrq2:
            move.l   (sp)+,d4
            tst.l    d0
            rts

;.if 0
;wdrq2a:
;            move.l   d1,-(sp)
;            pea      fmt2
;            jsr      cprintf
;            lea.l    8(sp),sp
;            bra      wdrq2
;
;fmt2:
;            .asciz	"WDRQBusy: %hx\n"
;.endif


;------------------------------------------------------------------------------
; Read a sector of 512 bytes into memory at (A0)
;
;  Call with:
;  A0 -- pointer to the data block
;  A5 -- base address of 8255
;
;  Exit with:
;  A0 is updated
;  D0,D1 are destroyed
;
;-----------------------------------------------------------------------------
read_data:
;.if FASTXFER
;.if FASTXFER<2
            ; WRS - an optimised read loop based on my Linux driver
            move.w   a0,d1                      ; we need to check if the buffer is 4-byte aligned
            and.b    #3,d1                      ; mask off low 2 bits of address
            bne      read_data_unaligned        ; handle unaligned case with the slow transfer loop
.endif
            movem.l  d2-d3/a1,-(sp)             ; save registers
            lea      portCTRL_o(a5),a1          ; save addr of 8255 control register
            move.b   #rd_ide_8255,(a1)          ; setup for read
            move.b   #ide_data,portC_o(a5)      ; select IDE data port
            move.w   #128-1,d1                  ; read 512 bytes = 128 dwords
            move.b   #13,d2                     ; 8255 bit set/reset mode: pin C6 on
            move.b   #12,d3                     ; 8255 bit set/reset mode: pin C6 off
ide_input_nextword:
            ; read a DWORD;
            move.b   d2,(a1)                    ; begin /RD pulse
            move.w   portA_o(a5),d0             ; reads LSB then MSB in that order
            move.b   d3,(a1)                    ; end /RD pulse
            swap     d0                         ; top word is done
            move.b   d2,(a1)                    ; begin /RD pulse
            move.w   portA_o(a5),d0             ; reads LSB then MSB in that order
            move.b   d3,(a1)                    ; end /RD pulse
            move.l   d0,(a0)+                   ; store to memory, advance ptr
            dbra     d1,ide_input_nextword      ; loop until done
            move.b   #rd_ide_8255,(a1)          ; setup for read
            clr.b    portC_o(a5)                ; release bus signals
            movem.l  (sp)+,d2-d3/a1             ; restore registers
            rts
;.endif
;.if FASTXFER<2
read_data_unaligned:
            move.l   d2,-(sp)                   ; save D2

            move.b   #ide_data,d0
            move.w   #256-1,d2                  ; read 512 bytes
rdblk2: 
            bsr      ide_read
;    Watch Out!  The buffer is byte aligned (68000 problem);
            move.b   d1,(a0)+                   ; store the first byte
            rol.w    #8,d1
            move.b   d1,(a0)+                   ; store the second byte
;********************************************************************

            dbra     d2,rdblk2

            move.l   (sp)+,d2                   ; restore D2
            rts
;.endif


;-----------------------------------------------------------------------------
; Write a block of 512 bytes (from A0) to the drive
;
;  Call with:
;  A0 -- pointer to the data block
;  A5 -- base address of 8255
;
;  Exit with:
;  A1 is preserved
;  D0,D1 are destroyed
;
;-----------------------------------------------------------------------------
write_data:
;.if FASTXFER
;.if FASTXFER<2
            ; WRS - an optimised write loop based on my Linux driver;
            move.w   a0,d1                   ; we need to check if the buffer is 4-byte aligned
            and.b    #3,d1                   ; mask off low 2 bits of address
            bne      write_data_unaligned    ; handle unaligned case with the slow transfer loop
;.endif
            movem.l  d2-d3/a1,-(sp)          ; save registers
            lea      portCTRL_o(a5),a1       ; save addr of 8255 control register
            move.b   #wr_ide_8255,(a1)       ; setup for read
            move.b   #ide_data,portC_o(a5)   ; select IDE data port
            move.w   #128-1,d1               ; read 512 bytes = 128 dwords
            move.b   #11,d2                  ; 8255 bit set/reset mode: pin C5 on
            move.b   #10,d3                  ; 8255 bit set/reset mode: pin C5 off
            ; note that to give the drive time to latch the data we do
            ;  housekeeping including swaps and branches while the /WR
            ; line is asserted -- so the first thing we do each loop is
            ; end the previous cycle's /WR pulse; this is a NOP on the
            ; entry to the first loop
ide_output_nextword:
            ; write a DWORD;
            move.l   (a0)+,d0                ; load from memory, advance ptr
            swap     d0                      ; top word goes first
            move.b   d3,(a1)                 ; end /WR pulse (NOP on first loop)
            move.w   d0,portA_o(a5)          ; writes LSB then MSB in that order
            move.b   d2,(a1)                 ; begin /WR pulse
            swap     d0                      ; get the bottom half
            move.b   d3,(a1)                 ; end /WR pulse
            move.w   d0,portA_o(a5)          ; writes LSB then MSB in that order
            move.b   d2,(a1)                 ; begin /WR pulse
            dbra     d1,ide_output_nextword  ; loop until done
;-------------------------------------------------------------
            move.b   d3,(a1)                 ; end final /WR pulse
            move.b   #rd_ide_8255,(a1)       ; reset for read
            clr.b    portC_o(a5)             ; release bus signals
            movem.l  (sp)+,d2-d3/a1          ; restore registers
            rts
;.endif
;.if FASTXFER<2
write_data_unaligned:
            move.l   d2,-(sp)                ; save D2

            move.b   #ide_data,d0
            move.w   #256-1,d2
wrblk2: 
;    Watch Out!  The buffer is byte aligned (68000 problem)
            move.b   (a0)+,d1
            rol.w    #8,d1
            move.b   (a0)+,d1
;************************************************************************/
            ror.w    #8,d1
            bsr      ide_write
            dbra     d2,wrblk2

            move.l   (sp)+,d2                ; restore D2;
            rts
;.endif


;	
;-------------------------------------------------------------------------------

; Low Level I/O to the drive.  These are the routines that talk
; directly to the drive, via the 8255 chip.  Normally a main
; program would not call to these.

; Do a read bus cycle to the drive, using the 8255.
;
;  Call With:
;	D0.b = ide register address
;
;  Exit With:
;	D0.b preserved
;	D1.w = word read from IDE drive
;
;
ide_read:
            move.b   #rd_ide_8255,portCTRL_o(a5)   ; bsr set_ppi_rd
;           bsr      set_ppi_rd                    ; setup for a read cycle
;
            move.b   d0,portC_o(a5)                ; drive address onto control lines
            or.b     #ide_rd_line,d0               ; assert RD pin
            move.b   d0,portC_o(a5)
;
            move.b   portB_o(a5),d1                ; read MSB
            lsl.w    #8,d1                         ; make room for LSB
            move.b   portA_o(a5),d1
;
            eor.b    #ide_rd_line,d0               ; clear RD signal
            move.b   d0,portC_o(a5)
;
;           move.b   #0,portC_o(a5)                ; clear all control lines
            clr.b    portC_o(a5)                   ; release bus signals

            rts




; Do a write bus cycle to the drive, via the 8255
;
;  Call With:
;  D0.b = ide register address
;  D1.w = word to write out
;
;  Exit with:
;  Nothing changed
;

ide_write:
            move.b   #wr_ide_8255,portCTRL_o(a5)   ; bsr	set_ppi_wr
;
            move.b   d1,portA_o(a5)                ; output LSB
            ror.w    #8,d1
            move.b   d1,portB_o(a5)                ; output MSB
            ror.w    #8,d1
;
            move.b   d0,portC_o(a5)                ; output the address
            or.b     #ide_wr_line,d0               ; assert the WR line
            move.b   d0,portC_o(a5)
;
            eor.b    #ide_wr_line,d0               ; clear the WR line
            move.b   d0,portC_o(a5)
;
;           move.b   #0,portC_o(a5)                ; release bus signals
            clr.b    portC_o(a5)                   ; release bus signals
            rts

;------------------------------------------------------------------------------
;  Verify a block of 512 bytes (one sector) from the drive
;
;  Call with:
;  Nothing
;
;  Exit with:
;  D0..D2 are destroyed
;
;-----------------------------------------------------------------------------
verify_data:
            move.b   #ide_data,d0
            move.w   #256-1,d2
verblk2: 
            bsr      ide_read
            dbra     d2,verblk2
;
            rts


;-----------------------------------------------------------------------------
; write the logical block address to the drive's registers
;
;  Call with:
;  A1 = disk table pointer (use to get slave bit)
;  D2.l = logical block address
;  D3.b = sector count
;
;  Exit with:
;  D0, D1  are destroyed
;
;-----------------------------------------------------------------------------
wr_lba:
            move.l   d2,d1                ; LBA address to D1
            move.b   (disk_slave_o,a1),d0 ; get slave byte
            and.b    #$10,d0             ; for safety
            rol.l    #8,d1                ; hi byte of LBA to low 8 bits
            and.b    #$0F,d1             ; 28 bit limit
            or.b     d0,d1                ; slave bit to D1
            or.b     #$E0,d1             ; select LBA mode

            move.b   #ide_head,d0         ; write to head register
            bsr      ide_write
;
            rol.l    #8,d1
            sub.l    #1,d0                ; cyl msb reg
            bsr      ide_write
;
            rol.l    #8,d1
            sub.l    #1,d0                ; cyl lsb reg
            bsr      ide_write
;
            rol.l    #8,d1
            sub.l    #1,d0                ; sector reg
            bsr      ide_write
;
            move.b   d3,d1                ; sector count from D3
            and.b    #$7f,d1             ; for safety
            sub.l    #1,d0                ; sector count reg
            bsr      ide_write
;
            rts

;**********************************************************************
;
; Delay in microseconds:
;
;    Enter with:
;     D0 = delay in microseconds (resolution is 16 usec)
;
;**********************************************************************/
;
usec_delay:
            move.l   d1,-(sp)             ; save D1
            lsr      #4,d0                ; divide by 16
            move.l   d0,d1                ; D0.w is the low count
            swap     d1                   ; D1.w is high count, likely 0
ud1:
            jsr      usec1x               ; 16 microsecond delay
            dbra     d0,ud1               ; count down to -1
            dbra     d1,ud1               ; count down to -1
;
            move.l   (sp)+,d1             ; restore D1
            rts
;
usec20:
            nop
            nop
            nop
            nop
usec16:
            nop
            nop
            nop
usec1x:                                   ; positioned for 'usec_delay' above
            nop
usec12:
            nop
            nop
usec10:
            nop
usec09:
            rts

;-----------------------------------------------------------------------------
; End of PPIDE disk driver
;

fbuffer:       ds.b     1                  ; frame buffer
