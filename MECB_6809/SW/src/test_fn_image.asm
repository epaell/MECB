;
;
;
image_tests:
         ldx   #stimage       ; Write test message
         lbsr  print
;
         ldx   #stmounth      ; Mount the host slot
         ldy   #tbuffer
         lbsr  strcpynt
         lda   im_host_slot   ; Get the host slot
         inca                 ; convert to 1-based value
         lbsr  hex2dec
         ldx   #stnewline
         lbsr  strcpy
         ldx   #tbuffer
         lbsr  print
         pcrlf
;
; test fujinet_mount_slot
;
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldd   #rxdata        ; Set up receive and transmit buffers
         std   DCB_RX_BUFFER,x
         ldd   #txdata
         std   DCB_TX_BUFFER,x
         ldb   im_host_slot
         lbsr  fujinet_mount_host   ; Mount the host slot
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
         ldx   #stmount3      ; Mount the device slot
         ldy   #tbuffer
         lbsr  strcpynt
         lda   device_slot    ; Get the device slot
         inca                 ; convert to 1-based value
         lbsr  hex2dec
         ldx   #stnewline
         lbsr  strcpy
         ldx   #tbuffer
         lbsr  print
         pcrlf
;
; test fujinet_mount_image
;
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldd   #rxdata        ; Set up receive and transmit buffers
         std   DCB_RX_BUFFER,x
         ldd   #txdata
         std   DCB_TX_BUFFER,x
         ldb   device_slot
         lda   #MODE_WRITE
         lbsr  fujinet_mount_image   ; Mount the device image
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error

;
; test fujinet_disk_read
;
         ldx   #stimread      ; Read from image
         lbsr  print
;
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldd   #rxdata        ; Set up receive and transmit buffers
         std   DCB_RX_BUFFER,x
         ldd   #txdata
         std   DCB_TX_BUFFER,x
         ldb   device_slot
         ldy   #0             ; read sector 0
         lbsr  fujinet_disk_read   ; Read the disk
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; test fujinet_disk_write
;
         ldx   #stimwrite     ; Write to image
         lbsr  print
;
         ldx   #txdata        ; fill the transmit buffer with data
         ldb   #0
txloop1  stb   ,x+            ; first 256 bytes counts
         incb
         bne   txloop1
txloop2  clr   ,x+            ; next 256 bytes cleared
         incb
         bne   txloop2
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldd   #rxdata        ; Set up receive and transmit buffers
         std   DCB_RX_BUFFER,x
         ldd   #txdata
         std   DCB_TX_BUFFER,x
         ldb   device_slot
         ldy   #0             ; write sector 0
         lbsr  fujinet_disk_write   ; Write to the disk
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; Read back what was written
;
         ldx   #stimread      ; Read from image
         lbsr  print
;
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldd   #rxdata        ; Set up receive and transmit buffers
         std   DCB_RX_BUFFER,x
         ldd   #txdata
         std   DCB_TX_BUFFER,x
         ldb   device_slot
         ldy   #0             ; read sector 0
         lbsr  fujinet_disk_read   ; Read the disk
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
         rts
;
; test fujinet_unmount_image
;
         ldx   #stunmount3    ; Unmount the device slot image
         ldy   #tbuffer
         lbsr  strcpynt
         lda   device_slot    ; Get the device slot
         inca                 ; convert to 1-based value
         lbsr  hex2dec
         ldx   #stnewline
         lbsr  strcpy
         ldx   #tbuffer
         lbsr  print
         pcrlf

         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldb   device_slot
         lbsr  fujinet_unmount_image   ; Unount the device image
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error

         rts
;
stimage:          fcb   CR,LF,'====== Image access tests ======',CR,LF,EOT
stmounth:         fcb   'Mounting host slot ',EOT
stmount3:         fcb   'Mounting image in device slot ',EOT
stimread:         fcb   'Reading sector from image',CR,LF,EOT
stimwrite:        fcb   'Writing sector to image',CR,LF,EOT
stunmount3:       fcb   'Unmounting image in device slot ',EOT
im_host_slot:     fcb   0
device_slot:      fcb   0
