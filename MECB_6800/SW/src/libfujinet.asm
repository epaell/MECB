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
;      Bit 7 = BUS_READY*     (MASK_CMD_READY, BIT_CMD_ACK)
;      Bit 6 = BUS_PROCEED*   (MASK_PROCEED, BIT_PROCEED)
;      Bit 1-5 = UNUSED
;      Bit 0 = BUS_MISO       (MASK_MISO, BIT_MISO)
;
MASK_CMD_ACK               equ   $80
MASK_PROCEED               equ   $40
MASK_MISO                  equ   $01
BIT_CMD_ACK                equ   $07
BIT_PROCEED                equ   $06
BIT_MISO                   equ   $00

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

DELAYMS  macro del
         if DEBUG>0
         psha
         stx   dumpx
         ldx   #del
dloop:
         jsr   delay1ms
         dex
         bne   dloop
         ldx   dumpx
         lda   #'D'
         jsr   OUTCH
         pula
         endif
         endm

;
; Initialise the FujiNet hardware
;
fujinet_hal_init:
         DUMP  1,"fujinet_hal_init"
         psha
         lda   #FN_INIT       ; clock low, MOSI high
         sta   assert_val
         sta   FN_CSR
         pula
         rts

;
; Output byte to Fujinet device
; entry:
;    a = byte to write
;
fujinet_hal_tx:
         RDUMPA 1,"fujinet_hal_tx"
         psha                 ; save registers
         pshb
         stx   fntempx1
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
;
         pshb
         ldb   FN_CSR         ; clock in an RX bit
         rorb
         ldb   tx_rx
         rolb
         stb   tx_rx
         pulb
 ;
         decb                 ; clock low, MOSI low
         stb   FN_CSR
         dex
         bne   tx_bit
         bra   tx_done

tx_rx    rmb   1

tx_high:
         orb   #2             ; clock low, MOSI high
         stb   FN_CSR
         incb                 ; clock high, MOSI high
         stb   FN_CSR
;
         pshb
         ldb   FN_CSR         ; clock in an RX bit
         rorb
         ldb   tx_rx
         rolb
         stb   tx_rx
         pulb
 ;
         decb                 ; clock low, MOSI high
         stb   FN_CSR
         dex
         beq   tx_done
         jmp   tx_bit
tx_done:
         ldx   fntempx1
         ldb   tx_rx
         RDUMPB 2,"MISO="
         pulb
         pula
         rts                  ; restore registers and return

;
; Input byte from FujiNet device
; exit:
;    a = byte read
fujinet_hal_rx:
         DUMP  1,"fujinet_hal_rx"
         pshb
         lda   #8             ; 8 bits to receive
         sta   bits
         clra                 ; initialize input byte

rx_bit:
         ldb   assert_val
         orb   #2             ; clock low, MOSI high epaell added
         stb   FN_CSR         ;                      epaell added
         orb   #3             ; clock high, MOSI high
         stb   FN_CSR
         ldb   FN_CSR         ; get MISO state
         rorb                 ; carry = MISO
         rola                 ; shift MISO into bit 0
         ldb   assert_val
         andb  #MASK_SPI
         orb   #2             ; clock low, MOSI high
         stb   FN_CSR
         dec   bits
         bne   rx_bit
         pulb
         RDUMPA 1,"fujinet_hal_rx RX="
         rts                  ; restore registers and return

bits     rmb   1
;
; Assert the COMMAND line
;
fujinet_hal_assert_cmd:
         DUMP  2,"fujinet_hal_assert_cmd"
         psha
         lda   assert_val     ; de-assert
         anda  #$7f           ; BUS_CMD low
         sta   assert_val
         sta   FN_CSR
         pula
         rts

;
; Deassert the COMMAND line
;
fujinet_hal_deassert_cmd:
         DUMP  2,"fujinet_hal_deassert_cmd"
         psha
         lda   assert_val
         ora   #$80
         sta   assert_val
         sta   FN_CSR
         pula
         rts

;
; Assert the SPI CS line
;
fujinet_hal_assert_spi_cs:
         DUMP  2,"fujinet_hal_assert_spi_cs"
         psha
         lda   assert_val
         anda  #$fb          ; 0b11111011
         sta   assert_val
         sta   FN_CSR
         pula
         rts

;
; Deassert the SPI CS line
;
fujinet_hal_deassert_spi_cs:
         DUMP  2,"fujinet_hal_deassert_spi_cs"
         psha
         lda   assert_val     ; de-assert
         ora   #$04
         sta   assert_val
         sta   FN_CSR
         pula
         rts

;
; Poll the CCOMMAND_READY line
;  exit: if A = 0, then asserted
;
fujinet_hal_poll_cmd_ready:
         DUMP  2,"fujinet_hal_poll_cmd_ready"
         lda   FN_CSR
         anda  #MASK_CMD_ACK
         RDUMPA 1,"fujinet_hal_poll_cmd_ready"
         rts

;
; Wait for CCOMMAND_READY to be asserted
;
fujinet_hal_wait_cmd_ready:
         DUMP  2,"fujinet_hal_wait_cmd_ready"
         psha
fujinet_hal_wait_cmd_ready2:
         lda   FN_CSR
         anda  #MASK_CMD_ACK
         bne   fujinet_hal_wait_cmd_ready2
         pula
         rts

; ENTRY: dcb_ttimeout = timeout in 10ths of seconds
; EXIT:   C-flag if timeout
fujinet_hal_wait_cmd_ready_timeout:
         DUMP  2,"fujinet_hal_wait_cmd_ready_timeout"
         psha
         stx   fntempx1
         ldx   dcb_ttimeout
wait_cmd1:
         lda   FN_CSR         ; Read the input register
         anda  #MASK_CMD_ACK  ; zero is asserted
         bne   wait_cmd2
         ldx   fntempx1
         pula
         DUMP 1,"cmd_ready"
         clc                  ; clear the carry flag
         rts

wait_cmd2:
         cmpx  #$0            ; timer timed out?
         bne   wait_cmd3
         ldx   fntempx1       ; restore registers and return
         pula
         DUMP 2,"timed out"
         sec                  ; if so, set the carry flag
         rts

wait_cmd3:
         jsr   delay1ms
         dex
         bra   wait_cmd1

;
; Delay about 1mS
;
delay1ms:
         stx   fndelay1
         ldx   #MSCNT1MHZ
delay1ms2:
         dex
         bne   delay1ms2
         ldx   fndelay1
         rts

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
         jmp   fujinet_hal_init

;
; fujinet_checksum
; x = pointer to buffer
; dcb_tlen = length of buffer
;
; exit: A = checksum
fujinet_checksum:
         stx   fntempx1    ; save registers
         pshb
         lda   #0
         ldb   dcb_tlen
         stb   count
         ldb   dcb_tlen+1
         stb   count+1
fc_loop:
         eora  ,x
         inx
         ldb   count+1
         subb  #1
         stb   count+1
         ldb   count
         sbcb  #0
         stb   count
         tst   count
         bne   fc_loop
         tst   count+1
         bne   fc_loop
         pulb              ; restore registers
         ldx   fntempx1
         rts

;
; fujinet_dcb_exec
;
; ENTRY: x = dcb
; EXIT:  a = FUJINET_RC

fujinet_dcb_exec:
         pshb                          ; save register
         stx   dcb_ptr                 ; save the pointer
         lda   DCB_DEVICE,x            ; copy device from dcb
         sta   dcb_frame+DCB_DEVICE
         lda   DCB_COMMAND,x           ; copy command from dcb
         sta   dcb_frame+DCB_COMMAND
         lda   DCB_AUX1,x              ; copy aux1 from dcb
         sta   dcb_frame+DCB_AUX1
         lda   DCB_AUX2,x              ; copy aux2 from dcb
         sta   dcb_frame+DCB_AUX2
         clr   dcb_tlen
         lda   #4                      ; length of dcb_frame
         sta   dcb_tlen+1
         jsr   fujinet_checksum
         sta   dcb_frame+DCB_CHECKSUM  ; save the checksum
         jsr   fujinet_hal_assert_cmd  ; BUS_COMMAND = 0

; Wait for CMD_ACK to be asserted
         lda   DCB_TIMEOUT,x
         sta   dcb_ttimeout
         ldb   DCB_TIMEOUT+1,x
         stb   dcb_ttimeout+1
         jsr   fujinet_hal_wait_cmd_ready_timeout
         bcc   fnexec2
         jmp   exec_exit_TIMEOUT       ; ff timed out, exit
fnexec2:
         ldx   #5
         stx   dcb_tlen
         ldx   #dcb_frame              ; x points to the command frame
         jsr   tx_buff                 ; send the command frame
         ldx   dcb_ptr                 ; restore the dcb pointer
;
         jsr   fujinet_hal_wait_cmd_ready
         jsr   fujinet_hal_assert_spi_cs
         jsr   fujinet_hal_rx
;         RDUMPA 1,'*'
;         DELAYMS 2 ; This causes the FUJINET_RC_NO_COMPLETE error (works with 1mS delay)
         jsr   fujinet_hal_deassert_spi_cs
;         RDUMPA 1,'*'
         cmpa  #'A'
         beq   fnexec3
         jmp   exec_exit_NO_RACK
;
fnexec3
         tst   DCB_TX_BUFFER_LEN,x     ; Check if any buffer data to transmit
         bne   do_tx                   ; if so, send it
         tst   DCB_TX_BUFFER_LEN+1,x   ; Check if any buffer data to transmit
         beq   exec_skip_tx_buf        ; if no, skip
do_tx:   lda   DCB_TX_BUFFER_LEN,x
         sta   dcb_tlen
         lda   DCB_TX_BUFFER_LEN+1,x
         sta   dcb_tlen+1
         jsr   fujinet_hal_wait_cmd_ready
         ldx   DCB_TX_BUFFER,x         ; x points to the transmit buffer
         jsr   tx_buff                 ; send the buffer
         ldx   dcb_ptr                 ; restore the dcb pointer
         jsr   fujinet_hal_wait_cmd_ready
         jsr   fujinet_hal_assert_spi_cs
         jsr   fujinet_hal_rx
         jsr   fujinet_hal_deassert_spi_cs
         RDUMPA 1,'o'
         cmpa  #'A'
         beq   exec_skip_tx_buf
         jmp   exec_exit_NO_TACK

exec_skip_tx_buf:
         jsr   fujinet_hal_wait_cmd_ready ; ** epaell added
         ldx   dcb_ptr                 ; Restore the DCB pointer
         tst   DCB_RX_BUFFER_LEN,x     ; Check if any buffer data to receive
         bne   do_rx                   ; if so, send it
         tst   DCB_RX_BUFFER_LEN+1,x   ; Check if any buffer data to receive
         beq   exec_skip_rx_buf        ; if no, skip

do_rx:   lda   DCB_RX_BUFFER_LEN,x
         sta   dcb_tlen
         lda   DCB_RX_BUFFER_LEN+1,x
         sta   dcb_tlen+1
         jsr   fujinet_hal_wait_cmd_ready
         ldx   DCB_RX_BUFFER,x         ; point to the receive buffer
         jsr   rx_buff                 ; fill the receive buffer
; TODO - check checksum

exec_skip_rx_buf:
         jsr   fujinet_hal_wait_cmd_ready
         jsr   fujinet_hal_assert_spi_cs
         jsr   fujinet_hal_rx
         jsr   fujinet_hal_deassert_spi_cs
;         RDUMPA 1,'x'
         cmpa  #'C'
         bne   exec_exit_NO_COMPLETE

         DUMP  1,"exec_exit_OK"
         jsr   fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_OK
         ldx   dcb_ptr
         pulb
         rts

exec_exit_TIMEOUT:
         DUMP  1,"exec_exit_TIMEOUT"
         jsr   fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_TIMEOUT
         ldx   dcb_ptr
         pulb
         rts

exec_exit_NO_COMPLETE:
         DUMP  1,"exec_exit_NO_COMPLETE"
         jsr   fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_NO_COMPLETE
         ldx   dcb_ptr
         pulb
         rts

; split the two ACK-cases just for debug purposes (only one is needed)
exec_exit_NO_RACK:
         DUMP  1,"exec_exit_NO_RACK"
         jsr   fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_NO_ACK
         ldx   dcb_ptr
         pulb
         rts

exec_exit_NO_TACK:
         DUMP  1,"exec_exit_NO_TACK"
         jsr   fujinet_hal_deassert_cmd
         lda   #FUJINET_RC_NO_ACK
         ldx   dcb_ptr
         pulb
         rts

; tx_buff
; ENTRY x = pointer to buffer
;      dcb_tlen = bytes to send
;
tx_buff:
         DUMP  1,"tx_buff"
         lda   dcb_tlen    ; get bytes to transfer
         ldb   dcb_tlen+1
         RDUMPA  1,"Len(MSB)="
         RDUMPB  1,"Len(LSB)="
tx_buff2:
         tsta
         bne   tx_buff2a   ; handle if >255
         cmpb  #64         ; if length < 64?
         blo   tx_buff_64
tx_buff2a
         clra
         ldb   #64         ; transfer 64 bytes
         jsr   tx_buff_64
         ldb   dcb_tlen+1  ; Subtract LSB
         subb  #64
         stb   dcb_tlen+1
         lda   dcb_tlen    ; Subtract MSB
         sbca  #0
         sta   dcb_tlen
         jsr   fujinet_hal_wait_cmd_ready
         tsta
         bne   tx_buff2
         tstb
         bne   tx_buff2
         rts

;
; tranmit a transaction of 64 or less bytes
; ENTRY x = pointer to buffer
;       b = bytes to send
;
tx_buff_64:
         jsr   fujinet_hal_assert_spi_cs
tx_buff1:
         tstb
         beq   tx_buff3

         ; tx byte at pointer
         lda   ,x
         inx
         jsr   fujinet_hal_tx
         decb
         bra   tx_buff1

tx_buff3:
;         DELAYMS  20
         jsr  fujinet_hal_deassert_spi_cs
         rts

; -----------------------------------------------------------------------------

;ENTRY X = pointer to buffer
;      dcb_ttimeout = timeout (TODO)
;      dcb_tlen = bytes to receive
rx_buff:
         DUMP  1,"rx_buff"
         lda   dcb_tlen    ; Get the MSB of the length
         ldb   dcb_tlen+1  ; Get the LSB of the length
         tsta
         bne   rx_buff1    ; More to receive, continue
         tstb
         bne   rx_buff1    ; More to receive, continue
         rts               ; All done, return
rx_buff1:
         tsta
         bne   rx_buf1a    ; MSB non-zero so definitely >64, read in 64-byte chunks
         cmpb  #64
         blo   rx_buff_64  ; less than 64 bytes to receive, just get it and return

rx_buf1a:                  ; more than 64-bytes to receive so receive in 64-byte chunks
         ldb   #64         ; Set the number of bytes to receive
         jsr   rx_buff_64  ; Receive them
rx_buf1b:
         ldb   dcb_tlen+1  ; Subtract LSB
         subb  #64
         stb   dcb_tlen+1
         lda   dcb_tlen    ; Subtract MSB
         sbca  #0
         sta   dcb_tlen
         jsr   fujinet_hal_wait_cmd_ready
         tsta
         bne   rx_buff1    ; If there is anything left to receive go back and receive next chunk
         tstb
         bne   rx_buff1
         rts               ; Nothing left to receive, return.

;
; transmit a transaction of 64 or less bytes
; ENTRY X = pointer to buffer
;       dcb_ttimeout = timeout (TODO)
;       b = bytes to receive
rx_buff_64:
         jsr   fujinet_hal_assert_spi_cs
         DUMP  1,"rx_buff_64"
rx_buff2:
         tstb
         beq   rx_buff3
         ; rx byte to pointer
         jsr   fujinet_hal_rx
         sta   ,x
         inx
         decb
         bra   rx_buff2

rx_buff3:
         jsr   fujinet_hal_deassert_spi_cs
         rts

;
; Reset values in DCB
; ENTRY: x = pointer to buffer
clr_dcb: 
         clr   DCB_RX_BUFFER_LEN,x
         clr   DCB_RX_BUFFER_LEN+1,x
         clr   DCB_TX_BUFFER_LEN,x
         clr   DCB_TX_BUFFER_LEN+1,x
         psha
         lda   #FUJINET_TIMEOUT>>8     ; Set time-out
         sta   DCB_TIMEOUT,x
         lda   #FUJINET_TIMEOUT&$FF    ; Set time-out
         sta   DCB_TIMEOUT+1,x
         pula
         rts

; -----------------------------------------------------------------------------
count    rmb   2
fntempx1 rmb   2
fndelay1 rmb   2

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
