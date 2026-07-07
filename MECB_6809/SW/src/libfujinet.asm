;
; ==== libfujinet ====
; This software implements the basic protocol required to communicate with the
; FujiNet SPI interface via an Digicool MECB 6809. These routines are at a very
; low level. Most uses would communicate with the FujiNet device via the higher-level
; fujinet_* command routines.
;
; FujiNet SPI has the following bits:
;
;  Input:
;      Bit 7 = BUS_READY*     (MASK_CMD_READY, BIT_CMD_RDY)
;      Bit 6 = BUS_PROCEED*   (MASK_PROCEED, BIT_PROCEED)
;      Bit 1-5 = UNUSED
;      Bit 0 = BUS_MISO       (MASK_MISO, BIT_MISO)
;
MASK_CMD_RDY               equ   $80
MASK_PROCEED               equ   $40
MASK_MISO                  equ   $01
BIT_CMD_RDY                equ   7
BIT_PROCEED                equ   6
BIT_MISO                   equ   0

;
; Output:
;      Bit 7 = BUS_CMD*       (MASK_CMD,BIT_CMD)
;      Bit 6 = BUS_DATA*
;      Bit 3-5 = UNUSED
;      Bit 2 = BUS_CS*
;      Bit 1 = BUS_MOSI       (MASK_MOSI,BIT_MOSI)
;      Bit 0 = BUS_CLK
;
MASK_CMD                   equ   $80
MASK_MOSI                  equ   $02
MASK_SPI                   equ   $fc   ; Mask out all but BUS_CLK and BUS_MOSI
FN_INIT                    equ   $fe   ; BUS_CLK low, BUS_MOSI high
BIT_CMD                    equ   7
BIT_MOSI                   equ   1
BIT_CLK                    equ   0

MSCNT1MHZ   equ   122      ; number of loops to delay 1 mS with 1 MHz 6809 CPU
MSCNT2MHZ   equ   247      ; number of loops to delay 1 mS with 2 MHz 6809 CPU

;
; Initialise the FujiNet hardware
;
fujinet_hal_init:
         pshs  a
         lda   #FN_INIT       ; clock low, MOSI high
         sta   assert_val
         sta   FN_CSR
         puls  a,pc

;
; Output byte to Fujinet device
; entry:
;    a = byte to write
;
fujinet_hal_tx:
         pshs  a,b,x          ; save registers
         ldx   #8             ; 8 bits to transmit
tx_bit:
         ldb   assert_val
         lsla                 ; shift bit to transmit into carry
         bcs   tx_high        ; branch if handle hit bit
tx_low:
         andb  #MASK_SPI      ; clock low, MOSI low
         stb   FN_CSR
         incb                 ; clock high, MOSI low
         stb   FN_CSR
         decb                 ; clock low, MOSI low
         stb   FN_CSR
         leax  -1,x
         bne   tx_bit
         puls  a,b,x,pc       ; restore registers and return
tx_high:
         orb   #2             ; clock low, MOSI high
         stb   FN_CSR
         incb                 ; clock high, MOSI high
         stb   FN_CSR
         decb                 ; clock low, MOSI high
         stb   FN_CSR
         leax  -1,x
         bne   tx_bit
         puls  a,b,x,pc       ; restore registers and return

;
; Input byte from FujiNet device
; exit:
;    a = byte read
fujinet_hal_rx:
         pshs  b,x            ; save registers
         ldx   #8             ; 8 bits to receive
         lda   #0             ; initialize input byte

rx_bit:
         ldb   assert_val
         orb   #3             ; clock high, MOSI high
         stb   FN_CSR
         ldb   FN_CSR
         rorb
         rola
         ldb   assert_val
         andb  #MASK_SPI
         orb   #2             ; clock low, MOSI high
         stb   FN_CSR
         leax  -1,x
         bne   rx_bit
         puls  b,x,pc       ; restore registers and return

;
; Assert the COMMAND line
;
fujinet_hal_assert_cmd:
         pshs  a
         lda   assert_val     ; de-assert
         anda  #$7f           ; BUS_CMD low
         sta   assert_val
         sta   FN_CSR
         puls  a,pc

;
; Deassert the COMMAND line
;
fujinet_hal_deassert_cmd:
         pshs  a
         lda   assert_val
         ora   #$80
         sta   assert_val
         sta   FN_CSR
         puls  a,pc

;
; Assert the SPI CS line
;
fujinet_hal_assert_spi_cs:
         pshs  a
         lda   assert_val
         anda  #$fb          ; 0b11111011
         sta   assert_val
         sta   FN_CSR
         puls  a,pc

;
; Deassert the SPI CS line
;
fujinet_hal_deassert_spi_cs:
         pshs  a
         lda   assert_val     ; de-assert
         ora   #$04
         sta   assert_val
         sta   FN_CSR
         puls  a,pc

;
; Poll the CCOMMAND_READY line
;  exit: if A = 0, then asserted
;
fujinet_hal_poll_cmd_ready:
         lda   FN_CSR
         anda  #MASK_CMD_RDY
         rts

;
; Wait for CCOMMAND_READY to be asserted
;
fujinet_hal_wait_cmd_ready:
         pshs  a
fujinet_hal_wait_cmd_ready2:
         lda   FN_CSR
         anda  #MASK_CMD_RDY
         bne   fujinet_hal_wait_cmd_ready2
         puls  a,pc

; ENTRY: dcb_ttimeout = timeout in 10ths of seconds
; EXIT:   C-flag if timeout
fujinet_hal_wait_cmd_ready_timeout:
         pshs  a,y
         ldy   dcb_ttimeout
wait_cmd1:
         lda   FN_CSR         ; Read the input register
         anda  #MASK_CMD_RDY  ; zero is asserted
         bne   wait_cmd2
         andcc #$fe           ; clear the carry flag
         puls  a,y,pc         ; BUS_READY = 0

wait_cmd2:
         cmpy  #$0            ; timer timed out?
         bne   wait_cmd3
         orcc  #$01           ; if so, set the carry flag
         puls  a,y,pc         ; restore registers and return

wait_cmd3:
         lbsr  delay1ms
         leay  -1,y
         bra   wait_cmd1

;
; Delay about 1mS
;
delay1ms:
         pshs  x
         ldx   #MSCNT2MHZ
delay1ms2:
         leax  -1,x
         bne   delay1ms2
         puls  x,pc

;
; Poll BUS_PROCEED line
; EXIT: A=0 if not asserted; A=1 if asserted
;
fujinet_poll_proceed:
         lda   FN_CSR
         anda  #MASK_PROCEED
         beq   proceed_asserted
         lda   #0
         rts

proceed_asserted:
         lda   #1
         rts

;
; Common section
;
fujinet_init:
         lbra  fujinet_hal_init

;
; fujinet_checksum
; x = pointer to buffer
; dcb_tlen = length of buffer
;
; exit: A = checksum
fujinet_checksum:
         pshs  x,y      ; save registers
         lda   #0
         ldy   dcb_tlen

fc_loop:
         eora  ,x+
         leay  -1,y
         bne   fc_loop
         puls  x,y,pc   ; restore registers

;
; fujinet_dcb_exec
;
; ENTRY: x = dcb
; EXIT:  a = FUJINET_RC

fujinet_dcb_exec:
         pshs  b                       ; save register
         stx   dcb_ptr                 ; save the pointer
         ldd   DCB_DEVICE,x            ; copy device/command from dcb
         std   dcb_frame+DCB_DEVICE
         ldd   DCB_AUX1,x              ; copy aux1/2 from dcb
         std   dcb_frame+DCB_AUX1
         ldd   #4                      ; length of dcb_frame
         std   dcb_tlen
         lbsr  fujinet_checksum
         sta   dcb_frame+DCB_CHECKSUM  ; save the checksum
         lbsr  fujinet_hal_assert_cmd  ; BUS_COMMAND = 0

; Wait for CMD_RDY to be asserted
         ldd   DCB_TIMEOUT,x
         std   dcb_ttimeout
         lbsr  fujinet_hal_wait_cmd_ready_timeout
         bcs   exec_exit_TIMEOUT       ; ff timed out, exit
         ldx   #5
         stx   dcb_tlen
         ldx   #dcb_frame              ; x points to the command frame
         lbsr  tx_buff                 ; send the command frame
         ldx   dcb_ptr                 ; restore the dcb pointer
;
         lbsr  fujinet_hal_wait_cmd_ready
         lbsr  fujinet_hal_assert_spi_cs
         lbsr  fujinet_hal_rx
         lbsr  fujinet_hal_deassert_spi_cs
         cmpa  #'A'
         bne   exec_exit_NO_RACK
;
         ldd   DCB_TX_BUFFER_LEN,x     ; Check if any buffer data to transmit
         beq   exec_skip_tx_buf        ; if no, skip
         std   dcb_tlen
         
         lbsr  fujinet_hal_wait_cmd_ready
         ldx   DCB_TX_BUFFER,x         ; x points to the transmit buffer
         lbsr  tx_buff                 ; send the buffer
         ldx   dcb_ptr                 ; restore the dcb pointer
         lbsr  fujinet_hal_wait_cmd_ready
         lbsr  fujinet_hal_assert_spi_cs
         lbsr  fujinet_hal_rx
         lbsr  fujinet_hal_deassert_spi_cs
         cmpa  #'A'
         bne   exec_exit_NO_TACK

exec_skip_tx_buf:
         ldx   dcb_ptr                 ; Restore the DCB pointer
         ldd   DCB_RX_BUFFER_LEN,x     ; Check if anything to receive 
         beq   exec_skip_rx_buf
         std   dcb_tlen
         lbsr  fujinet_hal_wait_cmd_ready
         ldx   DCB_RX_BUFFER,x         ; point to the receive buffer
         lbsr  rx_buff                 ; fill the receive buffer
; TODO - check checksum

exec_skip_rx_buf:
         lbsr  fujinet_hal_wait_cmd_ready
         lbsr  fujinet_hal_assert_spi_cs

         lbsr  fujinet_hal_rx
         lbsr  fujinet_hal_deassert_spi_cs
         cmpa  #'C'
         bne   exec_exit_NO_COMPLETE

         lbsr  fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_OK
         ldx   dcb_ptr
         puls  b,pc

exec_exit_TIMEOUT:
         lbsr  fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_TIMEOUT
         ldx   dcb_ptr
         puls  b,pc

exec_exit_NO_COMPLETE:
         lbsr  fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_NO_COMPLETE
         ldx   dcb_ptr
         puls  b,pc

; split the two ACK-cases just for debug purposes (only one is needed)
exec_exit_NO_RACK:
         lbsr  fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_NO_ACK
         ldx   dcb_ptr
         puls  b,pc

exec_exit_NO_TACK:
         lbsr  fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_NO_ACK
         ldx   dcb_ptr
         puls  b,pc

; tx_buff
; ENTRY x = pointer to buffer
;      dcb_tlen = bytes to send
;
tx_buff:
         ldd   dcb_tlen
tx_buff2:
         cmpd  #64         ; if length < 64?
         blo   tx_buff_64
         ldb   #64         ; transfer 64 bytes
         lbsr  tx_buff_64
         ldd   dcb_tlen    ; Update bytes to transfer
         subd  #64
         std   dcb_tlen
         lbsr  fujinet_hal_wait_cmd_ready
         cmpd  #0
         bne   tx_buff2
         rts

;
; tranmit a transaction of 64 or less bytes
; ENTRY x = pointer to buffer
;       b = bytes to send
;
tx_buff_64:
         lbsr  fujinet_hal_assert_spi_cs
tx_buff1:
         tstb
         beq   tx_buff3

         ; tx byte at pointer
         lda   ,x+
         lbsr  fujinet_hal_tx
         decb
         bra   tx_buff1

tx_buff3:
         lbsr fujinet_hal_deassert_spi_cs
         rts

; -----------------------------------------------------------------------------

;ENTRY X = pointer to buffer
;      dcb_ttimeout = timeout (TODO)
;      dcb_tlen = bytes to receive
rx_buff:
         ldd   dcb_tlen
         bne   rx_buff1
         rts
rx_buff1:
         cmpd  #64
         blo   rx_buff_64
         ldb   #64
         lbsr  rx_buff_64

         ldd   dcb_tlen    ; Update bytes to transfer
         subd  #64
         std   dcb_tlen
         lbsr  fujinet_hal_wait_cmd_ready
         cmpd  #0
         bne   rx_buff1
         rts

;
; tranmit a transaction of 64 or less bytes
; ENTRY X = pointer to buffer
;       dcb_ttimeout = timeout (TODO)
;       b = bytes to receive
rx_buff_64:
         lbsr  fujinet_hal_assert_spi_cs
rx_buff2:
         tstb
         beq   rx_buff3

         ; rx byte to pointer
         lbsr  fujinet_hal_rx
         sta   ,x+   
         decb
         bra   rx_buff2

rx_buff3:
         lbsr  fujinet_hal_deassert_spi_cs
         rts

dump_reg:
         stx   dumpx
         sta   dumpa
         stb   dumpb
         lda   #' '
         outch
         lda   #'A'
         outch
         lda   #'='
         outch
         lda   dumpa
         jsr   out2h
         lda   #' '
         outch
         
         lda   #'B'
         outch
         lda   #'='
         outch
         lda   dumpb
         jsr   out2h
         lda   #' '
         outch
         
         lda   #'X'
         outch
         lda   #'='
         outch
         lda   dumpx
         ldb   dumpx+1
         jsr   out4h
         pcrlf
         
         ldb   dumpb
         lda   dumpa
         ldx   dumpx
         rts
;
dumpa    rmb   1
dumpb    rmb   1
dumpx    rmb   2

; -----------------------------------------------------------------------------

dcb_frame:
            fcb   0,0,0,0
dcb_frame_checksum:
            fcb   0
dcb_ttimeout:
            fdb   0
dcb_tlen:
            fdb   0
dcb_ptr:
            fdb   0
;
assert_val  rmb   1
