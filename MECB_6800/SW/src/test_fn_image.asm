;
; Image tests
;
image_tests:
         ldx   #stimage       ; Write test message
         jsr   print
;
         ldx   #tbuffer       ; Mount the host slot
         stx   ptrdest
         ldx   #stmounth
         jsr   strcpynt
         lda   im_host_slot   ; Get the host slot
         inca                 ; convert to 1-based value
         jsr   hex2dec
         ldx   #stnewline
         jsr   strcpy
         ldx   #tbuffer
         jsr   print
         jsr   pcrlf
;
; test fujinet_mount_slot
;
         jsr   set_buff       ; Reset the buffers
         ldb   im_host_slot
         jsr   fujinet_mount_host   ; Mount the host slot
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   image2
         jmp   error          ; if not, report error
;
image2:
         ldx   #tbuffer      ; Mount the device slot
         stx   ptrdest
         ldx   #stmount3
         jsr   strcpynt
         lda   device_slot    ; Get the device slot
         inca                 ; convert to 1-based value
         jsr   hex2dec
         ldx   #stnewline
         jsr   strcpy
         ldx   #tbuffer
         jsr   print
         jsr   pcrlf
;
; test fujinet_mount_image
;
         jsr   set_buff       ; Reset the buffers
         ldb   device_slot
         lda   #MODE_WRITE
         jsr   fujinet_mount_image   ; Mount the device image
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   image3
         jmp   error          ; if not, report error

;
; test fujinet_disk_read
;
image3:
         ldx   #stimread      ; Read from image
         jsr   print
;
         jsr   set_buff       ; Reset the buffers
         ldb   device_slot
         clr   DCB_AUX1,x     ; read sector 0 (LSB)
         clr   DCB_AUX2,x     ; (MSB)
         jsr   fujinet_disk_read   ; Read the disk
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   image4
         jmp   error          ; if not, report error
;
; test fujinet_disk_write
;
image4:
         rts
         ldx   #stimwrite     ; Write to image
         jsr   print
;
         ldx   #txdata        ; fill the transmit buffer with data
         ldb   #0
txloop1  stb   ,x             ; first 256 bytes counts
         inx
         incb
         bne   txloop1
txloop2  clr   ,x             ; next 256 bytes cleared
         inx
         incb
         bne   txloop2
;
         jsr   set_buff       ; Reset the buffers
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldb   device_slot
         clr   DCB_AUX1,x     ; write sector 0 (LSB)
         clr   DCB_AUX2,x     ; (MSB)
         jsr   fujinet_disk_write   ; Write to the disk
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   image5
         jmp   error          ; if not, report error
;
; Read back what was written
;
image5:
         ldx   #stimread      ; Read from image
         jsr   print
;
         jsr   set_buff       ; Reset the buffers
         ldb   device_slot
         clr   DCB_AUX1,x     ; read sector 0 (LSB)
         clr   DCB_AUX2,x     ; (MSB)
         jsr  fujinet_disk_read   ; Read the disk
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   image6
         jmp   error          ; if not, report error
;
; test fujinet_unmount_image
;
image6:
         ldx   #tbuffer
         stx   ptrdest
         ldx   #stunmount3    ; Unmount the device slot image
         jsr   strcpynt
         lda   device_slot    ; Get the device slot
         inca                 ; convert to 1-based value
         jsr   hex2dec
         ldx   #stnewline
         jsr   strcpy
         ldx   #tbuffer
         jsr   print
         jsr   pcrlf
;
         jsr   set_buff       ; Reset the buffers
         ldb   device_slot
         jsr   fujinet_unmount_image   ; Unount the device image
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   image7
         jmp   error          ; if not, report error
image7:
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
