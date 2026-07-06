;
;
;
dir_tests:
         ldx   #stdir         ; Write test message
         lbsr  print
;
         ldx   #stmount       ; Mount the host slot
         ldy   #tbuffer
         lbsr  strcpynt
         lda   dir_slot       ; Get the host slot
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
         ldb   dir_slot
;         lbsr  fujinet_mount_host   ; Mount the host slot
         lbsr  fujinet_mount_all   ; Mount all host slots
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; test fujinet_open_directory
;
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldy   DCB_TX_BUFFER,x   ; Set up the transmit buffer with the root and file specification
         ldx   #strroot       ; copy the root
         lbsr  strcpy
         ldx   #strfs         ; add the file specification
         lbsr  strcpy
         ldx   #fujinet_dcb   ; Point to the DCB
         ldb   dir_slot       ; Set up the host slot to open
         lbsr  fujinet_open_directory   ; Open the directory
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
         ldx   #stdirh
         lbsr  print
;
; test fujinet_read_dir_entry
;
rloop    ldb   #$80
         ldx   #fujinet_dcb
         lbsr  fujinet_read_dir_entry
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
         ldx   DCB_RX_BUFFER,x   ; point to the receive buffer
         lda   ,x
         cmpa  #$7f
         lbeq  dir_close
         lda   1,x
         cmpa  #$7f
         lbeq  dir_close
;
; print the directory path
;
         ldy   #tbuffer
         ldb   ,x             ; get the year
         tstb
         bmi   adjy
         lda   #20
         lbsr  hex2dec2
         tfr   b,a
         bra   addy

adjy     lda   #19
         lbsr  hex2dec2
         lda   ,x
         adda  #100
;
addy     lbsr  hex2dec2
         lda   #'-'
         sta   ,y+
         lda   1,x            ; get the month
         lbsr  hex2dec2
         lda   #'-'
         sta   ,y+
         lda   2,x            ; get the day
         lbsr  hex2dec2
         lda   #' '
         sta   ,y+
         lda   3,x            ; get the hour
         lbsr  hex2dec2
         lda   #':'
         sta   ,y+
         lda   4,x            ; get the minute
         lbsr  hex2dec2
         lda   #':'
         sta   ,y+
         lda   5,x            ; get the second
         lbsr  hex2dec2
         lda   #' '
         sta   ,y+
         lda   #'$'
         sta   ,y+
         lda   #EOT
         sta   ,y+
         pshs  x
         ldx   #tbuffer
         lbsr  print
         puls  x
         ldd   8,x            ; get the MSB length
         exg   a,b
         lbsr  out4h
         ldd   6,x            ; get the LSB length
         exg   a,b
         lbsr  out4h
         lda   #' '
         outch
         lda   10,x            ; get the flags
         lbsr  out2h
         lda   #' '
         outch
         lda   11,x            ; get the type
         lbsr  out2h
         lda   #' '
         outch
         
         leax  DIR_ENTRY_ATTR_LEN,x ; Skip over the attribute
         lbsr  print
         pcrlf
;
         lbra   rloop
;
; test fujinet_close_directory
;
dir_close:
         ldx   #stclose       ; Close the directory
         lbsr  print
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         lbsr  fujinet_close_directory   ; Close the directory
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; test fujinet_unmount_slot
;
;         ldx   #stunmount     ; Unmount the host slot
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
stdir:   fcb   CR,LF,'====== Directory access tests =======',CR,LF,EOT
stmount: fcb   'Mounting host slot ',EOT
stunmount: fcb   'Unmounting host slot ',EOT
stdirh:  fcb   'Date       Time     Size      FL TY Path',CR,LF,EOT
stclose: fcb   'Close directory',CR,LF,EOT
strroot: fcb   '/',EOT
strfs:   fcb   '*.*',EOT
dir_slot: fcb   0
