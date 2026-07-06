;
; Fujinet WiFi tests
;
wifi_tests:
         ldx   #stwifi        ; Write test message
         lbsr  print
         ldx   #stscan        ; Write scanning message
         lbsr  print
;
; test fujinet_scan_for_networks
;
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldd   #rxdata        ; Set up receive and transmit buffers
         std   DCB_RX_BUFFER,x
         ldd   #txdata
         std   DCB_TX_BUFFER,x
         lbsr  fujinet_scan_for_networks   ; Do a Wifi scan
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
         ldx   #stsres1
         ldy   #tbuffer
         lbsr  strcpynt       ; copy but don't terminate
         lda   rxdata
         sta   nscan          ; store the number of scans
         lbsr  hex2dec        ; add the number of scans to string
         ldx   #stsres2       ; complete the message
         lbsr  strcpy
         ldx   #tbuffer
         lbsr  print
         lda   nscan
         cmpa  #0
         lbeq  wifi_done      ; No scans to print
;
; test fujinet_get_scan_result
;
         ldx   #blank         ; Clear out the string buffer
         ldy   #tbuffer
         lbsr  strcpy
         ldx   #stwifih1      ; Print the header
         ldy   #tbuffer
         lbsr  strcpynt       ; copy without EOT
         ldx   #stwifih2
         ldy   #tbuffer+MAX_SSID_LEN+1
         lbsr  strcpy         ; copy with EOT
         ldx   #tbuffer       ; print it
         lbsr  print
;
         ldb   #0             ; start with scan 0
loop:
         ldx   #fujinet_dcb   ; point to the DCB
         lbsr  fujinet_get_scan_result
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne   error
         ldx   #blank         ; Create a blank string for output
         ldy   #tbuffer
         lbsr  strcpy
         ldx   #rxdata         ; Copy the SSID
         ldy   #tbuffer
         lbsr  strcpynt

         lda   rxdata+MAX_SSID_LEN ; Get the RSSI
         ldy   #tbuffer+MAX_SSID_LEN+1
         lbsr  hex2dec        ; write signed decimal value
         ldx   #stdbm         ; add the dBm string
         lbsr  strcpy
         ldx   #tbuffer
         lbsr  print
         incb
         cmpb  nscan
         blt   loop           ; loop until all scans requested
wifi_done:
;
; Test fujinet_set_ssid command
;
         ldx   #stsetssid     ; Write setting message
         lbsr  print
;
         ldx   #fujinet_dcb   ; point to the DCB
         ldd   #ssid          ; Temporarily point the TX_BUFFER to the SSID information
         std   DCB_TX_BUFFER,x
         lbsr  fujinet_set_ssid
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne   error
         ldx   #fujinet_dcb   ; point to the DCB
         ldd   #txdata        ; restore the TX_BUFFER
         std   DCB_TX_BUFFER,x
         rts
;
stwifi:  fcb   CR,LF,'============= WiFi tests ============',CR,LF,EOT
stscan:  fcb   'Scanning for WiFi networks ...',CR,LF,EOT
stsres1: fcb   'Found ',EOT
stsres2: fcb   ' networks',CR,LF,LF,EOT
stwifih1: fcb   'SSID',EOT
stwifih2: fcb   'RSSI',CR,LF,EOT
stdbm:   fcb   ' dBm',CR,LF,EOT
stsetssid: fcb 'Test setting of WiFi SSID and password',CR,LF,EOT
;
ssid:    fcb   'Aragorn',0,0,0,0,0,0,0,0,0
         fcb   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         fcb   0
         fcb   'woaidi2liudi2',0,0,0
         fcb   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         fcb   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         fcb   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

scan     rmb   1
nscan    rmb   1
