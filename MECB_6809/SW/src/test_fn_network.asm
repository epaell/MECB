;
;
;
network_tests:
         ldx   #stnet        ; Write test message
         lbsr  print
;
;
; test fujinet_network_open
;
; /FLEX6809.CFG
; /FLEX6800.CFG
; /MECB/FLEX6809/SB09BOOT.DSK
;
         ldx   #stnopen       ; open network
         lbsr  print
         ldx   #fujinet_dcb   ; initialise the receive and transmit buffer in the DCB
         ldy   DCB_TX_BUFFER,x   ; set up the transmit buffer with the root and file specification
         ldx   #stnpath       ; copy the path
         lbsr  strcpy
         ldx   #fujinet_dcb   ; point to the DCB
         ldb   net_channel
         lbsr  fujinet_network_open   ; Open the network channel
         cmpa  #FUJINET_RC_OK ; check if OK
         lbne  error          ; if not, report error

;
; test fujinet_network_status
;
         ldx   #stnstat       ; network status
         lbsr  print
         ldx   #fujinet_dcb   ; initialise the receive and transmit buffer in the DCB
         ldb   net_channel
         lbsr  fujinet_network_status   ; get the network status
         cmpa  #FUJINET_RC_OK ; check if OK
         lbne  error          ; if not, report error
         ldx   #fujinet_dcb
         ldy   DCB_RX_BUFFER,x   ; Point to the network status structure
         ldx   #stns
         lbsr  print
         lda   ,y             ; get the network status
         lbsr  out2h
         ldx   #stnec
         lda   1,y            ; get the network error code
         lbsr  out2h
         ldx   #stnavail
         ldd   2,y            ; number of bytes available to read
         lbsr  out4h
         ldd   4,y
         lbsr  out4h
         pcrlf
;
; test fujinet_network_close
;
         ldx   #stnclose      ; Close the network channel
         lbsr  print
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldb   net_channel
         lbsr  fujinet_network_close   ; Close the network channel
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error

         rts
;
stnet:           fcb   CR,LF,'====== Network device tests =======',CR,LF,EOT
stnopen:          fcb   'Open network',CR,LF,EOT
stnstat:          fcb   'Network status',CR,LF,EOT
stnread:          fcb   'Read network',CR,LF,EOT
stnclose:         fcb   'Close network',CR,LF,EOT
stnpath:          fcb   '/FLEX6809.CFG',EOT
stns:             fcb   'nstatus=$',EOT
stnec:            fcb   ' ncode=$',EOT
stnavail:         fcb   ' bytes=$',EOT
net_channel:      fcb   1
