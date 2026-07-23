;
; ==== libfujinet ====
; This software implements the basic protocol required to communicate with the
; FujiNet SPI interface via a Digicool MECB 68008. These routines are at a very
; low level. Most uses would communicate with the FujiNet device via the higher-level
; fujinet_* command routines.
;
; FujiNet SPI has the following bits:
;
;  Input:
;      Bit 7 = BUS_READY*     (BIT_CMD_RDY)
;      Bit 6 = BUS_PROCEED*   (BIT_PROCEED)
;      Bit 1-5 = UNUSED
;      Bit 0 = BUS_MISO       (BIT_MISO)
;
BIT_CMD_RDY                equ   7
BIT_PROCEED                equ   6
BIT_MISO                   equ   0

;
; Output:
;      Bit 7 = BUS_CMD*       (BIT_CMD)
;      Bit 6 = BUS_DATA*      (BIT_DATA)
;      Bit 3-5 = UNUSED
;      Bit 2 = BUS_CS*        (BIT_CS)
;      Bit 1 = BUS_MOSI       (BIT_MOSI)
;      Bit 0 = BUS_CLK        (BIT_CLK)
;
MASK_SPI                   equ   $fc   ; Mask out all but BUS_CLK and BUS_MOSI
FN_INIT                    equ   $fe   ; BUS_CLK low, BUS_MOSI high
BIT_CMD                    equ   7
BIT_DATA                   equ   6
BIT_CS                     equ   2
BIT_MOSI                   equ   1
BIT_CLK                    equ   0

MSCNT10MHZ                 equ   545      ; number of loops to delay ~1 mS with 10 MHz 68008 CPU

DCB_FRAME_SIZE             equ   8
;
; Initialise the FujiNet hardware (d2 contains current assert_val)
;
fujinet_hal_init:
         move.b   #FN_INIT,d2 ; clock low, MOSI high
         move.b   d2,FN_CSR
         rts

;
; Output byte to Fujinet device
; entry:
;    d0 = byte to write
;    d2 = assert_val
; exit
;    d0,d1 = modified
;    d2 = assert_val
;
fujinet_hal_tx:
         move.w   #7,d1       ; 8 bits to transmit
tx_bit:
         lsl.b    d0          ; shift bit to transmit into carry
         bcs      tx_high     ; branch if handle hit bit
tx_low:
         and.b    #MASK_SPI,d2   ; clock low, MOSI low
         move.b   d2,FN_CSR
         add.b    #1,d2          ; clock high, MOSI low
         move.b   d2,FN_CSR
         sub.b    #1,d2          ; clock low, MOSI low
         move.b   d2,FN_CSR
         dbra     d1,tx_bit
         rts
tx_high:
         bset     #BIT_MOSI,d2   ; clock low, MOSI high
         move.b   d2,FN_CSR
         add.b    #1,d2          ; clock high, MOSI high
         move.b   d2,FN_CSR
         sub.b.   #1,d2          ; clock low, MOSI high
         move.b   d2,FN_CSR
         dbra     d1,tx_bit
         rts

;
; Input byte from FujiNet device
; exit:
;    d0 = byte read
;    d2 = assert_val
fujinet_hal_rx:
         move.w   #7,d1          ; 8 bits to receive
         move.b   #0,d0          ; initialize input byte
rx_bit:
         or.b     #3,d2          ; clock high, MOSI high
         move.b   d2,FN_CSR      ; $7f
         swap     d2
         move.b   FN_CSR,d2
         lsr.b    d2
         roxl.b   d0
         swap     d2
         and.b    #MASK_SPI,d2
         or.b     #2,d2   ; clock low, MOSI high $7e
         move.b   d2,FN_CSR
         dbra     d1,rx_bit
         rts

;
; Assert the COMMAND line (d2 contains current assert_val)
;
fujinet_hal_assert_cmd:
         bclr     #BIT_CMD,d2
         move.b   d2,FN_CSR
         rts

;
; Deassert the COMMAND line (d2 contains current assert_val)
;
fujinet_hal_deassert_cmd:
         bset     #BIT_CMD,d2
         move.b   d2,FN_CSR
         rts

;
; Assert the SPI CS line (d2 contains current assert_val)
;
fujinet_hal_assert_spi_cs:
         bclr     #BIT_CS,d2
         move.b   d2,FN_CSR
         rts
;
; Deassert the SPI CS line (d2 contains current assert_val)
;
fujinet_hal_deassert_spi_cs:
         bset     #BIT_CS,d2
         move.b   d2,FN_CSR
         rts

;
; Wait for CCOMMAND_READY to be asserted
;
fujinet_hal_wait_cmd_ready:
         tst.b    FN_CSR
         bmi      fujinet_hal_wait_cmd_ready
         rts

; ENTRY: d0 = timeout in 10ths of seconds
; EXIT:   C-flag if timeout
fujinet_hal_wait_cmd_ready_timeout:
         tst.b    FN_CSR
         bmi      wait_cmd2
         and.b    #$fe,ccr    ; clear the carry flag
         rts

wait_cmd2:
         tst.w    d0          ; timer timed out?
         bne      wait_cmd3
         or.b     #$01,ccr    ; set the carry flag
         rts

wait_cmd3:
         bsr      delay1ms
         sub.w    #1,d0
         bra      fujinet_hal_wait_cmd_ready_timeout

;
; Delay about 1mS
;
delay1ms:
         move.l   d0,-(a7)
         move.w   #MSCNT10MHZ,d0
delay1ms2:
         dbra     d0,delay1ms2
         move.l   (a7)+,d0
         rts

;
; Poll BUS_PROCEED line
; EXIT: d0=0 if not asserted; d0=1 if asserted
;
fujinet_poll_proceed:
         btst.b   #BIT_PROCEED,FN_CSR
         beq      proceed_asserted
         move.b   #0,d0
         rts

proceed_asserted:
         move.b   #1,d0
         rts

;
; fujinet_checksum
; a1 = pointer to buffer
; d1 = length of buffer-1
;
; exit: d0 = checksum
fujinet_checksum:
         movem.l  d2/a1,-(a7)          ; save buffer pointer
         move.l   #0,d0
fc_loop:
         move.b   (a1)+,d2             ; get a byte
         eor.b    d2,d0                ; adjust the checksum
         dbra     d1,fc_loop           ; loop until all bytes processed
         movem.l  (a7)+,d2/a1          ; restore buffer pointer
         rts

;
; fujinet_dcb_exec
;
; ENTRY: a0 = dcb
; EXIT:  d0 = FUJINET_RC

fujinet_dcb_exec:
         movem.l  d1-d5/a0-a1,-(a7)       ; save register
         bsr      fujinet_hal_init        ; initial assert value
         sub.l    #DCB_FRAME_SIZE,a7      ; make space for the frame
         move.l   a7,a1                   ; a1 points to the DCB frame
         move.l   (a0),(a1)               ; copy DCB to DCB frame
         move.l   #3,d1                   ; actual data size (minus 1) of DCB frame
         bsr      fujinet_checksum        ; get the checksum
         move.b   d0,DCB_CHECKSUM(a1)     ; save it in the DCB frame
         bsr      fujinet_hal_assert_cmd  ; BUS_COMMAND = 0

; Wait for CMD_RDY to be asserted and then transmit the command frame
         move.w   DCB_TIMEOUT(a0),d0
         bsr      fujinet_hal_wait_cmd_ready_timeout
         bcs      exec_exit_TIMEOUT       ; ff timed out, exit
         move.l   #5,d1                   ; size of DCB frame with checksum
         bsr      tx_buff                 ; send the command frame
;
         bsr      fujinet_hal_wait_cmd_ready
         bsr      fujinet_hal_assert_spi_cs
         bsr      fujinet_hal_rx
         bsr      fujinet_hal_deassert_spi_cs
         add.l    #DCB_FRAME_SIZE,a7      ; remove the command frame from the stack
         cmp.b    #'A',d0
         bne      exec_exit_NO_RACK
;
         tst.w    DCB_TX_BUFFER_LEN(a0)   ; Check if any buffer data to transmit
         beq      exec_skip_tx_buf        ; if no, skip
; prepare to transmit TX buffer
         bsr      fujinet_hal_wait_cmd_ready
         move.w   DCB_TX_BUFFER_LEN(a0),d1
         move.l   DCB_TX_BUFFER(a0),a1    ; a1 points to the transmit buffer
         bsr      tx_buff                 ; send the buffer
; wait for the acknowledgement
         bsr      fujinet_hal_wait_cmd_ready
         bsr      fujinet_hal_assert_spi_cs
         bsr      fujinet_hal_rx
         bsr      fujinet_hal_deassert_spi_cs
         cmp.b    #'A',d0
         bne      exec_exit_NO_TACK

exec_skip_tx_buf:
         tst.w    DCB_RX_BUFFER_LEN(a0)   ; Check if anything to receive 
         beq      exec_skip_rx_buf
; prepare to receive into RX buffer
         bsr      fujinet_hal_wait_cmd_ready
         move.w   DCB_RX_BUFFER_LEN(a0),d1
         move.l   DCB_RX_BUFFER(a0),a1    ; a1 points to the receive buffer
         bsr      rx_buff                 ; fill the receive buffer
; TODO - check checksum

; wait for the command completion
exec_skip_rx_buf:
         bsr      fujinet_hal_wait_cmd_ready
         bsr      fujinet_hal_assert_spi_cs
         bsr      fujinet_hal_rx
         bsr      fujinet_hal_deassert_spi_cs
         cmp.b    #'C',d0
         bne      exec_exit_NO_COMPLETE

         move.b   #FUJINET_RC_OK,d0
         bra      exec_exit

exec_exit_NO_COMPLETE:
         move.b   #FUJINET_RC_NO_COMPLETE,d0
         bra      exec_exit

; split the two ACK-cases just for debug purposes (only one is needed)
exec_exit_NO_RACK:
         bsr      out2h
         move.b   #FUJINET_RC_NO_ACK,d0
         bra      exec_exit

exec_exit_NO_TACK:
         move.b   #FUJINET_RC_NO_ACK,d0
         bra      exec_exit

exec_exit_TIMEOUT:
         move.b   #FUJINET_RC_TIMEOUT,d0
exec_exit
         bsr      fujinet_hal_deassert_cmd
         movem.l  (a7)+,d1-d5/a0-a1
         rts

; tx_buff
; ENTRY a1.l = pointer to buffer
;       d1.w = bytes to send
; EXIT   a1,d0,d1,d2,d3 modified
;
tx_buff:
         cmp.w    #64,d1         ; if length < 64?
         bhs      tx_buff2
         move.w   d1,d3          ; d3 is the residual number of bytes to send (<64)
         bra      tx_buff_64
tx_buff2:
         move.w   #64,d3         ; transfer 64 bytes
         move.w   d1,d5
         bsr      tx_buff_64
         move.w   d5,d1
         sub.w    #64,d1
         bsr      fujinet_hal_wait_cmd_ready
         tst.w    d1
         bne      tx_buff
         rts

;
; tranmit a transaction of 64 or less bytes
; ENTRY a1.l = pointer to buffer
;       d3.w = bytes to send
; EXIT  a1,d0,d1,d2,d3 - modified
;
tx_buff_64:
         bsr      fujinet_hal_assert_spi_cs
         tst.w    d3
         beq      tx_buff3
tx_buff1:
         ; tx byte at pointer
         move.b   (a1)+,d0
         bsr      fujinet_hal_tx
         sub.w    #1,d3
         bne      tx_buff1

tx_buff3:
         bsr      fujinet_hal_deassert_spi_cs
         rts

; -----------------------------------------------------------------------------

;ENTRY a1 = pointer to buffer
;      d1 = bytes to receive
;      d4 = timeout (TODO)
rx_buff:
         tst.w    d1
         bne      rx_buff1
         rts
rx_buff1:
         cmp.w    #64,d1
         bhs      rx_buff4
         move.w   d1,d3
         bra      rx_buff_64
rx_buff4:
         move.w   #64,d3
         move.w   d1,d5
         bsr      rx_buff_64
         move.w   d5,d1
         sub.w    #64,d1
         bsr      fujinet_hal_wait_cmd_ready
         tst.w    d1
         bne      rx_buff1
         rts

;
; receive a transaction of 64 or less bytes
; ENTRY a1 = pointer to buffer
;       d3 = bytes to receive
;       d4 = timeout (TODO)
rx_buff_64:
         bsr      fujinet_hal_assert_spi_cs
         tst.w    d3
         beq      rx_buff3
rx_buff2:
         ; rx byte to pointer
         bsr      fujinet_hal_rx
         move.b   d0,(a1)+
         sub.w    #1,d3
         bne      rx_buff2

rx_buff3:
         bsr      fujinet_hal_deassert_spi_cs
         rts
