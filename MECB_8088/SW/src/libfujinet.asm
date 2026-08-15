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
SET_CMD_RDY                equ   80h
SET_PROCEED                equ   40h
SET_MISO                   equ   01h
;
MASK_CMD_RDY               equ   7fh
MASK_PROCEED               equ   0bfh
MASK_MISO                  equ   0feh
;
; Output:
;      Bit 7 = BUS_CMD*       (BIT_CMD)
;      Bit 6 = BUS_DATA*      (BIT_DATA)
;      Bit 3-5 = UNUSED
;      Bit 2 = BUS_CS*        (BIT_CS)
;      Bit 1 = BUS_MOSI       (BIT_MOSI)
;      Bit 0 = BUS_CLK        (BIT_CLK)
;
MASK_SPI                   equ   0fch   ; Mask out all but BUS_CLK and BUS_MOSI
FN_INIT                    equ   0feh   ; BUS_CLK low, BUS_MOSI high
SET_CMD                    equ   80h
SET_DATA                   equ   40h
SET_CS                     equ   04h
SET_MOSI                   equ   02h
SET_CLK                    equ   01h
SET_SPI                    equ   03h
;
MASK_CMD                   equ   7fh
MASK_DATA                  equ   0bfh
MASK_CS                    equ   0fbh
MASK_MOSI                  equ   0fdh
MASK_CLK                   equ   0feh

MSCNT8MHZ                  equ   467      ; number of loops to delay ~1 mS with 8 MHz 8088 CPU

DCB_FRAME_SIZE             equ   8

;
; Initialise the FujiNet hardware (bl contains current assert_val)
;
fujinet_hal_init:
         push  ax
         mov   al,FN_INIT
         mov   bl,al
         out   FN_CSR,al      ; clock low, MOSI high
         pop   ax
         ret

;
; Output byte to Fujinet device
; entry:
;    al = byte to write
;    bl = assert_val
; exit
;    ax = modified
;    bl = assert_val
;
fujinet_hal_tx:
         push  cx
         xchg  ax,bx             ; bx = byte to write; ax = assert_val
         mov   cx,8              ; 8 bits to transmit
tx_bit:
         shl   bl,1              ; shift bit to transmit into carry
         jc    tx_high           ; branch if handle hit bit
tx_low:
         and   al,MASK_SPI       ; clock low, MOSI low
         out   FN_CSR,al
         inc   al                ; clock high, MOSI low
         out   FN_CSR,al
         dec   al                ; clock low, MOSI low
         out   FN_CSR,al
         loop  tx_bit
         pop   cx
         xchg  ax,bx
         ret
tx_high:
         or    al,SET_MOSI       ; clock low, MOSI high
         out   FN_CSR,al
         inc   al                ; clock high, MOSI high
         out   FN_CSR,al
         dec   al                ; clock low, MOSI high
         out   FN_CSR,al
         loop  tx_bit
         pop   cx
         mov   bl,al             ; restore assert_val
         ret

;
; Input byte from FujiNet device
;    bl = assert_val
; exit:
;    ax = byte read
;    bl = assert_val
fujinet_hal_rx:
         push  cx
         xchg  ax,bx             ; bl = byte read; al = assert_val
         mov   bl,0
         mov   cx,8              ; 8 bits to transmit
.1:
         or    al,SET_SPI        ; clock high, MOSI high
         out   FN_CSR,al
         mov   ah,al             ; ah = assert_val
         in    al,FN_CSR         ; get MOSI
         shr   al,1              ; shift MOSI into carry
         rcl   bl,1              ; shift carry into read byte
         mov   al,ah
         and   al,MASK_SPI
         or    al,SET_MOSI       ; clock low, MOSI high $7e
         out   FN_CSR,al
         loop  .1
         pop   cx
         xchg  ax,bx
         ret

;
; Assert the COMMAND line (bl contains current assert_val)
;
fujinet_hal_assert_cmd:
         push  ax
         mov   al,bl
         and   al,MASK_CMD       ; CMD low
         out   FN_CSR,al
         mov   bl,al
         pop   ax
         ret

;
; Deassert the COMMAND line (d2 contains current assert_val)
;
fujinet_hal_deassert_cmd:
         push  ax
         mov   al,bl
         or    al,SET_CMD        ; CMD high
         out   FN_CSR,al
         mov   bl,al
         pop   ax
         ret

;
; Assert the SPI CS line (d2 contains current assert_val)
;
fujinet_hal_assert_spi_cs:
         push  ax
         mov   al,bl
         and   al,MASK_CS       ; CS low
         out   FN_CSR,al
         mov   bl,al
         pop   ax
         ret

;
; Deassert the SPI CS line (d2 contains current assert_val)
;
fujinet_hal_deassert_spi_cs:
         push  ax
         mov   al,bl
         or    al,SET_CS        ; CS high
         out   FN_CSR,al
         mov   bl,al
         pop   ax
         ret

;
; Wait for CCOMMAND_READY to be asserted
;
fujinet_hal_wait_cmd_ready:
         push  ax                ; save ax
.1:
         in    al,FN_CSR         ; read the FN register
         test  al,SET_CMD_RDY    ; check state of CMD_RDY bit
         jnz   .1                ; if high, loop back
         pop   ax                ; CMD_RDY is low, restore ax
         ret                     ; return

; ENTRY: cx = timeout in 10ths of seconds
; EXIT:   C-flag if timeout
fujinet_hal_wait_cmd_ready_timeout:
         push  ax
.1:
         in    al,FN_CSR
         test  al,SET_CMD_RDY
         jnz   .2
         pop   ax
         clc                     ; OK, so clear carry
         ret

.2:
         call  delay1ms
         loop  .1
         pop   ax
         stc                     ; timeout, so set carry
         ret

;
; Delay about 1mS
;
delay1ms:                        ; call 19 cycles
         push  cx                ; 15 cycles
         mov   cx,MSCNT8MHZ      ; 4 cycles
.2:
         loop  .2                ; 17 cycles
         pop   cx                ; 12 cycles
         ret                     ; 16 cycles

;
; Poll BUS_PROCEED line
; EXIT: al=0 if not asserted; al=1 if asserted
;
fujinet_poll_proceed:
         in    al,FN_CSR
         and   al,SET_PROCEED
         jz    proceed_asserted
         mov   al,0
         ret

proceed_asserted:
         mov   al,1
         ret

;
; fujinet_checksum
; si = pointer to buffer
; cx = length of buffer
;
; exit: al = checksum
fujinet_checksum:
         push  si                ; save pointer
         xor   ah,ah             ; clear checksum
fc_loop:
         lodsb                   ; get a byte
         xor   ah,al
         loop  fc_loop
         mov   al,ah
         pop   si                ; restore pointer
         ret

;
; fujinet_dcb_exec
;
; ENTRY: ds:si = dcb
; EXIT:  al = FUJINET_RC

fujinet_dcb_exec:
         push  bx                ; save registers
         push  cx
         push  dx
         push  si
         push  di
                  
         call  fujinet_hal_init  ; initial assert value
         mov   cx,4              ; actual data size of DCB frame
         call  fujinet_checksum  ; get the checksum
         mov   dl,ds:[si+DCB_CHECKSUM] ; save current value at checksum location
         mov   ds:[si+DCB_CHECKSUM],al ; save it in the DCB frame
         call  fujinet_hal_assert_cmd  ; BUS_COMMAND = 0

; Wait for CMD_RDY to be asserted and then transmit the command frame
         mov   cx,ds:[si+DCB_TIMEOUT]
         call  fujinet_hal_wait_cmd_ready_timeout
         jb    exec_exit_TIMEOUT ; fn timed out, exit
         mov   cx,5              ; size of DCB frame with checksum
         push  si
         call  tx_buff           ; send the command frame
         pop   si
         mov   ds:[si+DCB_CHECKSUM],dl ; restore data at checksum location
;
         call  fujinet_hal_wait_cmd_ready
         call  fujinet_hal_assert_spi_cs
         call  fujinet_hal_rx    ; read response
         call  fujinet_hal_deassert_spi_cs
         cmp   al,'A'
         jnz   exec_exit_NO_RACK
;
         mov   ax,ds:[si+DCB_TX_BUFFER_LEN] ; Check if any buffer data to transmit
         test  ax,ax
         jz    exec_skip_tx_buf  ; if no, skip
; prepare to transmit TX buffer
         call  fujinet_hal_wait_cmd_ready
         mov   cx,ds:[si+DCB_TX_BUFFER_LEN]
         mov   ax,ds:[si+DCB_TX_BUFFERSEG]
         push  si
         mov   si,ds:[si+DCB_TX_BUFFER]
         push  ds                ; save ds
         mov   ds,ax             ; ds:si points to transmit buffer
         call  tx_buff           ; send the buffer
         pop   ds                ; restore ds
         pop   si                ; restore si
; wait for the acknowledgement
         call  fujinet_hal_wait_cmd_ready
         call  fujinet_hal_assert_spi_cs
         call  fujinet_hal_rx    ; get the response
         call  fujinet_hal_deassert_spi_cs
         cmp   al,'A'
         jnz   exec_exit_NO_TACK

exec_skip_tx_buf:
         mov   ax,ds:[si+DCB_RX_BUFFER_LEN]  ; Check if anything to receive 
         test  ax,ax
         jz    exec_skip_rx_buf
; prepare to receive into RX buffer
         call  fujinet_hal_wait_cmd_ready
         mov   cx,ds:[si+DCB_RX_BUFFER_LEN]  ; get the length
         push  es
         mov   di,ds:[si+DCB_RX_BUFFER]
         mov   ax,ds:[si+DCB_RX_BUFFERSEG]
         mov   es,ax             ; es:di points to receive buffer
         call  rx_buff           ; fill the receive buffer
         pop   es
; TODO - check checksum

; wait for the command completion
exec_skip_rx_buf:
         call  fujinet_hal_wait_cmd_ready
         call  fujinet_hal_assert_spi_cs
         call  fujinet_hal_rx
         call  fujinet_hal_deassert_spi_cs
         cmp   al,'C'            ; check response
         jnz   exec_exit_NO_COMPLETE

         mov   al,FUJINET_RC_OK
         jmp   exec_exit

exec_exit_NO_COMPLETE:
         mov   al,FUJINET_RC_NO_COMPLETE
         jmp   exec_exit

; split the two ACK-cases just for debug purposes (only one is needed)
exec_exit_NO_RACK:
         mov   al,FUJINET_RC_NO_ACK
         jmp   exec_exit

exec_exit_NO_TACK:
         mov   al,FUJINET_RC_NO_ACK
         jmp   exec_exit

exec_exit_TIMEOUT:
         mov   al,FUJINET_RC_TIMEOUT
exec_exit:
         call  fujinet_hal_deassert_cmd
         pop   di                ; restore registers
         pop   si
         pop   dx
         pop   cx
         pop   bx
         ret

; tx_buff
; ENTRY ds:si = pointer to buffer
;       cx = bytes to send
; EXIT  cx modified
;
tx_buff:
         test  cx,cx             ; is there anything to transmit
         jnz   tx_buff1          ; if there is start transmitting
         ret                     ; nothing to transmit, return
tx_buff1:
         cmp   cx,64             ; if length < 64?
         ja    tx_buff4          ; if there are more than 64 bytes chunk the data up
         call  tx_buff_64        ; less than 64, OK to transmit as is
         ret
tx_buff4:
         push  cx
         mov   cx,64             ; transfer 64 bytes
         call  tx_buff_64
         pop   cx
         sub   cx,64             ; reduce amount to transfer
         call  fujinet_hal_wait_cmd_ready
         test  cx,cx
         jnz   tx_buff
         ret

;
; transmit a transaction of 64 or less bytes
; ENTRY ds:si = pointer to buffer
;       cx = bytes to send
; EXIT  cx modified
;
tx_buff_64:
         call  fujinet_hal_assert_spi_cs
         test  cx,cx             ; are there still bytes to transmit
         jz    tx_buff3          ; no, exit.
tx_buff2:
         lodsb                   ; get a byte from the source (ds:si)
         call  fujinet_hal_tx
         loop  tx_buff2
tx_buff3:
         call  fujinet_hal_deassert_spi_cs
         ret

; -----------------------------------------------------------------------------

;ENTRY es:di = pointer to buffer
;      cx = bytes to receive
;      dx = timeout (TODO)
rx_buff:
         test  cx,cx             ; check if there is anything to receive
         jnz   rx_buff1          ; if there is, start receiving
         ret                     ; nothing to receive, return
rx_buff1:
         cmp   cx,64
         ja    rx_buff4          ; if there are more than 64 bytes chunk the data up
         jmp   rx_buff_64        ; less than 64, OK to read into buffer
rx_buff4:
         push  cx                ; save the actual count of bytes to receive
         mov   cx,64             ; send a 64-byte chunk
         call  rx_buff_64
         pop   cx                ; restore the actual count
         sub   cx,64             ; reduce by the 64 that has now been received
         call  fujinet_hal_wait_cmd_ready
         test  cx,cx             ; check if there is more to receive
         jnz   rx_buff1          ; yes, loop back
         ret                     ; finished, return

;
; receive a transaction of 64 or less bytes
; ENTRY es:di = pointer to buffer
;       cx = bytes to receive
;       dx = timeout (TODO)
rx_buff_64:
         call  fujinet_hal_assert_spi_cs
         test  cx,cx             ; are there still bytes to receive
         jz    rx_buff3          ; no, exit.
rx_buff2:
         ; rx byte to pointer
         call  fujinet_hal_rx    ; receive a byte
         stosb                   ; save the byte in the destination (es:di)
         loop  rx_buff2          ; loop back until all requested bytes received

rx_buff3:
         call  fujinet_hal_deassert_spi_cs
         ret
