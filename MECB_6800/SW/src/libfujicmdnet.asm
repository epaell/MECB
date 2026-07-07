
;
; network commands
;

;
; fujinet_network_open - open a network connection
; Entry: x - points to DCB area
;            DCB_TX_BUFFER = url
;        a - CR/LF translation
;        b - network unit (0-7)
; Exit:  a - return code
;
fujinet_network_open:
;         pshs  b
;         addb  #RC2014_DEVICEID_NETWORK   ; working with a network device
;         stb   DCB_DEVICE,x
;         sta   DCB_AUX2,x                 ; CR/LF translation
;         lda   #DEVICE_OPEN               ; open
;         sta   DCB_COMMAND,x
;         ldd   #0
;         std   DCB_RX_BUFFER_LEN,x
;         ldd   #FUJINET_NETWORK_TIMEOUT
;         std   DCB_TIMEOUT,x
;         lda   #OUPDATE
;         sta   DCB_AUX1,x              ; read and write
;         ldd   #MAX_PATH_LEN           ; transmit buffer has the file path
;         std   DCB_TX_BUFFER_LEN,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc

;
; fujinet_network_read - read from a network connection
; Entry: x - points to DCB area
;        y - number of bytes to read
;        b - network unit (0-7)
; Exit:  a - return code
;            DCB_RX_BUFFER = data
;
fujinet_network_read:
;         pshs  b
;         addb  #RC2014_DEVICEID_NETWORK   ; working with a network device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_READ            ; device read
;         sta   DCB_COMMAND,x
;         tfr   y,d                     ; get the read length
;         std   DCB_RX_BUFFER_LEN,x
;         sta   DCB_AUX2,x              ; auxilary bytes also contain length
;         stb   DCB_AUX1,x
;         ldd   #0                      ; transmit buffer empty
;         std   DCB_TX_BUFFER_LEN,x
;         ldd   #FUJINET_NETWORK_TIMEOUT
;         std   DCB_TIMEOUT,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc

;
; fujinet_network_status - get network status
; Entry: x - points to DCB area
;        b - network unit (0-7)
; Exit:  a - return code
;        DCB_RX_BUFFER = network status structure
;
fujinet_network_status:
;         pshs  b
;         addb  #RC2014_DEVICEID_NETWORK   ; working with a network device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_STATUS             ; device status
;         sta   DCB_COMMAND,x
;         ldd   #NETWORK_STATUS_LEN
;         std   DCB_RX_BUFFER_LEN,x
;         ldd   #FUJINET_NETWORK_TIMEOUT
;         std   DCB_TIMEOUT,x
;         ldd   #0
;         sta   DCB_AUX1,x
;         std   DCB_TX_BUFFER_LEN,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc

;
; fujinet_network_write - write to a network connection
; Entry: x - points to DCB area
;        y - number of bytes to write
;        b - network unit (0-7)
;        DCB_TX_BUFFER = data to write
; Exit:  a - return code
;
fujinet_network_write:
;         pshs  b
;         addb  #RC2014_DEVICEID_NETWORK   ; working with a network device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_WRITE           ; file write
;         sta   DCB_COMMAND,x
;         tfr   y,d                     ; get the write length
;         std   DCB_TX_BUFFER_LEN,x
;         sta   DCB_AUX2,x              ; auxilary bytes also contain length
;         stb   DCB_AUX1,x
;         ldd   #FUJINET_NETWORK_TIMEOUT
;         std   DCB_TIMEOUT,x
;         ldd   #0
;         sta   DCB_AUX1,x
;         std   DCB_RX_BUFFER_LEN,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc

;
; fujinet_network_close - close a network connection
; Entry: x - points to DCB area
;        b - network unit (0-7)
; Exit:  a - return code
;
fujinet_network_close:
;         pshs  b
;         addb  #RC2014_DEVICEID_NETWORK   ; working with a network device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_CLOSE              ; close
;         sta   DCB_COMMAND,x
;         ldd   #0
;         std   DCB_RX_BUFFER_LEN,x
;         std   DCB_TX_BUFFER_LEN,x
;         ldd   #FUJINET_NETWORK_TIMEOUT
;         std   DCB_TIMEOUT,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc

fujinet_network_channel_mode:
         rts

fujinet_network_json_parse:
         rts

fujinet_network_json_query:
         rts

fujinet_network_login:
         rts

