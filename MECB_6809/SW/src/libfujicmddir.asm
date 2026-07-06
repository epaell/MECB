; fujinet_open_directory - open directory on specified host
; Entry: x - points to DCB area
;        b - 0-based host slot
;        DCB_TX_BUFFER - "%s\0%s" %(prefix, file_spec)
; Exit:  a - return code
; 
fujinet_open_directory:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_OPEN_DIRECTORY ; Set up DCB for open directory command
         sta   DCB_COMMAND,x
         clra                          ; Clear aux2
         sta   DCB_AUX2,x
         stb   DCB_AUX1,x              ; set up host
         clrb
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=0
         inca
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=256
         ldd   #FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

; fujinet_read_dir_entry - read a directory entry
; Entry: x - points to DCB area
;        b - if msb set then entry details are prepended to path
; Exit:  a - return code
;        DCB_RX_BUFFER - =12(attr)+244(path) if msb of b set e.g. b=$80
;        DCB_RX_BUFFER - =256(path) if msb of b clear
;        DCB_RX_BUFFER[0..1] = $7F if end of directory reached
; 
fujinet_read_dir_entry:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_READ_DIR_ENTRY ; Set up DCB for reading a directory entry
         sta   DCB_COMMAND,x
         stb   DCB_AUX2,x
         ldd   #$00ff                  ; set up the buffer length
         stb   DCB_AUX1,x              ; set up host
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=255
         clrb
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldd   #FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

; fujinet_close_directory - close directory on specified host
; Entry: x - points to DCB area
; Exit:  a - return code
; 
fujinet_close_directory:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_CLOSE_DIRECTORY ; Set up DCB for close directory command
         sta   DCB_COMMAND,x
         ldd   #0                      ; Clear aux1/2
         std   DCB_AUX1,x
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=0
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldd   #FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

fujinet_set_directory_position:
         rts

fujinet_get_directory_position:
         rts

