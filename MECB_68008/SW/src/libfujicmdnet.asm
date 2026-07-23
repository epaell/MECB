
;
; network commands
;

;
; fujinet_network_open - open a network connection
; Entry: a0 - points to DCB area
;             DCB_TX_BUFFER = url
;        d0.b - CR/LF translation
;        d1.b - network unit (0-7)
; Exit:  d0.b - return code
;
fujinet_network_open:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w #  RC2014_DEVICEID_NETWORK<<8+DEVICE_OPEN,d1   ; working with a network device and opening
         move.w   d1,DCB_DEVICE(a0)
         move.b   d0,DCB_AUX2(a0)
         move.w   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         move.b   #OUPDATE,DCB_AUX1(a0)                     ; read and write
         move.w   #MAX_PATH_LEN,DCB_TX_BUFFER_LEN(a0)       ; transmit buffer has the file path
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

;
; fujinet_network_read - read from a network connection
; Entry: a0 - points to DCB area
;        d0.w - number of bytes to read
;        d1.b - network unit (0-7)
; Exit:  d0.b - return code
;            DCB_RX_BUFFER = data
;
fujinet_network_read:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w    #RC2014_DEVICEID_NETWORK<<8+DEVICE_READ,d1   ; working with a network device and reading
         move.w   d1,DCB_DEVICE(a0)
         move.w   d0,DCB_RX_BUFFER_LEN(a0)
         move.w   #0,DCB_TX_BUFFER_LEN(a0)
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         move.b   d0,DCB_AUX1(a0)                         ; LSM of length
         lsr.w    #8,d0
         move.b   d0,DCB_AUX2(a0)                         ; MSB of length
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

;
; fujinet_network_status - get network status
; Entry: a0 - points to DCB area
;        d1.b - network unit (0-7)
; Exit:  d0.b - return code
;        DCB_RX_BUFFER = network status structure
;
fujinet_network_status:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w    #RC2014_DEVICEID_NETWORK<<8+DEVICE_STATUS,d1   ; working with a network device and status
         move.w   d1,DCB_DEVICE(a0)
         move.w   #NETWORK_STATUS_LEN,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         move.w   #0,DCB_AUX1(a0)
         move.w   #0,DCB_TX_BUFFER_LEN(a0)
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

;
; fujinet_network_write - write to a network connection
; Entry: a0 - points to DCB area
;        d0.w - number of bytes to write
;        d1 - network unit (0-7)
;        DCB_TX_BUFFER = data to write
; Exit:  d0.b - return code
;
fujinet_network_write:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w    #RC2014_DEVICEID_NETWORK<<8+DEVICE_WRITE,d1   ; working with a network device and writing
         move.w   d1,DCB_DEVICE(a0)
         move.w   d0,DCB_TX_BUFFER_LEN(a0)
         move.b   d0,DCB_AUX1(a0)                           ; LSM of length
         lsr.w    #8,d0
         move.b   d0,DCB_AUX2(a0)                           ; MSB of length
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         move.w   #0,DCB_RX_BUFFER_LEN(a0)
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

;
; fujinet_network_close - close a network connection
; Entry: a0 - points to DCB area
;        d1.b - network unit (0-7)
; Exit:  d0.b - return code
;
fujinet_network_close:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w    #RC2014_DEVICEID_NETWORK<<8+DEVICE_CLOSE,d1   ; working with a network device and closing
         move.w   d1,DCB_DEVICE(a0)
         move.w   #0,DCB_AUX1(a0)
         move.l   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

fujinet_network_channel_mode:
         rts

fujinet_network_json_parse:
         rts

fujinet_network_json_query:
         rts

fujinet_network_login:
         rts

