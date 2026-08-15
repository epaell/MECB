*******************************************************************
* REL - Relocation routine
*
* This module MUST occupy the last 256 bytes of ROM ($FF00-$FFFF)
* due to the way the Corsham board is designed.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2017/05/08  Boisy G. Pitre
*   2      2026/07/13  Emil Lenc
* Modified for Digicool MECB 6809
*

                    nam       REL
                    ttl       Relocation routine

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $05
edition             set       5

Begin               mod       eom,name,tylg,atrv,start,size

                    org       0
size                equ       .                   REL doesn't require any memory

name                fcs       /REL/
                    fcb       edition

*************************************************************************
* Entry point for Level 1

Start
* epaell begin
                    clra                           make A=0 for later
                    IFNE  H6309
                    tfr       0,dp                 set direct page to $0000
                    ldmd      #3                   native mode
                    ELSE
                    tfr       a,dp
                    ENDC
* epaell end
* Initialize UART
                    ldx       #UARTBase            POINT TO CONTROL PORT ADDRESS
                    lda       #3                   RESET ACIA PORT CODE
                    sta       ,x                   STORE IN CONTROL REGISTER
                    lda       #$11                 SET 8 DATA, 2 STOP AN 0 PARITY
                    sta       ,x                   STORE IN CONTROL REGISTER
                    tst       1,x                  ANYTHING IN DATA REGISTER?

* Initialization is complete at this point
* Jump into Kernel (changed from $F011)
; epaell this is a bit ugly and has to be modified each time krn.asm/krnp2.asm is modified
; in order to jump to the correct location in rom
                    jmp       $ee00+$11            jump into Krn

; epaell begin - add fujinet low-level library to rom
;
; offset to temporary stack variables used by fn_dcb_exec
;
v$dcb_frame         equ       0
v$dcb_ttimeout      equ       5
v$dcb_tlen          equ       7
v$dcb_ptr           equ       9
v$assert_val        equ       11

; Output byte to Fujinet device
; entry:
;    a = byte to write
;
fn_hal_tx:
                    pshs      a,b,x                ; save registers
                    ldx       #8                   ; 8 bits to transmit
tx_bit:
                    ldb       v$assert_val,u
                    lsla                           ; shift bit to transmit into carry
                    bcs       tx_high              ; branch if handle hit bit
tx_low:
                    andb      #MASK_SPI            ; clock low, MOSI low
                    stb       FNBASE
                    incb                           ; clock high, MOSI low
                    stb       FNBASE
                    decb                           ; clock low, MOSI low
                    stb       FNBASE
                    leax      -1,x
                    bne       tx_bit
                    puls      a,b,x,pc             ; restore registers and return
tx_high:
                    orb       #2                   ; clock low, MOSI high
                    stb       FNBASE
                    incb                           ; clock high, MOSI high
                    stb       FNBASE
                    decb                           ; clock low, MOSI high
                    stb       FNBASE
                    leax      -1,x
                    bne       tx_bit
                    puls      a,b,x,pc             ; restore registers and return

;
; Input byte from FujiNet device
; exit:
;    a = byte read
fn_hal_rx:
                    pshs      b,x                  ; save registers
                    ldx       #8                   ; 8 bits to receive
                    lda       #0                   ; initialize input byte

rx_bit:
                    ldb       v$assert_val,u
                    orb       #3                   ; clock high, MOSI high
                    stb       FNBASE
                    ldb       FNBASE
                    rorb
                    rola
                    ldb       v$assert_val,u
                    andb      #MASK_SPI
                    orb       #2                   ; clock low, MOSI high
                    stb       FNBASE
                    leax      -1,x
                    bne       rx_bit
                    puls      b,x,pc               ; restore registers and return

;
; Assert the COMMAND line
;
fn_hal_assert_cmd:
                    pshs      a
                    lda       v$assert_val,u       ; de-assert
                    anda      #$7f                 ; BUS_CMD low
                    sta       v$assert_val,u
                    sta       FNBASE
                    puls      a,pc

;
; Deassert the COMMAND line
;
fn_hal_deassert_cmd:
                    pshs      a
                    lda       v$assert_val,u
                    ora       #$80
                    sta       v$assert_val,u
                    sta       FNBASE
                    puls      a,pc

;
; Assert the SPI CS line
;
fn_hal_assert_spi_cs:
                    pshs      a
                    lda       v$assert_val,u
                    anda      #$fb                 ; 0b11111011
                    sta       v$assert_val,u
                    sta       FNBASE
                    puls      a,pc

;
; Deassert the SPI CS line
;
fn_hal_deassert_spi_cs:
                    pshs      a
                    lda       v$assert_val,u       ; de-assert
                    ora       #$04
                    sta       v$assert_val,u
                    sta       FNBASE
                    puls      a,pc

;
; Poll the CCOMMAND_READY line
;  exit: if A = 0, then asserted
;
fn_hal_poll_cmd_ready:
                    lda       FNBASE
                    anda      #MASK_CMD_RDY
                    rts

;
; Wait for CCOMMAND_READY to be asserted
;
fn_hal_wait_cmd_ready:
                    pshs      a
fn_hal_wait_cmd_ready2:
                    lda       FNBASE
                    anda      #MASK_CMD_RDY
                    bne       fn_hal_wait_cmd_ready2
                    puls      a,pc

; ENTRY: v$dcb_ttimeout = timeout in 10ths of seconds
; EXIT:   C-flag if timeout
fn_hal_wait_cmd_ready_timeout:
                    pshs      a,y
                    ldy       v$dcb_ttimeout,u
wait_cmd1:
                    lda       FNBASE               ; Read the input register
                    anda      #MASK_CMD_RDY        ; zero is asserted
                    bne       wait_cmd2
                    andcc     #$fe                 ; clear the carry flag
                    puls      a,y,pc               ; BUS_READY = 0

wait_cmd2:
                    cmpy      #$0                  ; timer timed out?
                    bne       wait_cmd3
                    orcc      #$01                 ; if so, set the carry flag
                    puls      a,y,pc               ; restore registers and return

wait_cmd3:
                    lbsr      delay1ms
                    leay      -1,y
                    bra       wait_cmd1

;
; Delay about 1mS
;
delay1ms:
                    pshs      x
                    ldx       #MSCNT2MHZ
delay1ms2:
                    leax      -1,x
                    bne       delay1ms2
                    puls      x,pc

;
; Poll BUS_PROCEED line
; EXIT: A=0 if not asserted; A=1 if asserted
;
fn_poll_proceed:
                    lda       FNBASE
                    anda      #MASK_PROCEED
                    beq       proceed_asserted
                    lda       #0
                    rts

proceed_asserted:
                    lda       #1
                    rts

;
; fn_checksum
; x = pointer to buffer
; v$dcb_tlen = length of buffer
;
; exit: A = checksum
fn_checksum:
                    pshs      x,y                  ; save registers
                    lda       #0
                    ldy       v$dcb_tlen,u

fc_loop:
                    eora      ,x+
                    leay      -1,y
                    bne       fc_loop
                    puls      x,y,pc               ; restore registers

;
; fn_dcb_exec
;
; ENTRY: x = dcb
; EXIT:  a = FUJINET_RC
;
fn_dcb_exec:
                    orcc      #IntMasks                  ; disable interrupts
                    pshs      b,u                        ; save registers
                    leas      -12,s                      ; make space for temporary variables
                    leau      0,s                        ; u points to local variables
                    lda       #FN_INIT                   ; clock low, MOSI* high, CMD* high, DATA* high, CS* high
                    sta       v$assert_val,u
                    sta       FNBASE
                    stx       v$dcb_ptr,u                ; save the pointer
                    ldd       DCB_DEVICE,x               ; copy device/command from dcb
                    std       v$dcb_frame+DCB_DEVICE,u
                    ldd       DCB_AUX1,x                 ; copy aux1/2 from dcb
                    std       v$dcb_frame+DCB_AUX1,u
                    ldd       #4                         ; length of v$dcb_frame
                    std       v$dcb_tlen,u
                    lbsr      fn_checksum
                    sta       v$dcb_frame+DCB_CHECKSUM,u ; save the checksum
                    lbsr      fn_hal_assert_cmd     ; BUS_COMMAND = 0

; Wait for CMD_RDY to be asserted
                    ldd       DCB_TIMEOUT,x
                    std       v$dcb_ttimeout,u
                    lbsr      fn_hal_wait_cmd_ready_timeout
                    bcs       exec_exit_TIMEOUT          ; ff timed out, exit
                    ldx       #5
                    stx       v$dcb_tlen,u
                    leax      v$dcb_frame,u              ; x points to the command frame
                    lbsr      tx_buff                    ; send the command frame
                    ldx       v$dcb_ptr,u                ; restore the dcb pointer
;
                    lbsr      fn_hal_wait_cmd_ready
                    lbsr      fn_hal_assert_spi_cs
                    lbsr      fn_hal_rx
                    lbsr      fn_hal_deassert_spi_cs
                    cmpa      #'A'
                    bne       exec_exit_NO_RACK
;
                    ldd       DCB_TX_BUFFER_LEN,x        ; Check if any buffer data to transmit
                    beq       exec_skip_tx_buf           ; if no, skip
                    std       v$dcb_tlen,u
         
                    lbsr      fn_hal_wait_cmd_ready
                    ldx       DCB_TX_BUFFER,x            ; x points to the transmit buffer
                    lbsr      tx_buff                    ; send the buffer
                    ldx       v$dcb_ptr,u                ; restore the dcb pointer
                    lbsr      fn_hal_wait_cmd_ready
                    lbsr      fn_hal_assert_spi_cs
                    lbsr      fn_hal_rx
                    lbsr      fn_hal_deassert_spi_cs
                    cmpa      #'A'
                    bne       exec_exit_NO_TACK

exec_skip_tx_buf:
                    ldx       v$dcb_ptr,u                ; Restore the DCB pointer
                    ldd       DCB_RX_BUFFER_LEN,x        ; Check if anything to receive 
                    beq       exec_skip_rx_buf
                    std       v$dcb_tlen,u
                    lbsr      fn_hal_wait_cmd_ready
                    ldx       DCB_RX_BUFFER,x            ; point to the receive buffer
                    lbsr      rx_buff                    ; fill the receive buffer
; TODO - check checksum

exec_skip_rx_buf:
                    lbsr      fn_hal_wait_cmd_ready
                    lbsr      fn_hal_assert_spi_cs

                    lbsr      fn_hal_rx
                    lbsr      fn_hal_deassert_spi_cs
                    cmpa      #'C'
                    bne       exec_exit_NO_COMPLETE

                    lbsr      fn_hal_deassert_cmd
                    lda       #FUJINET_RC_OK
exec_ret:
                    ldx       v$dcb_ptr,u
                    leas      12,s                       ; remove local variable space
                    andcc     #^IntMasks                 ; enable interrupts
                    puls      b,u,pc                     ; restore registers and return

exec_exit_TIMEOUT:
                    lbsr      fn_hal_deassert_cmd
                    lda       #FUJINET_RC_TIMEOUT
                    bra       exec_ret

exec_exit_NO_COMPLETE:
                    lbsr      fn_hal_deassert_cmd
                    lda       #FUJINET_RC_NO_COMPLETE
                    bra       exec_ret

; split the two ACK-cases just for debug purposes (only one is needed)
exec_exit_NO_RACK:
                    lbsr      fn_hal_deassert_cmd
                    lda       #FUJINET_RC_NO_ACK
                    bra       exec_ret

exec_exit_NO_TACK:
                    lbsr      fn_hal_deassert_cmd
                    lda       #FUJINET_RC_NO_ACK
                    bra       exec_ret

; tx_buff
; ENTRY x = pointer to buffer
;      v$dcb_tlen = bytes to send
;
tx_buff:
                    ldd       v$dcb_tlen,u
tx_buff2:
                    cmpd      #64                  ; if length < 64?
                    blo       tx_buff_64
                    ldb       #64                  ; transfer 64 bytes
                    lbsr      tx_buff_64
                    ldd       v$dcb_tlen,u         ; Update bytes to transfer
                    subd      #64
                    std       v$dcb_tlen,u
                    lbsr      fn_hal_wait_cmd_ready
                    cmpd      #0
                    bne       tx_buff2
                    rts

;
; tranmit a transaction of 64 or less bytes
; ENTRY x = pointer to buffer
;       b = bytes to send
;
tx_buff_64:
                    lbsr      fn_hal_assert_spi_cs
tx_buff1:
                    tstb
                    beq       tx_buff3

                    ; tx byte at pointer
                    lda       ,x+
                    lbsr      fn_hal_tx
                    decb
                    bra       tx_buff1

tx_buff3:
                    lbsr      fn_hal_deassert_spi_cs
                    rts

; -----------------------------------------------------------------------------

;ENTRY X = pointer to buffer
;      v$dcb_ttimeout = timeout (TODO)
;      v$dcb_tlen = bytes to receive
rx_buff:
                    ldd       v$dcb_tlen,u
                    bne       rx_buff1
                    rts
rx_buff1:
                    cmpd      #64
                    blo       rx_buff_64
                    ldb       #64
                    lbsr      rx_buff_64

                    ldd       v$dcb_tlen,u             ; Update bytes to transfer
                    subd      #64
                    std       v$dcb_tlen,u
                    lbsr      fn_hal_wait_cmd_ready
                    cmpd      #0
                    bne       rx_buff1
                    rts

;
; tranmit a transaction of 64 or less bytes
; ENTRY X = pointer to buffer
;       v$dcb_ttimeout = timeout (TODO)
;       b = bytes to receive
rx_buff_64:
                    lbsr      fn_hal_assert_spi_cs
rx_buff2:
                    tstb
                    beq       rx_buff3

                    ; rx byte to pointer
                    lbsr      fn_hal_rx
                    sta       ,x+   
                    decb
                    bra       rx_buff2

rx_buff3:
                    lbsr      fn_hal_deassert_spi_cs
                    rts

;
; output as hex digits contents of D register
;
Hex4Out             pshs      d
                    bsr       Hex2Out
                    exg       b,a
                    bsr       Hex2Out
                    puls      pc,d

;
; output two hex digits in A
;
Hex2Out             pshs  a
                    asra
                    asra
                    asra
                    asra
                    bsr       Hex1Out
                    puls      a
                    bsr       Hex1Out
                    rts

;
; output least significant nybble in A
;
Hex1Out             anda      #$0F
                    cmpa      #$0A
                    bcs       outnyb2
                    adda      #$07
outnyb2             adda      #$30
                    bsr       CharOut
                    rts


; epaell end

* Entry
* A = character to output
CharOut             pshs      b                    SAVE A ACCUM AND IX
fetch@              ldb       UARTBase             FETCH PORT STATUS
                    bitb      #2                   TEST TDRE, OK TO XMIT ?
                    beq       fetch@               IF NOT LOOP UNTIL RDY
                    sta       UARTBase+1           XMIT CHAR.
                    puls      b,pc                 restore and leave

* Entry
* X = nil terminated string
StringOut           pshs      a,x
loop@               lda       ,x+
                    beq       done@
                    bsr       CharOut
                    bra       loop@
done@               puls      a,x,pc

                    fill      $39,$300-*-EOMSize

EOMTop              equ       *

* I/O routines jump table (known locations)
LFFE3               fdb       $FD00+fn_dcb_exec
LFFE5               fdb       $FD00+Hex2Out
LFFE7               fdb       $FD00+Hex4Out
LFFE9               fdb       $FD00+CharOut
LFFEB               fdb       $FD00+StringOut

                    emod
eom                 equ       *

                    fdb       $0000
Vectors             fdb       $0100               SWI3
                    fdb       $0103               SWI2
                    fdb       $010F               FIRQ
                    fdb       $010C               IRQ
                    fdb       $0106               SWI
                    fdb       $0109               NMI
                    fdb       $FD00+Start         start of REL

EOMSize             equ       *-EOMTop

                    end
