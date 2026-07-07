;
; fujinet_scan_for_networks - scan for detectable WiFi networks (results retrieved with fujinet_get_scan_result)
; Entry: x - points to DCB area
; Exit:  a - return code
;
fujinet_scan_for_networks:
;         pshs  b
;         lda   #RC2014_DEVICEID_FUJINET
;         sta   DCB_DEVICE,x
;         lda   #FUJICMD_SCAN_NETWORKS  ; Set up DCB for Network scan command
;         sta   DCB_COMMAND,x
;         ldd   #0                      ; Clear aux1 and aux2
;         std   DCB_AUX1,x
;         std   DCB_TX_BUFFER_LEN,x     ; Clear transmit length
;         incb
;         std   DCB_RX_BUFFER_LEN,x     ; Receive length=1
;         ldd   #FUJINET_TIMEOUT        ; Set time-out
;         std   DCB_TIMEOUT,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc

;
; fujinet_get_scan_result - request a scan result after calling fujinet_scan_for_networks
; Entry: x - points to DCB area
;        b - nth scan result to receive
; Exit:  a - return code
;        rdata - SSIDInfo (ssid[SSID_MAXLEN=33], rssi=1)
;
fujinet_get_scan_result:
;         pshs  b
;         lda   #RC2014_DEVICEID_FUJINET
;         sta   DCB_DEVICE,x
;         lda   #FUJICMD_GET_SCAN_RESULT ; Scan for networks
;         sta   DCB_COMMAND,x
;         stb   DCB_AUX1,x              ; The network result to receive
;         ldd   #0
;         stb   DCB_AUX2,x
;         std   DCB_TX_BUFFER_LEN,x
;         ldb   #MAX_SSID_LEN+1         ; Size of SSIDInfo (SSID_MAXLEN = 33 + rssi)
;         std   DCB_RX_BUFFER_LEN,x
;         ldd   #FUJINET_TIMEOUT        ; Set time-out
;         std   DCB_TIMEOUT,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc


fujinet_get_ssid:
         rts
         
fujinet_get_wifi_status:
         rts
         
fujinet_set_ssid:
;         pshs  b
;         lda   #RC2014_DEVICEID_FUJINET
;         sta   DCB_DEVICE,x
;         lda   #FUJICMD_SET_SSID       ; Set the SSID for the network
;         sta   DCB_COMMAND,x
;         ldd   #0
;         std   DCB_AUX1,x              ; Reset AIX1/2
;         std   DCB_RX_BUFFER_LEN,x     ; Nothing to receive
;         ldb   #MAX_SSID_LEN+MAX_SSID_PW_LEN         ; Space for SSID and PW
;         std   DCB_TX_BUFFER_LEN,x
;         ldd   #FUJINET_TIMEOUT        ; Set time-out
;         std   DCB_TIMEOUT,x
;         lbsr  fujinet_dcb_exec
;         puls  b,pc

fujinet_get_wifi_enabled:
         rts

