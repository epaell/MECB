
;
; file commands
;

;
; fujinet_file_open - open a file
; Entry: x - points to DCB area
;            DCB_AUX1 = file mode
;            DCB_AUX2 = host slot
;            DCB_TX_BUFFER = path
;        b - file handle (0-7)
; Exit:  a - return code
;
fujinet_file_open:
;         pshs  b
;         addb  #RC2014_DEVICEID_FILE   ; working with a file device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_OPEN            ; open file
;         sta   DCB_COMMAND,x
;         ldd   #0
;         std   DCB_RX_BUFFER_LEN,x
;         ldd   #FUJINET_TIMEOUT
;         std   DCB_TIMEOUT,x
;         ldd   #MAX_PATH_LEN           ; transmit buffer has the file path
;         std   DCB_TX_BUFFER_LEN,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc
         rts

;
; fujinet_file_read - read a file
; Entry: x - points to DCB area
;        y - number of bytes to read
;        b - file handle (0-7)
; Exit:  a - return code
;        DCB_TX_BUFFER = data read
;
fujinet_file_read:
;         pshs  b
;         addb  #RC2014_DEVICEID_FILE   ; working with a file device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_READ            ; read file
;         sta   DCB_COMMAND,x
;         tfr   y,d                     ; get the read length
;         std   DCB_RX_BUFFER_LEN,x
;         sta   DCB_AUX2,x              ; auxilary bytes also contain length
;         stb   DCB_AUX1,x
;         ldd   #0                      ; transmit buffer empty
;         std   DCB_TX_BUFFER_LEN,x
;         ldd   #FUJINET_TIMEOUT
;         std   DCB_TIMEOUT,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc
         rts

;
; fujinet_file_status - get file status
; Entry: x - points to DCB area
;        b - file handle (0-7)
; Exit:  a - return code
;        DCB_RX_BUFFER = file status structure
;
fujinet_file_status:
;         pshs  b
;         addb  #RC2014_DEVICEID_FILE   ; working with a file device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_STATUS          ; file status
;         sta   DCB_COMMAND,x
;         ldd   #FILE_STATUS_LEN
;         std   DCB_RX_BUFFER_LEN,x
;         ldd   #FUJINET_TIMEOUT
;         std   DCB_TIMEOUT,x
;         ldd   #0
;         sta   DCB_AUX1,x
;         std   DCB_TX_BUFFER_LEN,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc
         rts

;
; fujinet_file_write - write a file
; Entry: x - points to DCB area
;        y - number of bytes to write
;        b - file handle (0-7)
;        DCB_TX_BUFFER = data to write
; Exit:  a - return code
;
fujinet_file_write:
;         pshs  b
;         addb  #RC2014_DEVICEID_FILE   ; working with a file device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_WRITE           ; file write
;         sta   DCB_COMMAND,x
;         tfr   y,d                     ; get the write length
;         std   DCB_TX_BUFFER_LEN,x
;         sta   DCB_AUX2,x              ; auxilary bytes also contain length
;         stb   DCB_AUX1,x
;         ldd   #FUJINET_TIMEOUT
;         std   DCB_TIMEOUT,x
;         ldd   #0
;         sta   DCB_AUX1,x
;         std   DCB_RX_BUFFER_LEN,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc
         rts

;
; fujinet_file_close - close a file
; Entry: x - points to DCB area
;        b - file handle (0-7)
; Exit:  a - return code
;
fujinet_file_close:
;         pshs  b
;         addb  #RC2014_DEVICEID_FILE   ; working with a file device
;         stb   DCB_DEVICE,x
;         lda   #DEVICE_CLOSE           ; close file
;         sta   DCB_COMMAND,x
;         ldd   #0
;         std   DCB_RX_BUFFER_LEN,x
;         std   DCB_TX_BUFFER_LEN,x
;         std   DCB_AUX1,x
;         ldd   #FUJINET_TIMEOUT
;         std   DCB_TIMEOUT,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc
         rts
