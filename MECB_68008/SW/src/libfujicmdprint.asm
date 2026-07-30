fujinet_printer_stream:
         rts

;
; fujinet_printer_write - write to a printer connection
; Entry: a0 - points to DCB area
;        d0.b - number of bytes to write
;        d1 - printer unit (0-3)
;        DCB_TX_BUFFER = data to write
; Exit:  d0.b - return code
;
fujinet_printer_write:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w    #RC2014_DEVICEID_PRINTER<<8+DEVICE_WRITE,d1   ; working with a network device and writing
         move.w   d1,DCB_DEVICE(a0)
         and.w    #$ff,d0
         move.w   d0,DCB_TX_BUFFER_LEN(a0)
         move.b   d0,DCB_AUX1(a0)                           ; LSB of length
         move.b   #0,DCB_AUX2(a0)                           ; MSB of length
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         move.w   #0,DCB_RX_BUFFER_LEN(a0)
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

