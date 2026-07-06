;
;
;
file_tests:
         ldx   #stfile        ; Write test message
         lbsr  print
;
         ldx   #stmount2      ; Mount the host slot
         ldy   #tbuffer
         lbsr  strcpynt
         lda   file_host_slot ; Get the host slot
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
         ldb   file_host_slot
         lbsr  fujinet_mount_host   ; Mount the host slot
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; test fujinet_file_open
;
; /FLEX6809.CFG
; /FLEX6800.CFG
; /MECB/FLEX6809/SB09BOOT.DSK
;
         ldx   #stfopen       ; open file
         lbsr  print
         ldx   #fujinet_dcb   ; initialise the receive and transmit buffer in the DCB
         ldy   DCB_TX_BUFFER,x   ; set up the transmit buffer with the root and file specification
         ldx   #stfpath       ; copy the path
         lbsr  strcpy
         ldx   #fujinet_dcb   ; point to the DCB
         ldb   file_handle
         lda   file_host_slot
         sta   DCB_AUX2,x   
         lda   #OREAD         ; open for read
         sta   DCB_AUX1,x   
         ldb   file_host_slot ; set up the host slot to open
         lbsr  fujinet_file_open   ; Open the file
         cmpa  #FUJINET_RC_OK ; check if OK
         lbne  error          ; if not, report error

;
; test fujinet_file_status
;
         ldx   #stfstat       ; file status
         lbsr  print
         ldx   #fujinet_dcb   ; initialise the receive and transmit buffer in the DCB
         ldb   file_handle
         lbsr  fujinet_file_status   ; get the file status
         cmpa  #FUJINET_RC_OK ; check if OK
         lbne  error          ; if not, report error
         ldx   #fujinet_dcb
         ldy   DCB_RX_BUFFER,x   ; Point to the file status structure
         ldx   #stfs
         lbsr  print
         lda   ,y             ; get the file status
         lbsr  out2h
         ldx   #stfec
         lda   1,y            ; get the file error code
         lbsr  out2h
         ldx   #stavail
         ldd   2,y            ; number of bytes available to read
         lbsr  out4h
         ldd   4,y
         lbsr  out4h
         pcrlf
         lbra  file_close
;
; test fujinet_read_file
;
rfloop   ldb   #$80
         ldx   #fujinet_dcb
         lbsr  fujinet_file_read
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
         ldx   DCB_RX_BUFFER,x   ; point to the receive buffer
         lda   ,x
         cmpa  #$7f
         lbeq  file_close
         lda   1,x
         cmpa  #$7f
         lbeq  file_close
;
         lbra   rfloop
;
; test fujinet_file_close
;
file_close:
         ldx   #stfclose      ; Close the file
         lbsr  print
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldb   file_handle
         lbsr  fujinet_file_close   ; Close the file
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; test fujinet_unmount_slot
;
;         ldx   #stunmount2    ; Unmount the host slot
;         ldy   #tbuffer
;         lbsr  strcpynt
;         lda   dir_slot       ; Get the host slot
;         inca                 ; convert to 1-based value
;         lbsr  hex2dec
;         ldx   #stnewline
;         lbsr  strcpy
;         ldx   #tbuffer
;         lbsr  print
;         pcrlf
; *** Note yet implemented in the firmware ***
;         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
;         ldd   #rxdata        ; Set up receive and transmit buffers
;         std   DCB_RX_BUFFER,x
;         ldd   #txdata
;         std   DCB_TX_BUFFER,x
;         ldb   dir_slot
;         lbsr  fujinet_unmount_host   ; Mount the host slot
;         cmpa  #FUJINET_RC_OK ; Check if OK
;         lbne  error          ; if not, report error

         rts
;
stfile:           fcb   CR,LF,'====== File access tests =======',CR,LF,EOT
stmount2:         fcb   'Mounting host slot ',EOT
stunmount2:       fcb   'Unmounting host slot ',EOT
stfopen:          fcb   'Open file',CR,LF,EOT
stfstat:          fcb   'File status',CR,LF,EOT
stfread:          fcb   'Read file',CR,LF,EOT
stfclose:         fcb   'Close file',CR,LF,EOT
stfpath:          fcb   '/FLEX6809.CFG',EOT
stfs:             fcb   'fstatus=$',EOT
stfec:            fcb   ' fcode=$',EOT
stavail:          fcb   ' available=$',EOT
file_host_slot:   fcb   0
file_handle:      fcb   1
